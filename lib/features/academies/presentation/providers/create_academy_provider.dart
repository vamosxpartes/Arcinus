// Needed for User type
import 'dart:developer' as developer;

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

/// Provider for managing the state of academy creation.
final createAcademyProvider = StateNotifierProvider.autoDispose<
    CreateAcademyNotifier, CreateAcademyState>((ref) {
  // Obtener dependencias reales
  final academyRepository = ref.watch(academyRepositoryProvider);
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider); // Obtener repo subs
  final membershipRepository = ref.watch(membershipRepositoryProvider); // <-- Añadir Repo Membresías
  final firebaseAuth = ref.watch(firebaseAuthProvider); // Para obtener el User ID
  developer.log('Creando CreateAcademyNotifier con dependencias reales'); // Log actualizado
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

  // TODO: Esta lista debería venir de una fuente de datos real (configuración, Firestore)
  final List<Map<String, String>> availableSports = [
    {'code': 'soccer', 'name': 'Fútbol'},
    {'code': 'basketball', 'name': 'Baloncesto'},
    {'code': 'volleyball', 'name': 'Voleibol'},
    // ... más deportes
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
    if (!(formKey.currentState?.validate() ?? false)) {
      developer.log('Formulario inválido');
      return;
    }

    // 2. Validar selección de deporte
    if (selectedSportCode == null) {
      developer.log('Error: Deporte no seleccionado');
      state = CreateAcademyState.error(
        Failure.validationError(message: 'Debes seleccionar un deporte'),
      );
      _clearErrorAfterDelay();
      return;
    }

    // 3. Obtener User ID
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      developer.log('Error: Usuario no autenticado');
      state = const CreateAcademyState.error(
        Failure.authError(code: 'unauthenticated'),
      );
      _clearErrorAfterDelay();
      return;
    }
    final userId = user.uid;

    // 4. Iniciar estado de carga
    state = const CreateAcademyState.loading();
    developer.log('Estado: Cargando creación de academia para usuario $userId');

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
          developer.log('Estado: Error creando academia - $failure');
          state = CreateAcademyState.error(failure);
          _clearErrorAfterDelay();
        },
        (createdAcademy) async {
          developer.log('Estado: Éxito creando academia - ID: ${createdAcademy.id}');
          
          // PASO 2: Crear suscripción inicial
          try {
            developer.log('Creando suscripción inicial para la academia ${createdAcademy.id}');
            // Definir suscripción inicial (ej. trial de 30 días)
            final initialSubscription = SubscriptionModel(
              academyId: createdAcademy.id!,
              status: SubscriptionStatus.trial.name, // Usar el nombre del enum
              endDate: Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))), // Usar Timestamp.fromDate
            );
            
            final subscriptionResult = await _subscriptionRepository.createInitialSubscription(initialSubscription);
            
            await subscriptionResult.fold(
              (subFailure) async {
                 developer.log('Error creando suscripción inicial: $subFailure. Fallando operación completa...');
                 // Si falla la suscripción, revertir estado a error.
                 state = CreateAcademyState.error(subFailure); 
                 _clearErrorAfterDelay();
                 // Opcional: Podríamos intentar eliminar la academia creada aquí, pero es complejo.
              },
              (_) async { // Suscripción creada
                 developer.log('Suscripción inicial creada con éxito.');
                 
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
                        developer.log('Error creando membresía del propietario: $memFailure. Continuando...');
                        // Decidir: ¿fallar todo? Por ahora, solo log y éxito parcial.
                        state = CreateAcademyState.success(createdAcademy.id!); 
                        _ref.read(currentAcademyIdProvider.notifier).state = createdAcademy.id;
                     },
                     (_) {
                        developer.log('Membresía del propietario creada con éxito.');
                        // Todas las operaciones (Academia, Suscripción, Membresía) exitosas
                        state = CreateAcademyState.success(createdAcademy.id!); 
                        _ref.read(currentAcademyIdProvider.notifier).state = createdAcademy.id;
                     }
                   );
                 } catch (memError, memStackTrace) {
                    developer.log('Excepción inesperada creando membresía: $memError\n$memStackTrace. Continuando...');
                    state = CreateAcademyState.success(createdAcademy.id!); 
                    _ref.read(currentAcademyIdProvider.notifier).state = createdAcademy.id;
                 }
              },
            );

          } catch (subError, subStackTrace) {
             developer.log('Excepción inesperada creando suscripción: $subError\n$subStackTrace. Fallando operación...');
             state = CreateAcademyState.error(Failure.unexpectedError(error: subError, stackTrace: subStackTrace)); 
             _clearErrorAfterDelay();
          }
        },
      );

    } catch (e, stackTrace) {
      developer.log('Estado: Error (excepción inesperada) creando academia - $e\n$stackTrace');
      state = CreateAcademyState.error(Failure.unexpectedError(error: e, stackTrace: stackTrace));
      _clearErrorAfterDelay();
    }
  }

  /// Limpia el estado de error después de 3 segundos si aún es un error.
  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
        state = const CreateAcademyState.initial();
      }
    });
  }

  @override
  void dispose() {
    developer.log('Disposing CreateAcademyNotifier controllers');
    nameController.dispose();
    super.dispose();
  }
} 