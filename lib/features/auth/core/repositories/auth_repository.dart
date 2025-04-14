import 'dart:io';

import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/models/pre_registered_user.dart';

/// Interfaz para el repositorio de autenticación
abstract class AuthRepository {
  /// Obtiene el usuario actualmente autenticado
  Future<User?> currentUser();
  
  /// Inicia sesión con correo electrónico y contraseña
  Future<User> signInWithEmailAndPassword(String email, String password);
  
  /// Registra un nuevo usuario con correo electrónico y contraseña
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
  
  /// Crea un usuario pre-registrado y genera un código de activación
  Future<PreRegisteredUser> createPreRegisteredUser(String email, String name, UserRole role, String createdBy);
  
  /// Verifica si un código de activación es válido
  Future<PreRegisteredUser?> verifyActivationCode(String activationCode);
  
  /// Completa el registro de un usuario pre-registrado
  Future<User> completeRegistration(String activationCode, String password);
  
  /// Obtiene todos los usuarios pre-registrados
  Future<List<PreRegisteredUser>> getAllPreRegisteredUsers();
  
  /// Elimina un usuario pre-registrado
  Future<void> deletePreRegisteredUser(String id);
} 