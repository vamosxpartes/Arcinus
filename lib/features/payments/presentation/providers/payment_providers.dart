import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/repositories/payment_repository_impl.dart';
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
  PaymentsState build() {
    loadPayments();
    return const PaymentsState();
  }

  /// Carga todos los pagos de la academia actual
  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, failure: null);
    
    final academyId = ref.read(currentAcademyIdProvider);
    if (academyId == null) {
      state = state.copyWith(
        isLoading: false,
        failure: const Failure.serverError(
            message: 'No se pudo determinar la academia actual'),
      );
      return;
    }
    
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.getPaymentsByAcademy(academyId);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (payments) => state = state.copyWith(
        isLoading: false,
        payments: payments,
      ),
    );
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
  }) async {
    state = state.copyWith(isLoading: true, failure: null);
    
    final academyId = ref.read(currentAcademyIdProvider);
    final userId = ref.read(authStateNotifierProvider).user?.id;
    
    if (academyId == null || userId == null) {
      state = state.copyWith(
        isLoading: false,
        failure: const Failure.serverError(
            message: 'Error al obtener información necesaria'),
      );
      return;
    }
    
    final payment = PaymentModel(
      academyId: academyId,
      athleteId: athleteId,
      amount: amount,
      currency: currency,
      concept: concept,
      paymentDate: paymentDate,
      notes: notes,
      registeredBy: userId,
      createdAt: DateTime.now(),
      receiptUrl: receiptUrl,
    );
    
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.registerPayment(payment);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (newPayment) {
        loadPayments(); // Recargar la lista de pagos
      },
    );
  }

  /// Elimina un pago (soft delete)
  Future<void> deletePayment(String paymentId) async {
    state = state.copyWith(isLoading: true, failure: null);
    
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.deletePayment(paymentId);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (_) {
        loadPayments(); // Recargar la lista de pagos
      },
    );
  }
}

/// Provider que gestiona los pagos de un atleta específico
@riverpod
class AthletePaymentsNotifier extends _$AthletePaymentsNotifier {
  @override
  PaymentsState build(String athleteId) {
    _loadAthletePayments(athleteId);
    return const PaymentsState();
  }

  /// Carga los pagos de un atleta específico
  Future<void> _loadAthletePayments(String athleteId) async {
    state = state.copyWith(isLoading: true, failure: null);
    
    final academyId = ref.read(currentAcademyIdProvider);
    if (academyId == null) {
      state = state.copyWith(
        isLoading: false,
        failure: const Failure.serverError(
            message: 'No se pudo determinar la academia actual'),
      );
      return;
    }
    
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.getPaymentsByAthlete(academyId, athleteId);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (payments) => state = state.copyWith(
        isLoading: false,
        payments: payments,
      ),
    );
  }
}

/// Provider para el formulario de registro de pago
@riverpod
class PaymentFormNotifier extends _$PaymentFormNotifier {
  @override
  PaymentFormState build() {
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
  }) async {
    state = state.copyWith(isSubmitting: true, failure: null, isSuccess: false);
    
    // Delegar al notifier de pagos de academia para el registro efectivo
    final academyPaymentsNotifier = ref.read(academyPaymentsNotifierProvider.notifier);
    
    // Capturar el estado actual para detectar errores
    final previousFailure = ref.read(academyPaymentsNotifierProvider).failure;
    
    await academyPaymentsNotifier.registerPayment(
      athleteId: athleteId,
      amount: amount,
      currency: currency,
      paymentDate: paymentDate,
      concept: concept,
      notes: notes,
      receiptUrl: receiptUrl,
    );
    
    // Verificar si hubo error en el registro
    final currentFailure = ref.read(academyPaymentsNotifierProvider).failure;
    
    if (currentFailure != null && currentFailure != previousFailure) {
      state = state.copyWith(
        isSubmitting: false,
        failure: currentFailure,
        isSuccess: false,
      );
    } else {
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      );
    }
  }

  /// Reinicia el estado del formulario
  void reset() {
    state = const PaymentFormState();
  }
} 