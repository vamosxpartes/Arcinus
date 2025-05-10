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
import 'package:logger/logger.dart'; // Importar logger

// Instancia de Logger
final _logger = Logger();

/// Provider for managing the state of academy creation.
final createAcademyProvider = StateNotifierProvider.autoDispose<
    CreateAcademyNotifier, CreateAcademyState>((ref) {
  // Obtener dependencias reales
  final academyRepository = ref.watch(academyRepositoryProvider);
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider); // Obtener repo subs
  final membershipRepository = ref.watch(membershipRepositoryProvider); // <-- Añadir Repo Membresías
  final firebaseAuth = ref.watch(firebaseAuthProvider); // Para obtener el User ID
  _logger.d('Creando CreateAcademyNotifier con dependencias reales');
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

  /// Intenta crear la academia validando el formulario y el deporte seleccionado.
  Future<void> createAcademy() async {
    // 1. Validar formulario
    final isFormValid = formKey.currentState?.validate() ?? false;
    String? nameValidationError;
    if (!isFormValid) {
      // Capturar el error específico del nombre si es el caso
      if (nameController.text.trim().isEmpty) {
          nameValidationError = 'Ingresa el nombre de la academia';
      }
      _logger.w('Formulario inválido');
      // No retornar aún, verificar deporte también
    }

    // 2. Validar selección de deporte
    String? sportValidationError;
    if (selectedSportCode == null) {
      sportValidationError = 'Debes seleccionar un deporte';
      _logger.w('Error: Deporte no seleccionado');
    }

    // Si hay algún error de validación, actualizar estado y retornar
    if (!isFormValid || sportValidationError != null) {
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
      _logger.e('Error: Usuario no autenticado');
      state = const CreateAcademyState.error(
        Failure.authError(code: 'unauthenticated'),
      );
      _clearErrorAfterDelay();
      return;
    }
    final userId = user.uid;

    // 4. Iniciar estado de carga
    state = const CreateAcademyState.loading();
    _logger.d('Estado: Cargando creación de academia para usuario $userId');

    // 5. Intentar crear con llamada real al repositorio
    try {
      final academyToCreateModel = AcademyModel(
        ownerId: userId,
        name: nameController.text.trim(),
        sportCode: selectedSportCode!,
        location: '',
        // createdAt se añadirá en el repositorio
      );

      final academyResult = await _academyRepository.createAcademy(academyToCreateModel);

      await academyResult.fold(
        (failure) async {
          _logger.e('Estado: Error creando academia - $failure', error: failure);
          state = CreateAcademyState.error(failure);
          _clearErrorAfterDelay();
        },
        (createdAcademy) async {
          _logger.i('Estado: Éxito creando academia - ID: ${createdAcademy.id}');

          // PASO 2: Crear suscripción inicial
          try {
            _logger.d('Creando suscripción inicial para la academia ${createdAcademy.id}');
            // Definir suscripción inicial (ej. trial de 30 días)
            final initialSubscription = SubscriptionModel(
              academyId: createdAcademy.id!,
              status: SubscriptionStatus.trial.name, // Usar el nombre del enum
              endDate: Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))), // Usar Timestamp.fromDate
            );

            final subscriptionResult = await _subscriptionRepository.createInitialSubscription(initialSubscription);

            await subscriptionResult.fold(
              (subFailure) async {
                 _logger.e('Error creando suscripción inicial: $subFailure. Fallando operación completa...', error: subFailure);
                 // Si falla la suscripción, revertir estado a error.
                 state = CreateAcademyState.error(subFailure);
                 _clearErrorAfterDelay();
                 // Opcional: Podríamos intentar eliminar la academia creada aquí, pero es complejo.
              },
              (_) async { // Suscripción creada
                 _logger.i('Suscripción inicial creada con éxito.');

                 // PASO 3: Crear membresía para el propietario
                 try {
                   final ownerMembership = MembershipModel(
                      userId: userId,
                      academyId: createdAcademy.id!,
                      role: AppRole.propietario,
                      addedAt: DateTime.now(),
                      // permissions: [], // Vacío por defecto
                   );
                   final membershipResult = await _membershipRepository.createMembership(ownerMembership);

                   membershipResult.fold(
                     (memFailure) {
                        _logger.e('Error creando membresía del propietario: $memFailure. Continuando...', error: memFailure);
                        // Decidir: ¿fallar todo? Por ahora, solo log y éxito parcial.
                        state = CreateAcademyState.success(createdAcademy.id!);
                        // Usar el nuevo provider que maneja el objeto completo en lugar de solo el ID
                        _ref.read(currentAcademyProvider.notifier).state = createdAcademy;
                     },
                     (_) {
                        _logger.i('Membresía del propietario creada con éxito.');
                        // Todas las operaciones (Academia, Suscripción, Membresía) exitosas
                        state = CreateAcademyState.success(createdAcademy.id!); 
                        // Usar el nuevo provider que maneja el objeto completo en lugar de solo el ID
                        _ref.read(currentAcademyProvider.notifier).state = createdAcademy;
                     }
                   );
                 } catch (memError, memStackTrace) {
                    _logger.e('Excepción inesperada creando membresía: $memError', error: memError, stackTrace: memStackTrace);
                    state = CreateAcademyState.success(createdAcademy.id!); 
                    // Usar el nuevo provider que maneja el objeto completo en lugar de solo el ID
                    _ref.read(currentAcademyProvider.notifier).state = createdAcademy;
                 }
              },
            );

          } catch (subError, subStackTrace) {
             _logger.e('Excepción inesperada creando suscripción: $subError', error: subError, stackTrace: subStackTrace);
             state = CreateAcademyState.error(Failure.unexpectedError(error: subError, stackTrace: subStackTrace));
             _clearErrorAfterDelay();
          }
        },
      );

    } catch (e, stackTrace) {
      _logger.e('Estado: Error (excepción inesperada) creando academia', error: e, stackTrace: stackTrace);
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
    _logger.d('Disposing CreateAcademyNotifier controllers');
    nameController.dispose();
    super.dispose();
  }
} 