import 'dart:io';

import 'package:arcinus/features/app/users/user/core/models/user.dart';
// import 'package:arcinus/features/app/users/user/core/models/user_role.dart'; // Importación eliminada, UserRole viene de user.dart

/// Interfaz para el repositorio de autenticación
abstract class AuthRepository {
  /// Obtiene el usuario actualmente autenticado
  Future<User?> currentUser();
  
  /// Inicia sesión con correo electrónico y contraseña
  Future<User> signInWithEmailAndPassword(String email, String password);
  
  /// Registra un nuevo usuario DIRECTAMENTE (Este método podría quedar obsoleto o usarse solo para casos especiales si el pre-registro es mandatorio)
  /// Considerar si se debe mantener o eliminar según la lógica final de negocio.
  /// Por ahora, lo dejamos pero comentamos su propósito original.
  Future<User> signUpWithEmailAndPassword(String email, String password, String name, UserRole role);
  
  /// Cierra la sesión del usuario actual
  Future<void> signOut();
  
  /// Envía un correo electrónico para restablecer la contraseña
  Future<void> sendPasswordResetEmail(String email);
  
  /// Stream de cambios en el estado de autenticación del usuario
  Stream<User?> get authStateChanges;
  
  /// Actualiza la información de un usuario
  Future<User> updateUser(User user);
  
  /// Sube una imagen de perfil a Firebase Storage y devuelve la URL
  Future<String> uploadProfileImage(File imageFile, String userId);
  
  /// Crea un registro de activación pendiente en Firestore y devuelve el código de activación.
  Future<String> createPendingActivation({
    required String academyId,
    required String name,
    required UserRole role,
    required String createdBy, // UID del admin que crea el pre-registro
  });
  
  /// Verifica si un código de activación es válido para una academia específica.
  /// Devuelve los datos del pre-registro (nombre, rol) si es válido, null si no.
  Future<Map<String, dynamic>?> verifyPendingActivation({
    required String academyId,
    required String activationCode,
  });
  
  /// Completa el proceso de activación: verifica código, crea cuenta Auth,
  /// crea registro de usuario en Firestore y elimina el registro pendiente.
  Future<User> completeActivationWithCode({
    required String academyId,
    required String activationCode,
    required String email,
    required String password,
  });
} 