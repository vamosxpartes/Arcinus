import 'dart:io';

import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

/// Provider para la gestión del perfil de usuario
@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<User?> build() async {
    final user = await ref.watch(authStateProvider.future);
    return user;
  }
  
  /// Actualiza el perfil del usuario actual
  Future<void> updateProfile({
    String? name,
    String? email,
    Map<String, bool>? permissions,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // Obtener el usuario actual
      final currentUser = await ref.read(authStateProvider.future);
      
      if (currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }
      
      // Crear usuario actualizado
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
        permissions: permissions ?? currentUser.permissions,
      );
      
      // Actualizar usuario en el repositorio
      final result = await ref.read(authRepositoryProvider).updateUser(updatedUser);
      
      // Actualizar estado
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
  
  /// Selecciona una imagen desde la galería o la cámara y la actualiza como foto de perfil
  Future<void> pickAndUpdateProfileImage(ImageSource source) async {
    state = const AsyncValue.loading();
    
    try {
      // Obtener el usuario actual
      final currentUser = await ref.read(authStateProvider.future);
      
      if (currentUser == null) {
        throw Exception('No hay usuario autenticado');
      }
      
      // Seleccionar imagen
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        // El usuario canceló la selección
        // Restaurar el estado anterior
        state = AsyncValue.data(currentUser);
        return;
      }
      
      // Convertir a File
      final imageFile = File(pickedFile.path);
      
      // Subir imagen y actualizar usuario
      final updatedUser = await ref.read(authStateProvider.notifier).updateProfileImage(imageFile);
      
      // Actualizar estado
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
} 