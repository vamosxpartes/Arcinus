import '../../../../shared/models/user.dart';

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
} 