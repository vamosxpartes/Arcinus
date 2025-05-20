import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_config_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

/// Provider para el repositorio de configuración de pagos
final paymentConfigRepositoryProvider = Provider<PaymentConfigRepository>((
  ref,
) {
  return PaymentConfigRepositoryImpl();
});

/// Provider que proporciona la configuración de pagos para una academia específica
final paymentConfigProvider = FutureProvider.family<PaymentConfigModel, String>(
  (ref, academyId) async {
    final repository = ref.watch(paymentConfigRepositoryProvider);

    final result = await repository.getPaymentConfig(academyId);

    return result.fold((failure) {
      AppLogger.logError(
        message: 'Error al obtener configuración de pagos',
        error: failure,
        className: 'paymentConfigProvider',
        params: {'academyId': academyId},
      );
      // Devolver configuración por defecto en caso de error
      return PaymentConfigModel.defaultConfig(academyId: academyId);
    }, (config) => config);
  },
);

/// Notifier para modificar la configuración de pagos
class PaymentConfigNotifier
    extends StateNotifier<AsyncValue<PaymentConfigModel>> {
  final PaymentConfigRepository _repository;
  final Ref _ref;
  final String _academyId;

  PaymentConfigNotifier({
    required PaymentConfigRepository repository,
    required Ref ref,
    required String academyId,
  }) : _repository = repository,
       _ref = ref,
       _academyId = academyId,
       super(const AsyncLoading()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    state = const AsyncLoading();

    try {
      final result = await _repository.getPaymentConfig(_academyId);

      state = result.fold(
        (failure) => AsyncError(failure, StackTrace.current),
        (config) => AsyncData(config),
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Actualiza la configuración de pagos
  Future<void> updatePaymentConfig(PaymentConfigModel updatedConfig) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.updatePaymentConfig(updatedConfig);

      state = result.fold(
        (failure) => AsyncError(failure, StackTrace.current),
        (config) => AsyncData(config),
      );

      // Invalidar el provider de configuración para que se vuelva a cargar
      _ref.invalidate(paymentConfigProvider(_academyId));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Actualiza el modo de facturación
  Future<void> updateBillingMode(BillingMode mode) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final currentConfig = currentState.value!;

    final updatedConfig = currentConfig.copyWith(billingMode: mode);

    await updatePaymentConfig(updatedConfig);
  }

  /// Actualiza la posibilidad de pagos parciales
  Future<void> updateAllowPartialPayments(bool allow) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final currentConfig = currentState.value!;

    final updatedConfig = currentConfig.copyWith(allowPartialPayments: allow);

    await updatePaymentConfig(updatedConfig);
  }

  /// Actualiza los días de gracia
  Future<void> updateGracePeriodDays(int days) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final currentConfig = currentState.value!;

    final updatedConfig = currentConfig.copyWith(gracePeriodDays: days);

    await updatePaymentConfig(updatedConfig);
  }

  /// Actualiza la configuración de descuento por pronto pago
  Future<void> updateEarlyPaymentDiscount({
    required bool enabled,
    double? discountPercent,
    int? daysBeforeLimit,
  }) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final currentConfig = currentState.value!;

    final updatedConfig = currentConfig.copyWith(
      earlyPaymentDiscount: enabled,
      earlyPaymentDiscountPercent:
          discountPercent ?? currentConfig.earlyPaymentDiscountPercent,
      earlyPaymentDays: daysBeforeLimit ?? currentConfig.earlyPaymentDays,
    );

    await updatePaymentConfig(updatedConfig);
  }

  /// Actualiza la configuración de recargo por pago tardío
  Future<void> updateLateFee({
    required bool enabled,
    double? feePercent,
  }) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final currentConfig = currentState.value!;

    final updatedConfig = currentConfig.copyWith(
      lateFeeEnabled: enabled,
      lateFeePercent: feePercent ?? currentConfig.lateFeePercent,
    );

    await updatePaymentConfig(updatedConfig);
  }

  /// Actualiza la configuración de renovación automática
  Future<void> updateAutoRenewal(bool enabled) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final currentConfig = currentState.value!;

    final updatedConfig = currentConfig.copyWith(autoRenewal: enabled);

    await updatePaymentConfig(updatedConfig);
  }
}

/// Provider para PaymentConfigNotifier
final paymentConfigNotifierProvider = StateNotifierProvider.family<
  PaymentConfigNotifier,
  AsyncValue<PaymentConfigModel>,
  String
>((ref, academyId) {
  final repository = ref.watch(paymentConfigRepositoryProvider);
  return PaymentConfigNotifier(
    repository: repository,
    ref: ref,
    academyId: academyId,
  );
});

