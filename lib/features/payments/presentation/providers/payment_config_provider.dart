import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_config_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_config_provider.g.dart';

/// Provider para el repositorio de configuración de pagos
final paymentConfigRepositoryProvider = Provider<PaymentConfigRepository>((
  ref,
) {
  return PaymentConfigRepositoryImpl();
});

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

/// Provider para gestionar la configuración de pagos de una academia
@riverpod
class PaymentConfig extends _$PaymentConfig {
  static const String _className = 'PaymentConfig';

  @override
  Future<PaymentConfigModel> build(String academyId) async {
    AppLogger.logInfo(
      'Obteniendo configuración de pagos',
      className: _className,
      functionName: 'build',
      params: {'academyId': academyId},
    );

    try {
      final firestore = FirebaseFirestore.instance;
      final configsRef = firestore
          .collection('academies')
          .doc(academyId)
          .collection('payment_configs');

      // Buscar la configuración existente
      final snapshot = await configsRef.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final config = PaymentConfigModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });

        AppLogger.logInfo(
          'Configuración de pagos obtenida',
          className: _className,
          functionName: 'build',
          params: {'academyId': academyId, 'configId': config.id},
        );

        return config;
      }

      // Si no existe, crear una configuración por defecto
      final defaultConfig = PaymentConfigModel.defaultConfig(academyId: academyId);
      final docRef = await configsRef.add(defaultConfig.toJson());

      AppLogger.logInfo(
        'Creada configuración de pagos predeterminada',
        className: _className,
        functionName: 'build',
        params: {'academyId': academyId, 'configId': docRef.id},
      );

      return defaultConfig.copyWith(id: docRef.id);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener configuración de pagos',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'build',
        params: {'academyId': academyId},
      );
      throw Exception('Error al obtener configuración de pagos: $e');
    }
  }

  /// Actualiza la configuración de pagos
  Future<void> updateConfig(PaymentConfigModel updatedConfig) async {
    AppLogger.logInfo(
      'Actualizando configuración de pagos',
      className: _className,
      functionName: 'updateConfig',
      params: {'academyId': updatedConfig.academyId, 'configId': updatedConfig.id},
    );

    // Guardar el estado actual por si falla la actualización
    final previousState = state;
    state = const AsyncValue.loading();

    try {
      final firestore = FirebaseFirestore.instance;
      final configDocRef = firestore
          .collection('academies')
          .doc(updatedConfig.academyId)
          .collection('payment_configs')
          .doc(updatedConfig.id);
      
      await configDocRef.update(updatedConfig.toJson());

      AppLogger.logInfo(
        'Configuración de pagos actualizada',
        className: _className,
        functionName: 'updateConfig',
        params: {'academyId': updatedConfig.academyId, 'configId': updatedConfig.id},
      );
      // Actualizar el estado con la nueva configuración
      // Es importante construir un nuevo AsyncData para que los watchers reaccionen.
      state = AsyncData(updatedConfig);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar configuración de pagos',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateConfig',
        params: {'academyId': updatedConfig.academyId, 'configId': updatedConfig.id},
      );
      // Revertir al estado anterior en caso de error
      state = previousState;
      // Propagar la excepción para que la UI pueda manejarla si es necesario
      throw Exception('Error al actualizar configuración de pagos: $e');
    }
  }
}

/// Extensión para facilitar el acceso a PaymentConfigModel desde AsyncValue
extension PaymentConfigModelAsyncValue on AsyncValue<PaymentConfigModel> {
  /// Devuelve el PaymentConfigModel si está disponible, sino null.
  PaymentConfigModel? get config => whenOrNull(data: (config) => config);
}

// TODO: Eliminar PaymentConfigNotifier y paymentConfigNotifierProvider si ya no se usan
//       después de verificar que todo funciona con la clase PaymentConfig generada.
//       Si se decide mantener PaymentConfigNotifier, considerar refactorizar
//       la lógica de obtención y actualización para que sea consistente.
//       Por ejemplo, PaymentConfig podría usar PaymentConfigRepository
//       en lugar de acceder directamente a Firestore.


