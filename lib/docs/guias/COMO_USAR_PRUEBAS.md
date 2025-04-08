# Guía para Utilizar las Pruebas Automatizadas

Este documento explica cómo utilizar el sistema de pruebas automatizadas para el Sistema de Entrenamientos de Arcinus.

## Prerrequisitos

Antes de comenzar, asegúrate de tener:

1. Las dependencias de testing instaladas:
   ```bash
   flutter pub add --dev mocktail fake_cloud_firestore
   ```

2. Los archivos de prueba en la carpeta `test/` del proyecto

## Ejecutar las Pruebas

Para ejecutar todas las pruebas automatizadas:

```bash
flutter test
```

Para ejecutar solo las pruebas del sistema de entrenamientos:

```bash
flutter test test/automated_training_tests.dart
```

Para ejecutar una prueba específica:

```bash
flutter test test/automated_training_tests.dart --name "Navegación a pantalla de entrenamientos"
```

Para ver más información sobre la ejecución:

```bash
flutter test test/automated_training_tests.dart -v
```

## Estructura de las Pruebas

El sistema de pruebas está organizado de la siguiente manera:

1. **Mocks de Servicios**: Simulan el comportamiento de los servicios reales sin depender de Firebase
2. **Clases de Testing**: Proveen un entorno aislado para probar widgets específicos
3. **Grupos de Pruebas**: Organizan las pruebas por funcionalidad
4. **Pruebas Individuales**: Verifican comportamientos específicos

## Cómo Añadir Nuevas Pruebas

Para añadir una nueva prueba:

1. Identifica la funcionalidad a probar
2. Configura los mocks necesarios en el bloque `setUp()`
3. Añade la prueba en el grupo correspondiente

Ejemplo:

```dart
group('Sistema de Entrenamientos - Creación', () {
  testWidgets('Crear un nuevo entrenamiento', (WidgetTester tester) async {
    // Configuración específica para esta prueba
    
    // Renderizar el widget
    await tester.pumpWidget(/* ... */);
    
    // Acciones de usuario (tap, ingreso de texto, etc.)
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    
    // Verificaciones
    expect(find.text('Entrenamiento creado'), findsOneWidget);
  });
});
```

## Cómo Extender los Mocks

Si necesitas añadir comportamiento a los mocks existentes:

```dart
// En el bloque setUp
when(() => mockTrainingService.someMethod(any())).thenAnswer(
  (_) => Future.value(someValue)
);
```

Si necesitas crear un nuevo mock:

```dart
class MockNewService extends Mock implements NewService {}

// En el bloque setUp
final mockNewService = MockNewService();
```

## Valores Fallback para Tipos Personalizados

Al usar `any()` con tipos personalizados, debes registrar valores fallback:

```dart
setUpAll(() {
  registerFallbackValue(MyCustomType());
  registerFallbackValue(SomeEnum.value);
});
```

## Depuración de Pruebas Fallidas

Si una prueba falla:

1. Revisa los mensajes de error con detalle
2. Usa `-v` para ver información adicional
3. Agrega prints temporales para entender qué está sucediendo:
   ```dart
   print('Estado actual: ${myObject.state}');
   ```
4. Verifica que los mocks estén configurados correctamente
5. Asegúrate de que los valores fallback estén registrados para todos los tipos necesarios

## Consideraciones Importantes

- Las pruebas deben ser independientes entre sí
- Evita dependencias de estado global
- Limpia después de cada prueba (en el bloque `tearDown()` si es necesario)
- Simula solo el comportamiento necesario para la prueba
- Enfócate en probar un solo aspecto a la vez

## Recursos Adicionales

- [Documentación oficial de Flutter Testing](https://docs.flutter.dev/testing)
- [Documentación de Mocktail](https://pub.dev/packages/mocktail)
- [Guía de Flutter Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction) 