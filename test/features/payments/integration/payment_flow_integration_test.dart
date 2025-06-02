import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart' as client_user;
import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/payments/domain/services/subscription_billing_service.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';

void main() {
  group('Payment Flow Integration Tests', () {
    late SubscriptionBillingService billingService;
    late PaymentConfigModel defaultConfig;
    late SubscriptionPlanModel testPlan;
    late client_user.SubscriptionPlanModel clientTestPlan;

    setUp(() {
      billingService = SubscriptionBillingService();
      
      // Configuración por defecto
      defaultConfig = PaymentConfigModel(
        id: 'test-config',
        academyId: 'test-academy',
        billingMode: BillingMode.advance,
        allowPartialPayments: true,
        gracePeriodDays: 5,
        earlyPaymentDiscount: true,
        earlyPaymentDiscountPercent: 10.0,
        earlyPaymentDays: 7,
        lateFeeEnabled: true,
        lateFeePercent: 5.0,
        autoRenewal: false,
        allowManualStartDateInPrepaid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Plan de prueba estándar
      testPlan = SubscriptionPlanModel(
        name: 'Plan Mensual',
        amount: 100.0,
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Plan de cliente de prueba
      clientTestPlan = SubscriptionPlanModel(
        id: 'client-test-plan',
        name: 'Plan Cliente Mensual',
        amount: 100.0,
        currency: 'USD',
        billingCycle: client_user.BillingCycle.monthly, 
        createdAt: DateTime.now(),
      );
    });

    group('Flujo Completo - Modo Prepago', () {
      test('Debe completar flujo completo de asignación y pago en modo prepago', () {
        // Arrange
        final paymentDate = DateTime(2024, 1, 15);
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: false,
        );

        // Act - Paso 1: Calcular fechas de facturación
        final billingCalculation = billingService.calculateBillingDates(
          paymentDate: paymentDate,
          plan: testPlan,
          config: config,
        );

        // Assert - Validar cálculo de fechas
        expect(billingCalculation.isValidConfiguration, isTrue);
        expect(billingCalculation.startDate, equals(paymentDate));
        expect(billingCalculation.endDate, equals(paymentDate.add(Duration(days: 30))));

        // Act - Paso 2: Crear asignación de suscripción
        final assignment = SubscriptionAssignmentModel(
          academyId: 'test-academy',
          athleteId: 'test-user',
          subscriptionPlanId: 'test-plan',
          paymentDate: paymentDate,
          startDate: billingCalculation.startDate,
          endDate: billingCalculation.endDate,
          status: SubscriptionAssignmentStatus.active,
          amountPaid: testPlan.amount,
          currency: testPlan.currency,
          createdBy: 'test-admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert - Validar asignación
        expect(assignment.paymentDate, equals(paymentDate));
        expect(assignment.startDate, equals(paymentDate));
        expect(assignment.endDate, equals(paymentDate.add(Duration(days: 30))));
        expect(assignment.status, equals(SubscriptionAssignmentStatus.active));

        // Act - Paso 3: Consultar días restantes
        final remainingDays = billingService.calculateRemainingDays(
          paymentDate.add(Duration(days: 10)), // 10 días después del pago
          assignment.endDate,
        );

        // Assert - Validar días restantes
        expect(remainingDays, equals(20)); // 30 - 10 = 20 días restantes

        // Act - Paso 4: Simular renovación
        final renewalPaymentDate = assignment.endDate.add(Duration(days: 2)); // Pago 2 días tarde
        final renewalCalculation = billingService.calculateBillingDates(
          paymentDate: renewalPaymentDate,
          plan: testPlan,
          config: config,
        );

        // Assert - Validar renovación
        expect(renewalCalculation.isValidConfiguration, isTrue);
        expect(renewalCalculation.startDate, equals(renewalPaymentDate));
        expect(renewalCalculation.endDate, equals(renewalPaymentDate.add(Duration(days: 30))));

        // Act - Paso 5: Validar período de gracia
        expect(
          () => billingService.validateGracePeriod(
            assignment.endDate,
            renewalPaymentDate,
            config,
          ),
          returnsNormally, // Debe pasar porque está dentro del período de gracia (5 días)
        );
      });

      test('Debe permitir fecha de inicio manual cuando está habilitado', () {
        // Arrange
        final paymentDate = DateTime(2024, 1, 15);
        final requestedStartDate = DateTime(2024, 1, 20); // 5 días después
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: true,
        );

        // Act
        final billingCalculation = billingService.calculateBillingDates(
          paymentDate: paymentDate,
          requestedStartDate: requestedStartDate,
          plan: testPlan,
          config: config,
        );

        // Assert
        expect(billingCalculation.isValidConfiguration, isTrue);
        expect(billingCalculation.startDate, equals(requestedStartDate));
        expect(billingCalculation.endDate, equals(requestedStartDate.add(Duration(days: 30))));
      });

      test('Debe rechazar fecha de inicio manual cuando está deshabilitado', () {
        // Arrange
        final paymentDate = DateTime(2024, 1, 15);
        final requestedStartDate = DateTime(2024, 1, 20);
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: false,
        );

        // Act
        final billingCalculation = billingService.calculateBillingDates(
          paymentDate: paymentDate,
          requestedStartDate: requestedStartDate,
          plan: testPlan,
          config: config,
        );

        // Assert
        expect(billingCalculation.isValidConfiguration, isFalse);
        expect(billingCalculation.validationMessage, contains('No se permite seleccionar fecha de inicio'));
      });
    });

    group('Flujo Completo - Modo Mes en Curso', () {
      test('Debe completar flujo completo en modo mes en curso', () {
        // Arrange
        final paymentDate = DateTime(2024, 1, 15);
        final config = defaultConfig.copyWith(billingMode: BillingMode.current);

        // Act - Calcular fechas
        final billingCalculation = billingService.calculateBillingDates(
          paymentDate: paymentDate,
          plan: testPlan,
          config: config,
        );

        // Assert
        expect(billingCalculation.isValidConfiguration, isTrue);
        expect(billingCalculation.startDate, equals(paymentDate));
        expect(billingCalculation.endDate, equals(paymentDate.add(Duration(days: 30))));

        // Act - Crear asignación
        final assignment = SubscriptionAssignmentModel(
          academyId: 'test-academy',
          athleteId: 'test-user',
          subscriptionPlanId: 'test-plan',
          paymentDate: paymentDate,
          startDate: billingCalculation.startDate,
          endDate: billingCalculation.endDate,
          status: SubscriptionAssignmentStatus.active,
          amountPaid: testPlan.amount,
          currency: testPlan.currency,
          createdBy: 'test-admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert - Validar que el servicio ya está activo
        expect(assignment.startDate, equals(paymentDate));
        expect(assignment.isActive, isTrue);
      });
    });

    group('Flujo Completo - Modo Mes Vencido', () {
      test('Debe completar flujo completo en modo mes vencido', () {
        // Arrange
        final now = DateTime.now();
        final paymentDate = now; // Pago hoy
        final config = defaultConfig.copyWith(billingMode: BillingMode.arrears);

        // Act - Calcular fechas
        final billingCalculation = billingService.calculateBillingDates(
          paymentDate: paymentDate,
          plan: testPlan,
          config: config,
        );

        // Assert - En mes vencido, se paga por período ya consumido
        expect(billingCalculation.isValidConfiguration, isTrue);
        expect(billingCalculation.endDate, equals(paymentDate));
        expect(billingCalculation.startDate, equals(paymentDate.subtract(Duration(days: 30))));

        // Act - Crear asignación
        final assignment = SubscriptionAssignmentModel(
          academyId: 'test-academy',
          athleteId: 'test-user',
          subscriptionPlanId: 'test-plan',
          paymentDate: paymentDate,
          startDate: billingCalculation.startDate,
          endDate: billingCalculation.endDate,
          status: SubscriptionAssignmentStatus.active,
          amountPaid: testPlan.amount,
          currency: testPlan.currency,
          createdBy: 'test-admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert - Validar características del pago postpago
        // En modo mes vencido: paymentDate = endDate, startDate = endDate - 30 días
        // Por lo tanto: paymentDate NO es antes de startDate (isPrepaid = false)
        // Y paymentDate NO es después de endDate (isPostpaid = false)
        expect(assignment.isPostpaid, isFalse); // El pago es exactamente en la fecha de fin
        expect(assignment.isPrepaid, isFalse); // El pago NO es antes de la fecha de inicio
        
        // En modo mes vencido, el período ya terminó cuando se paga
        expect(billingCalculation.endDate.isAtSameMomentAs(paymentDate), isTrue);
      });
    });

    group('Validaciones de Período de Gracia', () {
      test('Debe aceptar pago dentro del período de gracia', () {
        // Arrange
        final dueDate = DateTime(2024, 1, 15);
        final paymentDate = DateTime(2024, 1, 18); // 3 días tarde
        final config = defaultConfig.copyWith(gracePeriodDays: 5);

        // Act & Assert
        expect(
          () => billingService.validateGracePeriod(dueDate, paymentDate, config),
          returnsNormally,
        );

        expect(
          billingService.isPaymentWithinGrace(dueDate, paymentDate, config.gracePeriodDays),
          isTrue,
        );
      });

      test('Debe rechazar pago fuera del período de gracia', () {
        // Arrange
        final dueDate = DateTime(2024, 1, 15);
        final paymentDate = DateTime(2024, 1, 22); // 7 días tarde
        final config = defaultConfig.copyWith(gracePeriodDays: 5);

        // Act & Assert
        expect(
          () => billingService.validateGracePeriod(dueDate, paymentDate, config),
          throwsA(isA<BillingValidationException>()),
        );

        expect(
          billingService.isPaymentWithinGrace(dueDate, paymentDate, config.gracePeriodDays),
          isFalse,
        );
      });
    });

    group('Cálculos de Descuentos y Recargos', () {
      test('Debe calcular descuento por pronto pago correctamente', () {
        // Arrange
        final dueDate = DateTime(2024, 1, 15);
        final paymentDate = DateTime(2024, 1, 5); // 10 días antes
        final amount = 100.0;
        final config = defaultConfig.copyWith(
          earlyPaymentDiscount: true,
          earlyPaymentDays: 7,
          earlyPaymentDiscountPercent: 10.0,
        );

        // Act
        final discount = billingService.calculateEarlyPaymentDiscount(
          paymentDate,
          dueDate,
          amount,
          config,
        );

        // Assert
        expect(discount, equals(10.0)); // 10% de 100 = 10
      });

      test('Debe calcular recargo por pago tardío correctamente', () {
        // Arrange
        final dueDate = DateTime(2024, 1, 15);
        final paymentDate = DateTime(2024, 1, 20); // 5 días tarde
        final amount = 100.0;
        final config = defaultConfig.copyWith(
          lateFeeEnabled: true,
          lateFeePercent: 5.0,
        );

        // Act
        final lateFee = billingService.calculateLateFee(
          paymentDate,
          dueDate,
          amount,
          config,
        );

        // Assert
        expect(lateFee, equals(5.0)); // 5% de 100 = 5
      });
    });

    group('Flujos con ClientUserModel', () {
      test('Debe manejar correctamente planes de ClientUserModel', () {
        // Arrange
        final paymentDate = DateTime(2024, 1, 15);
        final config = defaultConfig.copyWith(billingMode: BillingMode.advance);

        // Act
        final billingCalculation = billingService.calculateBillingDatesFromClientPlan(
          paymentDate: paymentDate,
          plan: clientTestPlan,
          config: config,
        );

        // Assert
        expect(billingCalculation.isValidConfiguration, isTrue);
        expect(billingCalculation.startDate, equals(paymentDate));
        expect(billingCalculation.endDate, equals(paymentDate.add(Duration(days: 30))));

        // Act - Calcular fecha de fin directamente
        final endDate = billingService.calculateEndDateFromClientPlan(paymentDate, clientTestPlan);

        // Assert
        expect(endDate, equals(paymentDate.add(Duration(days: 30))));
      });

      test('Debe manejar diferentes ciclos de facturación', () {
        // Arrange
        final paymentDate = DateTime(2024, 1, 15);
        final config = defaultConfig.copyWith(billingMode: BillingMode.advance);

        final quarterlyPlan = clientTestPlan.copyWith(
          billingCycle: client_user.BillingCycle.quarterly,
        );

        // Act
        final billingCalculation = billingService.calculateBillingDatesFromClientPlan(
          paymentDate: paymentDate,
          plan: quarterlyPlan,
          config: config,
        );

        // Assert
        expect(billingCalculation.isValidConfiguration, isTrue);
        expect(billingCalculation.endDate, equals(paymentDate.add(Duration(days: 90))));
      });
    });

    group('Escenarios de Renovación', () {
      test('Debe manejar renovación automática correctamente', () {
        // Arrange
        final originalPaymentDate = DateTime(2024, 1, 15);
        final originalEndDate = originalPaymentDate.add(Duration(days: 30));
        final renewalPaymentDate = originalEndDate.subtract(Duration(days: 2)); // Renovación anticipada

        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          autoRenewal: true,
        );

        // Act - Primera suscripción
        final originalCalculation = billingService.calculateBillingDates(
          paymentDate: originalPaymentDate,
          plan: testPlan,
          config: config,
        );

        // Act - Renovación
        final renewalCalculation = billingService.calculateBillingDates(
          paymentDate: renewalPaymentDate,
          plan: testPlan,
          config: config,
        );

        // Assert
        expect(originalCalculation.isValidConfiguration, isTrue);
        expect(renewalCalculation.isValidConfiguration, isTrue);
        
        // La renovación debe comenzar desde la fecha de pago de renovación
        expect(renewalCalculation.startDate, equals(renewalPaymentDate));
        expect(renewalCalculation.endDate, equals(renewalPaymentDate.add(Duration(days: 30))));
      });
    });

    group('Validaciones de Fechas Retroactivas', () {
      test('Debe rechazar fecha de inicio anterior al pago en prepago', () {
        // Arrange
        final paymentDate = DateTime(2024, 1, 15);
        final retroactiveStartDate = DateTime(2024, 1, 10); // 5 días antes del pago
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: true,
        );

        // Act
        final billingCalculation = billingService.calculateBillingDates(
          paymentDate: paymentDate,
          requestedStartDate: retroactiveStartDate,
          plan: testPlan,
          config: config,
        );

        // Assert
        expect(billingCalculation.isValidConfiguration, isFalse);
        expect(billingCalculation.validationMessage, contains('no puede ser anterior a la fecha de pago'));
      });
    });
  });
} 