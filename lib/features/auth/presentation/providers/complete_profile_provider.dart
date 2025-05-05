import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/error/failures.dart'; // Asumiendo ubicación
import 'package:arcinus/features/auth/presentation/state/complete_profile_state.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart'; // Para obtener el usuario actual
import 'package:arcinus/features/auth/data/models/user_model.dart'; // Importar UserModel
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart'; // Para invalidar el provider
import 'package:arcinus/features/users/domain/repositories/user_repository.dart'; // <--- Importar interfaz
import 'package:arcinus/features/users/data/repositories/user_repository_impl.dart'; // <--- Importar provider del repo
import 'package:logger/logger.dart'; // Importar logger

// Instancia de Logger
final _logger = Logger();

// Provider
final completeProfileProvider = StateNotifierProvider.autoDispose<
    CompleteProfileNotifier, CompleteProfileState>((ref) {
  // Obtener las dependencias necesarias
  final userRepository = ref.watch(userRepositoryProvider); // <--- Usar provider del repositorio
  final currentAuthUser = ref.watch(currentUserProvider);
  
  _logger.d('Creando CompleteProfileNotifier con userId: ${currentAuthUser?.id}');
  return CompleteProfileNotifier(ref, userRepository);
});

// Notifier
class CompleteProfileNotifier extends StateNotifier<CompleteProfileState> {
  CompleteProfileNotifier(this.ref, this.userRepository)
      : super(const CompleteProfileState.initial());

  final Ref ref;
  final UserRepository userRepository; // <--- Repositorio de usuarios
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();

  Future<void> submitProfile() async {
    if (formKey.currentState?.validate() ?? false) {
      state = const CompleteProfileState.loading();
      _logger.d('Estado: Cargando');
      try {
        // Obtener el usuario actual
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null || currentUser.id.isEmpty) {
          _logger.e('Error: No hay usuario autenticado');
          state = CompleteProfileState.error(const Failure.authError(
            code: 'no-user',
            message: 'No hay usuario autenticado',
          ));
          return;
        }

        // Crear el modelo de usuario con los datos actualizados
        final fullName = '${nameController.text.trim()} ${lastNameController.text.trim()}';
        final userToUpdate = UserModel(
          id: currentUser.id,
          email: currentUser.email, // Mantener email original
          displayName: fullName, // <--- Usar displayName
          profileCompleted: true, // <--- Marcar como completado
          appRole: currentUser.role, // Mantener el rol existente del currentUser
          // photoUrl: Mantener o actualizar si hubiera campo para ello
          // createdAt: No se modifica al actualizar
        );

        // Llamar al repositorio para guardar/actualizar
        final result = await userRepository.upsertUser(userToUpdate);

        result.fold(
          (failure) {
            _logger.e('Error guardando perfil: $failure', error: failure);
            state = CompleteProfileState.error(failure);
          },
          (_) {
            _logger.i('Perfil guardado via repositorio para usuario: ${currentUser.id}');
            // Actualizar estado a éxito
            state = const CompleteProfileState.success();
            _logger.d('Estado: Éxito (guardado via repositorio)');

            // Importante: Forzar actualización del userProfileProvider
            ref.invalidate(userProfileProvider(currentUser.id)); // <--- Invalidate necesita userProfileProvider importado
            _logger.d('userProfileProvider invalidado para forzar actualización');

            // Esperar un momento para que se propague la actualización
            // Esta espera podría no ser ideal, GoRouter debería reaccionar al estado.
            // await Future.delayed(const Duration(milliseconds: 500));
          },
        );
      } catch (e, s) {
        _logger.e('Estado: Error (excepción inesperada)', error: e, stackTrace: s);
        state = CompleteProfileState.error(Failure.unexpectedError(error: e, stackTrace: s));
      }
    } else {
      _logger.w('Formulario inválido');
    }
  }

  @override
  void dispose() {
    _logger.d('Disposing CompleteProfileNotifier controllers');
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
} 