import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart';
import 'package:arcinus/features/users/data/models/manager_user_model.dart';
import 'package:arcinus/features/users/data/repositories/user_repository_impl.dart';
import 'package:arcinus/features/users/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late UserRepository userRepository;
  late FakeFirebaseFirestore fakeFirestore;

  final testUser = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    appRole: AppRole.desconocido,
    createdAt: DateTime.now(),
  );

  // Configuración utilizando fake_cloud_firestore para pruebas de integración
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    userRepository = UserRepositoryImpl(fakeFirestore);
  });

  group('getUserByEmail', () {
    test('debería devolver un usuario cuando existe con el email dado', () async {
      // Arrange
      final userJson = testUser.toJson();
      await fakeFirestore.collection('users').doc(testUser.id).set(userJson);

      // Act
      final result = await userRepository.getUserByEmail(testUser.email);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r, isNotNull);
          expect(r!.email, testUser.email);
        },
      );
    });

    test('debería devolver null cuando no existe usuario con el email dado', () async {
      // Arrange - no se agrega ningún usuario a Firestore

      // Act
      final result = await userRepository.getUserByEmail('nonexistent@example.com');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) => expect(r, isNull),
      );
    });

    test('debería devolver un error de validación para email inválido', () async {
      // Act
      final result = await userRepository.getUserByEmail('');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Debería fallar con ValidationFailure'),
      );
    });
  });

  group('getUserById', () {
    test('debería devolver un usuario cuando existe con el ID dado', () async {
      // Arrange
      final userJson = testUser.toJson();
      await fakeFirestore.collection('users').doc(testUser.id).set(userJson);

      // Act
      final result = await userRepository.getUserById(testUser.id);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) => expect(r.email, testUser.email),
      );
    });

    test('debería devolver error NotFound cuando no existe usuario con el ID dado', () async {
      // Act
      final result = await userRepository.getUserById('non-existent-id');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<Failure>().having((f) => f.message.contains('no encontrado'), 'es error de no encontrado', true)),
        (r) => fail('Debería fallar con Failure.notFound'),
      );
    });

    test('debería devolver error ValidationFailure para ID vacío', () async {
      // Act
      final result = await userRepository.getUserById('');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Debería fallar con ValidationFailure'),
      );
    });
  });

  group('upsertUser', () {
    test('debería crear un usuario si no existe', () async {
      // Act
      final result = await userRepository.upsertUser(testUser);

      // Assert
      expect(result.isRight(), true);
      
      // Verificar que realmente se guardó en Firestore
      final doc = await fakeFirestore.collection('users').doc(testUser.id).get();
      expect(doc.exists, true);
      expect(doc.data()!['email'], testUser.email);
    });

    test('debería actualizar un usuario existente', () async {
      // Arrange - Primero creamos un usuario
      await fakeFirestore.collection('users').doc(testUser.id).set(testUser.toJson());
      
      // Usuario actualizado con nuevo displayName
      final updatedUser = testUser.copyWith(displayName: 'Updated Name');
      
      // Act
      final result = await userRepository.upsertUser(updatedUser);

      // Assert
      expect(result.isRight(), true);
      
      // Verificar que realmente se actualizó en Firestore
      final doc = await fakeFirestore.collection('users').doc(testUser.id).get();
      expect(doc.exists, true);
      expect(doc.data()!['displayName'], 'Updated Name');
    });

    test('debería devolver error ValidationFailure para usuario con ID vacío', () async {
      // Arrange
      final invalidUser = testUser.copyWith(id: '');
      
      // Act
      final result = await userRepository.upsertUser(invalidUser);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Debería fallar con ValidationFailure'),
      );
    });
  });

  group('createOrUpdateManagerUser', () {
    test('debería crear un manager de tipo propietario correctamente', () async {
      // Arrange - Primero creamos un usuario base
      await fakeFirestore.collection('users').doc(testUser.id).set(testUser.toJson());
      
      // Act
      final result = await userRepository.createOrUpdateManagerUser(
        testUser.id, 
        'academy-id', 
        AppRole.propietario
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.userId, testUser.id);
          expect(r.academyId, 'academy-id');
          expect(r.managerType, AppRole.propietario);
          expect(r.permissions.contains(ManagerPermission.fullAccess), true);
        },
      );

      // Verificar que realmente se guardó en Firestore
      final doc = await fakeFirestore
          .collection('academies')
          .doc('academy-id')
          .collection('managers')
          .doc(testUser.id)
          .get();
      expect(doc.exists, true);
    });

    test('debería crear un manager de tipo colaborador con permisos específicos', () async {
      // Arrange - Primero creamos un usuario base
      await fakeFirestore.collection('users').doc(testUser.id).set(testUser.toJson());
      
      // Act
      final result = await userRepository.createOrUpdateManagerUser(
        testUser.id, 
        'academy-id', 
        AppRole.colaborador,
        permissions: [ManagerPermission.manageUsers, ManagerPermission.viewStats]
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.userId, testUser.id);
          expect(r.academyId, 'academy-id');
          expect(r.managerType, AppRole.colaborador);
          expect(r.permissions.contains(ManagerPermission.manageUsers), true);
          expect(r.permissions.contains(ManagerPermission.viewStats), true);
          expect(r.permissions.contains(ManagerPermission.fullAccess), false);
        },
      );
    });

    test('debería devolver error ValidationFailure para tipo de manager inválido', () async {
      // Arrange - Primero creamos un usuario base
      await fakeFirestore.collection('users').doc(testUser.id).set(testUser.toJson());
      
      // Act
      final result = await userRepository.createOrUpdateManagerUser(
        testUser.id, 
        'academy-id', 
        AppRole.atleta // Rol inválido para manager
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Debería fallar con ValidationFailure'),
      );
    });

    test('debería devolver error NotFound si el usuario no existe', () async {
      // Act
      final result = await userRepository.createOrUpdateManagerUser(
        'non-existent-id', 
        'academy-id', 
        AppRole.propietario
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<Failure>().having((f) => f.message.contains('no encontrado'), 'es error de no encontrado', true)),
        (r) => fail('Debería fallar con Failure.notFound'),
      );
    });
  });

  group('createOrUpdateClientUser', () {
    test('debería crear un cliente de tipo atleta correctamente', () async {
      // Arrange - Primero creamos un usuario base
      await fakeFirestore.collection('users').doc(testUser.id).set(testUser.toJson());
      
      // Act
      final result = await userRepository.createOrUpdateClientUser(
        testUser.id, 
        'academy-id', 
        AppRole.atleta
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.userId, testUser.id);
          expect(r.academyId, 'academy-id');
          expect(r.clientType, AppRole.atleta);
        },
      );

      // Verificar que realmente se guardó en Firestore
      final doc = await fakeFirestore
          .collection('academies')
          .doc('academy-id')
          .collection('clients')
          .doc(testUser.id)
          .get();
      expect(doc.exists, true);
    });

    test('debería crear un cliente de tipo padre con metadata adicional', () async {
      // Arrange - Primero creamos un usuario base
      await fakeFirestore.collection('users').doc(testUser.id).set(testUser.toJson());
      
      // Act
      final additionalData = {'childrenIds': ['child1', 'child2']};
      final result = await userRepository.createOrUpdateClientUser(
        testUser.id, 
        'academy-id', 
        AppRole.padre,
        additionalData: additionalData
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.userId, testUser.id);
          expect(r.academyId, 'academy-id');
          expect(r.clientType, AppRole.padre);
          expect(r.metadata, additionalData);
        },
      );
    });

    test('debería devolver error ValidationFailure para tipo de cliente inválido', () async {
      // Arrange - Primero creamos un usuario base
      await fakeFirestore.collection('users').doc(testUser.id).set(testUser.toJson());
      
      // Act
      final result = await userRepository.createOrUpdateClientUser(
        testUser.id, 
        'academy-id', 
        AppRole.propietario // Rol inválido para cliente
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ValidationFailure>()),
        (r) => fail('Debería fallar con ValidationFailure'),
      );
    });

    test('debería devolver error NotFound si el usuario no existe', () async {
      // Act
      final result = await userRepository.createOrUpdateClientUser(
        'non-existent-id', 
        'academy-id', 
        AppRole.atleta
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<Failure>().having((f) => f.message.contains('no encontrado'), 'es error de no encontrado', true)),
        (r) => fail('Debería fallar con Failure.notFound'),
      );
    });
  });
} 