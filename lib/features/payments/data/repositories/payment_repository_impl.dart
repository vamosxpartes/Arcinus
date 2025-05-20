import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/domain/repositories/payment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'payment_repository_impl.g.dart';

/// Proveedor del repositorio de pagos
@riverpod
PaymentRepository paymentRepository(Ref ref) {
  AppLogger.logInfo(
    'Creando instancia de PaymentRepository',
    className: 'payment_repository',
    functionName: 'paymentRepository',
  );
  return PaymentRepositoryImpl(firestore: FirebaseFirestore.instance);
}

/// Implementación del repositorio de pagos
class PaymentRepositoryImpl implements PaymentRepository {
  static const String _className = 'PaymentRepositoryImpl';
  final FirebaseFirestore _firestore;

  PaymentRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore {
    AppLogger.logInfo(
      'Inicializado PaymentRepositoryImpl',
      className: _className,
      functionName: 'constructor',
    );
  }

  // Referencia a la subcolección de pagos de una academia
  CollectionReference<Map<String, dynamic>> _getPaymentsCollection(
    String academyId,
  ) {
    return _firestore
        .collection('academies')
        .doc(academyId)
        .collection('payments');
  }

  @override
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByAcademy(
    String academyId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo pagos por academia',
        className: _className,
        functionName: 'getPaymentsByAcademy',
        params: {'academyId': academyId},
      );

      final snapshot =
          await _getPaymentsCollection(academyId)
              .where('isDeleted', isEqualTo: false)
              .orderBy('paymentDate', descending: true)
              .get();

