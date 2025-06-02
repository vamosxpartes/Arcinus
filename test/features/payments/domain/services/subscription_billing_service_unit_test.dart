import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart' as client_user;
import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/payments/domain/services/subscription_billing_service.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';

void main() {
  group('SubscriptionBillingService - Unit Tests', () {
    late SubscriptionBillingService service;
    late PaymentConfigModel defaultConfig;
    late SubscriptionPlanModel testPlan;
    late client_user.SubscriptionPlanModel clientTestPlan;

    setUp(() {
      service = SubscriptionBillingService();
      
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

      testPlan = SubscriptionPlanModel(
        name: 'Plan Mensual Test',
        amount: 100.0,
        currency: 'USD',
        createdAt: DateTime.now(),
      );

      clientTestPlan = client_user.SubscriptionPlanModel(
        id: 'client-plan-test',
        name: 'Plan Cliente Test',
        amount: 100.0,
        currency: 'USD',
        billingCycle: client_user.BillingCycle.monthly, 
        createdAt: DateTime.now(),
      );
    });

    group('Funciones Principales del TODO', () {
      group('calculateEndDate', () {
        test('Debe calcular correctamente la fecha de fin para plan mensual', () {
          // Arrange
          final startDate = DateTime(2024, 1, 15);

          // Act
          final endDate = service.calculateEndDate(startDate, testPlan);

          // Assert
          expect(endDate, equals(DateTime(2024, 2, 14))); // 30 días después
        });

        test('Debe calcular correctamente la fecha de fin para plan con días extra', () {
          // Arrange
          final startDate = DateTime(2024, 1, 15);
          final planWithExtraDays = testPlan.copyWith(extraDays: 5);

          // Act
          final endDate = service.calculateEndDate(startDate, planWithExtraDays);

          // Assert
          expect(endDate, equals(DateTime(2024, 2, 19))); // 30 + 5 = 35 días después
        });
      });

      group('isValidStartDate', () {
        test('Debe validar fecha de inicio igual a fecha de pago en prepago', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final startDate = DateTime(2024, 1, 15);
          final config = defaultConfig.copyWith(
            billingMode: BillingMode.advance,
            allowManualStartDateInPrepaid: false,
          );

          // Act
          final isValid = service.isValidStartDate(startDate, paymentDate, config, BillingMode.advance);

          // Assert
          expect(isValid, isTrue);
        });

        test('Debe rechazar fecha de inicio diferente en prepago cuando no está permitido', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final startDate = DateTime(2024, 1, 20);
          final config = defaultConfig.copyWith(
            billingMode: BillingMode.advance,
            allowManualStartDateInPrepaid: false,
          );

          // Act
          final isValid = service.isValidStartDate(startDate, paymentDate, config, BillingMode.advance);

          // Assert
          expect(isValid, isFalse);
        });

        test('Debe permitir fecha de inicio diferente en prepago cuando está habilitado', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final startDate = DateTime(2024, 1, 20);
          final config = defaultConfig.copyWith(
            billingMode: BillingMode.advance,
            allowManualStartDateInPrepaid: true,
          );

          // Act
          final isValid = service.isValidStartDate(startDate, paymentDate, config, BillingMode.advance);

          // Assert
          expect(isValid, isTrue);
        });

        test('Debe rechazar fecha de inicio anterior al pago en prepago', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final startDate = DateTime(2024, 1, 10);
          final config = defaultConfig.copyWith(
            billingMode: BillingMode.advance,
            allowManualStartDateInPrepaid: true,
          );

          // Act
          final isValid = service.isValidStartDate(startDate, paymentDate, config, BillingMode.advance);

          // Assert
          expect(isValid, isFalse);
        });

        test('Debe permitir fechas flexibles en modo mes en curso', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final startDate = DateTime(2024, 1, 20);
          final config = defaultConfig.copyWith(billingMode: BillingMode.current);

          // Act
          final isValid = service.isValidStartDate(startDate, paymentDate, config, BillingMode.current);

          // Assert
          expect(isValid, isTrue);
        });

        test('Debe rechazar fechas muy futuras en modo mes en curso', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final startDate = DateTime(2024, 3, 15); // 60 días en el futuro
          final config = defaultConfig.copyWith(billingMode: BillingMode.current);

          // Act
          final isValid = service.isValidStartDate(startDate, paymentDate, config, BillingMode.current);

          // Assert
          expect(isValid, isFalse);
        });
      });

      group('calculateRemainingDays', () {
        test('Debe calcular días restantes correctamente', () {
          // Arrange
          final now = DateTime(2024, 1, 15);
          final endDate = DateTime(2024, 1, 25);

          // Act
          final remainingDays = service.calculateRemainingDays(now, endDate);

          // Assert
          expect(remainingDays, equals(10));
        });

        test('Debe retornar 0 para fechas ya vencidas', () {
          // Arrange
          final now = DateTime(2024, 1, 25);
          final endDate = DateTime(2024, 1, 15);

          // Act
          final remainingDays = service.calculateRemainingDays(now, endDate);

          // Assert
          expect(remainingDays, equals(0));
        });

        test('Debe retornar 0 para fecha de vencimiento igual a hoy', () {
          // Arrange
          final now = DateTime(2024, 1, 15);
          final endDate = DateTime(2024, 1, 15);

          // Act
          final remainingDays = service.calculateRemainingDays(now, endDate);

          // Assert
          expect(remainingDays, equals(0));
        });
      });

      group('isPaymentWithinGrace', () {
        test('Debe aceptar pago dentro del período de gracia', () {
          // Arrange
          final dueDate = DateTime(2024, 1, 15);
          final paymentDate = DateTime(2024, 1, 18); // 3 días tarde
          const graceDays = 5;

          // Act
          final isWithinGrace = service.isPaymentWithinGrace(dueDate, paymentDate, graceDays);

          // Assert
          expect(isWithinGrace, isTrue);
        });

        test('Debe rechazar pago fuera del período de gracia', () {
          // Arrange
          final dueDate = DateTime(2024, 1, 15);
          final paymentDate = DateTime(2024, 1, 22); // 7 días tarde
          const graceDays = 5;

          // Act
          final isWithinGrace = service.isPaymentWithinGrace(dueDate, paymentDate, graceDays);

          // Assert
          expect(isWithinGrace, isFalse);
        });

        test('Debe aceptar pago exactamente en el último día del período de gracia', () {
          // Arrange
          final dueDate = DateTime(2024, 1, 15);
          final paymentDate = DateTime(2024, 1, 20); // Exactamente 5 días tarde
          const graceDays = 5;

          // Act
          final isWithinGrace = service.isPaymentWithinGrace(dueDate, paymentDate, graceDays);

          // Assert
          expect(isWithinGrace, isTrue);
        });

        test('Debe aceptar pago anticipado', () {
          // Arrange
          final dueDate = DateTime(2024, 1, 15);
          final paymentDate = DateTime(2024, 1, 10); // 5 días antes
          const graceDays = 5;

          // Act
          final isWithinGrace = service.isPaymentWithinGrace(dueDate, paymentDate, graceDays);

          // Assert
          expect(isWithinGrace, isTrue);
        });
      });
    });

    group('Funciones de Soporte y Adicionales', () {
      group('calculateEndDateFromClientPlan', () {
        test('Debe calcular correctamente para plan mensual de cliente', () {
          // Arrange
          final startDate = DateTime(2024, 1, 15);

          // Act
          final endDate = service.calculateEndDateFromClientPlan(startDate, clientTestPlan);

          // Assert
          expect(endDate, equals(DateTime(2024, 2, 14))); // 30 días después
        });

        test('Debe calcular correctamente para plan trimestral de cliente', () {
          // Arrange
          final startDate = DateTime(2024, 1, 15);
          final quarterlyPlan = clientTestPlan.copyWith(
            billingCycle: client_user.BillingCycle.quarterly,
          );

          // Act
          final endDate = service.calculateEndDateFromClientPlan(startDate, quarterlyPlan);

          // Assert
          expect(endDate, equals(DateTime(2024, 4, 14))); // 90 días después
        });

        test('Debe calcular correctamente para plan anual de cliente', () {
          // Arrange
          final startDate = DateTime(2024, 1, 15);
          final annualPlan = clientTestPlan.copyWith(
            billingCycle: client_user.BillingCycle.annual,
          );

          // Act
          final endDate = service.calculateEndDateFromClientPlan(startDate, annualPlan);

          // Assert
          expect(endDate, equals(DateTime(2025, 1, 14))); // 365 días después (15 + 365 = 14 del siguiente año)
        });
      });

      group('calculateFinancialAdjustments', () {
        test('Debe calcular solo descuento por pronto pago', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 5);
          final dueDate = DateTime(2024, 1, 15); // 10 días después
          const baseAmount = 100.0;
          final config = defaultConfig.copyWith(
            earlyPaymentDiscount: true,
            earlyPaymentDays: 7,
            earlyPaymentDiscountPercent: 10.0,
            lateFeeEnabled: false,
          );

          // Act
          final adjustment = service.calculateFinancialAdjustments(
            paymentDate: paymentDate,
            dueDate: dueDate,
            baseAmount: baseAmount,
            config: config,
          );

          // Assert
          expect(adjustment.earlyPaymentDiscount, equals(10.0));
          expect(adjustment.lateFee, equals(0.0));
          expect(adjustment.finalAmount, equals(90.0));
          expect(adjustment.description, contains('Descuento por pronto pago'));
        });

        test('Debe calcular solo recargo por pago tardío', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 20);
          final dueDate = DateTime(2024, 1, 15); // 5 días antes
          const baseAmount = 100.0;
          final config = defaultConfig.copyWith(
            earlyPaymentDiscount: false,
            lateFeeEnabled: true,
            lateFeePercent: 5.0,
          );

          // Act
          final adjustment = service.calculateFinancialAdjustments(
            paymentDate: paymentDate,
            dueDate: dueDate,
            baseAmount: baseAmount,
            config: config,
          );

          // Assert
          expect(adjustment.earlyPaymentDiscount, equals(0.0));
          expect(adjustment.lateFee, equals(5.0));
          expect(adjustment.finalAmount, equals(105.0));
          expect(adjustment.description, contains('Recargo por pago tardío'));
        });

        test('Debe calcular sin ajustes cuando no aplican', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final dueDate = DateTime(2024, 1, 15); // Mismo día
          const baseAmount = 100.0;
          final config = defaultConfig.copyWith(
            earlyPaymentDiscount: false,
            lateFeeEnabled: false,
          );

          // Act
          final adjustment = service.calculateFinancialAdjustments(
            paymentDate: paymentDate,
            dueDate: dueDate,
            baseAmount: baseAmount,
            config: config,
          );

          // Assert
          expect(adjustment.earlyPaymentDiscount, equals(0.0));
          expect(adjustment.lateFee, equals(0.0));
          expect(adjustment.finalAmount, equals(100.0));
          expect(adjustment.description, contains('Monto base: \$100.00'));
          expect(adjustment.description, contains('Monto final: \$100.00'));
        });
      });

      group('validateGracePeriod', () {
        test('Debe pasar validación dentro del período de gracia', () {
          // Arrange
          final expectedDueDate = DateTime(2024, 1, 15);
          final paymentDate = DateTime(2024, 1, 18); // 3 días tarde
          final config = defaultConfig.copyWith(gracePeriodDays: 5);

          // Act & Assert
          expect(
            () => service.validateGracePeriod(expectedDueDate, paymentDate, config),
            returnsNormally,
          );
        });

        test('Debe lanzar excepción fuera del período de gracia', () {
          // Arrange
          final expectedDueDate = DateTime(2024, 1, 15);
          final paymentDate = DateTime(2024, 1, 22); // 7 días tarde
          final config = defaultConfig.copyWith(gracePeriodDays: 5);

          // Act & Assert
          expect(
            () => service.validateGracePeriod(expectedDueDate, paymentDate, config),
            throwsA(isA<BillingValidationException>()),
          );
        });

        test('Debe pasar validación cuando no hay período de gracia configurado', () {
          // Arrange
          final expectedDueDate = DateTime(2024, 1, 15);
          final paymentDate = DateTime(2024, 1, 25); // 10 días tarde
          final config = defaultConfig.copyWith(gracePeriodDays: 0);

          // Act & Assert
          expect(
            () => service.validateGracePeriod(expectedDueDate, paymentDate, config),
            returnsNormally,
          );
        });
      });

      group('calculateEarlyPaymentDiscount', () {
        test('Debe calcular descuento cuando se paga con suficiente anticipación', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 5);
          final dueDate = DateTime(2024, 1, 15); // 10 días después
          const amount = 100.0;
          final config = defaultConfig.copyWith(
            earlyPaymentDiscount: true,
            earlyPaymentDays: 7,
            earlyPaymentDiscountPercent: 15.0,
          );

          // Act
          final discount = service.calculateEarlyPaymentDiscount(paymentDate, dueDate, amount, config);

          // Assert
          expect(discount, equals(15.0)); // 15% de 100
        });

        test('Debe retornar 0 cuando no se paga con suficiente anticipación', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 12);
          final dueDate = DateTime(2024, 1, 15); // Solo 3 días antes
          const amount = 100.0;
          final config = defaultConfig.copyWith(
            earlyPaymentDiscount: true,
            earlyPaymentDays: 7,
            earlyPaymentDiscountPercent: 15.0,
          );

          // Act
          final discount = service.calculateEarlyPaymentDiscount(paymentDate, dueDate, amount, config);

          // Assert
          expect(discount, equals(0.0));
        });

        test('Debe retornar 0 cuando el descuento está deshabilitado', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 5);
          final dueDate = DateTime(2024, 1, 15);
          const amount = 100.0;
          final config = defaultConfig.copyWith(earlyPaymentDiscount: false);

          // Act
          final discount = service.calculateEarlyPaymentDiscount(paymentDate, dueDate, amount, config);

          // Assert
          expect(discount, equals(0.0));
        });
      });

      group('calculateLateFee', () {
        test('Debe calcular recargo cuando se paga tarde', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 20);
          final dueDate = DateTime(2024, 1, 15); // 5 días antes
          const amount = 100.0;
          final config = defaultConfig.copyWith(
            lateFeeEnabled: true,
            lateFeePercent: 8.0,
          );

          // Act
          final lateFee = service.calculateLateFee(paymentDate, dueDate, amount, config);

          // Assert
          expect(lateFee, equals(8.0)); // 8% de 100
        });

        test('Debe retornar 0 cuando se paga a tiempo o antes', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 15);
          final dueDate = DateTime(2024, 1, 15); // Mismo día
          const amount = 100.0;
          final config = defaultConfig.copyWith(
            lateFeeEnabled: true,
            lateFeePercent: 8.0,
          );

          // Act
          final lateFee = service.calculateLateFee(paymentDate, dueDate, amount, config);

          // Assert
          expect(lateFee, equals(0.0));
        });

        test('Debe retornar 0 cuando el recargo está deshabilitado', () {
          // Arrange
          final paymentDate = DateTime(2024, 1, 20);
          final dueDate = DateTime(2024, 1, 15);
          const amount = 100.0;
          final config = defaultConfig.copyWith(lateFeeEnabled: false);

          // Act
          final lateFee = service.calculateLateFee(paymentDate, dueDate, amount, config);

          // Assert
          expect(lateFee, equals(0.0));
        });
      });
    });

    group('Casos Edge y Validaciones Especiales', () {
      test('Debe manejar fechas de año bisiesto correctamente', () {
        // Arrange
        final startDate = DateTime(2024, 2, 29); // Año bisiesto
        final plan = testPlan.copyWith(extraDays: 1); // 31 días total

        // Act
        final endDate = service.calculateEndDate(startDate, plan);

        // Assert
        expect(endDate, equals(DateTime(2024, 3, 31))); // 31 días después del 29 de febrero
      });

      test('Debe manejar cambios de año correctamente', () {
        // Arrange
        final startDate = DateTime(2023, 12, 15);

        // Act
        final endDate = service.calculateEndDate(startDate, testPlan);

        // Assert
        expect(endDate, equals(DateTime(2024, 1, 14))); // Cruza al siguiente año
      });

      test('Debe manejar microsegundos en comparaciones de fechas', () {
        // Arrange
        final dueDate = DateTime(2024, 1, 15, 12, 0, 0, 0, 0);
        final paymentDate = DateTime(2024, 1, 15, 12, 0, 0, 0, 1); // 1 microsegundo después
        const graceDays = 0;

        // Act
        final isWithinGrace = service.isPaymentWithinGrace(dueDate, paymentDate, graceDays);

        // Assert
        expect(isWithinGrace, isFalse); // Debe ser estricto con las fechas
      });
    });
  });
} 