import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/payments/domain/services/enhanced_payment_service.dart';
import 'package:arcinus/features/payments/domain/services/integrated_payment_service.dart';
import 'package:arcinus/features/subscriptions/domain/repositories/period_repository.dart';
import 'package:arcinus/features/subscriptions/domain/services/period_management_service.dart';

void main() {
  group('IntegratedPaymentService - Validaciones', () {
    late IntegratedPaymentService service;
    late FakeEnhancedPaymentService fakeEnhancedPaymentService;
    late FakePeriodRepository fakePeriodRepository;
    late FakePeriodManagementService fakePeriodManagementService;

    setUp(() {
      fakeEnhancedPaymentService = FakeEnhancedPaymentService();
      fakePeriodRepository = FakePeriodRepository();
      fakePeriodManagementService = FakePeriodManagementService();
      
      service = IntegratedPaymentService(
        fakeEnhancedPaymentService,
        fakePeriodRepository,
        fakePeriodManagementService,
      );
    });

    group('Validaciones de pago', () {
      test('debe fallar cuando el monto es cero o negativo', () async {
        // Arrange
        final payment = _createTestPayment(amount: 0.0);
        final plan = _createTestPlan();
        final config = _createTestConfig();

        // Act
        final result = await service.registerCompletePayment(
          payment: payment,
          plan: plan,
          config: config,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('mayor a cero'));
          },
          (success) => fail('Debería fallar'),
        );
      });

      test('debe fallar cuando el número de períodos es inválido', () async {
        // Arrange
        final payment = _createTestPayment();
        final plan = _createTestPlan();
        final config = _createTestConfig();

        // Act
        final result = await service.registerCompletePayment(
          payment: payment,
          plan: plan,
          config: config,
          numberOfPeriods: 0,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('inválido'));
          },
          (success) => fail('Debería fallar'),
        );
      });

      test('debe fallar cuando el monto es insuficiente para los períodos solicitados', () async {
        // Arrange
        final payment = _createTestPayment(amount: 50.0);
        final plan = _createTestPlan(amount: 100.0);
        final config = _createTestConfig();

        // Act
        final result = await service.registerCompletePayment(
          payment: payment,
          plan: plan,
          config: config,
          numberOfPeriods: 2,
          validateBalance: true,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('insuficiente'));
          },
          (success) => fail('Debería fallar'),
        );
      });
    });

    group('Simulación de pagos', () {
      test('debe calcular correctamente los períodos que se pueden pagar', () async {
        // Arrange
        final plan = _createTestPlan(amount: 100.0);
        final config = _createTestConfig();

        // Act
        final result = await service.simulatePayment(
          academyId: 'academy_123',
          athleteId: 'athlete_123',
          plan: plan,
          config: config,
          amount: 250.0,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('No debería fallar'),
          (simulation) {
            expect(simulation.affordablePeriods, 2);
            expect(simulation.requestedPeriods, 2);
            expect(simulation.totalAmount, 200.0);
          },
        );
      });

      test('debe fallar simulación cuando el monto es insuficiente', () async {
        // Arrange
        final plan = _createTestPlan(amount: 100.0);
        final config = _createTestConfig();

        // Act
        final result = await service.simulatePayment(
          academyId: 'academy_123',
          athleteId: 'athlete_123',
          plan: plan,
          config: config,
          amount: 50.0,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('no es suficiente'));
          },
          (success) => fail('Debería fallar'),
        );
      });
    });
  });
}

// Implementaciones fake para testing
class FakeEnhancedPaymentService implements EnhancedPaymentService {
  @override
  Future<Either<Failure, EnhancedPaymentResult>> registerPaymentWithPeriods({
    required PaymentModel payment,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
    int numberOfPeriods = 1,
    DateTime? requestedStartDate,
  }) async {
    return Right(EnhancedPaymentResult(
      payment: payment,
      createdPeriods: [],
      totalRemainingDays: numberOfPeriods * 30,
      message: 'Test payment registered',
    ));
  }

  @override
  int calculateAffordablePeriods(double paymentAmount, double planAmount) {
    return (paymentAmount / planAmount).floor();
  }

  @override
  Future<bool> canMakeMultiplePeriodPayment({
    required String academyId,
    required String athleteId,
    required PaymentConfigModel config,
    required int requestedPeriods,
  }) async {
    return requestedPeriods <= 12;
  }

  @override
  Future<Either<Failure, AthletePeriodsStatus>> getAthletePeriodsSummary(
    String academyId,
    String athleteId,
  ) async {
    return Right(AthletePeriodsStatus(
      allPeriods: [],
      activePeriods: [],
      totalRemainingDays: 0,
    ));
  }
}

class FakePeriodRepository implements PeriodRepository {
  @override
  Future<Either<Failure, SubscriptionAssignmentModel>> createPeriod(
    SubscriptionAssignmentModel period,
  ) async {
    return Right(period);
  }

  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> createMultiplePeriods(
    List<SubscriptionAssignmentModel> periods,
  ) async {
    return Right(periods);
  }

  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAthletesPeriods(
    String academyId,
    String athleteId, {
    SubscriptionAssignmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, SubscriptionAssignmentModel?>> getCurrentPeriod(
    String academyId,
    String athleteId,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getActivePeriods(
    String academyId,
    String athleteId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getUpcomingPeriods(
    String academyId,
    String athleteId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, SubscriptionAssignmentModel>> updatePeriodStatus(
    String academyId,
    String periodId,
    SubscriptionAssignmentStatus newStatus,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SubscriptionAssignmentModel>> updatePeriod(
    String academyId,
    String periodId,
    SubscriptionAssignmentModel updatedPeriod,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> deletePeriod(
    String academyId,
    String periodId,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getPeriodsExpiringInRange(
    String academyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAcademyPeriods(
    String academyId, {
    SubscriptionAssignmentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    return const Right([]);
  }
}

class FakePeriodManagementService implements PeriodManagementService {
  // Implementar solo los métodos necesarios para los tests
  // Los demás pueden lanzar UnimplementedError
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// Helpers para crear objetos de prueba
PaymentModel _createTestPayment({double amount = 100.0}) {
  return PaymentModel(
    id: 'payment_123',
    academyId: 'academy_123',
    athleteId: 'athlete_123',
    subscriptionPlanId: 'plan_123',
    amount: amount,
    currency: 'USD',
    paymentDate: DateTime.now(),
    registeredBy: 'test_user',
    createdAt: DateTime.now(),
  );
}

SubscriptionPlanModel _createTestPlan({double amount = 100.0}) {
  return SubscriptionPlanModel(
    id: 'plan_123',
    name: 'Plan Mensual',
    amount: amount,
    currency: 'USD',
    billingCycle: BillingCycle.monthly,
    createdAt: DateTime.now(),
  );
}

PaymentConfigModel _createTestConfig() {
  return PaymentConfigModel(
    id: 'config_123',
    academyId: 'academy_123',
    billingMode: BillingMode.advance,
    createdAt: DateTime.now(),
  );
} 