import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz para el repositorio de pagos
abstract class PaymentRepository {
  /// Obtiene todos los pagos de una academia
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByAcademy(String academyId);
  
  /// Obtiene todos los pagos de un atleta específico
  Future<Either<Failure, List<PaymentModel>>> getPaymentsByAthlete(String academyId, String athleteId);
  
  /// Registra un nuevo pago
  Future<Either<Failure, PaymentModel>> registerPayment(PaymentModel payment);
  
  /// Actualiza un pago existente
  Future<Either<Failure, PaymentModel>> updatePayment(PaymentModel payment);
  
  /// Elimina un pago (soft delete)
  Future<Either<Failure, Unit>> deletePayment(String paymentId);
  
  /// Busca pagos por período de fecha
  Future<Either<Failure, List<PaymentModel>>> searchPaymentsByDateRange(
    String academyId,
    DateTime startDate,
    DateTime endDate,
  );
} 