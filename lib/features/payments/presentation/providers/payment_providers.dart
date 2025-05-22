import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_providers.g.dart';
part 'payment_providers.freezed.dart';

/// Estado para la gestión de pagos
@freezed
class PaymentsState with _$PaymentsState {
  const factory PaymentsState({
    @Default([]) List<PaymentModel> payments,
    @Default(false) bool isLoading,
    Failure? failure,
  }) = _PaymentsState;
}

/// Estado para el formulario de pago
@freezed
class PaymentFormState with _$PaymentFormState {
  const factory PaymentFormState({
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
    Failure? failure,
  }) = _PaymentFormState;
}

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
    // Opcionalmente, esperar a que la nueva carga termine si es necesario
    // await future;
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

    // Ya no se modifica el state aquí directamente para indicar carga
    // El estado AsyncValue se manejará automáticamente por la recarga

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
      // Lanzar un error o manejarlo de forma apropiada
      // En un AsyncNotifier, esto pondría el estado en AsyncError
      throw const Failure.serverError(message: errorMsg);
    }

    final payment = PaymentModel(
      academyId: currentAcademy.id!,
      athleteId: athleteId,
      amount: amount,
      currency: currency,
      concept: concept,
      paymentDate: paymentDate,
      notes: notes,
      registeredBy: userId,
      createdAt: DateTime.now(),
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
        // En caso de error al registrar, lanzar la excepción
        // para que la UI pueda reaccionar al estado AsyncError.
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

    // Ya no se modifica el state aquí directamente para indicar carga

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
        // Lanzar excepción en caso de error
        throw failure;
      },
      (_) async {
        AppLogger.logInfo(
          'Pago eliminado exitosamente',
          className: 'AcademyPaymentsNotifier',
          functionName: 'deletePayment',
          params: {'paymentId': paymentId},
        );
        // Invalidar para recargar la lista tras eliminar
        ref.invalidateSelf();
      },
    );
  }
}

/// Provider que gestiona los pagos de un atleta específico
@riverpod
class AthletePaymentsNotifier extends _$AthletePaymentsNotifier {
  // Convertir también a AsyncNotifier si se necesita estado AsyncValue
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
    // await future;
  }
}

/// Provider para el formulario de registro de pago
@riverpod
class PaymentFormNotifier extends _$PaymentFormNotifier {
  @override
  PaymentFormState build() {
    AppLogger.logInfo(
      'Inicializando formulario de pago',
      className: 'PaymentFormNotifier',
      functionName: 'build',
    );
    return const PaymentFormState();
  }

