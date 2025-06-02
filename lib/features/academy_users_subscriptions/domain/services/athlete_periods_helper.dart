import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Información calculada de períodos de un atleta
class AthletePeriodsInfo {
  final List<SubscriptionAssignmentModel> allPeriods;
  final List<SubscriptionAssignmentModel> activePeriods;
  final SubscriptionAssignmentModel? currentPeriod;
  final SubscriptionAssignmentModel? nextPeriod;
  final int totalRemainingDays;
  final DateTime? nextPaymentDate;
  final DateTime? lastPaymentDate;
  final bool hasActivePlan;
  final double totalValue;
  final SubscriptionPlanModel? currentPlan;
  
  const AthletePeriodsInfo({
    required this.allPeriods,
    required this.activePeriods,
    this.currentPeriod,
    this.nextPeriod,
    required this.totalRemainingDays,
    this.nextPaymentDate,
    this.lastPaymentDate,
    required this.hasActivePlan,
    required this.totalValue,
    this.currentPlan,
  });
  
  /// Verifica si el atleta tiene períodos activos
  bool get hasActivePeriods => activePeriods.isNotEmpty;
  
  /// Verifica si hay un período actual activo
  bool get hasCurrentPeriod => currentPeriod != null;
  
  /// Verifica si hay períodos futuros programados
  bool get hasUpcomingPeriods => nextPeriod != null;
  
  /// Número total de períodos
  int get totalPeriodsCount => allPeriods.length;
  
  /// Número de períodos activos
  int get activePeriodsCount => activePeriods.length;
  
  /// Verifica si está próximo a vencer (menos de 7 días)
  bool get isNearExpiry => totalRemainingDays > 0 && totalRemainingDays <= 7;
  
  /// Verifica si está vencido
  bool get isExpired => totalRemainingDays <= 0 && hasActivePlan;
}

/// Helper service para calcular información derivada de períodos de atletas
class AthletePeriodsHelper {
  static const String _className = 'AthletePeriodsHelper';
  
  /// Calcula toda la información derivada de una lista de períodos
  static AthletePeriodsInfo calculatePeriodsInfo(
    List<SubscriptionAssignmentModel> periods, {
    SubscriptionPlanModel? currentPlan,
  }) {
    try {
      AppLogger.logInfo(
        'Calculando información de períodos',
        className: _className,
        functionName: 'calculatePeriodsInfo',
        params: {
          'totalPeriods': periods.length,
          'currentPlan': currentPlan?.name,
        },
      );
      
      final now = DateTime.now();
      
      // Filtrar períodos activos (no cancelados y no expirados)
      final activePeriods = periods
          .where((period) => 
              period.status == SubscriptionAssignmentStatus.active &&
              period.endDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));
      
      // Encontrar período actual (activo y en ejecución)
      final currentPeriod = periods
          .where((period) => 
              period.status == SubscriptionAssignmentStatus.active &&
              period.startDate.isBefore(now) &&
              period.endDate.isAfter(now))
          .fold<SubscriptionAssignmentModel?>(
            null,
            (current, period) {
              if (current == null) return period;
              // Retornar el que está más cerca de vencer
              return period.endDate.isBefore(current.endDate) ? period : current;
            },
          );
      
      // Encontrar próximo período futuro
      final nextPeriod = periods
          .where((period) => 
              period.status == SubscriptionAssignmentStatus.active &&
              period.startDate.isAfter(now))
          .fold<SubscriptionAssignmentModel?>(
            null,
            (current, period) {
              if (current == null) return period;
              // Retornar el que inicia más pronto
              return period.startDate.isBefore(current.startDate) ? period : current;
            },
          );
      
      // Calcular días restantes hasta el vencimiento más lejano
      final totalRemainingDays = activePeriods.isNotEmpty
          ? activePeriods.last.endDate.difference(now).inDays.clamp(0, double.infinity).toInt()
          : 0;
      
      // Calcular próxima fecha de pago (fecha de vencimiento del último período activo)
      final nextPaymentDate = activePeriods.isNotEmpty ? activePeriods.last.endDate : null;
      
      // Calcular última fecha de pago (fecha de pago más reciente)
      final lastPaymentDate = periods.isNotEmpty
          ? periods
              .map((p) => p.paymentDate)
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : null;
      
      // Calcular valor total de períodos activos
      final totalValue = activePeriods.fold<double>(
        0.0,
        (sum, period) => sum + period.amountPaid,
      );
      
      final hasActivePlan = activePeriods.isNotEmpty || currentPlan != null;
      
      final result = AthletePeriodsInfo(
        allPeriods: periods,
        activePeriods: activePeriods,
        currentPeriod: currentPeriod,
        nextPeriod: nextPeriod,
        totalRemainingDays: totalRemainingDays,
        nextPaymentDate: nextPaymentDate,
        lastPaymentDate: lastPaymentDate,
        hasActivePlan: hasActivePlan,
        totalValue: totalValue,
        currentPlan: currentPlan,
      );
      
      AppLogger.logInfo(
        'Información de períodos calculada',
        className: _className,
        functionName: 'calculatePeriodsInfo',
        params: {
          'activePeriods': result.activePeriodsCount,
          'totalRemainingDays': result.totalRemainingDays,
          'hasCurrentPeriod': result.hasCurrentPeriod,
          'hasUpcomingPeriods': result.hasUpcomingPeriods,
          'totalValue': result.totalValue,
        },
      );
      
      return result;
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error calculando información de períodos',
        error: e,
        className: _className,
        functionName: 'calculatePeriodsInfo',
      );
      
      // Retornar información vacía en caso de error
      return AthletePeriodsInfo(
        allPeriods: periods,
        activePeriods: const [],
        totalRemainingDays: 0,
        hasActivePlan: false,
        totalValue: 0.0,
      );
    }
  }
  
  /// Calcula solo los días restantes de una lista de períodos
  static int calculateRemainingDays(List<SubscriptionAssignmentModel> periods) {
    final info = calculatePeriodsInfo(periods);
    return info.totalRemainingDays;
  }
  
  /// Calcula solo la próxima fecha de pago de una lista de períodos
  static DateTime? calculateNextPaymentDate(List<SubscriptionAssignmentModel> periods) {
    final info = calculatePeriodsInfo(periods);
    return info.nextPaymentDate;
  }
  
  /// Calcula solo la última fecha de pago de una lista de períodos
  static DateTime? calculateLastPaymentDate(List<SubscriptionAssignmentModel> periods) {
    final info = calculatePeriodsInfo(periods);
    return info.lastPaymentDate;
  }
  
  /// Verifica si un atleta tiene algún plan activo (período activo o actual)
  static bool hasActivePlan(List<SubscriptionAssignmentModel> periods) {
    final info = calculatePeriodsInfo(periods);
    return info.hasActivePlan;
  }
  
  /// Obtiene el plan de suscripción actual (del período activo actual)
  static String? getCurrentSubscriptionPlanId(List<SubscriptionAssignmentModel> periods) {
    final info = calculatePeriodsInfo(periods);
    return info.currentPeriod?.subscriptionPlanId ?? info.activePeriods.firstOrNull?.subscriptionPlanId;
  }
  
  /// Determina el estado de pago más apropiado basado en períodos
  static String determinePaymentStatusFromPeriods(List<SubscriptionAssignmentModel> periods) {
    final info = calculatePeriodsInfo(periods);
    
    if (!info.hasActivePlan) {
      return 'inactive';
    }
    
    if (info.isExpired) {
      return 'overdue';
    }
    
    return 'active';
  }
} 