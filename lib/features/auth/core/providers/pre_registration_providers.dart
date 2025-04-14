import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/models/pre_registered_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_providers.dart';

part 'pre_registration_providers.g.dart';

/// Proveedor para obtener todos los usuarios pre-registrados
@riverpod
Future<List<PreRegisteredUser>> preRegisteredUsers(Ref ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getAllPreRegisteredUsers();
}

/// Proveedor para crear un nuevo usuario pre-registrado
@riverpod
Future<PreRegisteredUser> createPreRegisteredUser(
  Ref ref, {
  required String email,
  required String name,
  required UserRole role,
  required String createdBy,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  try {
    final preRegisteredUser = await authRepository.createPreRegisteredUser(
      email,
      name,
      role,
      createdBy,
    );
    
    // Invalidar el proveedor de usuarios pre-registrados para refrescar la lista
    ref.invalidate(preRegisteredUsersProvider);
    
    return preRegisteredUser;
  } catch (e) {
    debugPrint('Error al crear usuario pre-registrado: $e');
    rethrow;
  }
}

/// Proveedor para verificar un código de activación
@riverpod
Future<PreRegisteredUser?> verifyActivationCode(
  Ref ref, 
  String activationCode,
) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.verifyActivationCode(activationCode);
}

/// Proveedor para completar el registro de un usuario pre-registrado
@riverpod
Future<User> completeRegistration(
  Ref ref, {
  required String activationCode,
  required String password,
}) async {
  final authRepository = ref.watch(authRepositoryProvider);
  try {
    final user = await authRepository.completeRegistration(activationCode, password);
    
    // Invalidar el proveedor de usuarios pre-registrados
    ref.invalidate(preRegisteredUsersProvider);
    
    return user;
  } catch (e) {
    debugPrint('Error al completar registro: $e');
    rethrow;
  }
}

/// Proveedor para eliminar un usuario pre-registrado
@riverpod
Future<void> deletePreRegisteredUser(
  Ref ref,
  String id,
) async {
  final authRepository = ref.watch(authRepositoryProvider);
  await authRepository.deletePreRegisteredUser(id);
  
  // Invalidar el proveedor de usuarios pre-registrados para refrescar la lista
  ref.invalidate(preRegisteredUsersProvider);
} 