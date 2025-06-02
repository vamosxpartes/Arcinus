import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';

/// Excepción para errores en gestión de períodos
class PeriodManagementException implements Exception {
  final String message;
  const PeriodManagementException(this.message);
  
  @override
  String toString() => 'PeriodManagementException: $message';
}

/// Resultado de crear un nuevo período
class PeriodCreationResult {
  final SubscriptionAssignmentModel newPeriod;
  final List<SubscriptionAssignmentModel> affectedPeriods;
  final String message;
  
  const PeriodCreationResult({
    required this.newPeriod,
    required this.affectedPeriods,
    required this.message,
  });
}

/// Servicio para gestionar períodos de suscripción independientes
/// 
/// Este servicio implementa la arquitectura propuesta donde:
/// - Los planes están ligados a PERÍODOS, no a usuarios
/// - Cada período tiene su propia configuración de facturación
/// - Permite múltiples períodos activos/futuros por usuario
/// - Resuelve automáticamente la continuidad entre períodos
class PeriodManagementService {
  static const String _className = 'PeriodManagementService';
  
  /// Crea un nuevo período de suscripción considerando períodos existentes
  /// 
  /// Casos soportados:
  /// a. Prepago múltiple: Pago 2 planes por adelantado
  /// b. Pago anticipado: Pago en mes vencido 7 días antes
  /// c. Extensión: Pago múltiple en mes en curso
  PeriodCreationResult createSubscriptionPeriod({
    required String academyId,
    required String athleteId,
    required String subscriptionPlanId,
    required DateTime paymentDate,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
    required double amountPaid,
    required String currency,
    required String createdBy,
    List<SubscriptionAssignmentModel> existingPeriods = const [],
    DateTime? requestedStartDate,
    int numberOfPeriods = 1,
  }) {
    AppLogger.logInfo(
      'Creando período(s) de suscripción',
      className: _className,
      functionName: 'createSubscriptionPeriod',
      params: {
        'athleteId': athleteId,
        'planId': subscriptionPlanId,
        'paymentDate': paymentDate.toString(),
        'numberOfPeriods': numberOfPeriods,
        'billingMode': config.billingMode.displayName,
        'existingPeriodsCount': existingPeriods.length,
      },
    );
    
    // Ordenar períodos existentes por fecha de fin
    final sortedPeriods = List<SubscriptionAssignmentModel>.from(existingPeriods)
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
    
    // Encontrar la fecha de inicio para el nuevo período
    final startDate = _calculatePeriodStartDate(
      paymentDate: paymentDate,
      requestedStartDate: requestedStartDate,
      config: config,
      existingPeriods: sortedPeriods,
    );
    
    // Crear los períodos solicitados
    final newPeriods = <SubscriptionAssignmentModel>[];
    DateTime currentStartDate = startDate;
    
    for (int i = 0; i < numberOfPeriods; i++) {
      final endDate = _calculatePeriodEndDate(currentStartDate, plan);
      
      final period = SubscriptionAssignmentModel(
        academyId: academyId,
        athleteId: athleteId,
        subscriptionPlanId: subscriptionPlanId,
        paymentDate: paymentDate,
        startDate: currentStartDate,
        endDate: endDate,
        status: _determinePeriodStatus(currentStartDate, paymentDate, config),
        amountPaid: amountPaid / numberOfPeriods, // Dividir monto entre períodos
        currency: currency,
        isPartialPayment: numberOfPeriods > 1, // Marcar como parcial si es múltiple
        totalPlanAmount: amountPaid,
        notes: _generatePeriodNotes(i + 1, numberOfPeriods, config.billingMode),
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );
      
      newPeriods.add(period);
      
      // La fecha de inicio del siguiente período es la fecha de fin del actual
      currentStartDate = endDate;
    }
    
    // Retornar el primer período como principal y los demás como afectados
    final message = _generateCreationMessage(numberOfPeriods, config.billingMode);
    
    return PeriodCreationResult(
      newPeriod: newPeriods.first,
      affectedPeriods: newPeriods.skip(1).toList(),
      message: message,
    );
  }
  
