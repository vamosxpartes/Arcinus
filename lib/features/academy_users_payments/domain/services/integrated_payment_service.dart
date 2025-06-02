import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_model.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/period_repository.dart';
import 'package:arcinus/features/academy_users_payments/domain/services/enhanced_payment_service.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/services/period_management_service.dart';
import 'package:fpdart/fpdart.dart';

/// Servicio integrado que combina Enhanced Payment Service con gestión completa de períodos
/// 
/// Este servicio proporciona una API unificada para:
/// - Registro de pagos con creación automática de períodos
/// - Gestión completa del ciclo de vida de períodos
/// - Validaciones de negocio
/// - Informes y estadísticas
class IntegratedPaymentService {
  final EnhancedPaymentService _enhancedPaymentService;
  final PeriodRepository _periodRepository;
  final PeriodManagementService _periodManagementService;
  
  static const String _className = 'IntegratedPaymentService';
  
  IntegratedPaymentService(
    this._enhancedPaymentService,
    this._periodRepository,
    this._periodManagementService,
  );
  
  /// Registra un pago completo con validaciones y creación de períodos
  /// 
  /// Este método es el punto de entrada principal para registrar pagos
  /// en la nueva arquitectura basada en períodos
  Future<Either<Failure, CompletePaymentResult>> registerCompletePayment({
    required PaymentModel payment,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
    int numberOfPeriods = 1,
    DateTime? requestedStartDate,
    bool validateBalance = true,
  }) async {
    try {
      AppLogger.logInfo(
        'Iniciando registro completo de pago',
        className: _className,
        functionName: 'registerCompletePayment',
        params: {
          'paymentId': payment.id,
          'athleteId': payment.athleteId,
          'numberOfPeriods': numberOfPeriods,
          'validateBalance': validateBalance,
        },
      );
      
      // 1. Validaciones previas
      final validationResult = await _validatePaymentRequest(
        payment,
        plan,
        config,
        numberOfPeriods,
        validateBalance,
      );
      
      final validationPassed = validationResult.fold(
        (failure) => false,
        (success) => success,
      );
      
      if (!validationPassed) {
        return validationResult.fold(
          (failure) => Left(failure),
          (success) => Left(ValidationFailure(message: 'Validación falló')),
        );
      }
      
      // 2. Obtener estado actual del atleta
      final currentStatusResult = await _enhancedPaymentService.getAthletePeriodsSummary(
        payment.academyId,
        payment.athleteId,
      );
      
      final previousStatus = currentStatusResult.fold(
        (failure) => null,
        (status) => status,
      );
      
      // 3. Registrar pago con Enhanced Payment Service
      final paymentResult = await _enhancedPaymentService.registerPaymentWithPeriods(
        payment: payment,
        plan: plan,
        config: config,
        numberOfPeriods: numberOfPeriods,
        requestedStartDate: requestedStartDate,
      );
      
      return paymentResult.fold(
        (failure) => Left(failure),
        (enhancedResult) async {
          // 4. Obtener estado actualizado
          final updatedStatusResult = await _enhancedPaymentService.getAthletePeriodsSummary(
            payment.academyId,
            payment.athleteId,
          );
          
          final updatedStatus = updatedStatusResult.fold(
            (failure) => null,
            (status) => status,
          );
          
          // 5. Generar análisis del cambio
          final changeAnalysis = _analyzeStatusChange(previousStatus, updatedStatus);
          
          // 6. Crear resultado completo
          final completeResult = CompletePaymentResult(
            paymentResult: enhancedResult,
            previousStatus: previousStatus,
            updatedStatus: updatedStatus,
            changeAnalysis: changeAnalysis,
            validationsPassed: true,
          );
          
          AppLogger.logInfo(
            'Registro completo de pago finalizado exitosamente',
            className: _className,
            functionName: 'registerCompletePayment',
            params: {
              'paymentId': enhancedResult.payment.id,
              'totalRemainingDays': enhancedResult.totalRemainingDays,
              'periodsCreated': enhancedResult.createdPeriods.length,
            },
          );
          
          return Right(completeResult);
        },
      );
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error en registro completo de pago',
        error: e,
        className: _className,
        functionName: 'registerCompletePayment',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Obtiene un dashboard completo del estado de pagos y períodos de un atleta
  Future<Either<Failure, AthletePaymentDashboard>> getAthletePaymentDashboard(
    String academyId,
    String athleteId,
  ) async {
    try {
      AppLogger.logInfo(
        'Generando dashboard de pagos del atleta',
        className: _className,
        functionName: 'getAthletePaymentDashboard',
        params: {
          'academyId': academyId,
          'athleteId': athleteId,
        },
      );
      
      // Obtener estado actual de períodos
      final statusResult = await _enhancedPaymentService.getAthletePeriodsSummary(
        academyId,
        athleteId,
      );
      
      return statusResult.fold(
        (failure) => Left(failure),
        (status) async {
          // Obtener próximos vencimientos
          final now = DateTime.now();
          final nextMonth = now.add(const Duration(days: 30));
          
          final upcomingExpirationsResult = await _periodRepository.getPeriodsExpiringInRange(
            academyId,
            now,
            nextMonth,
          );
          
          final upcomingExpirations = upcomingExpirationsResult.fold(
            (failure) => <SubscriptionAssignmentModel>[],
            (periods) => periods.where((p) => p.athleteId == athleteId).toList(),
          );
          
          // Calcular métricas adicionales
          final metrics = _calculatePaymentMetrics(status, upcomingExpirations);
          
          final dashboard = AthletePaymentDashboard(
            athleteStatus: status,
            upcomingExpirations: upcomingExpirations,
            metrics: metrics,
            lastUpdated: DateTime.now(),
          );
          
          return Right(dashboard);
        },
      );
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al generar dashboard de pagos',
        error: e,
        className: _className,
        functionName: 'getAthletePaymentDashboard',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Simula un pago para mostrar el resultado antes de ejecutarlo
  Future<Either<Failure, PaymentSimulationResult>> simulatePayment({
    required String academyId,
    required String athleteId,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
    required double amount,
    int? requestedPeriods,
    DateTime? requestedStartDate,
  }) async {
    try {
      // Calcular cuántos períodos se pueden pagar
      final affordablePeriods = _enhancedPaymentService.calculateAffordablePeriods(
        amount,
        plan.amount,
      );
      
      final periodsToUse = requestedPeriods ?? affordablePeriods;
      
      if (periodsToUse <= 0) {
        return Left(ValidationFailure(message: 'El monto no es suficiente para pagar un período'));
      }
      
      // Obtener estado actual
      final currentStatusResult = await _enhancedPaymentService.getAthletePeriodsSummary(
        academyId,
        athleteId,
      );
      
      final currentStatus = currentStatusResult.fold(
        (failure) => null,
        (status) => status,
      );
      
      // Simular la creación de períodos
      final simulatedResult = _periodManagementService.simulatePeriodsCreation(
        academyId: academyId,
        athleteId: athleteId,
        subscriptionPlanId: plan.id!,
        plan: plan,
        config: config,
        numberOfPeriods: periodsToUse,
        existingPeriods: currentStatus?.allPeriods ?? [],
        requestedStartDate: requestedStartDate,
      );
      
      final simulation = PaymentSimulationResult(
        affordablePeriods: affordablePeriods,
        requestedPeriods: periodsToUse,
        totalAmount: periodsToUse * plan.amount,
        currentStatus: currentStatus,
        simulatedPeriods: simulatedResult.periods,
        newTotalDays: simulatedResult.totalDays,
        isValid: true,
        warnings: simulatedResult.warnings,
      );
      
      return Right(simulation);
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al simular pago',
        error: e,
        className: _className,
        functionName: 'simulatePayment',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Valida si un pago puede ser procesado
  Future<Either<Failure, bool>> _validatePaymentRequest(
    PaymentModel payment,
    SubscriptionPlanModel plan,
    PaymentConfigModel config,
    int numberOfPeriods,
    bool validateBalance,
  ) async {
    // Validar monto mínimo
    if (payment.amount <= 0) {
      return Left(ValidationFailure(message: 'El monto del pago debe ser mayor a cero'));
    }
    
    // Validar número de períodos
    if (numberOfPeriods <= 0 || numberOfPeriods > 12) {
      return Left(ValidationFailure(message: 'Número de períodos inválido (1-12)'));
    }
    
    // Validar balance si está habilitado
    if (validateBalance) {
      final expectedAmount = numberOfPeriods * plan.amount;
      if (payment.amount < expectedAmount) {
        return Left(ValidationFailure(
          message: 'Monto insuficiente. Se esperaban \$${expectedAmount.toStringAsFixed(2)} para $numberOfPeriods período(s)',
        ));
      }
    }
    
    // Validar capacidad de pagos múltiples según configuración
    final canMakeMultiple = await _enhancedPaymentService.canMakeMultiplePeriodPayment(
      academyId: payment.academyId,
      athleteId: payment.athleteId,
      config: config,
      requestedPeriods: numberOfPeriods,
    );
    
    if (!canMakeMultiple) {
      return Left(ValidationFailure(
        message: 'No se pueden procesar $numberOfPeriods períodos con la configuración actual',
      ));
    }
    
    return const Right(true);
  }
  
  /// Analiza los cambios entre el estado anterior y actual
  StatusChangeAnalysis _analyzeStatusChange(
    AthletePeriodsStatus? previous,
    AthletePeriodsStatus? current,
  ) {
    if (previous == null || current == null) {
      return StatusChangeAnalysis(
        daysAdded: current?.totalRemainingDays ?? 0,
        periodsAdded: current?.totalPeriodsCount ?? 0,
        statusChanged: false,
        becameActive: current?.hasActivePeriods ?? false,
      );
    }
    
    return StatusChangeAnalysis(
      daysAdded: current.totalRemainingDays - previous.totalRemainingDays,
      periodsAdded: current.totalPeriodsCount - previous.totalPeriodsCount,
      statusChanged: current.hasActivePeriods != previous.hasActivePeriods,
      becameActive: !previous.hasActivePeriods && current.hasActivePeriods,
    );
  }
  
  /// Calcula métricas de pago
  PaymentMetrics _calculatePaymentMetrics(
    AthletePeriodsStatus status,
    List<SubscriptionAssignmentModel> upcomingExpirations,
  ) {
    final now = DateTime.now();
    
    // Calcular valor total de períodos activos
    final totalValue = status.activePeriods.fold<double>(
      0.0,
      (sum, period) => sum + period.amountPaid,
    );
    
    // Próximo vencimiento
    final nextExpiration = status.activePeriods.isNotEmpty
        ? status.activePeriods
            .where((p) => p.endDate.isAfter(now))
            .map((p) => p.endDate)
            .reduce((a, b) => a.isBefore(b) ? a : b)
        : null;
    
    return PaymentMetrics(
      totalActivePeriods: status.activePeriodsCount,
      totalRemainingDays: status.totalRemainingDays,
      totalValueActive: totalValue,
      nextExpirationDate: nextExpiration,
      upcomingExpirationsCount: upcomingExpirations.length,
      averagePeriodValue: status.activePeriods.isNotEmpty
          ? totalValue / status.activePeriods.length
          : 0.0,
    );
  }
}

/// Resultado completo del registro de pago
class CompletePaymentResult {
  final EnhancedPaymentResult paymentResult;
  final AthletePeriodsStatus? previousStatus;
  final AthletePeriodsStatus? updatedStatus;
  final StatusChangeAnalysis changeAnalysis;
  final bool validationsPassed;
  
  const CompletePaymentResult({
    required this.paymentResult,
    this.previousStatus,
    this.updatedStatus,
    required this.changeAnalysis,
    required this.validationsPassed,
  });
}

/// Análisis de cambio de estado
class StatusChangeAnalysis {
  final int daysAdded;
  final int periodsAdded;
  final bool statusChanged;
  final bool becameActive;
  
  const StatusChangeAnalysis({
    required this.daysAdded,
    required this.periodsAdded,
    required this.statusChanged,
    required this.becameActive,
  });
}

/// Dashboard de pagos del atleta
class AthletePaymentDashboard {
  final AthletePeriodsStatus athleteStatus;
  final List<SubscriptionAssignmentModel> upcomingExpirations;
  final PaymentMetrics metrics;
  final DateTime lastUpdated;
  
  const AthletePaymentDashboard({
    required this.athleteStatus,
    required this.upcomingExpirations,
    required this.metrics,
    required this.lastUpdated,
  });
}

/// Métricas de pagos
class PaymentMetrics {
  final int totalActivePeriods;
  final int totalRemainingDays;
  final double totalValueActive;
  final DateTime? nextExpirationDate;
  final int upcomingExpirationsCount;
  final double averagePeriodValue;
  
  const PaymentMetrics({
    required this.totalActivePeriods,
    required this.totalRemainingDays,
    required this.totalValueActive,
    this.nextExpirationDate,
    required this.upcomingExpirationsCount,
    required this.averagePeriodValue,
  });
}

/// Resultado de simulación de pago
class PaymentSimulationResult {
  final int affordablePeriods;
  final int requestedPeriods;
  final double totalAmount;
  final AthletePeriodsStatus? currentStatus;
  final List<SubscriptionAssignmentModel> simulatedPeriods;
  final int newTotalDays;
  final bool isValid;
  final List<String> warnings;
  
  const PaymentSimulationResult({
    required this.affordablePeriods,
    required this.requestedPeriods,
    required this.totalAmount,
    this.currentStatus,
    required this.simulatedPeriods,
    required this.newTotalDays,
    required this.isValid,
    required this.warnings,
  });
}

/// Resultado de simulación de períodos
class PeriodsSimulationResult {
  final List<SubscriptionAssignmentModel> periods;
  final int totalDays;
  final List<String> warnings;
  
  const PeriodsSimulationResult({
    required this.periods,
    required this.totalDays,
    required this.warnings,
  });
}

/// Extensión del PeriodManagementService para simulaciones
extension PeriodManagementServiceSimulation on PeriodManagementService {
  /// Simula la creación de períodos sin guardarlos
  PeriodsSimulationResult simulatePeriodsCreation({
    required String academyId,
    required String athleteId,
    required String subscriptionPlanId,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
    required int numberOfPeriods,
    required List<SubscriptionAssignmentModel> existingPeriods,
    DateTime? requestedStartDate,
  }) {
    // Esta es una implementación simulada
    // En la implementación real, este método debería existir en PeriodManagementService
    final warnings = <String>[];
    final simulatedPeriods = <SubscriptionAssignmentModel>[];
    
    // Lógica básica de simulación
    final startDate = requestedStartDate ?? DateTime.now();
    var currentStart = startDate;
    
    for (int i = 0; i < numberOfPeriods; i++) {
      final endDate = currentStart.add(Duration(days: plan.durationInDays));
      
      final period = SubscriptionAssignmentModel(
        id: 'simulated_$i',
        academyId: academyId,
        athleteId: athleteId,
        subscriptionPlanId: subscriptionPlanId,
        paymentDate: DateTime.now(),
        startDate: currentStart,
        endDate: endDate,
        status: SubscriptionAssignmentStatus.active,
        amountPaid: plan.amount,
        currency: 'USD',
        createdBy: 'simulation',
        createdAt: DateTime.now(),
      );
      
      simulatedPeriods.add(period);
      currentStart = endDate;
    }
    
    final totalDays = simulatedPeriods.fold<int>(
      0,
      (sum, period) => sum + period.totalDurationDays,
    );
    
    return PeriodsSimulationResult(
      periods: simulatedPeriods,
      totalDays: totalDays,
      warnings: warnings,
    );
  }
} 