import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/subscriptions/domain/services/period_management_service.dart';
import 'package:arcinus/features/subscriptions/domain/repositories/period_repository.dart';
import 'package:arcinus/features/payments/domain/services/payment_service.dart';
import 'package:fpdart/fpdart.dart';

/// Resultado del registro de pago con nueva arquitectura de períodos
class EnhancedPaymentResult {
  final PaymentModel payment;
  final List<SubscriptionAssignmentModel> createdPeriods;
  final SubscriptionAssignmentModel? currentPeriod;
  final int totalRemainingDays;
  final String message;
  
  const EnhancedPaymentResult({
    required this.payment,
    required this.createdPeriods,
    this.currentPeriod,
    required this.totalRemainingDays,
    required this.message,
  });
}

/// Servicio mejorado de pagos que utiliza la nueva arquitectura de períodos
/// 
/// Este servicio implementa la propuesta de migración donde:
/// - Los planes están ligados a períodos, no a usuarios
/// - Maneja pagos múltiples y continuidad automática
/// - Resuelve todos los casos propuestos (prepago, mes vencido, mes en curso)
class EnhancedPaymentService {
  final PaymentRepository _paymentRepository;
  final PeriodRepository _periodRepository;
  final PeriodManagementService _periodManagementService;
  
  static const String _className = 'EnhancedPaymentService';
  
  EnhancedPaymentService(
    this._paymentRepository,
    this._periodRepository,
    this._periodManagementService,
  );
  
