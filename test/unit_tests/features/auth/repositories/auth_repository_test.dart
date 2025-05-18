import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/auth/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mocks para Firebase Auth
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockIdTokenResult extends Mock implements firebase_auth.IdTokenResult {}

/// Mocks para Firestore
class MockFirestore extends Mock implements FirebaseFirestore {}
// Forma segura de hacer mock de clases selladas en Firebase
// ignore: subtype_of_sealed_class
abstract class _CollectionReference<T> implements CollectionReference<T> {}
// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock implements _CollectionReference<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

/// Pruebas unitarias para el AuthRepository (implementación con Firebase).
/// 
/// Estas pruebas verifican que:
/// - El AuthRepository interactúe correctamente con Firebase Auth y Firestore
/// - Maneje correctamente casos de éxito y error
/// - Convierta correctamente entre modelos de Firebase y modelos de dominio
/// 
/// Mejores prácticas implementadas:
/// - Uso de mocks para simular dependencias externas
/// - Pruebas de diferentes escenarios de éxito y error
/// - Verificación de comportamiento de métodos específicos

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirestore mockFirestore;
  late FirebaseAuthRepository authRepository;
  late MockUserCredential mockUserCredential;
  late MockFirebaseUser mockFirebaseUser;
  late MockIdTokenResult mockIdTokenResult;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockDocumentSnapshot mockUserSnapshot;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirestore();
    mockUserCredential = MockUserCredential();
    mockFirebaseUser = MockFirebaseUser();
    mockIdTokenResult = MockIdTokenResult();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockUserSnapshot = MockDocumentSnapshot();
    
    authRepository = FirebaseAuthRepository(mockFirebaseAuth, mockFirestore);

    // Configuración de mocks para Firestore
    when(() => mockFirestore.collection('users'))
        .thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc(any()))
        .thenReturn(mockUserDoc);
  });

  group('signInWithEmailAndPassword', () {
    final testEmail = 'test@example.com';
    final testPassword = 'password123';
    
    test('retorna User cuando la autenticación es exitosa', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);
      
      when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
      when(() => mockFirebaseUser.uid).thenReturn('test-uid');
      when(() => mockFirebaseUser.email).thenReturn(testEmail);
      when(() => mockFirebaseUser.displayName).thenReturn('Test User');
      when(() => mockFirebaseUser.photoURL).thenReturn(null);
      when(() => mockFirebaseUser.getIdTokenResult(true))
          .thenAnswer((_) async => mockIdTokenResult);
      
      // Simular claims sin rol definido
      when(() => mockIdTokenResult.claims).thenReturn({});
      
      // Simular documento de usuario en Firestore
      when(() => mockUserDoc.get())
          .thenAnswer((_) async => mockUserSnapshot);
      when(() => mockUserSnapshot.exists).thenReturn(true);
      when(() => mockUserSnapshot.data())
          .thenReturn({'role': 'propietario'});
      
      // Act
      final result = await authRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      );
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) {
          expect(user.id, 'test-uid');
          expect(user.email, testEmail);
          expect(user.name, 'Test User');
          expect(user.role, AppRole.propietario);
        },
      );
      
      // Verify
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });
    
    test('retorna AuthFailure cuando ocurre un error de autenticación', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(
        firebase_auth.FirebaseAuthException(
          code: 'wrong-password',
          message: 'Contraseña incorrecta',
        ),
      );
      
      // Act
      final result = await authRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      );
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect((failure as AuthFailure).code, 'wrong-password');
        },
        (_) => fail('Should not return success'),
      );
    });
  });

  group('currentUser', () {
    test('retorna User cuando hay un usuario autenticado', () {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
      when(() => mockFirebaseUser.uid).thenReturn('test-uid');
      when(() => mockFirebaseUser.email).thenReturn('test@example.com');
      when(() => mockFirebaseUser.displayName).thenReturn('Test User');
      
      // Act
      final user = authRepository.currentUser;
      
      // Assert
      expect(user, isNotNull);
      expect(user!.id, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.role, AppRole.desconocido); // Sin claims, rol por defecto
    });
    
    test('retorna null cuando no hay usuario autenticado', () {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      
      // Act
      final user = authRepository.currentUser;
      
      // Assert
      expect(user, isNull);
    });
  });

  group('signOut', () {
    test('retorna success cuando el cierre de sesión es exitoso', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      
      // Act
      final result = await authRepository.signOut();
      
      // Assert
      expect(result.isRight(), true);
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
    
    test('retorna UnexpectedError cuando ocurre un error', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('Error de cierre de sesión'));
      
      // Act
      final result = await authRepository.signOut();
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedError>()),
        (_) => fail('Should not return success'),
      );
    });
  });

  group('createUserWithEmailAndPassword', () {
    final testEmail = 'new@example.com';
    final testPassword = 'newpassword123';
    
    test('retorna User cuando la creación es exitosa', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);
      
      when(() => mockUserCredential.user).thenReturn(mockFirebaseUser);
      when(() => mockFirebaseUser.uid).thenReturn('new-uid');
      when(() => mockFirebaseUser.email).thenReturn(testEmail);
      when(() => mockFirebaseUser.getIdTokenResult(true))
          .thenAnswer((_) async => mockIdTokenResult);
      
      // Simular claims sin rol definido
      when(() => mockIdTokenResult.claims).thenReturn({});
      
      // Simular creación en Firestore
      when(() => mockUserDoc.set(any()))
          .thenAnswer((_) async {});
      when(() => mockUserDoc.get())
          .thenAnswer((_) async => mockUserSnapshot);
      when(() => mockUserSnapshot.exists).thenReturn(true);
      when(() => mockUserSnapshot.data())
          .thenReturn({'role': 'propietario'});
      
      // Act
      final result = await authRepository.createUserWithEmailAndPassword(
        testEmail,
        testPassword,
      );
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (user) {
          expect(user.id, 'new-uid');
          expect(user.email, testEmail);
          expect(user.role, AppRole.propietario);
        },
      );
      
      // Verify
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
      verify(() => mockUserDoc.set(any())).called(1);
    });
    
    test('retorna AuthFailure cuando ocurre un error de creación', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(
        firebase_auth.FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'El correo ya está en uso',
        ),
      );
      
      // Act
      final result = await authRepository.createUserWithEmailAndPassword(
        testEmail,
        testPassword,
      );
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect((failure as AuthFailure).code, 'email-already-in-use');
        },
        (_) => fail('Should not return success'),
      );
    });
  });
} 