      final payments =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return PaymentModel.fromJson({...data, 'id': doc.id});
          }).toList();

      AppLogger.logInfo(
        'Pagos obtenidos exitosamente',
        className: _className,
        functionName: 'getPaymentsByAcademy',
        params: {'academyId': academyId, 'count': payments.length},
      );

      return right(payments);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener pagos por academia',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getPaymentsByAcademy',
        params: {'academyId': academyId},
      );
      return left(
        const Failure.serverError(message: 'Error al obtener los pagos'),
      );
    }
  }

  @override
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByAthlete(
    String academyId,
    String athleteId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo pagos por atleta',
        className: _className,
        functionName: 'getPaymentsByAthlete',
        params: {'academyId': academyId, 'athleteId': athleteId},
      );

      final snapshot =
          await _getPaymentsCollection(academyId)
              .where('athleteId', isEqualTo: athleteId)
              .where('isDeleted', isEqualTo: false)
              .orderBy('paymentDate', descending: true)
              .get();

      final payments =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return PaymentModel.fromJson({...data, 'id': doc.id});
          }).toList();

      AppLogger.logInfo(
        'Pagos por atleta obtenidos exitosamente',
        className: _className,
        functionName: 'getPaymentsByAthlete',
        params: {
          'academyId': academyId,
          'athleteId': athleteId,
          'count': payments.length,
        },
      );

      return right(payments);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener pagos por atleta',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getPaymentsByAthlete',
        params: {'academyId': academyId, 'athleteId': athleteId},
      );
      return left(
        const Failure.serverError(
          message: 'Error al obtener los pagos del atleta',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentModel>> registerPayment(
    PaymentModel payment,
  ) async {
    try {
      AppLogger.logInfo(
        'Registrando nuevo pago',
        className: _className,
        functionName: 'registerPayment',
        params: {
          'academyId': payment.academyId,
          'amount': payment.amount,
          'concept': payment.concept,
          'athleteId': payment.athleteId,
        },
      );

      final academyId = payment.academyId;
      // No necesitamos incluir academyId en el documento cuando está en una subcolección
      final paymentData = payment.toJson();

      final docRef = await _getPaymentsCollection(academyId).add(paymentData);

      // Crear un nuevo modelo con el ID asignado
      final registeredPayment = payment.copyWith(id: docRef.id);

      AppLogger.logInfo(
        'Pago registrado exitosamente',
        className: _className,
        functionName: 'registerPayment',
        params: {
          'academyId': payment.academyId,
          'paymentId': docRef.id,
          'amount': payment.amount,
          'concept': payment.concept,
        },
      );

      return right(registeredPayment);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al registrar pago',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'registerPayment',
        params: {'academyId': payment.academyId, 'concept': payment.concept},
      );
      return left(
        const Failure.serverError(message: 'Error al registrar el pago'),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentModel>> updatePayment(
    PaymentModel payment,
  ) async {
    try {
      if (payment.id == null) {
        AppLogger.logWarning(
          'Intento de actualización de pago sin ID',
          className: _className,
          functionName: 'updatePayment',
          params: {'academyId': payment.academyId},
        );
        return left(
          const Failure.serverError(message: 'El pago no tiene un ID válido'),
        );
      }

      AppLogger.logInfo(
        'Actualizando pago',
        className: _className,
        functionName: 'updatePayment',
        params: {
          'academyId': payment.academyId,
          'paymentId': payment.id,
          'amount': payment.amount,
        },
      );

      await _getPaymentsCollection(
        payment.academyId,
      ).doc(payment.id).update(payment.toJson());

      AppLogger.logInfo(
        'Pago actualizado exitosamente',
        className: _className,
        functionName: 'updatePayment',
        params: {'academyId': payment.academyId, 'paymentId': payment.id},
      );

      return right(payment);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar pago',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updatePayment',
        params: {'academyId': payment.academyId, 'paymentId': payment.id},
      );
      return left(
        const Failure.serverError(message: 'Error al actualizar el pago'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePayment(
    String academyId,
    String paymentId,
  ) async {
    try {
      AppLogger.logInfo(
        'Eliminando pago (soft delete)',
        className: _className,
        functionName: 'deletePayment',
        params: {'academyId': academyId, 'paymentId': paymentId},
      );

      // Soft delete - marcar como eliminado en lugar de eliminar físicamente
      await _getPaymentsCollection(
        academyId,
      ).doc(paymentId).update({'isDeleted': true});

      AppLogger.logInfo(
        'Pago eliminado exitosamente',
        className: _className,
        functionName: 'deletePayment',
        params: {'academyId': academyId, 'paymentId': paymentId},
      );

      return right(unit);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al eliminar pago',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'deletePayment',
        params: {'academyId': academyId, 'paymentId': paymentId},
      );
      return left(
        const Failure.serverError(message: 'Error al eliminar el pago'),
      );
    }
  }

  @override
  Future<Either<Failure, List<PaymentModel>>> searchPaymentsByDateRange(
    String academyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      AppLogger.logInfo(
        'Buscando pagos por rango de fechas',
        className: _className,
        functionName: 'searchPaymentsByDateRange',
        params: {
          'academyId': academyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      final snapshot =
          await _getPaymentsCollection(academyId)
              .where('isDeleted', isEqualTo: false)
              .where('paymentDate', isGreaterThanOrEqualTo: startDate)
              .where('paymentDate', isLessThanOrEqualTo: endDate)
              .orderBy('paymentDate', descending: true)
              .get();

      final payments =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return PaymentModel.fromJson({...data, 'id': doc.id});
          }).toList();

      AppLogger.logInfo(
        'Pagos por rango de fechas obtenidos exitosamente',
        className: _className,
        functionName: 'searchPaymentsByDateRange',
        params: {
          'academyId': academyId,
          'count': payments.length,
          'dateRange':
              '${startDate.toIso8601String()} - ${endDate.toIso8601String()}',
        },
      );

      return right(payments);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al buscar pagos por rango de fechas',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'searchPaymentsByDateRange',
        params: {
          'academyId': academyId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      return left(
        const Failure.serverError(
          message: 'Error al buscar pagos en el rango de fechas',
        ),
      );
    }
  }
}
