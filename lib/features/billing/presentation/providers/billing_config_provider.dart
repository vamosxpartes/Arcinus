import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/features/billing/data/models/billing_config_model.dart';
import 'package:arcinus/features/billing/data/repositories/billing_repository_impl.dart';
import 'package:arcinus/features/billing/domain/repositories/billing_repository.dart';

part 'billing_config_provider.g.dart';

/// Provider para el repositorio de facturación
@riverpod
BillingRepository billingRepository(Ref ref) {
  return BillingRepositoryImpl();
}

/// Provider para obtener la configuración de facturación de una academia
@riverpod
Future<BillingConfigModel> billingConfig(Ref ref, String academyId) async {
  final repository = ref.watch(billingRepositoryProvider);
  
  final result = await repository.getBillingConfig(academyId);
  
  return result.fold(
    (failure) => failure.when(
      notFound: (_) => BillingConfigModel.defaultConfig(
        academyId: academyId,
        academyName: 'Mi Academia',
        phone: '',
        email: '',
        address: '',
      ),
      serverError: (message) => throw Exception(message),
      networkError: () => throw Exception('Error de red'),
      authError: (code, message) => throw Exception(message),
      validationError: (message) => throw Exception(message),
      cacheError: (message) => throw Exception(message),
      unexpectedError: (error, stackTrace) => throw Exception(error.toString()),
    ),
    (config) => config,
  );
}

/// Notifier para gestionar la configuración de facturación
@riverpod
class BillingConfigNotifier extends _$BillingConfigNotifier {
  @override
  Future<BillingConfigModel?> build(String academyId) async {
    try {
      return await ref.watch(billingConfigProvider(academyId).future);
    } catch (e) {
      // Retornar null en caso de error para que la UI pueda manejar el estado
      return null;
    }
  }
  
  /// Guarda la configuración de facturación
  Future<void> saveBillingConfig(BillingConfigModel config) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(billingRepositoryProvider);
    final result = await repository.saveBillingConfig(config);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (savedConfig) => AsyncValue.data(savedConfig),
    );
    
    // Invalidar el provider de configuración para que se recargue
    ref.invalidate(billingConfigProvider(config.academyId));
  }
}

/// Provider para obtener la lista de facturas de una academia
@riverpod
Future<List<dynamic>> academyInvoices(Ref ref, String academyId) async {
  final repository = ref.watch(billingRepositoryProvider);
  
  final result = await repository.getInvoicesByAcademy(academyId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (invoices) => invoices,
  );
} 