  /// Registra un pago y crea los períodos correspondientes
  /// 
  /// Casos soportados:
  /// a. Prepago múltiple: numberOfPeriods > 1 en modo advance
  /// b. Pago anticipado: Pago en mes vencido antes del vencimiento
  /// c. Extensión: Múltiples períodos en mes en curso
  Future<Either<Failure, EnhancedPaymentResult>> registerPaymentWithPeriods({
    required PaymentModel payment,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
    int numberOfPeriods = 1,
    DateTime? requestedStartDate,
  }) async {
    try {
      AppLogger.logInfo(
        'Registrando pago con nueva arquitectura de períodos',
        className: _className,
        functionName: 'registerPaymentWithPeriods',
        params: {
          'paymentId': payment.id,
          'athleteId': payment.athleteId,
          'planId': payment.subscriptionPlanId,
          'numberOfPeriods': numberOfPeriods,
          'billingMode': config.billingMode.displayName,
          'amount': payment.amount,
        },
      );
      
      // 1. Guardar el pago
      final paymentResult = await _paymentRepository.savePayment(payment);
      if (paymentResult.isError) {
        return Left(
          paymentResult.failure ?? ValidationFailure(message: 'Error desconocido al guardar pago'),
        );
      }
      
      final savedPayment = paymentResult.data!;
      
      // 2. Obtener períodos existentes del atleta
      final existingPeriodsResult = await _periodRepository.getAthletesPeriods(
        payment.academyId,
        payment.athleteId,
      );
      
      return existingPeriodsResult.fold(
        (failure) => Left(ValidationFailure(message: 'Error al obtener períodos existentes')),
        (existingPeriods) async {
          // 3. Crear nuevos períodos usando el servicio de gestión
          final periodCreationResult = _periodManagementService.createSubscriptionPeriod(
            academyId: payment.academyId,
            athleteId: payment.athleteId,
            subscriptionPlanId: payment.subscriptionPlanId!,
            paymentDate: payment.paymentDate,
            plan: plan,
            config: config,
            amountPaid: payment.amount,
            currency: payment.currency,
            createdBy: 'system', // O el ID del usuario que registra el pago
            existingPeriods: existingPeriods,
            requestedStartDate: requestedStartDate,
            numberOfPeriods: numberOfPeriods,
          );
          
          // 4. Guardar los períodos en la base de datos
          final allNewPeriods = [
            periodCreationResult.newPeriod,
            ...periodCreationResult.affectedPeriods,
          ];
          
          // Actualizar el ID del pago en cada período
          final periodsWithPaymentId = allNewPeriods.map((period) => 
            period.copyWith(paymentId: savedPayment.id)).toList();
          
          final createPeriodsResult = await _periodRepository.createMultiplePeriods(
            periodsWithPaymentId,
          );
          
          return createPeriodsResult.fold(
            (failure) => Left(ValidationFailure(message: 'Error al crear períodos de suscripción')),
            (createdPeriods) async {
              // 5. Obtener todos los períodos activos actualizados
              final allActivePeriodsResult = await _periodRepository.getActivePeriods(
                payment.academyId,
                payment.athleteId,
              );
              
              return allActivePeriodsResult.fold(
                (failure) => Right(_createDefaultResult(savedPayment, createdPeriods, numberOfPeriods, config.billingMode)),
                (allActivePeriods) {
                  // 6. Calcular información del estado actual
                  final currentPeriod = _periodManagementService.getCurrentPeriod(allActivePeriods);
                  final totalRemainingDays = _periodManagementService.calculateTotalRemainingDays(allActivePeriods);
                  
                  // 7. Generar mensaje descriptivo
                  final message = _generatePaymentMessage(numberOfPeriods, config.billingMode, totalRemainingDays);
                  
                  final result = EnhancedPaymentResult(
                    payment: savedPayment,
                    createdPeriods: createdPeriods,
                    currentPeriod: currentPeriod,
                    totalRemainingDays: totalRemainingDays,
                    message: message,
                  );
                  
                  AppLogger.logInfo(
                    'Pago registrado exitosamente con períodos',
                    className: _className,
                    functionName: 'registerPaymentWithPeriods',
                    params: {
                      'paymentId': savedPayment.id,
                      'createdPeriodsCount': createdPeriods.length,
                      'totalRemainingDays': totalRemainingDays,
                      'currentPeriodId': currentPeriod?.id,
                    },
                  );
                  
                  return Right(result);
                },
              );
            },
          );
        },
      );
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al registrar pago con períodos',
        error: e,
        className: _className,
        functionName: 'registerPaymentWithPeriods',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  /// Crea un resultado por defecto cuando no se puede obtener información de períodos activos
  EnhancedPaymentResult _createDefaultResult(
    PaymentModel payment,
    List<SubscriptionAssignmentModel> createdPeriods,
    int numberOfPeriods,
    BillingMode billingMode,
  ) {
    // Calcular días restantes básico de los períodos creados
    final totalDays = createdPeriods.fold<int>(
      0,
      (sum, period) => sum + period.daysRemaining,
    );
    
    return EnhancedPaymentResult(
      payment: payment,
      createdPeriods: createdPeriods,
      currentPeriod: createdPeriods.isNotEmpty ? createdPeriods.first : null,
      totalRemainingDays: totalDays,
      message: _generatePaymentMessage(numberOfPeriods, billingMode, totalDays),
    );
  }
  
  /// Calcula cuántos períodos se pueden pagar con un monto dado
  int calculateAffordablePeriods(double paymentAmount, double planAmount) {
    if (planAmount <= 0) return 0;
    return (paymentAmount / planAmount).floor();
  }
  
  /// Verifica si un atleta puede realizar un pago múltiple
  Future<bool> canMakeMultiplePeriodPayment({
    required String academyId,
    required String athleteId,
    required PaymentConfigModel config,
    required int requestedPeriods,
  }) async {
    // Obtener períodos existentes
    final existingPeriodsResult = await _periodRepository.getAthletesPeriods(
      academyId,
      athleteId,
    );
    
    return existingPeriodsResult.fold(
      (failure) => false,
      (existingPeriods) {
        // Verificar según el modo de facturación
        switch (config.billingMode) {
          case BillingMode.advance:
            // En prepago, siempre se puede pagar múltiples períodos
            return true;
            
          case BillingMode.current:
            // En mes en curso, se puede pagar múltiples si no hay conflictos
            return requestedPeriods <= 12; // Máximo un año
            
          case BillingMode.arrears:
            // En mes vencido, normalmente se paga un período a la vez
            return requestedPeriods <= 3; // Máximo 3 meses
        }
      },
    );
  }
  
  /// Obtiene un resumen del estado de períodos de un atleta
  Future<Either<Failure, AthletePeriodsStatus>> getAthletePeriodsSummary(
    String academyId,
    String athleteId,
  ) async {
    try {
      final periodsResult = await _periodRepository.getAthletesPeriods(
        academyId,
        athleteId,
      );
      
      return periodsResult.fold(
        (failure) => Left(ValidationFailure(message: 'Error al obtener períodos del atleta')),
        (allPeriods) {
          final activePeriods = _periodManagementService.getActivePeriods(allPeriods);
          final currentPeriod = _periodManagementService.getCurrentPeriod(allPeriods);
          final nextPeriod = _periodManagementService.getNextPeriod(allPeriods);
          final totalRemainingDays = _periodManagementService.calculateTotalRemainingDays(activePeriods);
          
          final status = AthletePeriodsStatus(
            allPeriods: allPeriods,
            activePeriods: activePeriods,
            currentPeriod: currentPeriod,
            nextPeriod: nextPeriod,
            totalRemainingDays: totalRemainingDays,
          );
          
          return Right(status);
        },
      );
      
    } catch (e) {
      return Left(Failure.unexpectedError(error: e));
    }
  }
  
  String _generatePaymentMessage(int numberOfPeriods, BillingMode billingMode, int totalDays) {
    if (numberOfPeriods == 1) {
      return 'Pago registrado en modo ${billingMode.displayName}. Total de días restantes: $totalDays';
    }
    
    return 'Pago de $numberOfPeriods períodos registrado en modo ${billingMode.displayName}. Total de días restantes: $totalDays';
  }
}

/// Estado completo de los períodos de un atleta
class AthletePeriodsStatus {
  final List<SubscriptionAssignmentModel> allPeriods;
  final List<SubscriptionAssignmentModel> activePeriods;
  final SubscriptionAssignmentModel? currentPeriod;
  final SubscriptionAssignmentModel? nextPeriod;
  final int totalRemainingDays;
  
  const AthletePeriodsStatus({
    required this.allPeriods,
    required this.activePeriods,
    this.currentPeriod,
    this.nextPeriod,
    required this.totalRemainingDays,
  });
  
  bool get hasActivePeriods => activePeriods.isNotEmpty;
  bool get hasCurrentPeriod => currentPeriod != null;
  bool get hasUpcomingPeriods => nextPeriod != null;
  int get totalPeriodsCount => allPeriods.length;
  int get activePeriodsCount => activePeriods.length;
} 