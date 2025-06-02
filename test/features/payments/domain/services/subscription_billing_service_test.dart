import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart' as client_user;
import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/features/payments/domain/services/subscription_billing_service.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';

void main() {
  group('SubscriptionBillingService', () {
    late SubscriptionBillingService service;
    late PaymentConfigModel defaultConfig;
    late SubscriptionPlanModel testPlan;
    late client_user.SubscriptionPlanModel clientTestPlan;

    setUp(() {
      service = SubscriptionBillingService();
      
      defaultConfig = PaymentConfigModel.defaultConfig(academyId: 'test-academy');
      
      testPlan = SubscriptionPlanModel(
        name: 'Plan Mensual',
        amount: 100.0,
        currency: 'COP',
        billingCycle: BillingCycle.monthly,
        createdAt: DateTime.now(),
      );
      
      clientTestPlan = client_user.SubscriptionPlanModel(
        name: 'Plan Mensual Cliente',
        amount: 100.0,
        currency: 'COP',
        billingCycle: client_user.BillingCycle.monthly, 
        createdAt: DateTime.now(),
      );
    });

    group('Paso 3: Adaptar Lógica de Asignación de Plan', () {
      test('debe calcular fecha de fin correctamente para plan estándar', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = service.calculateEndDate(startDate, testPlan);
        
        expect(endDate, equals(DateTime(2024, 1, 31))); // 30 días después
      });
      
      test('debe calcular fecha de fin correctamente para plan de cliente', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = service.calculateEndDateFromClientPlan(startDate, clientTestPlan);
        
        expect(endDate, equals(DateTime(2024, 1, 31))); // 30 días después
      });

      test('debe permitir fecha de inicio manual en prepago cuando está habilitado', () {
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: true,
        );
        
        final paymentDate = DateTime(2024, 1, 1);
        final requestedStartDate = DateTime(2024, 1, 15);
        
        final calculation = service.calculateBillingDatesFromClientPlan(
          paymentDate: paymentDate,
          requestedStartDate: requestedStartDate,
          plan: clientTestPlan,
          config: config,
        );
        
        expect(calculation.isValidConfiguration, isTrue);
        expect(calculation.startDate, equals(requestedStartDate));
        expect(calculation.endDate, equals(DateTime(2024, 2, 14))); // 30 días después del inicio
      });

      test('debe rechazar fecha de inicio manual en prepago cuando está deshabilitado', () {
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: false,
        );
        
        final paymentDate = DateTime(2024, 1, 1);
        final requestedStartDate = DateTime(2024, 1, 15);
        
        final calculation = service.calculateBillingDatesFromClientPlan(
          paymentDate: paymentDate,
          requestedStartDate: requestedStartDate,
          plan: clientTestPlan,
          config: config,
        );
        
        expect(calculation.isValidConfiguration, isFalse);
        expect(calculation.validationMessage, contains('No se permite seleccionar fecha de inicio'));
      });

      test('debe calcular fechas correctamente para mes en curso', () {
        final config = defaultConfig.copyWith(billingMode: BillingMode.current);
        final paymentDate = DateTime(2024, 1, 15);
        
        final calculation = service.calculateBillingDatesFromClientPlan(
          paymentDate: paymentDate,
          plan: clientTestPlan,
          config: config,
        );
        
        expect(calculation.isValidConfiguration, isTrue);
        expect(calculation.startDate, equals(paymentDate));
        expect(calculation.endDate, equals(DateTime(2024, 2, 14))); // 30 días después
      });

      test('debe calcular fechas correctamente para mes vencido', () {
        final config = defaultConfig.copyWith(billingMode: BillingMode.arrears);
        final paymentDate = DateTime(2024, 1, 31);
        
        final calculation = service.calculateBillingDatesFromClientPlan(
          paymentDate: paymentDate,
          plan: clientTestPlan,
          config: config,
        );
        
        expect(calculation.isValidConfiguration, isTrue);
        expect(calculation.endDate, equals(paymentDate));
        expect(calculation.startDate, equals(DateTime(2024, 1, 1))); // 30 días antes
      });
    });

    group('Paso 4: Validaciones de Negocio por Política de Facturación', () {
      test('debe validar fecha de inicio en modo prepago', () {
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: true,
        );
        
        final paymentDate = DateTime(2024, 1, 1);
        final validStartDate = DateTime(2024, 1, 15);
        final invalidStartDate = DateTime(2023, 12, 31); // Anterior al pago
        
        expect(
          service.isValidStartDate(validStartDate, paymentDate, config, BillingMode.advance),
          isTrue,
        );
        
        expect(
          service.isValidStartDate(invalidStartDate, paymentDate, config, BillingMode.advance),
          isFalse,
        );
      });

      test('debe validar período de gracia correctamente', () {
        final config = defaultConfig.copyWith(gracePeriodDays: 5);
        final dueDate = DateTime(2024, 1, 31);
        
        // Pago dentro del período de gracia
        final validPaymentDate = DateTime(2024, 2, 3); // 3 días después
        expect(
          service.isPaymentWithinGrace(dueDate, validPaymentDate, config.gracePeriodDays),
          isTrue,
        );
        
        // Pago fuera del período de gracia
        final invalidPaymentDate = DateTime(2024, 2, 10); // 10 días después
        expect(
          service.isPaymentWithinGrace(dueDate, invalidPaymentDate, config.gracePeriodDays),
          isFalse,
        );
        
        // Validación con excepción
        expect(
          () => service.validateGracePeriod(dueDate, invalidPaymentDate, config),
          throwsA(isA<BillingValidationException>()),
        );
      });

      test('debe calcular descuento por pronto pago correctamente', () {
        final config = defaultConfig.copyWith(
          earlyPaymentDiscount: true,
          earlyPaymentDiscountPercent: 10.0,
          earlyPaymentDays: 5,
        );
        
        final dueDate = DateTime(2024, 1, 31);
        final amount = 100.0;
        
        // Pago con descuento (7 días antes)
        final earlyPaymentDate = DateTime(2024, 1, 24);
        final discount = service.calculateEarlyPaymentDiscount(
          earlyPaymentDate,
          dueDate,
          amount,
          config,
        );
        expect(discount, equals(10.0)); // 10% de 100
        
        // Pago sin descuento (2 días antes, menos que el mínimo)
        final latePaymentDate = DateTime(2024, 1, 29);
        final noDiscount = service.calculateEarlyPaymentDiscount(
          latePaymentDate,
          dueDate,
          amount,
          config,
        );
        expect(noDiscount, equals(0.0));
      });

      test('debe calcular recargo por pago tardío correctamente', () {
        final config = defaultConfig.copyWith(
          lateFeeEnabled: true,
          lateFeePercent: 5.0,
        );
        
        final dueDate = DateTime(2024, 1, 31);
        final amount = 100.0;
        
        // Pago tardío
        final latePaymentDate = DateTime(2024, 2, 5);
        final lateFee = service.calculateLateFee(
          latePaymentDate,
          dueDate,
          amount,
          config,
        );
        expect(lateFee, equals(5.0)); // 5% de 100
        
        // Pago a tiempo
        final onTimePaymentDate = DateTime(2024, 1, 30);
        final noLateFee = service.calculateLateFee(
          onTimePaymentDate,
          dueDate,
          amount,
          config,
        );
        expect(noLateFee, equals(0.0));
      });

      test('debe calcular días restantes correctamente', () {
        final now = DateTime(2024, 1, 15);
        final endDate = DateTime(2024, 1, 31);
        
        final remainingDays = service.calculateRemainingDays(now, endDate);
        expect(remainingDays, equals(16));
        
        // Fecha ya vencida
        final expiredEndDate = DateTime(2024, 1, 10);
        final expiredDays = service.calculateRemainingDays(now, expiredEndDate);
        expect(expiredDays, equals(0));
      });
    });

    group('Validaciones de configuración', () {
      test('debe rechazar fecha de inicio anterior al pago en prepago', () {
        final config = defaultConfig.copyWith(
          billingMode: BillingMode.advance,
          allowManualStartDateInPrepaid: true,
        );
        
        final paymentDate = DateTime(2024, 1, 15);
        final invalidStartDate = DateTime(2024, 1, 10); // Anterior al pago
        
        final calculation = service.calculateBillingDatesFromClientPlan(
          paymentDate: paymentDate,
          requestedStartDate: invalidStartDate,
          plan: clientTestPlan,
          config: config,
        );
        
        expect(calculation.isValidConfiguration, isFalse);
        expect(calculation.validationMessage, contains('no puede ser anterior a la fecha de pago'));
      });

      test('debe manejar diferentes ciclos de facturación', () {
        final quarterlyPlan = clientTestPlan.copyWith(
          billingCycle: client_user.BillingCycle.quarterly,
        );
        
        final startDate = DateTime(2024, 1, 1);
        final endDate = service.calculateEndDateFromClientPlan(startDate, quarterlyPlan);
        
        expect(endDate, equals(DateTime(2024, 3, 31))); // 90 días después
      });
    });
  });
} 