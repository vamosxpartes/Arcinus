import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';

void main() {
  group('PaymentConfigModel - Paso 2 Validaciones', () {
    group('Configuración avanzada de planes', () {
      test('debe crear configuración con allowManualStartDateInPrepaid por defecto false', () {
        // Arrange & Act
        final config = PaymentConfigModel.defaultConfig(academyId: 'academy123');

        // Assert
        expect(config.allowManualStartDateInPrepaid, isFalse);
        expect(config.gracePeriodDays, equals(0));
      });

      test('debe permitir habilitar allowManualStartDateInPrepaid', () {
        // Arrange
        final config = PaymentConfigModel.defaultConfig(academyId: 'academy123');

        // Act
        final updatedConfig = config.copyWith(
          allowManualStartDateInPrepaid: true,
        );

        // Assert
        expect(updatedConfig.allowManualStartDateInPrepaid, isTrue);
        expect(updatedConfig.academyId, equals(config.academyId));
      });

      test('debe permitir configurar días de gracia', () {
        // Arrange
        final config = PaymentConfigModel.defaultConfig(academyId: 'academy123');

        // Act
        final updatedConfig = config.copyWith(
          gracePeriodDays: 5,
        );

        // Assert
        expect(updatedConfig.gracePeriodDays, equals(5));
      });

      test('debe serializar y deserializar correctamente las nuevas propiedades', () {
        // Arrange
        final config = PaymentConfigModel(
          academyId: 'academy123',
          allowManualStartDateInPrepaid: true,
          gracePeriodDays: 7,
          billingMode: BillingMode.advance,
          allowPartialPayments: true,
          earlyPaymentDiscount: true,
          earlyPaymentDiscountPercent: 10.0,
          earlyPaymentDays: 5,
          lateFeeEnabled: true,
          lateFeePercent: 5.0,
          autoRenewal: true,
          createdAt: DateTime.now(),
        );

        // Act
        final json = config.toJson();
        final fromJson = PaymentConfigModel.fromJson(json);

        // Assert
        expect(fromJson.allowManualStartDateInPrepaid, equals(config.allowManualStartDateInPrepaid));
        expect(fromJson.gracePeriodDays, equals(config.gracePeriodDays));
        expect(fromJson.academyId, equals(config.academyId));
        expect(fromJson.billingMode, equals(config.billingMode));
      });
    });

    group('Validaciones de configuración combinada', () {
      test('debe mantener configuración existente al actualizar nuevas propiedades', () {
        // Arrange
        final originalConfig = PaymentConfigModel(
          academyId: 'academy123',
          billingMode: BillingMode.arrears,
          allowPartialPayments: true,
          gracePeriodDays: 3,
          earlyPaymentDiscount: true,
          earlyPaymentDiscountPercent: 15.0,
          createdAt: DateTime.now(),
        );

        // Act
        final updatedConfig = originalConfig.copyWith(
          allowManualStartDateInPrepaid: true,
        );

        // Assert
        expect(updatedConfig.allowManualStartDateInPrepaid, isTrue);
        expect(updatedConfig.billingMode, equals(BillingMode.arrears));
        expect(updatedConfig.allowPartialPayments, isTrue);
        expect(updatedConfig.gracePeriodDays, equals(3));
        expect(updatedConfig.earlyPaymentDiscount, isTrue);
        expect(updatedConfig.earlyPaymentDiscountPercent, equals(15.0));
      });

      test('debe validar configuraciones lógicas', () {
        // Arrange & Act
        final config = PaymentConfigModel(
          academyId: 'academy123',
          billingMode: BillingMode.advance, // Prepago
          allowManualStartDateInPrepaid: true, // Permitir fecha manual
          gracePeriodDays: 5,
          createdAt: DateTime.now(),
        );

        // Assert - Configuración válida para prepago con fecha manual
        expect(config.billingMode, equals(BillingMode.advance));
        expect(config.allowManualStartDateInPrepaid, isTrue);
        expect(config.gracePeriodDays, greaterThan(0));
      });
    });

    group('Modos de facturación', () {
      test('debe tener nombres de display correctos', () {
        // Act & Assert
        expect(BillingMode.advance.displayName, equals('Por adelantado'));
        expect(BillingMode.current.displayName, equals('Mes en curso'));
        expect(BillingMode.arrears.displayName, equals('Mes vencido'));
      });

      test('debe serializar correctamente los modos de facturación', () {
        // Arrange
        final configs = [
          PaymentConfigModel(academyId: 'test', billingMode: BillingMode.advance, createdAt: DateTime.now()),
          PaymentConfigModel(academyId: 'test', billingMode: BillingMode.current, createdAt: DateTime.now()),
          PaymentConfigModel(academyId: 'test', billingMode: BillingMode.arrears, createdAt: DateTime.now()),
        ];

        // Act & Assert
        for (final config in configs) {
          final json = config.toJson();
          final fromJson = PaymentConfigModel.fromJson(json);
          expect(fromJson.billingMode, equals(config.billingMode));
        }
      });
    });

    group('Configuración por defecto', () {
      test('debe crear configuración por defecto con valores seguros', () {
        // Act
        final config = PaymentConfigModel.defaultConfig(academyId: 'academy123');

        // Assert
        expect(config.academyId, equals('academy123'));
        expect(config.billingMode, equals(BillingMode.advance));
        expect(config.allowPartialPayments, isFalse);
        expect(config.allowManualStartDateInPrepaid, isFalse);
        expect(config.gracePeriodDays, equals(0));
        expect(config.earlyPaymentDiscount, isFalse);
        expect(config.lateFeeEnabled, isFalse);
        expect(config.autoRenewal, isFalse);
        expect(config.createdAt, isNotNull);
      });
    });
  });
} 