  /// Registra un nuevo pago
  Future<void> submitPayment({
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
      'Enviando formulario de pago',
      className: 'PaymentFormNotifier',
      functionName: 'submitPayment',
      params: {
        'atleta': athleteId,
        'monto': amount,
        'moneda': currency,
        'fecha': paymentDate.toString(),
        'esParcial': isPartialPayment,
      },
    );

    state = state.copyWith(isSubmitting: true, failure: null, isSuccess: false);

    try {
      final currentAcademy = ref.read(currentAcademyProvider);
      if (currentAcademy == null || currentAcademy.id == null) {
        throw const Failure.serverError(message: 'No se pudo determinar la academia actual');
      }
      
      // Obtener la configuración de pagos de la academia
      final paymentConfigAsync = await ref.read(paymentConfigProvider(currentAcademy.id!).future);
      
      // Comprobar si se permiten pagos parciales
      if (isPartialPayment && !paymentConfigAsync.allowPartialPayments) {
        throw const Failure.validationError(message: 'Los pagos parciales no están habilitados en esta academia');
      }

      // Llamar directamente al método del Notifier de pagos de academia
      await ref
          .read(academyPaymentsNotifierProvider.notifier)
          .registerPayment(
            athleteId: athleteId,
            amount: amount,
            currency: currency,
            paymentDate: paymentDate,
            concept: concept,
            notes: notes,
            receiptUrl: receiptUrl,
            subscriptionPlanId: subscriptionPlanId,
            isPartialPayment: isPartialPayment,
            totalPlanAmount: totalPlanAmount,
            periodStartDate: periodStartDate,
            periodEndDate: periodEndDate,
          );
      
      // Después de registrar el pago exitosamente, actualizar el estado del atleta
      // según el modo de facturación y si el pago es parcial o completo
      final clientUserRepository = ref.read(clientUserRepositoryProvider);
      
      // Determinar el estado de pago según el modo de facturación y si es pago parcial
      PaymentStatus newPaymentStatus;
      
      if (isPartialPayment && totalPlanAmount != null && amount < totalPlanAmount) {
        // Si es pago parcial, el estado debería ser ACTIVE pero controlado por la fecha de vencimiento
        newPaymentStatus = PaymentStatus.active;
      } else {
        // Para pagos completos, siempre es ACTIVE
        newPaymentStatus = PaymentStatus.active;
      }
      
      // Aplicar el estado según el modo de facturación
      switch (paymentConfigAsync.billingMode) {
        case BillingMode.advance:
          // Pago por adelantado: estado activo inmediato
          newPaymentStatus = PaymentStatus.active;
          break;
        case BillingMode.current:
          // Pago mes en curso: activo si el pago cubre el periodo actual
          newPaymentStatus = PaymentStatus.active;
          break;
        case BillingMode.arrears:
          // Pago mes vencido: podría depender de otras condiciones
          // Por defecto activamos el usuario pero esto podría ajustarse
          newPaymentStatus = PaymentStatus.active;
          break;
      }
      
      // Actualizar el estado de pago del atleta
      final updateResult = await clientUserRepository.updateClientUserPaymentStatus(
        currentAcademy.id!,
        athleteId,
        newPaymentStatus,
      );
      
      updateResult.fold(
        (failure) {
          AppLogger.logWarning(
            'Se registró el pago pero no se pudo actualizar el estado del atleta',
            className: 'PaymentFormNotifier',
            functionName: 'submitPayment',
            params: {'athleteId': athleteId, 'failure': failure.toString()},
          );
          // No fallamos completamente ya que el pago se registró correctamente
        },
        (_) {
          AppLogger.logInfo(
            'Estado de pago del atleta actualizado a ${newPaymentStatus.name}',
            className: 'PaymentFormNotifier',
            functionName: 'submitPayment',
            params: {'athleteId': athleteId},
          );
          
          // También actualizar lastPaymentDate y otros datos relevantes del usuario
          try {
            // Obtener los datos actuales del usuario para preservarlos
            clientUserRepository.getClientUser(currentAcademy.id!, athleteId).then((userResult) {
              userResult.fold(
                (failure) {
                  AppLogger.logWarning(
                    'No se pudo obtener datos del usuario para actualizar lastPaymentDate',
                    className: 'PaymentFormNotifier',
                    functionName: 'submitPayment',
                    params: {'athleteId': athleteId, 'failure': failure.toString()},
                  );
                },
                (user) {
                  // Calcular la próxima fecha de pago si tenemos un plan de suscripción
                  DateTime? nextPaymentDate;
                  int? remainingDays;
                  
                  if (subscriptionPlanId != null && user.subscriptionPlan != null) {
                    // Calcular según el ciclo de facturación del plan
                    nextPaymentDate = _calculateNextPaymentDate(
                      paymentDate, 
                      user.subscriptionPlan!.billingCycle,
                      paymentConfigAsync.billingMode
                    );
                    
                    // Calcular días restantes
                    remainingDays = nextPaymentDate.difference(DateTime.now()).inDays;
                    remainingDays = remainingDays < 0 ? 0 : remainingDays;
                                    }
                  
                  // Preparar datos actualizados manteniendo los datos existentes
                  final updatedClientData = {
                    'subscriptionPlanId': subscriptionPlanId ?? user.subscriptionPlanId,
                    'paymentStatus': newPaymentStatus.name,
                    'lastPaymentDate': Timestamp.fromDate(paymentDate),
                    if (nextPaymentDate != null)
                      'nextPaymentDate': Timestamp.fromDate(nextPaymentDate),
                    if (remainingDays != null)
                      'remainingDays': remainingDays,
                  };
                  
                  // Actualizar los datos del usuario
                  clientUserRepository.updateClientUser(
                    currentAcademy.id!,
                    athleteId,
                    updatedClientData,
                  );
                },
              );
            });
          } catch (e) {
            AppLogger.logWarning(
              'Error al actualizar lastPaymentDate',
              className: 'PaymentFormNotifier',
              functionName: 'submitPayment',
              params: {'error': e.toString()},
            );
          }
        },
      );
      
      // Si la llamada anterior no lanzó excepción, fue exitosa
      AppLogger.logInfo(
        'Pago registrado exitosamente desde formulario',
        className: 'PaymentFormNotifier',
        functionName: 'submitPayment',
      );
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } on Failure catch (failure) {
      // Si registerPayment lanzó un Failure, lo capturamos aquí
      AppLogger.logError(
        message: 'Error al enviar formulario de pago',
        error: failure,
        className: 'PaymentFormNotifier',
        functionName: 'submitPayment',
        params: {'failure': failure.toString()},
      );
      state = state.copyWith(
        isSubmitting: false,
        failure: failure,
        isSuccess: false,
      );
    } catch (e) {
      // Capturar otros posibles errores
      AppLogger.logError(
        message: 'Error inesperado al enviar formulario de pago',
        error: e,
        className: 'PaymentFormNotifier',
        functionName: 'submitPayment',
      );
      state = state.copyWith(
        isSubmitting: false,
        failure: Failure.unexpectedError(error: e),
        isSuccess: false,
      );
    }
  }

  /// Calcular la próxima fecha de pago según el ciclo de facturación y modo de pago
  DateTime _calculateNextPaymentDate(
    DateTime currentPaymentDate, 
    BillingCycle billingCycle,
    BillingMode billingMode
  ) {
    // Ajustar la fecha base según el modo de facturación
    DateTime baseDate;
    
    switch (billingMode) {
      case BillingMode.advance:
        // Para pago por adelantado, la fecha base es la fecha actual
        baseDate = currentPaymentDate;
        break;
      case BillingMode.current:
        // Para pago mes en curso, podría ser el inicio del mes o la fecha actual
        baseDate = DateTime(currentPaymentDate.year, currentPaymentDate.month, 1);
        break;
      case BillingMode.arrears:
        // Para pago mes vencido, podría ser el fin del mes actual
        // Calculamos el último día del mes
        final nextMonth = currentPaymentDate.month == 12 
          ? DateTime(currentPaymentDate.year + 1, 1, 1)
          : DateTime(currentPaymentDate.year, currentPaymentDate.month + 1, 1);
        baseDate = nextMonth.subtract(const Duration(days: 1));
        break;
    }
    
    // Ahora calculamos la próxima fecha de pago basada en el ciclo
    switch (billingCycle) {
      case BillingCycle.monthly:
        return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
      case BillingCycle.quarterly:
        return DateTime(baseDate.year, baseDate.month + 3, baseDate.day);
      case BillingCycle.biannual:
        return DateTime(baseDate.year, baseDate.month + 6, baseDate.day);
      case BillingCycle.annual:
        return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
    }
  }

  /// Reinicia el estado del formulario
  void reset() {
    AppLogger.logInfo(
      'Reiniciando formulario de pago',
      className: 'PaymentFormNotifier',
      functionName: 'reset',
    );
    state = const PaymentFormState();
  }
}
