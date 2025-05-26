import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';

void main() {
  group('SubscriptionAssignmentModel', () {
    late DateTime paymentDate;
    late DateTime startDate;
    late DateTime endDate;
    
    setUp(() {
      paymentDate = DateTime(2024, 1, 15);
      startDate = DateTime(2024, 2, 1);
      endDate = DateTime(2024, 3, 1);
    });

    group('Paso 1 - Validaciones básicas', () {
      test('debe crear una suscripción con paymentDate != startDate sin error', () {
        // Arrange & Act
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: startDate,
          endDate: endDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Assert
        expect(assignment.paymentDate, equals(paymentDate));
        expect(assignment.startDate, equals(startDate));
        expect(assignment.endDate, equals(endDate));
        expect(assignment.paymentDate, isNot(equals(assignment.startDate)));
      });

      test('debe calcular daysRemaining correctamente', () {
        // Arrange
        final futureEndDate = DateTime.now().add(const Duration(days: 15));
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: startDate,
          endDate: futureEndDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act
        final daysRemaining = assignment.daysRemaining;

        // Assert
        expect(daysRemaining, greaterThanOrEqualTo(14));
        expect(daysRemaining, lessThanOrEqualTo(15));
      });

      test('debe retornar 0 días restantes si endDate está en el pasado', () {
        // Arrange
        final pastEndDate = DateTime.now().subtract(const Duration(days: 5));
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: startDate,
          endDate: pastEndDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act
        final daysRemaining = assignment.daysRemaining;

        // Assert
        expect(daysRemaining, equals(0));
      });
    });

    group('Propiedades computadas', () {
      test('debe identificar correctamente si es prepago', () {
        // Arrange
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate, // 15 de enero
          startDate: startDate, // 1 de febrero
          endDate: endDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(assignment.isPrepaid, isTrue);
        expect(assignment.isPostpaid, isFalse);
      });

      test('debe identificar correctamente si es postpago', () {
        // Arrange
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: DateTime(2024, 3, 15), // 15 de marzo
          startDate: startDate, // 1 de febrero
          endDate: endDate, // 1 de marzo
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(assignment.isPostpaid, isTrue);
        expect(assignment.isPrepaid, isFalse);
      });

      test('debe calcular correctamente la duración total en días', () {
        // Arrange
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: startDate, // 1 de febrero
          endDate: endDate, // 1 de marzo
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act
        final totalDays = assignment.totalDurationDays;

        // Assert
        expect(totalDays, equals(29)); // Febrero tiene 29 días en 2024 (año bisiesto)
      });

      test('debe formatear correctamente el período', () {
        // Arrange
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 3, 1),
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act
        final formattedPeriod = assignment.formattedPeriod;

        // Assert
        expect(formattedPeriod, equals('1/2/2024 - 1/3/2024'));
      });

      test('debe identificar correctamente si está próximo a vencer', () {
        // Arrange
        final nearExpiryDate = DateTime.now().add(const Duration(days: 5));
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: startDate,
          endDate: nearExpiryDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(assignment.isNearExpiry, isTrue);
        expect(assignment.isExpired, isFalse);
      });
    });

    group('Estados de asignación', () {
      test('debe tener estado activo por defecto', () {
        // Arrange & Act
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: startDate,
          endDate: endDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Assert
        expect(assignment.status, equals(SubscriptionAssignmentStatus.active));
        expect(assignment.isActive, isTrue);
      });

      test('debe serializar y deserializar correctamente desde JSON', () {
        // Arrange
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: startDate,
          endDate: endDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
          status: SubscriptionAssignmentStatus.paused,
        );

        // Act
        final json = assignment.toJson();
        final fromJson = SubscriptionAssignmentModel.fromJson(json);

        // Assert
        expect(fromJson.academyId, equals(assignment.academyId));
        expect(fromJson.athleteId, equals(assignment.athleteId));
        expect(fromJson.subscriptionPlanId, equals(assignment.subscriptionPlanId));
        expect(fromJson.paymentDate, equals(assignment.paymentDate));
        expect(fromJson.startDate, equals(assignment.startDate));
        expect(fromJson.endDate, equals(assignment.endDate));
        expect(fromJson.status, equals(assignment.status));
        expect(fromJson.amountPaid, equals(assignment.amountPaid));
        expect(fromJson.currency, equals(assignment.currency));
      });
    });

    group('Cálculo de progreso', () {
      test('debe calcular 0% de progreso si no ha comenzado', () {
        // Arrange
        final futureStartDate = DateTime.now().add(const Duration(days: 10));
        final futureEndDate = DateTime.now().add(const Duration(days: 40));
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: futureStartDate,
          endDate: futureEndDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act
        final progress = assignment.progressPercentage;

        // Assert
        expect(progress, equals(0.0));
      });

      test('debe calcular 100% de progreso si ya terminó', () {
        // Arrange
        final pastStartDate = DateTime.now().subtract(const Duration(days: 40));
        final pastEndDate = DateTime.now().subtract(const Duration(days: 10));
        final assignment = SubscriptionAssignmentModel(
          academyId: 'academy123',
          athleteId: 'athlete456',
          subscriptionPlanId: 'plan789',
          paymentDate: paymentDate,
          startDate: pastStartDate,
          endDate: pastEndDate,
          amountPaid: 100.0,
          currency: 'COP',
          createdBy: 'user123',
          createdAt: DateTime.now(),
        );

        // Act
        final progress = assignment.progressPercentage;

        // Assert
        expect(progress, equals(100.0));
      });
    });
  });
} 