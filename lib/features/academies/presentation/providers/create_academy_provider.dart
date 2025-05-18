// Needed for User type
import 'package:arcinus/core/providers/firebase_providers.dart'; // Firestore provider
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart'; // Interfaz Repo
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart'; // Provider del Repo
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart'; // Current Academy ID
import 'package:arcinus/features/academies/presentation/providers/state/create_academy_state.dart';
import 'package:arcinus/features/memberships/data/repositories/membership_repository_impl.dart'; // Provider del Repo de Membresías
import 'package:arcinus/features/memberships/domain/repositories/membership_repository.dart'; // Interfaz Repo Membresías
import 'package:arcinus/features/subscriptions/data/models/subscription_model.dart'; // Subscription model
import 'package:arcinus/features/subscriptions/domain/repositories/subscription_repository.dart'; // Importar Repo Subs
import 'package:arcinus/features/subscriptions/data/repositories/subscription_repository_impl.dart'; // Importar Provider Repo Subs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:arcinus/core/error/failures.dart'; // Asumiendo ubicación
import 'package:arcinus/core/auth/roles.dart'; // Needed for AppRole
import 'package:arcinus/features/memberships/data/models/membership_model.dart'; // Importar MembershipModel
import 'package:arcinus/core/utils/app_logger.dart';
import 'dart:io'; // Para File
import 'package:image_picker/image_picker.dart'; // Para ImageSource

/// Provider for managing the state of academy creation.
final createAcademyProvider = StateNotifierProvider.autoDispose<
    CreateAcademyNotifier, CreateAcademyState>((ref) {
  // Obtener dependencias reales
  final academyRepository = ref.watch(academyRepositoryProvider);
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider); // Obtener repo subs
  final membershipRepository = ref.watch(membershipRepositoryProvider); // <-- Añadir Repo Membresías
  final firebaseAuth = ref.watch(firebaseAuthProvider); // Para obtener el User ID
  AppLogger.logInfo('Creando CreateAcademyNotifier con dependencias reales');
  return CreateAcademyNotifier(ref, academyRepository, subscriptionRepository, membershipRepository, firebaseAuth); // <-- Pasar Repo Membresías
});

/// Notifier responsible for handling the logic of creating a new academy.
class CreateAcademyNotifier extends StateNotifier<CreateAcademyState> {
  // Dependencias
  final Ref _ref; // Para leer otros providers si es necesario
  final AcademyRepository _academyRepository;
  final SubscriptionRepository _subscriptionRepository; // Añadir repo subs
  final MembershipRepository _membershipRepository; // <-- Añadir Repo Membresías
  final FirebaseAuth _firebaseAuth; // Para obtener el User ID

  CreateAcademyNotifier(this._ref, this._academyRepository, this._subscriptionRepository, this._membershipRepository, this._firebaseAuth)
      : super(const CreateAcademyState.initial());

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  String? selectedSportCode;
  
  // Campos adicionales
  String description = '';
  String phone = '';
  String email = '';
  String address = '';
  File? logoFile;

