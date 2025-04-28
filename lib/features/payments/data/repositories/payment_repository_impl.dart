import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/domain/repositories/payment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_repository_impl.g.dart';

/// Proveedor del repositorio de pagos
@riverpod
PaymentRepository paymentRepository(PaymentRepositoryRef ref) {
  return PaymentRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
}

/// Implementación del repositorio de pagos
class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore;
  
  PaymentRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;
  
  // Colección de pagos en Firestore
  CollectionReference<Map<String, dynamic>> get _paymentsCollection =>
      _firestore.collection('payments');

  @override
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByAcademy(String academyId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('academyId', isEqualTo: academyId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('paymentDate', descending: true)
          .get();

      final payments = snapshot.docs.map((doc) {
        final data = doc.data();
        return PaymentModel.fromJson({...data, 'id': doc.id});
      }).toList();

      return right(payments);
    } catch (e) {
      return left(const Failure.serverError(message: 'Error al obtener los pagos'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByAthlete(
      String academyId, String athleteId) async {
    try {
      final snapshot = await _paymentsCollection
          .where('academyId', isEqualTo: academyId)
          .where('athleteId', isEqualTo: athleteId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('paymentDate', descending: true)
          .get();

      final payments = snapshot.docs.map((doc) {
        final data = doc.data();
        return PaymentModel.fromJson({...data, 'id': doc.id});
      }).toList();

      return right(payments);
    } catch (e) {
      return left(const Failure.serverError(
          message: 'Error al obtener los pagos del atleta'));
    }
  }

  @override
  Future<Either<Failure, PaymentModel>> registerPayment(PaymentModel payment) async {
    try {
      final docRef = await _paymentsCollection.add(payment.toJson());
      
      // Crear un nuevo modelo con el ID asignado
      final registeredPayment = payment.copyWith(id: docRef.id);
      
      return right(registeredPayment);
    } catch (e) {
      return left(const Failure.serverError(message: 'Error al registrar el pago'));
    }
  }

  @override
  Future<Either<Failure, PaymentModel>> updatePayment(PaymentModel payment) async {
    try {
      if (payment.id == null) {
        return left(const Failure.serverError(
            message: 'El pago no tiene un ID válido'));
      }
      
      await _paymentsCollection.doc(payment.id).update(payment.toJson());
      
      return right(payment);
    } catch (e) {
      return left(const Failure.serverError(message: 'Error al actualizar el pago'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePayment(String paymentId) async {
    try {
      // Soft delete - marcar como eliminado en lugar de eliminar físicamente
      await _paymentsCollection.doc(paymentId).update({'isDeleted': true});
      
      return right(unit);
    } catch (e) {
      return left(const Failure.serverError(message: 'Error al eliminar el pago'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentModel>>> searchPaymentsByDateRange(
      String academyId, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _paymentsCollection
          .where('academyId', isEqualTo: academyId)
          .where('isDeleted', isEqualTo: false)
          .where('paymentDate', isGreaterThanOrEqualTo: startDate)
          .where('paymentDate', isLessThanOrEqualTo: endDate)
          .orderBy('paymentDate', descending: true)
          .get();

      final payments = snapshot.docs.map((doc) {
        final data = doc.data();
        return PaymentModel.fromJson({...data, 'id': doc.id});
      }).toList();

      return right(payments);
    } catch (e) {
      return left(const Failure.serverError(
          message: 'Error al buscar pagos en el rango de fechas'));
    }
  }
} 