import 'package:flutter_test/flutter_test.dart';

// Ejemplo de una clase simple para probar
class Calculator {
  int add(int a, int b) => a + b;
  int subtract(int a, int b) => a - b;
}

void main() {
  // Grupo de pruebas para la clase Calculator
  group('Calculator', () {
    // Instancia de la clase a probar
    late Calculator calculator;

    // setUp se ejecuta antes de cada prueba en el grupo
    setUp(() {
      calculator = Calculator();
    });

    // Prueba individual para la suma
    test('adds two numbers', () {
      expect(calculator.add(2, 3), 5);
    });

    // Prueba individual para la resta
    test('subtracts two numbers', () {
      expect(calculator.subtract(5, 3), 2);
    });

    // Puedes añadir más pruebas aquí
  });
}
