import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/core/error/failures.dart';

/// Pruebas unitarias para los diferentes tipos de Failure en la aplicación.
/// 
/// Estas pruebas verifican que:
/// - Cada tipo de Failure se cree correctamente con sus parámetros
/// - Los valores predeterminados se asignen según lo esperado
/// - La serialización de mensajes funcione correctamente
/// 
/// Mejores prácticas implementadas:
/// - Pruebas específicas para cada tipo de Failure
/// - Validación directa de propiedades en lugar del método message

void main() {
  group('Failure', () {
    test('ServerFailure se crea correctamente con mensaje predeterminado', () {
      const failure = Failure.serverError();
      expect(failure, isA<ServerFailure>());
      // Verificamos directamente la propiedad en el objeto
      final serverFailure = failure as ServerFailure;
      expect(serverFailure.message, '');
    });

    test('ServerFailure se crea correctamente con mensaje personalizado', () {
      const failure = Failure.serverError(message: 'Error de conexión con el servidor');
      expect(failure, isA<ServerFailure>());
      final serverFailure = failure as ServerFailure;
      expect(serverFailure.message, 'Error de conexión con el servidor');
    });

    test('NetworkFailure se crea correctamente', () {
      const failure = Failure.networkError();
      expect(failure, isA<NetworkFailure>());
    });

    test('AuthFailure se crea correctamente con código y mensaje', () {
      const failure = Failure.authError(
        code: 'invalid-email',
        message: 'El formato del correo no es válido',
      );
      expect(failure, isA<AuthFailure>());
      final authFailure = failure as AuthFailure;
      expect(authFailure.code, 'invalid-email');
      expect(authFailure.message, 'El formato del correo no es válido');
    });

    test('AuthFailure muestra código por defecto cuando no hay mensaje', () {
      const failure = Failure.authError(code: 'invalid-email');
      expect(failure, isA<AuthFailure>());
      final authFailure = failure as AuthFailure;
      expect(authFailure.code, 'invalid-email');
      expect(authFailure.message, '');
    });

    test('ValidationFailure se crea correctamente con mensaje personalizado', () {
      const failure = Failure.validationError(message: 'Campo requerido');
      expect(failure, isA<ValidationFailure>());
      final validationFailure = failure as ValidationFailure;
      expect(validationFailure.message, 'Campo requerido');
    });

    test('ValidationFailure se crea con mensaje predeterminado', () {
      const failure = Failure.validationError();
      expect(failure, isA<ValidationFailure>());
      final validationFailure = failure as ValidationFailure;
      expect(validationFailure.message, '');
    });

    test('CacheFailure se crea correctamente', () {
      const failure = Failure.cacheError();
      expect(failure, isA<CacheFailure>());
      final cacheFailure = failure as CacheFailure;
      expect(cacheFailure.message, '');
    });

    test('NotFound se crea correctamente con mensaje personalizado', () {
      const failure = Failure.notFound(message: 'No se encontró la academia');
      // Verificamos el mensaje a través del patrón when ya que _NotFoundFailure es privada
      String? capturedMessage;
      failure.when(
        serverError: (_) => null,
        networkError: () => null,
        authError: (_, __) => null,
        validationError: (_) => null,
        cacheError: (_) => null,
        notFound: (message) => capturedMessage = message,
        unexpectedError: (_, __) => null,
      );
      expect(capturedMessage, 'No se encontró la academia');
    });

    test('UnexpectedError se crea correctamente con excepción', () {
      final exception = Exception('Test error');
      final failure = Failure.unexpectedError(error: exception);
      expect(failure, isA<UnexpectedError>());
      final unexpectedError = failure as UnexpectedError;
      expect(unexpectedError.error, exception);
    });

    test('UnexpectedError se crea correctamente sin excepción', () {
      const failure = Failure.unexpectedError();
      expect(failure, isA<UnexpectedError>());
      final unexpectedError = failure as UnexpectedError;
      expect(unexpectedError.error, isNull);
    });
  });
} 