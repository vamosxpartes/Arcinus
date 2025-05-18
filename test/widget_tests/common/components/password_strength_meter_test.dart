import 'package:arcinus/features/auth/presentation/ui/widgets/password_strength_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordStrengthMeter', () {
    Widget buildTestableWidget(String password) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: PasswordStrengthMeter(password: password),
          ),
        ),
      );
    }

    testWidgets('debería estar oculto cuando la contraseña está vacía', (WidgetTester tester) async {
      // Preparar
      await tester.pumpWidget(buildTestableWidget(''));
      
      // Verificar
      expect(find.byType(PasswordStrengthMeter), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('debería mostrar "Muy débil" para una contraseña corta', (WidgetTester tester) async {
      // Preparar
      await tester.pumpWidget(buildTestableWidget('abc'));
      
      // Verificar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Muy débil'), findsOneWidget);
      
      // Verificar color rojo
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressBar.color, equals(Colors.red));
      
      // Una contraseña corta debe tener fortaleza 0 o 1 dependiendo de la implementación
      // Verificamos que el valor esté entre 0.0 y 0.25
      expect(progressBar.value! <= 0.25, isTrue);
    });

    testWidgets('debería mostrar "Débil" para una contraseña con longitud suficiente y números', (WidgetTester tester) async {
      // Preparar
      await tester.pumpWidget(buildTestableWidget('password123'));
      
      // Verificar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Débil'), findsOneWidget);
      
      // Verificar color naranja
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressBar.color, equals(Colors.orange));
      
      // Debe tener fortaleza 2/4 = 0.5
      expect(progressBar.value, closeTo(0.5, 0.01));
    });

    testWidgets('debería mostrar "Buena" para una contraseña con minúsculas, mayúsculas y números', (WidgetTester tester) async {
      // Preparar
      await tester.pumpWidget(buildTestableWidget('Password123'));
      
      // Verificar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Buena'), findsOneWidget);
      
      // Verificar color amarillo
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressBar.color, equals(Colors.yellow[700]));
      
      // Debe tener fortaleza 3/4 = 0.75
      expect(progressBar.value, closeTo(0.75, 0.01));
    });

    testWidgets('debería mostrar "Fuerte" para una contraseña con todos los criterios', (WidgetTester tester) async {
      // Preparar
      await tester.pumpWidget(buildTestableWidget('Password123!'));
      
      // Verificar
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Fuerte'), findsOneWidget);
      
      // Verificar color verde
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressBar.color, equals(Colors.green));
      
      // Debe tener fortaleza 4/4 = 1.0
      expect(progressBar.value, closeTo(1.0, 0.01));
    });
  });
} 