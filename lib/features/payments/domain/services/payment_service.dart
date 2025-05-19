import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart' as plan;

// Repositorios - interfaces solo para definir la estructura
abstract class PaymentRepository {
  Future<RepositoryResult<PaymentModel>> savePayment(PaymentModel payment);
}

abstract class SubscriptionPlanRepository {
  Future<RepositoryResult<plan.SubscriptionPlanModel>> getSubscriptionPlanById(
    String academyId,
    String planId,
  );
}

abstract class UserRepository {
  Future<RepositoryResult<dynamic>> getUserById(String academyId, String userId);
  Future<RepositoryResult<dynamic>> updateUser(dynamic user);
}

/// Resultado de una operación del repositorio
class RepositoryResult<T> {
  final T? data;
  final Failure? failure;
  
  RepositoryResult._({this.data, this.failure});
  
  factory RepositoryResult.success(T data) => RepositoryResult._(data: data);
  factory RepositoryResult.error(Failure failure) => RepositoryResult._(failure: failure);
  
  bool get isSuccess => failure == null && data != null;
  bool get isError => failure != null;
  
  R fold<R>(R Function(Failure) onError, R Function(T) onSuccess) {
    if (isError) {
      return onError(failure!);
    } else {
      return onSuccess(data as T);
    }
  }
  
  bool get isLeft => isError;
  
  T getOrElse(T Function() orElse) {
    if (isSuccess) {
      return data as T;
    }
    return orElse();
  }
}

/// Servicio para gestionar los pagos y la activación de planes de suscripción
class PaymentService {
  final PaymentRepository _paymentRepository;
  final SubscriptionPlanRepository _subscriptionPlanRepository;
  final UserRepository _userRepository;

  PaymentService(
    this._paymentRepository,
    this._subscriptionPlanRepository,
    this._userRepository,
  );

  /// Registra un nuevo pago y actualiza el estado de suscripción del atleta
  /// 
  /// Retorna el pago registrado si es exitoso o un Failure si ocurre un error
  Future<RepositoryResult<PaymentModel>> registerPayment({
    required PaymentModel payment,
    required bool shouldUpdateSubscription,
  }) async {
    try {
      // 1. Guardar el pago
      final paymentResult = await _paymentRepository.savePayment(payment);
      
      if (paymentResult.isLeft) {
        return paymentResult;
      }
      
      // Si no se debe actualizar la suscripción, solo devolver el pago
      if (!shouldUpdateSubscription) {
        return paymentResult;
      }
      
      // 2. Obtener el plan de suscripción si está especificado
      if (payment.subscriptionPlanId == null) {
        return RepositoryResult.error(ValidationFailure(
          message: 'Se requiere un plan de suscripción para actualizar el estado',
        ));
      }
      
      final planResult = await _subscriptionPlanRepository.getSubscriptionPlanById(
        payment.academyId,
        payment.subscriptionPlanId!,
      );
      
      // Si no se puede obtener el plan, devolver error
      if (planResult.isLeft) {
        return RepositoryResult.error(ValidationFailure(
          message: 'No se pudo obtener el plan de suscripción',
        ));
      }
      
      final plan = planResult.getOrElse(() => throw UnimplementedError());
      
      // 3. Obtener el usuario actual
      final userResult = await _userRepository.getUserById(
        payment.academyId,
        payment.athleteId,
      );
      
      if (userResult.isLeft) {
        return RepositoryResult.error(ValidationFailure(
          message: 'No se pudo obtener la información del atleta',
        ));
      }
      
      final user = userResult.getOrElse(() => throw UnimplementedError());
      
      // Verificar que el usuario sea un cliente
      if (user.clientData == null) {
        return RepositoryResult.error(ValidationFailure(
          message: 'El usuario no es un cliente',
        ));
      }
      
      // 4. Calcular las fechas de inicio y fin del periodo
      final DateTime startDate = payment.periodStartDate ?? DateTime.now();
      final DateTime endDate = _calculateEndDate(startDate, plan);
      
      // 5. Actualizar el estado de suscripción del cliente
      final clientData = user.clientData!.copyWith(
        subscriptionPlanId: plan.id,
        paymentStatus: user.PaymentStatus.active.name,
        lastPaymentDate: payment.paymentDate,
        nextPaymentDate: endDate,
        remainingDays: _calculateRemainingDays(endDate),
      );
      
      final updatedUser = user.copyWith(
        clientData: clientData,
      );
      
      // 6. Guardar el usuario actualizado
      final updateResult = await _userRepository.updateUser(updatedUser);
      
      if (updateResult.isLeft) {
        return RepositoryResult.error(ValidationFailure(
          message: 'No se pudo actualizar el estado de suscripción del usuario',
        ));
      }
      
      // 7. Devolver el pago exitoso
      return paymentResult;
    } catch (e) {
      return RepositoryResult.error(Failure.unexpectedError(error: e));
    }
  }
  
  /// Calcula la fecha de finalización del periodo basado en la fecha de inicio
  /// y el plan de suscripción seleccionado
  DateTime _calculateEndDate(DateTime startDate, plan.SubscriptionPlanModel plan) {
    return startDate.add(Duration(days: plan.durationInDays));
  }
  
  /// Calcula los días restantes hasta la fecha de finalización
  int _calculateRemainingDays(DateTime endDate) {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }
} 