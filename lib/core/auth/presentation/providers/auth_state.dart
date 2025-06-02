import 'package:arcinus/core/auth/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Estado para la autenticación
@freezed
class AuthState with _$AuthState {
  /// Estado inicial
  const factory AuthState.initial() = _Initial;

  /// Estado de carga
  const factory AuthState.loading() = _Loading;

  /// Estado de autenticado
  const factory AuthState.authenticated({required User user}) = _Authenticated;

  /// Estado de no autenticado
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Estado de error
  const factory AuthState.error({required String message}) = _Error;

  /// Constructor privado para las extensiones
  const AuthState._();

  /// Verifica si el estado es de carga
  bool get isLoading => this is _Loading;

  /// Verifica si el estado es autenticado
  bool get isAuthenticated => this is _Authenticated;

  /// Verifica si el estado es no autenticado
  bool get isUnauthenticated => this is _Unauthenticated;

  /// Verifica si el estado es de error
  bool get hasError => this is _Error;

  /// Obtiene el usuario actual (null si no está autenticado)
  User? get user => mapOrNull(authenticated: (state) => state.user);

  /// Obtiene el mensaje de error (null si no hay error)
  String? get errorMessage => mapOrNull(error: (state) => state.message);
}
