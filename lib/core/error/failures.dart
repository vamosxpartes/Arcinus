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
  const factory Failure.serverError({@Default('') String message}) = ServerFailure;

  /// Representa un error relacionado con la conexión de red.
  const factory Failure.networkError() = NetworkFailure;

  /// Representa un error relacionado con la autenticación.
  /// [code] puede contener un código de error específico (ej. de Firebase Auth)
  const factory Failure.authError({
    required String code,
    @Default('') String message,
  }) = AuthFailure;

  /// Representa un error relacionado con la validación de datos
  /// (ej. formularios).
  /// [message] puede contener una descripción del error de validación.
  const factory Failure.validationError({@Default('') String message}) =
      ValidationFailure;

  /// Representa un error al interactuar con la caché local.
  const factory Failure.cacheError({@Default('') String message}) = CacheFailure;

  /// Representa un error cuando un recurso no se encuentra.
  /// [message] puede contener una descripción del recurso no encontrado.
  const factory Failure.notFound({@Default('') String message}) = _NotFoundFailure;

  /// Representa un error inesperado o no clasificado.
  const factory Failure.unexpectedError({
    Object? error,
    StackTrace? stackTrace,
  }) = UnexpectedError;

  // --- Métodos de conveniencia ---

  /// Devuelve un mensaje legible por el usuario para el fallo.
  String get message {
    return when(
      serverError: (message) => message.isNotEmpty ? message : 'Error del servidor',
      networkError: () => 'Error de red. Verifica tu conexión.',
      authError: (code, message) =>
          message.isNotEmpty ? message : 'Error de autenticación ($code)',
      validationError: (message) =>
          message.isNotEmpty ? message : 'Error de validación',
      cacheError: (message) => message.isNotEmpty ? message : 'Error de caché',
      notFound: (message) => message.isNotEmpty ? message : 'Recurso no encontrado',
      unexpectedError: (error, stackTrace) =>
          'Error inesperado: ${error?.toString() ?? 'Desconocido'}',
    );
  }
}

/// Implementación del fallo cuando un recurso no se encuentra.
class _NotFoundFailure extends Failure {
  const _NotFoundFailure({this.message = ''}) : super._();
  
  @override
  final String message;
}
