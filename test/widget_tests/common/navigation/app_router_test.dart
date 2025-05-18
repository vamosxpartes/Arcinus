import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/core/navigation/app_router.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_state.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:arcinus/features/auth/presentation/ui/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Mock para AuthStateNotifier
class MockAuthStateNotifier extends Notifier<AuthState> implements AuthStateNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
  
  
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> signOut() async {
    throw UnimplementedError();
  }
}

// Usuarios de prueba para diferentes roles
final testUsers = {
  'propietario': User(
    id: 'owner-id',
    email: 'owner@example.com',
    name: 'Owner User',
    role: AppRole.propietario,
  ),
  'atleta': User(
    id: 'athlete-id',
    email: 'athlete@example.com',
    name: 'Athlete User',
    role: AppRole.atleta,
  ),
  'colaborador': User(
    id: 'collaborator-id',
    email: 'collaborator@example.com',
    name: 'Collaborator User',
    role: AppRole.colaborador,
  ),
  'superAdmin': User(
    id: 'admin-id',
    email: 'admin@example.com',
    name: 'Admin User',
    role: AppRole.superAdmin,
  ),
  'padre': User(
    id: 'parent-id',
    email: 'parent@example.com',
    name: 'Parent User', 
    role: AppRole.padre,
  ),
};

void main() {
  late ProviderContainer container;
  late GoRouter router;
  late MockAuthStateNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthStateNotifier();
    
    // Crear container con override del provider de autenticación
    container = ProviderContainer(
      overrides: [
        authStateNotifierProvider.overrideWith(() => mockAuthNotifier),
      ],
    );

    // Obtener instancia del router
    router = container.read(routerProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('Redirecciones basadas en autenticación', () {
    testWidgets('debería redirigir a welcome cuando no hay autenticación y ruta protegida', 
        (tester) async {
      // Simular estado no autenticado
      mockAuthNotifier.state = const AuthState.unauthenticated();
      
      // Crear widget de prueba con GoRouter
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Intentar navegar a una ruta protegida
      router.go(AppRoutes.managerRoot);
      await tester.pumpAndSettle();
      
      // Verificar que se muestra la pantalla de bienvenida
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('debería permitir acceso a rutas públicas cuando no hay autenticación', 
        (tester) async {
      // Simular estado no autenticado
      mockAuthNotifier.state = const AuthState.unauthenticated();
      
      // Crear widget de prueba con GoRouter
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Navegar a ruta pública
      router.go(AppRoutes.login);
      await tester.pumpAndSettle();
      
      // Verificar que se muestra la pantalla de login
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
} 