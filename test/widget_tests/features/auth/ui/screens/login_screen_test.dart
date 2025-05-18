import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_state.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock para reemplazar el AuthStateNotifier real
class MockAuthStateNotifier extends AutoDisposeNotifier<AuthState> implements AuthStateNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
  
  
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    // Simulamos que la operación toma tiempo
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AuthState.unauthenticated();
  }
  
  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AuthState.unauthenticated();
  }
  
  @override
  Future<void> signOut() async {
    state = const AuthState.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AuthState.unauthenticated();
  }
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        authStateNotifierProvider.overrideWith(() => MockAuthStateNotifier()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget buildTestableWidget() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen - UI', () {
    testWidgets('debería mostrar los elementos básicos del formulario', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Verificar elementos de UI básicos
      expect(find.text('Bienvenido a Arcinus'), findsOneWidget);
      expect(find.text('Inicia sesión para continuar'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // Logo
      
      // No podemos usar TextFormField directamente porque usa ReactiveForm
      // Buscar por el texto de las etiquetas
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      
      // Botón de inicio de sesión
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      
      // Enlaces adicionales
      expect(find.text('¿No tienes una cuenta?'), findsOneWidget);
      expect(find.text('Regístrate'), findsOneWidget);
      expect(find.text('Usar cuenta de prueba'), findsOneWidget);
    });

    testWidgets('debería mostrar errores de validación cuando el formulario es inválido', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Intentar enviar el formulario sin completar los campos
      await tester.tap(find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN'));
      await tester.pump();

      // Verificar mensajes de error
      expect(find.text('El correo electrónico es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
    });

    testWidgets('debería mostrar error específico para email inválido', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Ingresar un email inválido
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Correo electrónico'), 'correo-invalido');
      
      // Intentar enviar el formulario
      await tester.tap(find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN'));
      await tester.pump();

      // Verificar mensaje de error específico para email
      expect(find.text('Por favor ingresa un correo electrónico válido'), findsOneWidget);
    });

    testWidgets('debería mostrar CircularProgressIndicator durante el proceso de login', (tester) async {
      // Reemplazar el mock para este test específico con uno que muestre loading
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() => MockAuthStateNotifier()),
        ],
      );
      
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ));

      // Ingresar credenciales válidas
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Correo electrónico'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Contraseña'), 'password123');

      // Obtener notifier
      final notifier = container.read(authStateNotifierProvider.notifier);
      
      // Cambiar estado antes de tocar el botón
      await notifier.signInWithEmailAndPassword('test@example.com', 'password123');

      // Verificar que aparece el indicador de carga (estado actual)
      expect(container.read(authStateNotifierProvider), const AuthState.loading());
      
      // Intentar iniciar sesión
      await tester.tap(find.widgetWithText(ElevatedButton, 'INICIAR SESIÓN'));
      await tester.pump(); // Primera actualización para iniciar el proceso

      // Verificar que aparece el indicador de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('debería mostrar diálogo de cuentas de prueba', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Tocar el botón de cuentas de prueba
      await tester.tap(find.text('Usar cuenta de prueba'));
      await tester.pumpAndSettle(); // Esperar animaciones

      // Verificar que aparece el diálogo
      expect(find.text('Cuentas de prueba'), findsOneWidget);
      expect(find.text('Propietario de Academia'), findsOneWidget);
      expect(find.text('Colaborador'), findsOneWidget);
      expect(find.text('Atleta'), findsOneWidget);
      
      // Verificar botón de cancelar
      expect(find.text('Cancelar'), findsOneWidget);
    });
  });
} 