import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/payments/domain/repositories/payment_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PaymentRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  
  final testAcademyId = 'test-academy-id';
  final testAthleteId = 'test-athlete-id';

  // Datos de prueba
  final testPaymentModel = PaymentModel(
    academyId: testAcademyId,
    athleteId: testAthleteId,
    amount: 500.0,
    currency: 'MXN',
    concept: 'Mensualidad Octubre',
    paymentDate: DateTime(2023, 10, 15),
    registeredBy: 'admin-id',
    createdAt: DateTime(2023, 10, 15, 10, 30),
  );
  

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = PaymentRepositoryImpl(firestore: fakeFirestore);
  });

  group('getPaymentsByAcademy', () {
    test('debería retornar lista vacía cuando no hay pagos', () async {
      // Act
      final result = await repository.getPaymentsByAcademy(testAcademyId);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) => expect(r, isEmpty),
      );
    });

    test('debería retornar lista de pagos de la academia', () async {
      // Arrange
      final paymentRef = fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments');
      
      await paymentRef.add(testPaymentModel.toJson());
      await paymentRef.add(testPaymentModel.copyWith(amount: 600.0).toJson());
      
      // Act
      final result = await repository.getPaymentsByAcademy(testAcademyId);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.length, 2);
          expect(r.any((payment) => payment.amount == 500.0), true);
          expect(r.any((payment) => payment.amount == 600.0), true);
        },
      );
    });
    
    test('no debería retornar pagos marcados como eliminados', () async {
      // Arrange
      final paymentRef = fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments');
      
      await paymentRef.add(testPaymentModel.toJson());
      await paymentRef.add(testPaymentModel.copyWith(amount: 600.0, isDeleted: true).toJson());
      
      // Act
      final result = await repository.getPaymentsByAcademy(testAcademyId);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.length, 1);
          expect(r.first.amount, 500.0);
        },
      );
    });
  });

  group('getPaymentsByAthlete', () {
    test('debería retornar pagos de un atleta específico', () async {
      // Arrange
      final paymentRef = fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments');
      
      await paymentRef.add(testPaymentModel.toJson());
      await paymentRef.add(testPaymentModel.copyWith(athleteId: 'otro-atleta').toJson());
      
      // Act
      final result = await repository.getPaymentsByAthlete(testAcademyId, testAthleteId);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.length, 1);
          expect(r.first.athleteId, testAthleteId);
        },
      );
    });
  });

  group('registerPayment', () {
    test('debería registrar un nuevo pago correctamente', () async {
      // Act
      final result = await repository.registerPayment(testPaymentModel);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.id, isNotNull);
          expect(r.amount, 500.0);
          expect(r.athleteId, testAthleteId);
        },
      );
      
      // Verificar que se guardó en Firestore
      final snapshot = await fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments')
          .get();
          
      expect(snapshot.docs.length, 1);
    });
  });

  group('updatePayment', () {
    test('debería actualizar un pago existente correctamente', () async {
      // Arrange - Crear primero un pago
      final docRef = await fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments')
          .add(testPaymentModel.toJson());
      
      final paymentToUpdate = testPaymentModel.copyWith(
        id: docRef.id,
        amount: 750.0,
        concept: 'Concepto actualizado',
      );
      
      // Act
      final result = await repository.updatePayment(paymentToUpdate);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.id, docRef.id);
          expect(r.amount, 750.0);
          expect(r.concept, 'Concepto actualizado');
        },
      );
      
      // Verificar en Firestore
      final updatedDoc = await fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments')
          .doc(docRef.id)
          .get();
          
      final updatedData = updatedDoc.data();
      expect(updatedData?['amount'], 750.0);
      expect(updatedData?['concept'], 'Concepto actualizado');
    });
    
    test('debería fallar si el pago no tiene ID', () async {
      // Act
      final result = await repository.updatePayment(testPaymentModel); // Sin ID
      
      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<Failure>()),
        (r) => fail('Debería fallar'),
      );
    });
  });

  group('deletePayment', () {
    test('debería realizar soft delete de un pago', () async {
      // Arrange - Crear primero un pago
      final docRef = await fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments')
          .add(testPaymentModel.toJson());
      
      // Act
      final result = await repository.deletePayment(testAcademyId, docRef.id);
      
      // Assert
      expect(result.isRight(), true);
      
      // Verificar en Firestore que se marcó como eliminado
      final updatedDoc = await fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments')
          .doc(docRef.id)
          .get();
          
      expect(updatedDoc.data()?['isDeleted'], true);
    });
  });

  group('searchPaymentsByDateRange', () {
    test('debería retornar pagos dentro del rango de fechas', () async {
      // Arrange
      final paymentRef = fakeFirestore
          .collection('academies')
          .doc(testAcademyId)
          .collection('payments');
      
      // Pagos en diferentes fechas
      await paymentRef.add(testPaymentModel.copyWith(
        paymentDate: DateTime(2023, 9, 15),
      ).toJson());
      
      await paymentRef.add(testPaymentModel.copyWith(
        paymentDate: DateTime(2023, 10, 15),
      ).toJson());
      
      await paymentRef.add(testPaymentModel.copyWith(
        paymentDate: DateTime(2023, 11, 15),
      ).toJson());
      
      // Act
      final result = await repository.searchPaymentsByDateRange(
        testAcademyId,
        DateTime(2023, 10, 1),
        DateTime(2023, 10, 31),
      );
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.length, 1);
          expect(r.first.paymentDate.month, 10);
        },
      );
    });
  });
} 