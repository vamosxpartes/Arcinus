import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/user.dart';
import '../implementations/firebase_auth_repository.dart';
import '../repositories/auth_repository.dart';

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
    return ref.watch(authRepositoryProvider).currentUser();
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
    state = const AsyncValue.loading();
    
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
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
    try {
      final user = await ref.read(authStateProvider.future);
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }
      
      final imageUrl = await ref.read(authRepositoryProvider).uploadProfileImage(imageFile, user.id);
      
      // Actualizar el usuario con la nueva URL de imagen
      final updatedUser = user.copyWith(
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