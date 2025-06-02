import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_model.dart';
import 'package:arcinus/features/academy_users_payments/domain/services/payment_service.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado del formulario de pagos
class PaymentFormState extends Equatable {
  /// ID del atleta seleccionado
  final String athleteId;

  /// ID de la academia
  final String academyId;

  /// ID del plan de suscripción seleccionado
  final String? subscriptionPlanId;

  /// Monto del pago
  final double amount;

  /// Moneda del pago
  final String currency;

  /// Concepto o descripción del pago
  final String concept;

  /// Fecha del pago
  final DateTime paymentDate;

  /// Notas adicionales
  final String notes;

  /// Si es un pago parcial
  final bool isPartialPayment;

  /// Monto total del plan
  final double? totalPlanAmount;

  /// Fecha de inicio del periodo
  final DateTime? periodStartDate;

  /// Fecha de fin del periodo
  final DateTime? periodEndDate;

  /// Si se debe actualizar la suscripción del atleta
  final bool shouldUpdateSubscription;

  /// Estado de carga
  final bool isLoading;

  /// Error ocurrido
  final String? error;

  const PaymentFormState({
    required this.athleteId,
    required this.academyId,
    this.subscriptionPlanId,
    required this.amount,
    required this.currency,
    required this.concept,
    required this.paymentDate,
    this.notes = '',
    this.isPartialPayment = false,
    this.totalPlanAmount,
    this.periodStartDate,
    this.periodEndDate,
    this.shouldUpdateSubscription = true,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [
    athleteId,
    academyId,
    subscriptionPlanId,
    amount,
    currency,
    concept,
    paymentDate,
    notes,
    isPartialPayment,
    totalPlanAmount,
    periodStartDate,
    periodEndDate,
    shouldUpdateSubscription,
    isLoading,
    error,
  ];

  /// Estado inicial con valores por defecto
  factory PaymentFormState.initial({
    required String athleteId,
    required String academyId,
  }) {
    return PaymentFormState(
      athleteId: athleteId,
      academyId: academyId,
      subscriptionPlanId: null,
      amount: 0.0,
      currency: 'MXN',
      concept: 'Mensualidad',
      paymentDate: DateTime.now(),
    );
  }

  /// Crea una copia del estado con los campos actualizados
  PaymentFormState copyWith({
    String? athleteId,
    String? academyId,
    String? Function()? subscriptionPlanId,
    double? amount,
    String? currency,
    String? concept,
    DateTime? paymentDate,
    String? notes,
    bool? isPartialPayment,
    double? Function()? totalPlanAmount,
    DateTime? Function()? periodStartDate,
    DateTime? Function()? periodEndDate,
    bool? shouldUpdateSubscription,
    bool? isLoading,
    String? Function()? error,
  }) {
    return PaymentFormState(
      athleteId: athleteId ?? this.athleteId,
      academyId: academyId ?? this.academyId,
      subscriptionPlanId:
          subscriptionPlanId != null
              ? subscriptionPlanId()
              : this.subscriptionPlanId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      concept: concept ?? this.concept,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      isPartialPayment: isPartialPayment ?? this.isPartialPayment,
      totalPlanAmount:
          totalPlanAmount != null ? totalPlanAmount() : this.totalPlanAmount,
      periodStartDate:
          periodStartDate != null ? periodStartDate() : this.periodStartDate,
      periodEndDate:
          periodEndDate != null ? periodEndDate() : this.periodEndDate,
      shouldUpdateSubscription:
          shouldUpdateSubscription ?? this.shouldUpdateSubscription,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// Provider para el servicio de pagos
final paymentServiceProvider = Provider<PaymentService>((ref) {
  // Depende de la inyección de dependencias configurada
  throw UnimplementedError(
    'Este provider debe ser sobrescrito con un override',
  );
});

/// Notifier para el formulario de pagos
class PaymentFormNotifier extends StateNotifier<PaymentFormState> {
  final Ref _ref;

  PaymentFormNotifier({
    required Ref ref,
    required String athleteId,
    required String academyId,
  }) : _ref = ref,
       super(
         PaymentFormState.initial(athleteId: athleteId, academyId: academyId),
       );

  /// Selecciona un plan de suscripción y actualiza el formulario
  Future<void> selectSubscriptionPlan(String planId) async {
    // Obtener el plan de la lista de planes activos
    final plansAsyncValue = _ref.read(
      activeSubscriptionPlansProvider(state.academyId),
    );

    // Si está cargando o con error, no hacer nada
    if (plansAsyncValue is! AsyncData) {
      return;
    }

    final plans = plansAsyncValue.value ?? [];
    if (plans.isEmpty) {
      state = state.copyWith(error: () => 'No hay planes disponibles');
      return;
    }

    try {
      final selectedPlan = plans.firstWhere(
        (plan) => plan.id == planId,
        orElse: () => throw Exception('Plan no encontrado'),
      );

      // Actualizar el estado con los datos del plan
      state = state.copyWith(
        subscriptionPlanId: () => planId,
        amount: selectedPlan.amount,
        currency: selectedPlan.currency,
        concept: 'Pago de ${selectedPlan.name}',
        totalPlanAmount: () => selectedPlan.amount,
        isPartialPayment: false,
      );

      // Calcular y actualizar fechas de periodo
      _updatePeriodDates(selectedPlan);
    } catch (e) {
      state = state.copyWith(error: () => 'Plan no encontrado');
    }
  }

  /// Actualiza las fechas de inicio y fin del periodo según el plan seleccionado
  void _updatePeriodDates(SubscriptionPlanModel plan) {
    final now = DateTime.now();
    final startDate = now;
    final int days = plan.durationInDays;
    final endDate = now.add(Duration(days: days));

    state = state.copyWith(
      periodStartDate: () => startDate,
      periodEndDate: () => endDate,
    );
  }

  /// Actualiza el monto del pago
  void updateAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  /// Actualiza la moneda del pago
  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  /// Actualiza el concepto del pago
  void updateConcept(String concept) {
    state = state.copyWith(concept: concept);
  }

  /// Actualiza la fecha del pago
  void updatePaymentDate(DateTime date) {
    state = state.copyWith(paymentDate: date);
  }

  /// Actualiza las notas del pago
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Actualiza si es un pago parcial
  void updateIsPartialPayment(bool isPartial) {
    state = state.copyWith(isPartialPayment: isPartial);
  }

  /// Actualiza si se debe actualizar la suscripción
  void updateShouldUpdateSubscription(bool should) {
    state = state.copyWith(shouldUpdateSubscription: should);
  }

  /// Registra el pago utilizando el servicio
  Future<bool> registerPayment() async {
    try {
      // Validaciones básicas
      if (state.amount <= 0) {
        state = state.copyWith(error: () => 'El monto debe ser mayor a cero');
        return false;
      }

      if (state.shouldUpdateSubscription && state.subscriptionPlanId == null) {
        state = state.copyWith(
          error: () => 'Debe seleccionar un plan de suscripción',
        );
        return false;
      }

      // Iniciar carga
      state = state.copyWith(isLoading: true, error: () => null);

      // Crear modelo de pago con fecha automática
      final currentDateTime = DateTime.now();
      final payment = PaymentModel(
        academyId: state.academyId,
        athleteId: state.athleteId,
        subscriptionPlanId: state.subscriptionPlanId,
        amount: state.amount,
        currency: state.currency,
        concept: state.concept,
        paymentDate: currentDateTime, // Fecha automática al momento del registro
        notes: state.notes.isNotEmpty ? state.notes : null,
        registeredBy:
            'currentUserId', // Esto debe ser reemplazado por el ID del usuario actual
        createdAt: currentDateTime,
        isPartialPayment: state.isPartialPayment,
        totalPlanAmount: state.totalPlanAmount,
        periodStartDate: state.periodStartDate,
        periodEndDate: state.periodEndDate,
      );

      // Usar el servicio para registrar el pago
      final paymentService = _ref.read(paymentServiceProvider);
      final result = await paymentService.registerPayment(
        payment: payment,
        shouldUpdateSubscription: state.shouldUpdateSubscription,
      );

      // Manejar resultado
      final bool success = result.fold(
        (failure) {
          // Actualizar estado con error
          state = state.copyWith(
            isLoading: false,
            error: () => _getErrorMessage(failure),
          );
          return false;
        },
        (paymentResult) {
          // Pago exitoso
          state = state.copyWith(isLoading: false, error: () => null);
          return true;
        },
      );

      return success;
    } catch (e) {
      // Error inesperado
      state = state.copyWith(
        isLoading: false,
        error: () => 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }

  /// Obtiene el mensaje de error según el tipo de falla
  String _getErrorMessage(Failure failure) {
    return failure.when<String>(
      serverError: (message) => 'Error del servidor: $message',
      networkError: () => 'Error de red. Verifica tu conexión.',
      authError: (code, message) => 'Error de autenticación: $message',
      validationError: (message) => message,
      notFound: (message) => 'No encontrado: $message',
      cacheError: (message) => 'Error de caché: $message',
      unexpectedError: (error, stackTrace) => 'Error inesperado',
    );
  }

  /// Limpia el formulario
  void resetForm() {
    state = PaymentFormState.initial(
      athleteId: state.athleteId,
      academyId: state.academyId,
    );
  }
}

// Provider para el notifier del formulario
final paymentFormProvider = StateNotifierProviderFamily<
  PaymentFormNotifier,
  PaymentFormState,
  (String, String)
>((ref, params) {
  final athleteId = params.$1;
  final academyId = params.$2;

  return PaymentFormNotifier(
    ref: ref,
    athleteId: athleteId,
    academyId: academyId,
  );
});
