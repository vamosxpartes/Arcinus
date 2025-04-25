import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Clase base sellada para representar fallos controlados en la aplicación.
/// Utiliza Freezed para generar automáticamente el boilerplate y asegurar
/// el manejo exhaustivo de todos los tipos de fallos.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Representa un error ocurrido en el servidor/backend.
  /// [message] puede contener detalles adicionales del error.
  const factory Failure.serverError({String? message}) = ServerFailure;

  /// Representa un error relacionado con la conexión de red.
  const factory Failure.networkError() = NetworkFailure;

  /// Representa un error relacionado con la autenticación.
  /// [code] puede contener un código de error específico (ej. de Firebase Auth)
  const factory Failure.authError({required String code, String? message}) = 
      AuthFailure;
  
  /// Representa un error relacionado con la validación de datos 
  /// (ej. formularios).
  /// [message] puede contener una descripción del error de validación.
  const factory Failure.validationError({String? message}) = ValidationFailure;

  /// Representa un error al interactuar con la caché local.
  const factory Failure.cacheError({String? message}) = CacheFailure;

  /// Representa un error inesperado o no clasificado.
  const factory Failure.unexpectedError({
    Object? error, 
    StackTrace? stackTrace,
  }) =
      UnexpectedError;

  // --- Métodos de conveniencia ---

  /// Devuelve un mensaje legible por el usuario para el fallo.
  String get message {
    return when(
      serverError: (message) => message ?? 'Error del servidor',
      networkError: () => 'Error de red. Verifica tu conexión.',
      authError: (code, message) => message ?? 'Error de autenticación ($code)',
      validationError: (message) => message ?? 'Error de validación',
      cacheError: (message) => message ?? 'Error de caché',
      unexpectedError: (error, _) => 
          'Error inesperado: ${error?.toString() ?? 'Desconocido'}',
    );
  }
} 
