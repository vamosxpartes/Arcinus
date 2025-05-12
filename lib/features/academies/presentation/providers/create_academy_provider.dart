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
  
  // Flag para permitir pre-validación desde pantallas externas
  bool _isFormPreValidated = false;
  
  // Campos adicionales
  String description = '';
  String phone = '';
  String email = '';
  String address = '';
  File? logoFile;

  /// Establece si el formulario está pre-validado externamente
  void setFormPreValidated(bool validated) {
    _isFormPreValidated = validated;
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
    if (logoFile != null) this.logoFile = logoFile;
  }

  /// Intenta crear la academia validando el formulario y el deporte seleccionado.
  Future<void> createAcademy() async {
    // 1. Validar formulario - usar pre-validación si está habilitada
    final formKeyValid = formKey.currentState?.validate() ?? false;
    final isFormValid = formKeyValid || _isFormPreValidated;
    
    if (_isFormPreValidated) {
      AppLogger.logInfo(
        'Usando validación externa del formulario',
        className: 'CreateAcademyNotifier',
        functionName: 'createAcademy',
        params: {'formKeyValid': formKeyValid.toString(), 'preValidated': _isFormPreValidated.toString()}
      );
    }
    
    String? nameValidationError;
    if (!isFormValid) {
      // Capturar el error específico del nombre si es el caso
      if (nameController.text.trim().isEmpty) {
          nameValidationError = 'Ingresa el nombre de la academia';
          AppLogger.logWarning(
            'Validación fallida: Campo nombre vacío',
            className: 'CreateAcademyNotifier',
            functionName: 'createAcademy',
            params: {'nombreActual': nameController.text}
          );
      } else {
          AppLogger.logWarning(
            'Validación fallida: Formulario con errores desconocidos',
            className: 'CreateAcademyNotifier',
            functionName: 'createAcademy'
          );
      }
      // No retornar aún, verificar deporte también
    } else {
      AppLogger.logInfo(
        'Validación de nombre correcta',
        className: 'CreateAcademyNotifier',
        functionName: 'createAcademy',
        params: {'nombre': nameController.text.trim()}
      );
    }

    // 2. Validar selección de deporte
    String? sportValidationError;
    if (selectedSportCode == null) {
      sportValidationError = 'Debes seleccionar un deporte';
      AppLogger.logWarning(
        'Validación fallida: Deporte no seleccionado',
        className: 'CreateAcademyNotifier',
        functionName: 'createAcademy'
      );
    } else {
      AppLogger.logInfo(
        'Validación de deporte correcta',
        className: 'CreateAcademyNotifier',
        functionName: 'createAcademy',
        params: {'deporte': selectedSportCode}
      );
    }

    // Si hay algún error de validación, actualizar estado y retornar
    if (!isFormValid || sportValidationError != null) {
       AppLogger.logWarning(
         'Formulario inválido - No se puede crear academia',
         className: 'CreateAcademyNotifier',
         functionName: 'createAcademy',
         params: {
           'erroresNombre': nameValidationError ?? 'Ninguno',
           'erroresDeporte': sportValidationError ?? 'Ninguno',
           'formularioValido': isFormValid.toString()
         }
       );
       
       state = CreateAcademyState.error(
         Failure.validationError(message: 'Por favor corrige los errores'),
         nameError: nameValidationError,
         sportCodeError: sportValidationError,
       );
      _clearErrorAfterDelay(); // Limpiar estado de error después de un tiempo
      return;
    }

    // 3. Obtener User ID
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      AppLogger.logError(
        message: 'Error: Usuario no autenticado al intentar crear academia',
        className: 'CreateAcademyNotifier',
        functionName: 'createAcademy'
      );
      state = const CreateAcademyState.error(
        Failure.authError(code: 'unauthenticated'),
      );
      _clearErrorAfterDelay();
      return;
    }
    final userId = user.uid;

    // 4. Iniciar estado de carga
    state = const CreateAcademyState.loading();
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

    // 5. Intentar crear con llamada real al repositorio
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
          state = CreateAcademyState.error(failure);
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
                 state = CreateAcademyState.error(subFailure);
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
             state = CreateAcademyState.error(Failure.unexpectedError(error: subError, stackTrace: subStackTrace));
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
      state = CreateAcademyState.error(Failure.unexpectedError(error: e, stackTrace: stackTrace));
      _clearErrorAfterDelay();
    }
  }

  /// Limpia el estado de error después de 3 segundos si aún es un error.
  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.maybeWhen(error: (failure, nameError, sportCodeError) => true, orElse: () => false)) {
        state = const CreateAcademyState.initial();
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