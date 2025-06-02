import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/users/data/models/payment_status.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_providers.g.dart';

/// Provider que gestiona la lista de pagos de la academia actual
@riverpod
class AcademyPaymentsNotifier extends _$AcademyPaymentsNotifier {
  @override
  FutureOr<List<PaymentModel>> build() async {
    AppLogger.logInfo(
      'Iniciando carga de pagos de academia',
      className: 'AcademyPaymentsNotifier',
      functionName: 'build',
    );

    // El método build ahora devuelve directamente la Future que carga los datos
    // No se retorna un PaymentsState aquí, Riverpod maneja el AsyncValue
    return _fetchPayments();
  }

  /// Método privado para obtener los pagos
  Future<List<PaymentModel>> _fetchPayments() async {
    final currentAcademy = ref.read(currentAcademyProvider);

    AppLogger.logInfo(
      'Obteniendo pagos',
      className: 'AcademyPaymentsNotifier',
      functionName: '_fetchPayments',
      params: {
        'academia': currentAcademy?.name,
        'academiaId': currentAcademy?.id,
      },
    );

    if (currentAcademy == null || currentAcademy.id == null) {
      const errorMsg = 'No se pudo determinar la academia actual';
      AppLogger.logError(
        message: errorMsg,
        className: 'AcademyPaymentsNotifier',
        functionName: '_fetchPayments',
      );
      throw const Failure.serverError(message: errorMsg);
    }

    final paymentRepo = ref.read(paymentRepositoryProvider);
    AppLogger.logInfo(
      'Consultando repositorio de pagos',
      className: 'AcademyPaymentsNotifier',
      functionName: '_fetchPayments',
      params: {'academiaId': currentAcademy.id},
    );

    final result = await paymentRepo.getPaymentsByAcademy(currentAcademy.id!);

    return result.fold(
      (failure) {
        AppLogger.logError(
          message: 'Error al obtener pagos',
          error: failure,
          className: 'AcademyPaymentsNotifier',
          functionName: '_fetchPayments',
          params: {'failure': failure.toString()},
        );
        throw failure; // Lanzar el Failure en caso de error
      },
      (payments) {
        AppLogger.logInfo(
          'Pagos obtenidos exitosamente',
          className: 'AcademyPaymentsNotifier',
          functionName: '_fetchPayments',
          params: {'cantidadPagos': payments.length},
        );
        return payments; // Devolver la lista de pagos en caso de éxito
      },
    );
  }

  /// Carga/recarga los pagos invalidando el estado del provider.
  Future<void> refreshPayments() async {
    AppLogger.logInfo(
      'Refrescando pagos',
      className: 'AcademyPaymentsNotifier',
      functionName: 'refreshPayments',
    );
    // Invalida el provider para forzar la re-ejecución de build
    ref.invalidateSelf();
  }

  /// Registra un nuevo pago en la academia actual
  Future<void> registerPayment({
    required String athleteId,
    required double amount,
    required String currency,
    required DateTime paymentDate,
    String? concept,
    String? notes,
    String? receiptUrl,
    String? subscriptionPlanId,
    bool isPartialPayment = false,
    double? totalPlanAmount,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
  }) async {
    AppLogger.logInfo(
      'Registrando nuevo pago',
      className: 'AcademyPaymentsNotifier',
      functionName: 'registerPayment',
      params: {
        'atleta': athleteId,
        'monto': amount,
        'moneda': currency,
        'fecha': paymentDate.toString(),
      },
    );

    final currentAcademy = ref.read(currentAcademyProvider);
    final userId = ref.read(authStateNotifierProvider).user?.id;

    if (currentAcademy == null || currentAcademy.id == null || userId == null) {
      const errorMsg = 'Error al obtener información necesaria';
      AppLogger.logError(
        message: errorMsg,
        className: 'AcademyPaymentsNotifier',
        functionName: 'registerPayment',
        params: {'academiaId': currentAcademy?.id, 'userId': userId},
      );
      throw const Failure.serverError(message: errorMsg);
    }

    // Usar fecha actual automática para el registro del pago
    final currentDateTime = DateTime.now();
    final payment = PaymentModel(
      academyId: currentAcademy.id!,
      athleteId: athleteId,
      amount: amount,
      currency: currency,
      concept: concept,
      paymentDate: currentDateTime, // Fecha automática al momento del registro
      notes: notes,
      registeredBy: userId,
      createdAt: currentDateTime,
      receiptUrl: receiptUrl,
      subscriptionPlanId: subscriptionPlanId,
      isPartialPayment: isPartialPayment,
      totalPlanAmount: totalPlanAmount,
      periodStartDate: periodStartDate,
      periodEndDate: periodEndDate,
    );

    AppLogger.logInfo(
      'Creando modelo de pago',
      className: 'AcademyPaymentsNotifier',
      functionName: 'registerPayment',
      params: {
        'payment': '${payment.concept} - ${payment.amount} ${payment.currency}',
      },
    );

    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.registerPayment(payment);

    await result.fold(
      (failure) async {
        AppLogger.logError(
          message: 'Error al registrar pago',
          error: failure,
          className: 'AcademyPaymentsNotifier',
          functionName: 'registerPayment',
          params: {'failure': failure.toString()},
        );
        throw failure;
      },
      (newPayment) async {
        AppLogger.logInfo(
          'Pago registrado exitosamente',
          className: 'AcademyPaymentsNotifier',
          functionName: 'registerPayment',
          params: {'paymentId': newPayment.id},
        );
        // Si el registro fue exitoso, invalidar para recargar la lista
        ref.invalidateSelf();
      },
    );
  }

