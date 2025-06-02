import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/payments/domain/services/enhanced_payment_service.dart';
import 'package:arcinus/features/payments/domain/services/integrated_payment_service.dart';
import 'package:arcinus/features/subscriptions/domain/services/period_management_service.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/period_providers.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/features/payments/domain/services/payment_service.dart' as payment_service;
import 'package:arcinus/features/payments/domain/repositories/payment_repository.dart' as repo;

/// Adaptador para convertir PaymentRepository del domain/repositories al formato que espera EnhancedPaymentService
class PaymentRepositoryAdapter implements payment_service.PaymentRepository {
  final repo.PaymentRepository _repository;

  PaymentRepositoryAdapter(this._repository);

  @override
  Future<payment_service.RepositoryResult<PaymentModel>> savePayment(PaymentModel payment) async {
    final result = await _repository.registerPayment(payment);
    
    return result.fold(
      (failure) => payment_service.RepositoryResult.error(failure),
      (savedPayment) => payment_service.RepositoryResult.success(savedPayment),
    );
  }
}

/// Provider para el servicio de gestión de períodos
final periodManagementServiceProvider = Provider<PeriodManagementService>((ref) {
  return PeriodManagementService();
});

/// Provider para el adaptador del repositorio de pagos
final paymentRepositoryAdapterProvider = Provider<payment_service.PaymentRepository>((ref) {
  final repository = ref.read(paymentRepositoryProvider);
  return PaymentRepositoryAdapter(repository);
});

/// Provider para el servicio mejorado de pagos (EnhancedPaymentService)
final enhancedPaymentServiceProvider = Provider<EnhancedPaymentService>((ref) {
  final paymentRepository = ref.read(paymentRepositoryAdapterProvider);
  final periodRepository = ref.read(periodRepositoryProvider);
  final periodManagementService = ref.read(periodManagementServiceProvider);
  
  return EnhancedPaymentService(
    paymentRepository,
    periodRepository,
    periodManagementService,
  );
});

/// Provider para el servicio integrado de pagos
final integratedPaymentServiceProvider = Provider<IntegratedPaymentService>((ref) {
  final enhancedPaymentService = ref.read(enhancedPaymentServiceProvider);
  final periodRepository = ref.read(periodRepositoryProvider);
  final periodManagementService = ref.read(periodManagementServiceProvider);
  
  return IntegratedPaymentService(
    enhancedPaymentService,
    periodRepository,
    periodManagementService,
  );
});

/// Estado para el resultado de pago mejorado
typedef EnhancedPaymentState = AsyncValue<EnhancedPaymentResult?>;

/// Notifier para el registro de pagos con creación de períodos
class EnhancedPaymentNotifier extends StateNotifier<EnhancedPaymentState> {
  final Ref _ref;

  EnhancedPaymentNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Registra un pago y crea los períodos correspondientes
  Future<void> registerPaymentWithPeriods({
    required PaymentModel payment,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
    int numberOfPeriods = 1,
    DateTime? requestedStartDate,
  }) async {
    AppLogger.logInfo(
      'Iniciando registro de pago con períodos',
      className: 'EnhancedPaymentNotifier',
      functionName: 'registerPaymentWithPeriods',
      params: {
        'athleteId': payment.athleteId,
        'planId': payment.subscriptionPlanId,
        'numberOfPeriods': numberOfPeriods,
        'amount': payment.amount,
      },
    );

    state = const AsyncValue.loading();

    try {
      final enhancedService = _ref.read(enhancedPaymentServiceProvider);
      
      final result = await enhancedService.registerPaymentWithPeriods(
        payment: payment,
        plan: plan,
        config: config,
        numberOfPeriods: numberOfPeriods,
        requestedStartDate: requestedStartDate,
      );

      result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error al registrar pago con períodos',
            error: failure,
            className: 'EnhancedPaymentNotifier',
            functionName: 'registerPaymentWithPeriods',
          );
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (enhancedResult) {
          AppLogger.logInfo(
            'Pago registrado exitosamente con períodos',
            className: 'EnhancedPaymentNotifier',
            functionName: 'registerPaymentWithPeriods',
            params: {
              'paymentId': enhancedResult.payment.id,
              'createdPeriodsCount': enhancedResult.createdPeriods.length,
              'totalRemainingDays': enhancedResult.totalRemainingDays,
            },
          );
          state = AsyncValue.data(enhancedResult);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Excepción al registrar pago con períodos',
        error: e,
        stackTrace: stackTrace,
        className: 'EnhancedPaymentNotifier',
        functionName: 'registerPaymentWithPeriods',
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Resetea el estado del notifier
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider para el notifier de pagos mejorados
final enhancedPaymentNotifierProvider = StateNotifierProvider<EnhancedPaymentNotifier, EnhancedPaymentState>((ref) {
  return EnhancedPaymentNotifier(ref);
}); 