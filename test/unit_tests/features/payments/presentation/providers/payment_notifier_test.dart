import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_state.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/payments/domain/repositories/payment_repository.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

// Mock para el repositorio de pagos
class MockPaymentRepository extends Mock implements PaymentRepository {}

// Datos de prueba
final testAcademy = AcademyModel(
  id: 'academy-id-1',
  name: 'Academia Test',
  ownerId: 'owner-id-1',
  sportCode: 'FUTBOL',
  createdAt: DateTime.now(),
);

final testUser = User(
  id: 'user-id-1', 
  email: 'test@example.com',
);

void main() {
  late MockPaymentRepository paymentRepository;
  late ProviderContainer container;

  setUp(() {
    paymentRepository = MockPaymentRepository();

    // Crear un contenedor de proveedores con overrides para pruebas
    container = ProviderContainer(
      overrides: [
        // Override para el repositorio de pagos
        paymentRepositoryProvider.overrideWithValue(paymentRepository),
      ],
    );

    // Configurar academia actual y usuario autenticado
    container.read(currentAcademyProvider.notifier).state = testAcademy;
    container.read(authStateNotifierProvider.notifier).state = 
        AuthState.authenticated(user: testUser);

    // Registrar fallback values para parámetros que no coincidan exactamente
    registerFallbackValue(PaymentModel(
      academyId: 'academy-id-1',
      athleteId: 'athlete-id-1',
      amount: 100.0,
      currency: 'USD',
      paymentDate: DateTime.now(),
      registeredBy: 'user-id-1',
      createdAt: DateTime.now(),
    ));
  });

  tearDown(() {
    container.dispose();
  });

  group('AcademyPaymentsNotifier', () {
    test('build() debería obtener los pagos desde el repositorio', () async {
      // Arrange: Configurar el mock para devolver una lista de pagos
      final payments = [
        PaymentModel(
          id: 'payment-id-1',
          academyId: 'academy-id-1',
          athleteId: 'athlete-id-1',
          amount: 100.0,
          currency: 'USD',
          concept: 'Mensualidad',
          paymentDate: DateTime(2023, 5, 15),
          registeredBy: 'user-id-1',
          createdAt: DateTime(2023, 5, 15),
        ),
        PaymentModel(
          id: 'payment-id-2',
          academyId: 'academy-id-1',
          athleteId: 'athlete-id-2',
          amount: 150.0,
          currency: 'USD',
          concept: 'Clase extra',
          paymentDate: DateTime(2023, 5, 10),
          registeredBy: 'user-id-1',
          createdAt: DateTime(2023, 5, 10),
        ),
      ];

      when(() => paymentRepository.getPaymentsByAcademy('academy-id-1'))
          .thenAnswer((_) async => right(payments));

      // Act: Ejecutar el provider
      final result = await container.read(academyPaymentsNotifierProvider.future);

      // Assert: Verificar que se devuelvan los pagos correctos
      expect(result, equals(payments));
      verify(() => paymentRepository.getPaymentsByAcademy('academy-id-1')).called(1);
    });

    test('build() debería lanzar un error cuando no hay academia actual', () async {
      // Arrange: Crear un container sin academia actual
      final containerWithoutAcademy = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(paymentRepository),
        ],
      );

      // Act & Assert: Verificar que se lance un error
      expect(
        () => containerWithoutAcademy.read(academyPaymentsNotifierProvider.future),
        throwsA(isA<Failure>()),
      );

      // Cleanup
      containerWithoutAcademy.dispose();
    });

    test('registerPayment() debería registrar un pago correctamente', () async {
      // Arrange: Configurar el mock para registrar un pago
      final payment = PaymentModel(
        academyId: 'academy-id-1',
        athleteId: 'athlete-id-1',
        amount: 100.0,
        currency: 'USD',
        concept: 'Mensualidad',
        paymentDate: DateTime(2023, 5, 15),
        registeredBy: 'user-id-1',
        createdAt: DateTime(2023, 5, 15),
      );

      final registeredPayment = payment.copyWith(id: 'payment-id-1');

      when(() => paymentRepository.registerPayment(any()))
          .thenAnswer((_) async => right(registeredPayment));

      // No hay pagos disponibles inicialmente
      when(() => paymentRepository.getPaymentsByAcademy('academy-id-1'))
          .thenAnswer((_) async => right([]));

      // Act: Registrar un pago
      await container.read(academyPaymentsNotifierProvider.notifier).registerPayment(
        athleteId: 'athlete-id-1',
        amount: 100.0,
        currency: 'USD',
        paymentDate: DateTime(2023, 5, 15),
        concept: 'Mensualidad',
      );

      // Assert: Verificar que se llamó al repositorio para registrar el pago
      verify(() => paymentRepository.registerPayment(any())).called(1);
    });

    test('registerPayment() debería lanzar un error cuando falla el registro', () async {
      // Arrange: Configurar el mock para fallar al registrar un pago
      when(() => paymentRepository.registerPayment(any()))
          .thenAnswer((_) async => left(const Failure.serverError(message: 'Error al registrar el pago')));

      // No hay pagos disponibles inicialmente
      when(() => paymentRepository.getPaymentsByAcademy('academy-id-1'))
          .thenAnswer((_) async => right([]));

      // Act & Assert: Verificar que se lance un error
      expect(
        () => container.read(academyPaymentsNotifierProvider.notifier).registerPayment(
          athleteId: 'athlete-id-1',
          amount: 100.0,
          currency: 'USD',
          paymentDate: DateTime(2023, 5, 15),
          concept: 'Mensualidad',
        ),
        throwsA(isA<Failure>()),
      );

      verify(() => paymentRepository.registerPayment(any())).called(1);
    });

    test('deletePayment() debería eliminar un pago correctamente', () async {
      // Arrange: Configurar el mock para eliminar un pago
      when(() => paymentRepository.deletePayment('academy-id-1', 'payment-id-1'))
          .thenAnswer((_) async => right(unit));

      // No hay pagos disponibles inicialmente
      when(() => paymentRepository.getPaymentsByAcademy('academy-id-1'))
          .thenAnswer((_) async => right([]));

      // Act: Eliminar un pago
      await container.read(academyPaymentsNotifierProvider.notifier).deletePayment('payment-id-1');

      // Assert: Verificar que se llamó al repositorio para eliminar el pago
      verify(() => paymentRepository.deletePayment('academy-id-1', 'payment-id-1')).called(1);
    });

    test('deletePayment() debería lanzar un error cuando falla la eliminación', () async {
      // Arrange: Configurar el mock para fallar al eliminar un pago
      when(() => paymentRepository.deletePayment('academy-id-1', 'payment-id-1'))
          .thenAnswer((_) async => left(const Failure.serverError(message: 'Error al eliminar el pago')));

      // No hay pagos disponibles inicialmente
      when(() => paymentRepository.getPaymentsByAcademy('academy-id-1'))
          .thenAnswer((_) async => right([]));

      // Act & Assert: Verificar que se lance un error
      expect(
        () => container.read(academyPaymentsNotifierProvider.notifier).deletePayment('payment-id-1'),
        throwsA(isA<Failure>()),
      );

      verify(() => paymentRepository.deletePayment('academy-id-1', 'payment-id-1')).called(1);
    });
  });

  group('AthletePaymentsNotifier', () {
    test('build() debería obtener los pagos de un atleta', () async {
      // Arrange: Configurar el mock para devolver una lista de pagos de un atleta
      final payments = [
        PaymentModel(
          id: 'payment-id-1',
          academyId: 'academy-id-1',
          athleteId: 'athlete-id-1',
          amount: 100.0,
          currency: 'USD',
          concept: 'Mensualidad',
          paymentDate: DateTime(2023, 5, 15),
          registeredBy: 'user-id-1',
          createdAt: DateTime(2023, 5, 15),
        ),
        PaymentModel(
          id: 'payment-id-3',
          academyId: 'academy-id-1',
          athleteId: 'athlete-id-1',
          amount: 120.0,
          currency: 'USD',
          concept: 'Clase privada',
          paymentDate: DateTime(2023, 4, 15),
          registeredBy: 'user-id-1',
          createdAt: DateTime(2023, 4, 15),
        ),
      ];

      when(() => paymentRepository.getPaymentsByAthlete('academy-id-1', 'athlete-id-1'))
          .thenAnswer((_) async => right(payments));

      // Act: Ejecutar el provider
      final result = await container.read(athletePaymentsNotifierProvider('athlete-id-1').future);

      // Assert: Verificar que se devuelvan los pagos correctos
      expect(result, equals(payments));
      verify(() => paymentRepository.getPaymentsByAthlete('academy-id-1', 'athlete-id-1')).called(1);
    });

    test('build() debería lanzar un error cuando no hay academia actual', () async {
      // Arrange: Crear un container sin academia actual y configurar el container
      final containerWithoutAcademy = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(paymentRepository),
        ],
      );

      // Act & Assert: Verificar que se lance un error
      expect(
        () => containerWithoutAcademy.read(athletePaymentsNotifierProvider('athlete-id-1').future),
        throwsA(isA<Failure>()),
      );

      // Cleanup
      containerWithoutAcademy.dispose();
    });
  });

  group('AcademyPaymentsNotifier (Registro de pagos)', () {
    test('registerPayment() debería actualizar el estado correctamente en caso de éxito', () async {
      // Arrange: Configurar el mock para registrar un pago con éxito
      final registeredPayment = PaymentModel(
        id: 'payment-id-1',
        academyId: 'academy-id-1',
        athleteId: 'athlete-id-1',
        amount: 100.0,
        currency: 'USD',
        paymentDate: DateTime(2023, 5, 15),
        registeredBy: 'user-id-1',
        createdAt: DateTime(2023, 5, 15),
      );

      when(() => paymentRepository.registerPayment(any()))
          .thenAnswer((_) async => right(registeredPayment));

      when(() => paymentRepository.getPaymentsByAcademy('academy-id-1'))
          .thenAnswer((_) async => right([registeredPayment]));

      // Act: Enviar un formulario de pago
      await container.read(academyPaymentsNotifierProvider.notifier).registerPayment(
        athleteId: 'athlete-id-1',
        amount: 100.0,
        currency: 'USD',
        paymentDate: DateTime(2023, 5, 15),
      );

      // Assert: Verificar que el pago se registró correctamente
      final payments = await container.read(academyPaymentsNotifierProvider.future);
      expect(payments, contains(registeredPayment));
    });

    test('registerPayment() debería lanzar un error en caso de falla', () async {
      // Arrange: Configurar el mock para fallar al registrar un pago
      final failure = Failure.serverError(message: 'Error al registrar el pago');
      
      when(() => paymentRepository.registerPayment(any()))
          .thenAnswer((_) async => left(failure));

      when(() => paymentRepository.getPaymentsByAcademy('academy-id-1'))
          .thenAnswer((_) async => right([]));

      // Act & Assert: Verificar que se lance un error
      expect(
        () => container.read(academyPaymentsNotifierProvider.notifier).registerPayment(
          athleteId: 'athlete-id-1',
          amount: 100.0,
          currency: 'USD',
          paymentDate: DateTime(2023, 5, 15),
        ),
        throwsA(isA<Failure>()),
      );
    });
  });
} 