  /// Elimina un pago (soft delete)
  Future<void> deletePayment(String paymentId) async {
    AppLogger.logInfo(
      'Eliminando pago',
      className: 'AcademyPaymentsNotifier',
      functionName: 'deletePayment',
      params: {'paymentId': paymentId},
    );

    final paymentRepo = ref.read(paymentRepositoryProvider);
    final currentAcademy = ref.read(currentAcademyProvider);

    if (currentAcademy == null || currentAcademy.id == null) {
      const errorMsg = 'No se pudo determinar la academia actual';
      AppLogger.logError(
        message: errorMsg,
        className: 'AcademyPaymentsNotifier',
        functionName: 'deletePayment',
        params: {'academiaId': currentAcademy?.id},
      );
      throw const Failure.serverError(message: errorMsg);
    }

    final result = await paymentRepo.deletePayment(
      currentAcademy.id!,
      paymentId,
    );

    await result.fold(
      (failure) async {
        AppLogger.logError(
          message: 'Error al eliminar pago',
          error: failure,
          className: 'AcademyPaymentsNotifier',
          functionName: 'deletePayment',
          params: {'paymentId': paymentId, 'failure': failure.toString()},
        );
        throw failure;
      },
      (_) async {
        AppLogger.logInfo(
          'Pago eliminado exitosamente',
          className: 'AcademyPaymentsNotifier',
          functionName: 'deletePayment',
          params: {'paymentId': paymentId},
        );
        ref.invalidateSelf();
      },
    );
  }
}

/// Provider que gestiona los pagos de un atleta específico
@riverpod
class AthletePaymentsNotifier extends _$AthletePaymentsNotifier {
  @override
  FutureOr<List<PaymentModel>> build(String athleteId) {
    AppLogger.logInfo(
      'Iniciando carga de pagos de atleta',
      className: 'AthletePaymentsNotifier',
      functionName: 'build',
      params: {'athleteId': athleteId},
    );
    return _fetchAthletePayments(athleteId);
  }

  /// Carga los pagos de un atleta específico
  Future<List<PaymentModel>> _fetchAthletePayments(String athleteId) async {
    final currentAcademy = ref.read(currentAcademyProvider);

    AppLogger.logInfo(
      'Obteniendo pagos del atleta',
      className: 'AthletePaymentsNotifier',
      functionName: '_fetchAthletePayments',
      params: {'athleteId': athleteId, 'academiaId': currentAcademy?.id},
    );

    if (currentAcademy == null || currentAcademy.id == null) {
      const errorMsg = 'No se pudo determinar la academia actual';
      AppLogger.logError(
        message: errorMsg,
        className: 'AthletePaymentsNotifier',
        functionName: '_fetchAthletePayments',
        params: {'athleteId': athleteId},
      );
      throw const Failure.serverError(message: errorMsg);
    }

    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.getPaymentsByAthlete(
      currentAcademy.id!,
      athleteId,
    );

    return result.fold(
      (failure) {
        AppLogger.logError(
          message: 'Error al obtener pagos del atleta',
          error: failure,
          className: 'AthletePaymentsNotifier',
          functionName: '_fetchAthletePayments',
          params: {'athleteId': athleteId, 'failure': failure.toString()},
        );
        throw failure;
      },
      (payments) {
        AppLogger.logInfo(
          'Pagos del atleta obtenidos exitosamente',
          className: 'AthletePaymentsNotifier',
          functionName: '_fetchAthletePayments',
          params: {'athleteId': athleteId, 'cantidadPagos': payments.length},
        );
        return payments;
      },
    );
  }

  /// Recarga los pagos del atleta.
  Future<void> refreshAthletePayments(String athleteId) async {
    AppLogger.logInfo(
      'Refrescando pagos del atleta',
      className: 'AthletePaymentsNotifier',
      functionName: 'refreshAthletePayments',
      params: {'athleteId': athleteId},
    );
    ref.invalidateSelf();
  }
}
