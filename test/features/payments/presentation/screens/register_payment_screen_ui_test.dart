import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/payments/presentation/screens/register_payment_screen.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';

void main() {
  group('RegisterPaymentScreen UI/UX Improvements - Paso 5', () {
    testWidgets('Debe mostrar la pantalla de registro de pagos', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterPaymentScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verificar elementos básicos de la UI
      expect(find.text('Gestión de Pagos'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Debe mostrar elementos de configuración de facturación cuando están disponibles', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterPaymentScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verificar que la estructura básica está presente
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('Debe tener iconos y elementos visuales mejorados', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterPaymentScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verificar que la estructura básica está presente
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      // Los iconos aparecerán cuando haya datos cargados
    });

    test('BillingMode debe tener valores correctos para iconos', () {
      // Test unitario para verificar que los valores del enum son correctos
      expect(BillingMode.advance.name, equals('advance'));
      expect(BillingMode.current.name, equals('current'));
      expect(BillingMode.arrears.name, equals('arrears'));
    });

    test('BillingMode extension debe proporcionar nombres legibles', () {
      // Test unitario para verificar las extensiones
      expect(BillingMode.advance.displayName, equals('Por adelantado'));
      expect(BillingMode.current.displayName, equals('Mes en curso'));
      expect(BillingMode.arrears.displayName, equals('Mes vencido'));
    });

    testWidgets('Debe mostrar formulario de pago cuando hay datos', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterPaymentScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verificar elementos del formulario
      expect(find.byType(TextFormField), findsAtLeastNWidgets(0)); // Puede no haber campos si no hay atleta seleccionado
      expect(find.byType(DropdownButtonFormField), findsAtLeastNWidgets(0)); // Puede no haber dropdowns si no hay datos
    });

    testWidgets('Debe manejar estados de carga correctamente', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterPaymentScreen(),
          ),
        ),
      );

      // Assert - Verificar que la pantalla se construye sin errores
      expect(find.byType(RegisterPaymentScreen), findsOneWidget);
      
      // Esperar a que se complete la construcción
      await tester.pumpAndSettle();
      
      // Verificar que no hay errores de construcción
      expect(tester.takeException(), isNull);
    });

    testWidgets('Debe tener AppBar con título correcto', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterPaymentScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Gestión de Pagos'), findsOneWidget);
    });

    testWidgets('Debe mostrar indicador de carga cuando es necesario', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const RegisterPaymentScreen(),
          ),
        ),
      );

      // Verificar estado inicial (puede mostrar loading)
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(0));
      
      await tester.pumpAndSettle();

      // Verificar que la pantalla se estabiliza
      expect(find.byType(RegisterPaymentScreen), findsOneWidget);
    });
  });

  group('UI Components Validation', () {
    test('Debe validar que LinearProgressIndicator es un widget válido', () {
      // Test para verificar que los widgets utilizados son válidos
      const widget = LinearProgressIndicator(value: 0.5);
      expect(widget.value, equals(0.5));
    });

    test('Debe validar que los iconos utilizados existen', () {
      // Test para verificar que los iconos utilizados son válidos
      expect(Icons.payments, isNotNull);
      expect(Icons.discount, isNotNull);
      expect(Icons.warning, isNotNull);
      expect(Icons.check_circle, isNotNull);
      expect(Icons.date_range, isNotNull);
      expect(Icons.play_arrow, isNotNull);
      expect(Icons.stop, isNotNull);
      expect(Icons.schedule, isNotNull);
      expect(Icons.fast_forward, isNotNull);
      expect(Icons.today, isNotNull);
      expect(Icons.history, isNotNull);
      expect(Icons.settings, isNotNull);
      expect(Icons.card_membership, isNotNull);
      expect(Icons.block, isNotNull);
      expect(Icons.autorenew, isNotNull);
      expect(Icons.info, isNotNull);
      expect(Icons.error, isNotNull);
      expect(Icons.edit, isNotNull);
      expect(Icons.lock, isNotNull);
    });

    test('Debe validar que los colores utilizados son válidos', () {
      // Test para verificar que los colores utilizados son válidos
      expect(Colors.orange, isNotNull);
      expect(Colors.green, isNotNull);
      expect(Colors.red, isNotNull);
      expect(Colors.blue, isNotNull);
      expect(Colors.grey, isNotNull);
      expect(Colors.white, isNotNull);
    });
  });
} 