  /// Calcula la fecha de inicio de un período considerando el modo de facturación
  /// y períodos existentes
  DateTime _calculatePeriodStartDate({
    required DateTime paymentDate,
    DateTime? requestedStartDate,
    required PaymentConfigModel config,
    required List<SubscriptionAssignmentModel> existingPeriods,
  }) {
    switch (config.billingMode) {
      case BillingMode.advance:
        // PREPAGO: El servicio comienza después del pago
        if (existingPeriods.isNotEmpty) {
          // Si hay períodos existentes, empezar donde termina el último
          final lastPeriod = existingPeriods.last;
          return lastPeriod.endDate;
        }
        
        // Si no hay períodos, usar fecha solicitada o fecha de pago
        return requestedStartDate ?? paymentDate;
        
      case BillingMode.current:
        // MES EN CURSO: El servicio ya está activo
        if (existingPeriods.isNotEmpty) {
          // Si hay períodos existentes, empezar donde termina el último
          final lastPeriod = existingPeriods.last;
          return lastPeriod.endDate;
        }
        
        // Si no hay períodos, usar fecha solicitada o fecha de pago
        return requestedStartDate ?? paymentDate;
        
      case BillingMode.arrears:
        // MES VENCIDO: Se paga por período ya consumido
        if (existingPeriods.isNotEmpty) {
          // En mes vencido, el nuevo período empieza donde termina el último
          final lastPeriod = existingPeriods.last;
          return lastPeriod.endDate;
        }
        
        // Si no hay períodos existentes, calcular hacia atrás desde la fecha de pago
        return paymentDate.subtract(Duration(days: 30)); // Asumir mensual por defecto
    }
  }
  
  /// Calcula la fecha de fin de un período
  DateTime _calculatePeriodEndDate(DateTime startDate, SubscriptionPlanModel plan) {
    return startDate.add(Duration(days: plan.durationInDays));
  }
  
  /// Determina el estado inicial de un período según el modo de facturación
  SubscriptionAssignmentStatus _determinePeriodStatus(
    DateTime periodStartDate,
    DateTime paymentDate,
    PaymentConfigModel config,
  ) {
    final now = DateTime.now();
    
    // Si el período ya comenzó, está activo
    if (periodStartDate.isBefore(now) || periodStartDate.isAtSameMomentAs(now)) {
      return SubscriptionAssignmentStatus.active;
    }
    
    // Si el período es futuro pero está pagado, está pendiente de activación
    return SubscriptionAssignmentStatus.active; // Cambiar a 'pending' si se implementa
  }
  
  /// Genera notas descriptivas para el período
  String _generatePeriodNotes(int periodNumber, int totalPeriods, BillingMode billingMode) {
    if (totalPeriods == 1) {
      return 'Período único - ${billingMode.displayName}';
    }
    
    return 'Período $periodNumber de $totalPeriods - ${billingMode.displayName}';
  }
  
  /// Genera mensaje descriptivo del resultado
  String _generateCreationMessage(int numberOfPeriods, BillingMode billingMode) {
    if (numberOfPeriods == 1) {
      return 'Período de suscripción creado en modo ${billingMode.displayName}';
    }
    
    return '$numberOfPeriods períodos de suscripción creados en modo ${billingMode.displayName}';
  }
  
  /// Obtiene todos los períodos activos de un atleta
  List<SubscriptionAssignmentModel> getActivePeriods(
    List<SubscriptionAssignmentModel> allPeriods,
  ) {
    final now = DateTime.now();
    return allPeriods
        .where((period) => 
            period.status == SubscriptionAssignmentStatus.active &&
            period.endDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }
  
  /// Obtiene el período actual activo de un atleta
  SubscriptionAssignmentModel? getCurrentPeriod(
    List<SubscriptionAssignmentModel> allPeriods,
  ) {
    final now = DateTime.now();
    
    return allPeriods
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
  }
  
  /// Obtiene el próximo período que se activará
  SubscriptionAssignmentModel? getNextPeriod(
    List<SubscriptionAssignmentModel> allPeriods,
  ) {
    final now = DateTime.now();
    
    return allPeriods
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
  }
  
  /// Calcula los días restantes considerando todos los períodos activos
  int calculateTotalRemainingDays(List<SubscriptionAssignmentModel> activePeriods) {
    if (activePeriods.isEmpty) return 0;
    
    // Ordenar por fecha de fin y tomar el último
    final sortedPeriods = List<SubscriptionAssignmentModel>.from(activePeriods)
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
    
    final lastPeriod = sortedPeriods.last;
    final now = DateTime.now();
    
    if (lastPeriod.endDate.isBefore(now)) return 0;
    
    return lastPeriod.endDate.difference(now).inDays;
  }
  
  /// Valida si se puede crear un nuevo período
  bool canCreateNewPeriod({
    required List<SubscriptionAssignmentModel> existingPeriods,
    required PaymentConfigModel config,
    required DateTime proposedStartDate,
  }) {
    // Verificar si hay conflictos de fechas
    for (final period in existingPeriods) {
      if (period.status == SubscriptionAssignmentStatus.active) {
        // El nuevo período no puede comenzar antes de que termine uno activo
        if (proposedStartDate.isBefore(period.endDate)) {
          return false;
        }
      }
    }
    
    return true;
  }
} 