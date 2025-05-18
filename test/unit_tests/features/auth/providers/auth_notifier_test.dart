import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/auth/data/repositories/auth_repository.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}
class MockStream<T> extends Mock implements Stream<T> {}

// Fixtures
final testUser = User(
  id: 'test-id',
  email: 'test@example.com',
  name: 'Test User',
);

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;
  late Stream<User?> authStream;

  // Registrar un fallback para AuthState para que funcionen los matchers de mocktail
  setUpAll(() {
    registerFallbackValue(const AuthState.initial());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authStream = Stream.value(null);
    
    // Configuraciones básicas del mock
    when(() => mockAuthRepository.authStateChanges).thenAnswer((_) => authStream);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    
    // Configurar el container de providers para el test
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
    
    // Registrar un listener para el provider que queremos probar
    addTearDown(() => container.dispose());
  });

  group('AuthStateNotifier', () {
    test('estado cambia según el stream de autenticación', () async {
      // Cuando el stream emite un usuario null, el estado debería ser unauthenticated
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
          
      // Esperar que las operaciones asíncronas se completen
      await Future.delayed(Duration.zero);
      
      // Verificar estado inicial
      expect(
        container.read(authStateNotifierProvider).isLoading,
        false,
        reason: 'El estado debería haber cambiado de loading después de la inicialización',
      );
    });

    test('se puede establecer estado authenticated manualmente', () async {
      // Establecer el estado manualmente
      container.read(authStateNotifierProvider.notifier).state = 
          AuthState.authenticated(user: testUser);
      
      // Verificar estado
      final state = container.read(authStateNotifierProvider);
      expect(state.isAuthenticated, true);
    });

    group('signInWithEmailAndPassword', () {
      test('cambia estado a authenticated en caso exitoso', () async {
        // Arrange
        when(() => mockAuthRepository.signInWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => Right(testUser));
        
        // Act
        await container.read(authStateNotifierProvider.notifier)
            .signInWithEmailAndPassword('test@example.com', 'password');
        
        // Assert
        final state = container.read(authStateNotifierProvider);
        expect(state.isAuthenticated, true);
        
        // Verify
        verify(() => mockAuthRepository.signInWithEmailAndPassword(
          'test@example.com', 'password'
        )).called(1);
      });

      test('cambia estado a error cuando falla la autenticación', () async {
        // Arrange
        final failure = const Failure.authError(
          code: 'wrong-password', 
          message: 'Contraseña incorrecta'
        );
        
        when(() => mockAuthRepository.signInWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => Left(failure));
        
        // Act
        await container.read(authStateNotifierProvider.notifier)
            .signInWithEmailAndPassword('test@example.com', 'wrong-password');
        
        // Assert
        final state = container.read(authStateNotifierProvider);
        expect(state.hasError, true);
        expect(state.errorMessage, 'Contraseña incorrecta');
      });
    });

    group('createUserWithEmailAndPassword', () {
      test('cambia estado a authenticated en caso exitoso', () async {
        // Arrange
        when(() => mockAuthRepository.createUserWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => Right(testUser));
        
        // Act
        await container.read(authStateNotifierProvider.notifier)
            .createUserWithEmailAndPassword('new@example.com', 'password');
        
        // Assert
        final state = container.read(authStateNotifierProvider);
        expect(state.isAuthenticated, true);
        
        // Verify
        verify(() => mockAuthRepository.createUserWithEmailAndPassword(
          'new@example.com', 'password'
        )).called(1);
      });

      test('cambia estado a error cuando falla la creación', () async {
        // Arrange
        final failure = const Failure.authError(
          code: 'email-already-in-use', 
          message: 'El correo ya está en uso'
        );
        
        when(() => mockAuthRepository.createUserWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => Left(failure));
        
        // Act
        await container.read(authStateNotifierProvider.notifier)
            .createUserWithEmailAndPassword('new@example.com', 'password');
        
        // Assert
        final state = container.read(authStateNotifierProvider);
        expect(state.hasError, true);
        expect(state.errorMessage, 'El correo ya está en uso');
      });
    });

    group('signOut', () {
      test('cambia estado a unauthenticated en caso exitoso', () async {
        // Arrange - Configurar estado inicial autenticado
        container.read(authStateNotifierProvider.notifier).state = 
            AuthState.authenticated(user: testUser);
            
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));
        
        // Act
        await container.read(authStateNotifierProvider.notifier).signOut();
        
        // Assert
        final state = container.read(authStateNotifierProvider);
        expect(state.isUnauthenticated, true);
        
        // Verify
        verify(() => mockAuthRepository.signOut()).called(1);
      });

      test('cambia estado a error cuando falla el signOut', () async {
        // Arrange - Configurar estado inicial autenticado
        container.read(authStateNotifierProvider.notifier).state = 
            AuthState.authenticated(user: testUser);
            
        final failure = const Failure.unexpectedError(error: 'Error al cerrar sesión');
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => Left(failure));
        
        // Act
        await container.read(authStateNotifierProvider.notifier).signOut();
        
        // Assert
        final state = container.read(authStateNotifierProvider);
        expect(state.hasError, true);
        expect(state.errorMessage, contains('Error al cerrar sesión'));
      });
    });
  });
} 