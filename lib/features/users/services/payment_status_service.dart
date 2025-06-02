import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/users/data/models/payment_status.dart';

/// Servicio encargado de calcular y determinar el estado de pago de un usuario
class PaymentStatusService {
  /// Calcula y devuelve el estado de pago del usuario basado en las fechas de pago,
  /// plan de suscripción y configuración de pagos de la academia
  static PaymentStatus calculatePaymentStatus({
    required DateTime? lastPaymentDate,
    required DateTime? nextPaymentDate,
    required SubscriptionPlanModel? subscriptionPlan,
    required PaymentConfigModel? paymentConfig,
  }) {
    // Si no hay fechas o plan, el usuario está inactivo
    if (lastPaymentDate == null ||
        nextPaymentDate == null ||
        subscriptionPlan == null) {
      AppLogger.logInfo(
        'Usuario sin plan o fechas de pago, marcado como inactivo',
        className: 'PaymentStatusService',
        functionName: 'calculatePaymentStatus',
      );
      return PaymentStatus.inactive;
    }

    final now = DateTime.now();

    // Obtener días de gracia de la configuración
    final int gracePeriodDays = paymentConfig?.gracePeriodDays ?? 0;

    // Fecha de vencimiento con días de gracia aplicados
    final DateTime dueDate = nextPaymentDate.add(
      Duration(days: gracePeriodDays),
    );

    // Calcular si el pago está vencido
    final bool isOverdue = now.isAfter(dueDate);

    if (isOverdue) {
      AppLogger.logInfo(
        'Usuario con pago vencido, marcado como en mora',
        className: 'PaymentStatusService',
        functionName: 'calculatePaymentStatus',
        params: {
          'fechaProximoPago': nextPaymentDate.toString(),
          'diasGracia': gracePeriodDays.toString(),
          'fechaVencimiento': dueDate.toString(),
          'hoy': now.toString(),
        },
      );
      return PaymentStatus.overdue;
    }

    AppLogger.logInfo(
      'Usuario con pago al día, marcado como activo',
      className: 'PaymentStatusService',
      functionName: 'calculatePaymentStatus',
    );
    return PaymentStatus.active;
  }

  /// Calcula los días restantes hasta el próximo pago
  static int calculateRemainingDays({required DateTime? nextPaymentDate}) {
    if (nextPaymentDate == null) {
      return 0;
    }

    final now = DateTime.now();
    final daysRemaining = nextPaymentDate.difference(now).inDays;

    // Si es negativo, significa que ya pasó la fecha
    return daysRemaining < 0 ? 0 : daysRemaining;
  }

  /// Calcula la fecha del próximo pago basada en el último pago y el plan de suscripción
  static DateTime? calculateNextPaymentDate({
    required DateTime? lastPaymentDate,
    required SubscriptionPlanModel? subscriptionPlan,
    required PaymentConfigModel? paymentConfig,
  }) {
    if (lastPaymentDate == null || subscriptionPlan == null) {
      return null;
    }

    // Obtener el ciclo de facturación (asumiendo que es un enum o String)
    final billingCycle = subscriptionPlan.billingCycle;

    // Calcular el número de días según el ciclo
    int daysToAdd = 30; // Por defecto, mensual

    switch (billingCycle) {
      case BillingCycle.monthly:
        daysToAdd = 30;
        break;
      case BillingCycle.quarterly:
        daysToAdd = 90;
        break;
      case BillingCycle.biannual:
        daysToAdd = 180;
        break;
      case BillingCycle.annual:
        daysToAdd = 365;
        break;
    }
  
    // Por defecto, el próximo pago será después del período completo
    DateTime nextPaymentDate = lastPaymentDate.add(Duration(days: daysToAdd));

    AppLogger.logInfo(
      'Calculando próxima fecha de pago',
      className: 'PaymentStatusService',
      functionName: 'calculateNextPaymentDate',
      params: {
        'fechaÚltimoPago': lastPaymentDate.toString(),
        'cicloFacturación': billingCycle.toString(),
        'díasAgregar': daysToAdd.toString(),
        'próximaFechaPago': nextPaymentDate.toString(),
      },
    );

    return nextPaymentDate;
  }
}
