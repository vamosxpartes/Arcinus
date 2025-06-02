import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/core/error/failures.dart';

/// Estado posible de la autenticación
enum AuthStatus {
  /// Usuario no autenticado
  unauthenticated,
  
  /// En proceso de autenticación
  loading,
  
  /// Usuario autenticado
  authenticated,
  
  /// Usuario autenticado con perfil incompleto
  incompleteProfile,
  
  /// Error durante autenticación
  error
}

/// Clase que representa el estado de autenticación
class AuthState {
  /// Estado actual de autenticación
  final AuthStatus status;
  
  /// Usuario si está autenticado
  final User? user;
  
  /// Error si hay alguno
  final Failure? error;
  
  /// Constructor
  const AuthState({
    required this.status,
    this.user,
    this.error,
  });
  
  /// Estado inicial de la autenticación
  factory AuthState.initial() => const AuthState(
    status: AuthStatus.unauthenticated,
  );
  
  /// Estado de carga durante la autenticación
  factory AuthState.loading() => const AuthState(
    status: AuthStatus.loading,
  );
  
  /// Estado de autenticado
  factory AuthState.authenticated(User user) => AuthState(
    status: AuthStatus.authenticated,
    user: user,
  );
  
  /// Estado de perfil incompleto
  factory AuthState.incompleteProfile(User user) => AuthState(
    status: AuthStatus.incompleteProfile,
    user: user,
  );
  
  /// Estado de error
  factory AuthState.error(Failure failure) => AuthState(
    status: AuthStatus.error,
    error: failure,
  );
  
  /// Indica si el usuario está autenticado
  bool get isAuthenticated => 
      status == AuthStatus.authenticated || 
      status == AuthStatus.incompleteProfile;
  
  /// Indica si el perfil está incompleto
  bool get isIncompleteProfile => status == AuthStatus.incompleteProfile;
  
  /// Indica si hay un error
  bool get hasError => status == AuthStatus.error;
  
  /// Crear una copia modificada del estado actual
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Failure? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
} 