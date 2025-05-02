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
  FutureOr<List<PaymentModel>> build() async {
    // El método build ahora devuelve directamente la Future que carga los datos
    // No se retorna un PaymentsState aquí, Riverpod maneja el AsyncValue
    return _fetchPayments();
  }

  /// Método privado para obtener los pagos
  Future<List<PaymentModel>> _fetchPayments() async {
    final academyId = ref.read(currentAcademyIdProvider);
    if (academyId == null) {
      throw const Failure.serverError(
            message: 'No se pudo determinar la academia actual');
    }
    
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.getPaymentsByAcademy(academyId);
    
    return result.fold(
      (failure) => throw failure, // Lanzar el Failure en caso de error
      (payments) => payments, // Devolver la lista de pagos en caso de éxito
    );
  }
  
  /// Carga/recarga los pagos invalidando el estado del provider.
  Future<void> refreshPayments() async {
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
  }) async {
    // Ya no se modifica el state aquí directamente para indicar carga
    // El estado AsyncValue se manejará automáticamente por la recarga
    
    final academyId = ref.read(currentAcademyIdProvider);
    final userId = ref.read(authStateNotifierProvider).user?.id;
    
    if (academyId == null || userId == null) {
      // Lanzar un error o manejarlo de forma apropiada
      // En un AsyncNotifier, esto pondría el estado en AsyncError
      throw const Failure.serverError(
            message: 'Error al obtener información necesaria');
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
    
    await result.fold(
      (failure) async {
        // En caso de error al registrar, lanzar la excepción
        // para que la UI pueda reaccionar al estado AsyncError.
        throw failure;
      },
      (newPayment) async {
        // Si el registro fue exitoso, invalidar para recargar la lista
        ref.invalidateSelf();
      },
    );
  }

  /// Elimina un pago (soft delete)
  Future<void> deletePayment(String paymentId) async {
    // Ya no se modifica el state aquí directamente para indicar carga
    
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.deletePayment(paymentId);
    
    await result.fold(
      (failure) async {
         // Lanzar excepción en caso de error
        throw failure;
      },
      (_) async {
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
    return _fetchAthletePayments(athleteId);
  }

  /// Carga los pagos de un atleta específico
  Future<List<PaymentModel>> _fetchAthletePayments(String athleteId) async {
    final academyId = ref.read(currentAcademyIdProvider);
    if (academyId == null) {
       throw const Failure.serverError(
            message: 'No se pudo determinar la academia actual');
    }
    
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final result = await paymentRepo.getPaymentsByAthlete(academyId, athleteId);
    
    return result.fold(
      (failure) => throw failure,
      (payments) => payments,
    );
  }
  
  /// Recarga los pagos del atleta.
  Future<void> refreshAthletePayments(String athleteId) async {
      ref.invalidateSelf();
      // await future;
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
    
    try {
      // Llamar directamente al método del Notifier de pagos de academia
      await ref.read(academyPaymentsNotifierProvider.notifier).registerPayment(
        athleteId: athleteId,
        amount: amount,
        currency: currency,
        paymentDate: paymentDate,
        concept: concept,
        notes: notes,
        receiptUrl: receiptUrl,
      );
      // Si la llamada anterior no lanzó excepción, fue exitosa
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } on Failure catch (failure) {
      // Si registerPayment lanzó un Failure, lo capturamos aquí
      state = state.copyWith(isSubmitting: false, failure: failure, isSuccess: false);
    } catch (e) {
      // Capturar otros posibles errores
       state = state.copyWith(
         isSubmitting: false, 
         failure: Failure.unexpectedError(error: e), 
         isSuccess: false
      );
    }
  }

  /// Reinicia el estado del formulario
  void reset() {
    state = const PaymentFormState();
  }
} 