import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/repositories/auth_repository.dart';
import 'package:arcinus/features/auth/core/repositories/firebase_auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'auth_providers.g.dart';

/// Provider del repositorio de autenticación
@riverpod
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository();
}

/// Provider de estado de autenticación
@riverpod
class AuthState extends _$AuthState {
  @override
  Future<User?> build() async {
    final userChanges = ref.watch(authStateChangesProvider);
    return userChanges.when(
      data: (user) => user,
      loading: () => null,
      error: (e, s) {
        developer.log('Error en authStateChangesProvider: $e');
        return null;
      },
    );
  }
  
  /// Inicia sesión con correo electrónico y contraseña
  Future<User> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await ref.read(authRepositoryProvider)
          .signInWithEmailAndPassword(email, password);
      
      state = AsyncValue.data(user);
      return user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Registra un nuevo usuario con correo electrónico y contraseña
  Future<User> signUp(String email, String password, String name, UserRole role) async {
    state = const AsyncValue.loading();
    
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signUpWithEmailAndPassword(email, password, name, role);
      
      state = AsyncValue.data(user);
      return user;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      await ref.read(authRepositoryProvider).signOut();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Envía un correo electrónico para restablecer la contraseña
  Future<void> resetPassword(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }
  
  /// Actualiza la información de un usuario
  Future<User> updateUser(User user) async {
    state = const AsyncValue.loading();
    try {
      final updatedUser = await ref.read(authRepositoryProvider).updateUser(user);
      state = AsyncValue.data(updatedUser);
      return updatedUser;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Actualiza la imagen de perfil del usuario
  Future<User> updateProfileImage(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('No hay usuario autenticado para actualizar imagen');
      }
      
      final imageUrl = await ref.read(authRepositoryProvider).uploadProfileImage(imageFile, currentUser.id);
      
      final updatedUser = currentUser.copyWith(
        profileImageUrl: imageUrl,
      );
      return await updateUser(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider para el stream de autenticación
@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Provider para crear un registro de activación pendiente.
/// Devuelve el código de activación generado.
@riverpod
Future<String> createPendingActivation(
  Ref ref, {
  required String academyId,
  required String userName,
  required UserRole role,
  required String createdBy,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  try {
    final activationCode = await authRepository.createPendingActivation(
      academyId: academyId,
      name: userName,
      role: role,
      createdBy: createdBy,
    );
    return activationCode;
  } catch (e) {
    developer.log('Error en provider createPendingActivation: $e');
    rethrow;
  }
}

/// Provider para verificar un código de activación pendiente.
/// Devuelve los datos del pre-registro (Map) si es válido, null si no.
@riverpod
Future<Map<String, dynamic>?> verifyPendingActivation(
  Ref ref, {
  required String academyId,
  required String activationCode,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  try {
     return await authRepository.verifyPendingActivation(
       academyId: academyId,
       activationCode: activationCode,
     );
   } catch (e) {
     developer.log('Error en provider verifyPendingActivation: $e');
     return null;
   }
}

/// Provider para completar la activación de cuenta con código.
/// Devuelve el usuario final creado.
@riverpod
Future<User> completeActivationWithCode(
  Ref ref, {
  required String academyId,
  required String activationCode,
  required String email,
  required String password,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  try {
    final user = await authRepository.completeActivationWithCode(
      academyId: academyId,
      activationCode: activationCode,
      email: email,
      password: password,
    );
    return user;
  } catch (e) {
    developer.log('Error en provider completeActivationWithCode: $e');
    rethrow;
  }
} 