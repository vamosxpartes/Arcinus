import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Widget simple para probar
class SimpleWidget extends StatelessWidget {
  const SimpleWidget({required this.title, required this.message, super.key});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(message)),
      ),
    );
  }
}

void main() {
  // Grupo de pruebas para SimpleWidget
  group('SimpleWidget Tests', () {
    // Prueba individual: Verificar que los textos se muestran
    testWidgets('Displays title and message', (WidgetTester tester) async {
      // Construye el widget
      await tester.pumpWidget(const SimpleWidget(title: 'T', message: 'M'));

      // Busca los widgets de Texto
      final titleFinder = find.text('T');
      final messageFinder = find.text('M');

      // Verifica que se encuentre exactamente un widget para cada texto
      expect(titleFinder, findsOneWidget);
      expect(messageFinder, findsOneWidget);
    });

    // Puedes añadir más pruebas de widget aquí (interacciones, etc.)
  });
}