  // Método para navegar entre pasos
  void navigateToStep(FormStep step) {
    final currentStep = state.maybeMap(
      initial: (s) => s.currentStep,
      navigating: (s) => s.currentStep,
      selectingImage: (s) => s.currentStep,
      loading: (s) => s.currentStep,
      error: (s) => s.currentStep,
      orElse: () => FormStep.basicInfo,
    );
    
    final currentLogo = state.maybeMap(
      initial: (s) => s.logoFile,
      navigating: (s) => s.logoFile,
      selectingImage: (s) => s.logoFile,
      loading: (s) => s.logoFile,
      error: (s) => s.logoFile,
      orElse: () => null,
    );

    final currentImageStatus = state.maybeMap(
      initial: (s) => s.imageStatus,
      navigating: (s) => s.imageStatus,
      selectingImage: (s) => s.imageStatus,
      loading: (s) => s.imageStatus,
      error: (s) => s.imageStatus,
      orElse: () => ImageUploadStatus.notStarted,
    );
    
    final formIsValid = state.maybeMap(
      initial: (s) => s.formIsValid,
      navigating: (s) => s.formIsValid,
      selectingImage: (s) => s.formIsValid,
      loading: (s) => s.formIsValid,
      error: (s) => s.formIsValid,
      orElse: () => false,
    );

    // Validar el paso actual antes de permitir la navegación
    if (step.index > currentStep.index) {
      AppLogger.logInfo(
        'Intentando avanzar del paso ${currentStep.name} al paso ${step.name}',
        className: 'CreateAcademyNotifier',
        functionName: 'navigateToStep',
        params: {
          'requiereValidación': 'sí',
          'estadoImagenActual': currentImageStatus.name,
          'tieneImagen': (currentLogo != null).toString(),
          'formularioVálido': formIsValid.toString()
        }
      );
      
      final isStepValid = _validateCurrentStep(currentStep);
      if (!isStepValid) {
        AppLogger.logWarning(
          'Navegación bloqueada: el paso actual no es válido',
          className: 'CreateAcademyNotifier',
          functionName: 'navigateToStep',
          params: {'pasoActual': currentStep.name, 'pasoDestino': step.name}
        );
        return; // No permitir avanzar si el paso actual no es válido
      }
    } else {
      AppLogger.logInfo(
        'Navegando hacia atrás o al mismo paso',
        className: 'CreateAcademyNotifier',
        functionName: 'navigateToStep',
        params: {
          'pasoActual': currentStep.name,
          'pasoDestino': step.name,
          'dirección': step.index < currentStep.index ? 'atrás' : 'mismo'
        }
      );
    }

    AppLogger.logInfo(
      'Navegando de paso ${currentStep.name} a ${step.name}',
      className: 'CreateAcademyNotifier',
      functionName: 'navigateToStep'
    );

    state = CreateAcademyState.navigating(
      currentStep: step,
      previousStep: currentStep,
      imageStatus: currentImageStatus,
      logoFile: currentLogo,
      formIsValid: formIsValid,
    );
    
    // Después de un breve delay, actualizar a estado initial con el nuevo paso
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppLogger.logInfo(
          'Completando navegación al paso ${step.name}',
          className: 'CreateAcademyNotifier',
          functionName: 'navigateToStep'
        );
        
        state = CreateAcademyState.initial(
          currentStep: step,
          imageStatus: currentImageStatus,
          logoFile: currentLogo,
          formIsValid: formIsValid,
        );
      }
    });
  }

  // Método para validar el paso actual
  bool _validateCurrentStep(FormStep step) {
    AppLogger.logInfo(
      'Validando paso actual',
      className: 'CreateAcademyNotifier',
      functionName: '_validateCurrentStep',
      params: {'paso': step.name}
    );
    
    switch (step) {
      case FormStep.basicInfo:
        // Validar nombre y deporte
        if (nameController.text.trim().isEmpty) {
          AppLogger.logWarning(
            'Validación fallida: Campo nombre vacío',
            className: 'CreateAcademyNotifier',
            functionName: '_validateCurrentStep'
          );
          state = CreateAcademyState.error(
            Failure.validationError(message: 'Por favor corrige los errores'),
            nameError: 'Ingresa el nombre de la academia',
            currentStep: step,
            logoFile: logoFile,
          );
          _clearErrorAfterDelay();
          return false;
        }
        
        if (selectedSportCode == null) {
          AppLogger.logWarning(
            'Validación fallida: Deporte no seleccionado',
            className: 'CreateAcademyNotifier',
            functionName: '_validateCurrentStep'
          );
          state = CreateAcademyState.error(
            Failure.validationError(message: 'Por favor corrige los errores'),
            sportCodeError: 'Debes seleccionar un deporte',
            currentStep: step,
            logoFile: logoFile,
          );
          _clearErrorAfterDelay();
          return false;
        }
        
        AppLogger.logInfo(
          'Validación exitosa del paso de información básica',
          className: 'CreateAcademyNotifier',
          functionName: '_validateCurrentStep',
          params: {
            'nombre': nameController.text,
            'deporte': selectedSportCode
          }
        );
        
        return true;
        
      case FormStep.contactInfo:
        // Validar email si se proporcionó
        if (email.isNotEmpty && !email.contains('@')) {
          AppLogger.logWarning(
            'Validación fallida: Email inválido',
            className: 'CreateAcademyNotifier',
            functionName: '_validateCurrentStep'
          );
          state = CreateAcademyState.error(
            Failure.validationError(message: 'Por favor corrige los errores'),
            emailError: 'Introduce un email válido',
            currentStep: step,
            logoFile: logoFile,
          );
          _clearErrorAfterDelay();
          return false;
        }
        
        AppLogger.logInfo(
          'Validación exitosa del paso de información de contacto',
          className: 'CreateAcademyNotifier',
          functionName: '_validateCurrentStep',
          params: {
            'email': email.isEmpty ? 'no proporcionado' : email,
            'teléfono': phone.isEmpty ? 'no proporcionado' : phone,
            'dirección': address.isEmpty ? 'no proporcionada' : 'proporcionada'
          }
        );
        
        return true;
        
      case FormStep.logoImage:
        // No se requiere validación especial para la imagen
        AppLogger.logInfo(
          'Validación exitosa del paso de imagen',
          className: 'CreateAcademyNotifier',
          functionName: '_validateCurrentStep',
          params: {
            'tieneImagen': (logoFile != null).toString()
          }
        );
        
        return true;
    }
  }

  // Método para validar todos los pasos
  bool _validateAllSteps() {
    AppLogger.logInfo(
      'Iniciando validación de todos los pasos',
      className: 'CreateAcademyNotifier',
      functionName: '_validateAllSteps'
    );
    
    // Validar cada paso secuencialmente
    if (!_validateCurrentStep(FormStep.basicInfo)) {
      AppLogger.logWarning(
        'Validación completa fallida en paso de información básica',
        className: 'CreateAcademyNotifier',
        functionName: '_validateAllSteps'
      );
      navigateToStep(FormStep.basicInfo);
      return false;
    }
    
    if (!_validateCurrentStep(FormStep.contactInfo)) {
      AppLogger.logWarning(
        'Validación completa fallida en paso de información de contacto',
        className: 'CreateAcademyNotifier',
        functionName: '_validateAllSteps'
      );
      navigateToStep(FormStep.contactInfo);
      return false;
    }
    
    // No se requiere validación especial para la imagen
    AppLogger.logInfo(
      'Validación completa exitosa de todos los pasos',
      className: 'CreateAcademyNotifier',
      functionName: '_validateAllSteps'
    );
    
    return true;
  }

  /// Establece si el formulario está pre-validado externamente
  void setFormPreValidated(bool validated) {
    AppLogger.logInfo(
      'Formulario configurado como pre-validado',
      className: 'CreateAcademyNotifier',
      functionName: 'setFormPreValidated',
      params: {'preValidated': validated.toString()}
    );
  }

  // Esta lista debería venir de una fuente de datos real (configuración, Firestore)
  // Por ahora, se mantiene como datos estáticos.
  final List<Map<String, String>> availableSports = [
    {'code': 'soccer'     , 'name': 'Fútbol'},
    {'code': 'basketball' , 'name': 'Baloncesto'},
    {'code': 'volleyball' , 'name': 'Voleibol'},
  ];

  /// Actualiza el código del deporte seleccionado.
  void selectSport(String? sportCode) {
    if (selectedSportCode != sportCode) {
      selectedSportCode = sportCode;
    }
  }

  /// Actualiza los campos adicionales de la academia
  void updateAdditionalInfo({
    String? description,
    String? phone,
    String? email,
    String? address,
    File? logoFile,
  }) {
    if (description != null) this.description = description;
    if (phone != null) this.phone = phone;
    if (email != null) this.email = email;
    if (address != null) this.address = address;
    if (logoFile != null) {
      this.logoFile = logoFile;
      
      // Actualizar el estado para reflejar que se ha seleccionado una imagen
      final currentStep = state.maybeMap(
        initial: (s) => s.currentStep,
        navigating: (s) => s.currentStep,
        selectingImage: (s) => s.currentStep,
        loading: (s) => s.currentStep,
        error: (s) => s.currentStep,
        orElse: () => FormStep.logoImage,
      );
      
      state = CreateAcademyState.initial(
        currentStep: currentStep,
        imageStatus: ImageUploadStatus.selected,
        logoFile: logoFile,
      );
    }
  }

  /// Inicia el proceso de selección de imagen
  Future<void> selectAndUpdateLogo(ImageSource source) async {
    final currentStep = state.maybeMap(
      initial: (s) => s.currentStep,
      navigating: (s) => s.currentStep,
      selectingImage: (s) => s.currentStep,
      loading: (s) => s.currentStep,
      error: (s) => s.currentStep,
      orElse: () => FormStep.logoImage,
    );
    
    // Cambiar a estado de selección de imagen
    AppLogger.logInfo(
      'Iniciando proceso de selección de imagen',
      className: 'CreateAcademyNotifier',
      functionName: 'selectAndUpdateLogo',
      params: {
        'fuente': source.name,
        'pasoActual': currentStep.name
      }
    );
    
    state = CreateAcademyState.selectingImage(
      currentStep: currentStep,
    );

    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);
      
      if (pickedImage != null) {
        logoFile = File(pickedImage.path);
        
        AppLogger.logInfo(
          'Imagen seleccionada con éxito',
          className: 'CreateAcademyNotifier',
          functionName: 'selectAndUpdateLogo',
          params: {'path': pickedImage.path}
        );
        
        // Actualizar el estado con la imagen seleccionada
        state = CreateAcademyState.initial(
          currentStep: currentStep,
          imageStatus: ImageUploadStatus.selected,
          logoFile: logoFile,
        );
      } else {
        // El usuario canceló la selección
        AppLogger.logInfo(
          'Selección de imagen cancelada por el usuario',
          className: 'CreateAcademyNotifier',
          functionName: 'selectAndUpdateLogo'
        );
        
        state = CreateAcademyState.initial(
          currentStep: currentStep,
          imageStatus: logoFile != null ? ImageUploadStatus.selected : ImageUploadStatus.notStarted,
          logoFile: logoFile,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error al seleccionar imagen',
        error: e,
        stackTrace: stackTrace,
        className: 'CreateAcademyNotifier',
        functionName: 'selectAndUpdateLogo'
      );
      
      state = CreateAcademyState.error(
        Failure.unexpectedError(error: e, stackTrace: stackTrace),
        currentStep: currentStep,
        imageStatus: ImageUploadStatus.error,
        logoFile: logoFile,
      );
      _clearErrorAfterDelay();
    }
  }

  /// Intenta crear la academia validando el formulario y el deporte seleccionado.
  Future<void> createAcademy() async {
    // Validar todos los pasos antes de crear la academia
    if (!_validateAllSteps()) {
      return;
    }

    // Obtener User ID
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      AppLogger.logError(
        message: 'Error: Usuario no autenticado al intentar crear academia',
        className: 'CreateAcademyNotifier',
        functionName: 'createAcademy'
      );
      state = CreateAcademyState.error(
        Failure.authError(code: 'unauthenticated'),
        currentStep: FormStep.basicInfo,
      );
      _clearErrorAfterDelay();
      return;
    }
    final userId = user.uid;

    // Iniciar estado de carga
    state = CreateAcademyState.loading(
      currentStep: FormStep.logoImage,
      logoFile: logoFile,
    );
    
    AppLogger.logInfo(
      'Iniciando creación de academia',
      className: 'CreateAcademyNotifier',
      functionName: 'createAcademy',
      params: {
        'userId': userId,
        'nombre': nameController.text.trim(),
        'deporte': selectedSportCode,
        'tieneImagen': (logoFile != null).toString()
      }
    );

    // Intentar crear con llamada real al repositorio
    try {
      final academyToCreateModel = AcademyModel(
        ownerId: userId,
        name: nameController.text.trim(),
        sportCode: selectedSportCode!,
        location: '',
        description: description,
        phone: phone,
        email: email,
        address: address,
        // El logoUrl se manejará en el repositorio si logoFile no es null
        // createdAt se añadirá en el repositorio
      );

      // Si hay un archivo de logo, debemos pasarlo al repositorio
      final academyResult = logoFile != null 
          ? await _academyRepository.createAcademyWithLogo(academyToCreateModel, logoFile!)
          : await _academyRepository.createAcademy(academyToCreateModel);

      await academyResult.fold(
        (failure) async {
          AppLogger.logError(
            message: 'Error al crear academia en repositorio',
            error: failure,
            className: 'CreateAcademyNotifier',
            functionName: 'createAcademy',
            params: {
              'tipoError': failure.runtimeType.toString(),
              'mensaje': failure.message
            }
          );
          state = CreateAcademyState.error(
            failure,
            currentStep: FormStep.logoImage,
            logoFile: logoFile,
          );
          _clearErrorAfterDelay();
        },
        (createdAcademy) async {
          AppLogger.logInfo(
            'Academia creada con éxito',
            className: 'CreateAcademyNotifier',
            functionName: 'createAcademy',
            params: {
              'academyId': createdAcademy.id,
              'nombre': createdAcademy.name,
              'deporte': createdAcademy.sportCode
            }
          );

          // PASO 2: Crear suscripción inicial
          try {
            AppLogger.logInfo(
              'Creando suscripción inicial',
              className: 'CreateAcademyNotifier',
              functionName: 'createAcademy',
              params: {'academyId': createdAcademy.id}
            );
            // Definir suscripción inicial (ej. trial de 30 días)
            final initialSubscription = SubscriptionModel(
              academyId: createdAcademy.id!,
              status: SubscriptionStatus.trial.name, // Usar el nombre del enum
              endDate: Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))), // Usar Timestamp.fromDate
            );

            final subscriptionResult = await _subscriptionRepository.createInitialSubscription(initialSubscription);

            await subscriptionResult.fold(
              (subFailure) async {
                 AppLogger.logError(
                   message: 'Error al crear suscripción inicial',
                   error: subFailure,
                   className: 'CreateAcademyNotifier',
                   functionName: 'createAcademy',
                   params: {
                     'academyId': createdAcademy.id,
                     'tipoError': subFailure.runtimeType.toString(),
                     'mensaje': subFailure.message
                   }
                 );
                 // Si falla la suscripción, revertir estado a error.
                 state = CreateAcademyState.error(
                   subFailure,
                   currentStep: FormStep.logoImage,
                 );
                 _clearErrorAfterDelay();
                 // Opcional: Podríamos intentar eliminar la academia creada aquí, pero es complejo.
              },
              (_) async { // Suscripción creada
                 AppLogger.logInfo(
                   'Suscripción inicial creada con éxito',
                   className: 'CreateAcademyNotifier',
                   functionName: 'createAcademy',
                   params: {
                     'academyId': createdAcademy.id,
                     'tipoPlan': 'trial',
                     'duración': '30 días'
                   }
                 );

                 // PASO 3: Crear membresía para el propietario
                 try {
                   final ownerMembership = MembershipModel(
                      userId: userId,
                      academyId: createdAcademy.id!,
                      role: AppRole.propietario,
                      addedAt: DateTime.now(),
                      // permissions: [], // Vacío por defecto
                   );
                   AppLogger.logInfo(
                     'Creando membresía de propietario',
                     className: 'CreateAcademyNotifier',
                     functionName: 'createAcademy',
                     params: {
                       'academyId': createdAcademy.id,
                       'userId': userId,
                       'rol': AppRole.propietario.name
                     }
                   );
                   final membershipResult = await _membershipRepository.createMembership(ownerMembership);

                   membershipResult.fold(
                     (memFailure) {
                        AppLogger.logError(
                          message: 'Error al crear membresía de propietario',
                          error: memFailure,
                          className: 'CreateAcademyNotifier',
                          functionName: 'createAcademy',
                          params: {
                            'academyId': createdAcademy.id,
                            'userId': userId,
                            'tipoError': memFailure.runtimeType.toString(),
                            'mensaje': memFailure.message
                          }
                        );
                        // Decidir: ¿fallar todo? Por ahora, solo log y éxito parcial.
                        state = CreateAcademyState.success(createdAcademy.id!);
                        // Usar el nuevo provider que maneja el objeto completo en lugar de solo el ID
                        _ref.read(currentAcademyProvider.notifier).state = createdAcademy;
                     },
                     (_) {
                        AppLogger.logInfo(
                          'Membresía de propietario creada con éxito',
                          className: 'CreateAcademyNotifier',
                          functionName: 'createAcademy',
                          params: {
                            'academyId': createdAcademy.id,
                            'userId': userId
                          }
                        );
                        // Todas las operaciones (Academia, Suscripción, Membresía) exitosas
                        AppLogger.logInfo(
                          'Proceso completo de creación de academia finalizado con éxito',
                          className: 'CreateAcademyNotifier',
                          functionName: 'createAcademy',
                          params: {'academyId': createdAcademy.id}
                        );
                        state = CreateAcademyState.success(createdAcademy.id!); 
                        // Usar el nuevo provider que maneja el objeto completo en lugar de solo el ID
                        _ref.read(currentAcademyProvider.notifier).state = createdAcademy;
                     }
                   );
                 } catch (memError, memStackTrace) {
                    AppLogger.logError(
                      message: 'Excepción no controlada al crear membresía',
                      error: memError,
                      stackTrace: memStackTrace,
                      className: 'CreateAcademyNotifier',
                      functionName: 'createAcademy',
                      params: {
                        'academyId': createdAcademy.id,
                        'userId': userId,
                        'tipoError': memError.runtimeType.toString()
                      }
                    );
                    state = CreateAcademyState.success(createdAcademy.id!); 
                    // Usar el nuevo provider que maneja el objeto completo en lugar de solo el ID
                    _ref.read(currentAcademyProvider.notifier).state = createdAcademy;
                 }
              },
            );

          } catch (subError, subStackTrace) {
             AppLogger.logError(
               message: 'Excepción no controlada al crear suscripción',
               error: subError,
               stackTrace: subStackTrace,
               className: 'CreateAcademyNotifier',
               functionName: 'createAcademy',
               params: {
                 'academyId': createdAcademy.id,
                 'tipoError': subError.runtimeType.toString()
               }
             );
             state = CreateAcademyState.error(
               Failure.unexpectedError(error: subError, stackTrace: subStackTrace),
               currentStep: FormStep.logoImage,
             );
             _clearErrorAfterDelay();
          }
        },
      );

    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Estado: Error (excepción inesperada) creando academia',
        error: e,
        stackTrace: stackTrace
      );
      state = CreateAcademyState.error(
        Failure.unexpectedError(error: e, stackTrace: stackTrace),
        currentStep: FormStep.logoImage,
      );
      _clearErrorAfterDelay();
    }
  }

  /// Limpia el estado de error después de 3 segundos si aún es un error.
  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && state.maybeMap(
        error: (_) => true,
        orElse: () => false
      )) {
        final currentStep = state.maybeMap(
          error: (s) => s.currentStep,
          orElse: () => FormStep.basicInfo,
        );
        
        final logoFile = state.maybeMap(
          error: (s) => s.logoFile,
          orElse: () => null,
        );
        
        state = CreateAcademyState.initial(
          currentStep: currentStep,
          logoFile: logoFile,
        );
      }
    });
  }

  @override
  void dispose() {
    AppLogger.logInfo('Disposing CreateAcademyNotifier controllers');
    nameController.dispose();
    super.dispose();
  }
} 