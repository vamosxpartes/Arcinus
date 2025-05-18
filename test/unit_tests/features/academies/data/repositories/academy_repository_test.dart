import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/data/repositories/academy_repository_impl.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

// Mock de Firebase Storage
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockReference extends Mock implements Reference {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AcademyRepository academyRepository;
  late MockFirebaseStorage mockStorage;
  late MockReference mockStorageRef;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockStorageRef = MockReference();
    
    // Configurar el mock de Firebase Storage
    when(() => mockStorage.ref()).thenReturn(mockStorageRef);
    when(() => mockStorageRef.child(any())).thenReturn(mockStorageRef);
    
    // Inyectar el mock de Firebase Storage
    academyRepository = AcademyRepositoryImpl(fakeFirestore, storage: mockStorage);
  });

  group('createAcademy', () {
    test('debería crear una academia correctamente', () async {
      // Arrange
      final academy = AcademyModel(
        ownerId: 'owner-123',
        name: 'Academia Test',
        sportCode: 'futbol',
        address: 'Calle Principal 123',
        email: 'academia@test.com',
        phone: '123456789',
        description: 'Una academia de prueba',
      );

      // Act
      final result = await academyRepository.createAcademy(academy);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar: $l'),
        (createdAcademy) {
          expect(createdAcademy.id, isNotNull);
          expect(createdAcademy.name, academy.name);
          expect(createdAcademy.sportCode, academy.sportCode);
          expect(createdAcademy.createdAt, isNotNull);
          expect(createdAcademy.updatedAt, isNotNull);
        },
      );

      // Verificar que se guardó en Firestore
      final academiesSnapshot = await fakeFirestore.collection('academies').get();
      expect(academiesSnapshot.docs.length, 1);
      expect(academiesSnapshot.docs.first.data()['name'], academy.name);
    });

    test('debería formatear correctamente los números de teléfono como strings', () async {
      // Arrange
      final phoneNumber = 123456789;
      final academy = AcademyModel(
        ownerId: 'owner-123',
        name: 'Academia Test',
        sportCode: 'futbol',
        phone: phoneNumber.toString(), // Pasar como string
      );

      // Act
      final result = await academyRepository.createAcademy(academy);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar: $l'),
        (createdAcademy) {
          expect(createdAcademy.phone, phoneNumber.toString());
        },
      );
    });
  });

  group('getAcademyById', () {
    test('debería obtener una academia existente por ID', () async {
      // Arrange - crear primero una academia
      final academy = AcademyModel(
        ownerId: 'owner-123',
        name: 'Academia Test',
        sportCode: 'futbol',
      );
      
      final createResult = await academyRepository.createAcademy(academy);
      late String academyId;
      createResult.fold(
        (l) => fail('No debería fallar al crear: $l'),
        (createdAcademy) {
          academyId = createdAcademy.id!;
        },
      );

      // Act
      final result = await academyRepository.getAcademyById(academyId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar: $l'),
        (fetchedAcademy) {
          expect(fetchedAcademy.id, academyId);
          expect(fetchedAcademy.name, academy.name);
          expect(fetchedAcademy.sportCode, academy.sportCode);
        },
      );
    });

    test('debería devolver un error cuando el ID está vacío', () async {
      // Act
      final result = await academyRepository.getAcademyById('');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (r) => fail('No debería retornar academia: $r'),
      );
    });

    test('debería devolver un error cuando la academia no existe', () async {
      // Act
      final result = await academyRepository.getAcademyById('academia-inexistente');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (r) => fail('No debería retornar academia: $r'),
      );
    });
  });

  group('updateAcademy', () {
    test('debería actualizar una academia existente', () async {
      // Arrange - crear primero una academia
      final academy = AcademyModel(
        ownerId: 'owner-123',
        name: 'Academia Test',
        sportCode: 'futbol',
      );
      
      final createResult = await academyRepository.createAcademy(academy);
      late AcademyModel createdAcademy;
      createResult.fold(
        (l) => fail('No debería fallar al crear: $l'),
        (created) {
          createdAcademy = created;
        },
      );

      // Preparar actualización
      final updatedAcademy = createdAcademy.copyWith(
        name: 'Academia Actualizada',
        description: 'Descripción actualizada',
      );

      // Act
      final result = await academyRepository.updateAcademy(updatedAcademy);

      // Assert
      expect(result.isRight(), true);

      // Verificar que se actualizó en Firestore
      final academyDoc = await fakeFirestore.collection('academies').doc(createdAcademy.id).get();
      expect(academyDoc.data()!['name'], 'Academia Actualizada');
      expect(academyDoc.data()!['description'], 'Descripción actualizada');
      expect(academyDoc.data()!['sportCode'], 'futbol'); // Datos no actualizados permanecen
    });

    test('debería devolver error al actualizar academia sin ID', () async {
      // Arrange
      final academy = AcademyModel(
        ownerId: 'owner-123',
        name: 'Academia Test',
        sportCode: 'futbol',
      );

      // Act
      final result = await academyRepository.updateAcademy(academy);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('No debería actualizar una academia sin ID'),
      );
    });

    test('debería devolver error al intentar actualizar academia inexistente', () async {
      // Arrange
      final academy = AcademyModel(
        id: 'academia-inexistente',
        ownerId: 'owner-123',
        name: 'Academia Test',
        sportCode: 'futbol',
      );

      // Act
      final result = await academyRepository.updateAcademy(academy);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
        },
        (_) => fail('No debería actualizar una academia inexistente'),
      );
    });
  });
} 