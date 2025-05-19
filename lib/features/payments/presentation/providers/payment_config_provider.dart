import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_config_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el repositorio de configuración de pagos
final paymentConfigRepositoryProvider = Provider<PaymentConfigRepository>((ref) {
  // Depende de la inyección de dependencias configurada
  throw UnimplementedError('Este provider debe ser sobrescrito con un override');
});

/// Notifier para gestionar la configuración de pagos de una academia
class PaymentConfigNotifier extends StateNotifier<AsyncValue<PaymentConfigModel>> {
  final PaymentConfigRepository _repository;
  final String _academyId;
  
  PaymentConfigNotifier({
    required PaymentConfigRepository repository,
    required String academyId,
  }) : _repository = repository,
       _academyId = academyId,
       super(const AsyncLoading()) {
    _loadConfig();
  }
  
  Future<void> _loadConfig() async {
    state = const AsyncLoading();
    
    try {
      if (_academyId.isEmpty) {
        state = AsyncError(
          ValidationFailure(message: 'El ID de academia es requerido'), 
          StackTrace.current
        );
        return;
      }
      
      final result = await _repository.getPaymentConfig(_academyId);
      
      result.fold(
        (failure) {
          state = AsyncError(_mapFailureToException(failure), StackTrace.current);
        },
        (config) {
          state = AsyncData(config);
        },
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
  
  /// Actualiza la configuración de pagos de la academia
  Future<void> updatePaymentConfig(PaymentConfigModel updatedConfig) async {
    if (updatedConfig.academyId != _academyId) {
      state = AsyncError(
        ValidationFailure(
          message: 'El ID de academia no coincide con el configurado',
        ),
        StackTrace.current,
      );
      return;
    }
    
    state = const AsyncLoading();
    
    try {
      final result = await _repository.savePaymentConfig(updatedConfig);
      
      result.fold(
        (failure) {
          state = AsyncError(_mapFailureToException(failure), StackTrace.current);
        },
        (config) {
          state = AsyncData(config);
        },
      );
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
  
  /// Recarga la configuración
  Future<void> refreshConfig() async {
    await _loadConfig();
  }
}

/// Provider de la configuración de pagos que utiliza el notifier
final paymentConfigProvider = StateNotifierProvider.family<PaymentConfigNotifier, AsyncValue<PaymentConfigModel>, String>(
  (ref, academyId) {
    final repository = ref.watch(paymentConfigRepositoryProvider);
    return PaymentConfigNotifier(
      repository: repository,
      academyId: academyId,
    );
  },
);

/// Helper para mapear Failure a una Exception que AsyncValue puede manejar mejor
Exception _mapFailureToException(Failure failure) {
  return failure.when<Exception>(
    serverError: (message) =>
        Exception('Error del servidor${message.isNotEmpty ? ": $message" : ""}'),
    networkError: () => Exception('Error de red. Verifica tu conexión.'),
    authError: (code, message) => 
        Exception('Error de autenticación${message.isNotEmpty ? ": $message" : " ($code)"}'),
    validationError: (message) =>
        Exception('Error de validación${message.isNotEmpty ? ": $message" : ""}'),
    notFound: (message) =>
        Exception('No encontrado${message.isNotEmpty ? ": $message" : ""}'),
    cacheError: (message) => 
        Exception('Error de caché${message.isNotEmpty ? ": $message" : ""}'),
    unexpectedError: (error, stackTrace) => Exception(
      'Error inesperado: ${error?.toString() ?? 'Ocurrió un problema'}',
    ),
  );
} 