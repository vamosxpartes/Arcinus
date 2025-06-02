import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart' as client_user;
import 'package:arcinus/core/utils/app_logger.dart';

/// Excepción personalizada para errores de facturación
class BillingValidationException implements Exception {
  final String message;
  const BillingValidationException(this.message);
  
  @override
  String toString() => 'BillingValidationException: $message';
}

/// Resultado del cálculo de fechas de facturación
class BillingDateCalculation {
  final DateTime startDate;
  final DateTime endDate;
  final bool isValidConfiguration;
  final String? validationMessage;
  
  const BillingDateCalculation({
    required this.startDate,
    required this.endDate,
    this.isValidConfiguration = true,
    this.validationMessage,
  });
}

/// Resultado del cálculo de ajustes financieros
class FinancialAdjustment {
  final double earlyPaymentDiscount;
  final double lateFee;
  final double finalAmount;
  final String description;
  
  const FinancialAdjustment({
    required this.earlyPaymentDiscount,
    required this.lateFee,
    required this.finalAmount,
    required this.description,
  });
}

/// Servicio centralizado para manejar la lógica de facturación y suscripciones
/// 
/// Este servicio encapsula toda la lógica de negocio relacionada con:
/// - Cálculo de fechas de facturación según diferentes modos
/// - Validaciones de fechas y períodos de gracia
/// - Cálculo de descuentos y recargos
/// - Manejo de diferentes tipos de planes de suscripción
class SubscriptionBillingService {
  static const String _className = 'SubscriptionBillingService';
  
  /// Calcula la fecha de fin basada en la fecha de inicio y el plan
  DateTime calculateEndDate(DateTime startDate, SubscriptionPlanModel plan) {
    AppLogger.logInfo(
      'Calculando fecha de fin',
      className: _className,
      functionName: 'calculateEndDate',
      params: {
        'startDate': startDate.toString(),
        'planDuration': plan.durationInDays,
        'planName': plan.name,
      },
    );
    
    return startDate.add(Duration(days: plan.durationInDays));
  }
  
  /// Valida si una fecha de inicio es válida según la configuración y política de facturación
  bool isValidStartDate(
    DateTime startDate, 
    DateTime paymentDate,
    PaymentConfigModel config, 
    BillingMode billingMode,
  ) {
    try {
      _validateStartDate(startDate, paymentDate, config, billingMode);
      return true;
    } catch (e) {
      AppLogger.logWarning(
        'Fecha de inicio inválida',
        className: _className,
        functionName: 'isValidStartDate',
        params: {
          'startDate': startDate.toString(),
          'paymentDate': paymentDate.toString(),
          'billingMode': billingMode.displayName,
          'error': e.toString(),
        },
      );
      return false;
    }
  }
  
  /// Calcula los días restantes hasta el vencimiento
  int calculateRemainingDays(DateTime now, DateTime endDate) {
    if (endDate.isBefore(now)) return 0;
    final remaining = endDate.difference(now).inDays;
    
    AppLogger.logInfo(
      'Calculando días restantes',
      className: _className,
      functionName: 'calculateRemainingDays',
      params: {
        'now': now.toString(),
        'endDate': endDate.toString(),
        'remainingDays': remaining,
      },
    );
    
    return remaining;
  }
  
  /// Verifica si un pago está dentro del período de gracia
  bool isPaymentWithinGrace(DateTime dueDate, DateTime paymentDate, int graceDays) {
    final gracePeriodEnd = dueDate.add(Duration(days: graceDays));
    final isWithinGrace = paymentDate.isBefore(gracePeriodEnd) || paymentDate.isAtSameMomentAs(gracePeriodEnd);
    
    AppLogger.logInfo(
      'Verificando período de gracia',
      className: _className,
      functionName: 'isPaymentWithinGrace',
      params: {
        'dueDate': dueDate.toString(),
        'paymentDate': paymentDate.toString(),
        'graceDays': graceDays,
        'gracePeriodEnd': gracePeriodEnd.toString(),
        'isWithinGrace': isWithinGrace,
      },
    );
    
    return isWithinGrace;
  }
  
  /// Calcula la fecha de fin basada en la fecha de inicio y el plan (versión para ClientUserModel)
  DateTime calculateEndDateFromClientPlan(DateTime startDate, client_user.SubscriptionPlanModel plan) {
    final durationInDays = _getDurationFromBillingCycle(plan.billingCycle);
    
    AppLogger.logInfo(
      'Calculando fecha de fin desde plan de cliente',
      className: _className,
      functionName: 'calculateEndDateFromClientPlan',
      params: {
        'startDate': startDate.toString(),
        'planDuration': durationInDays,
        'planName': plan.name,
        'billingCycle': plan.billingCycle.displayName,
      },
    );
    
    return startDate.add(Duration(days: durationInDays));
  }
  
  /// Calcula todos los ajustes financieros (descuentos y recargos) en una sola operación
  FinancialAdjustment calculateFinancialAdjustments({
    required DateTime paymentDate,
    required DateTime dueDate,
    required double baseAmount,
    required PaymentConfigModel config,
  }) {
    final earlyDiscount = calculateEarlyPaymentDiscount(paymentDate, dueDate, baseAmount, config);
    final lateFee = calculateLateFee(paymentDate, dueDate, baseAmount, config);
    final finalAmount = baseAmount - earlyDiscount + lateFee;
    
    String description = 'Monto base: \$${baseAmount.toStringAsFixed(2)}';
    if (earlyDiscount > 0) {
      description += '\nDescuento por pronto pago: -\$${earlyDiscount.toStringAsFixed(2)}';
    }
    if (lateFee > 0) {
      description += '\nRecargo por pago tardío: +\$${lateFee.toStringAsFixed(2)}';
    }
    description += '\nMonto final: \$${finalAmount.toStringAsFixed(2)}';
    
    AppLogger.logInfo(
      'Calculando ajustes financieros',
      className: _className,
      functionName: 'calculateFinancialAdjustments',
      params: {
        'baseAmount': baseAmount,
        'earlyDiscount': earlyDiscount,
        'lateFee': lateFee,
        'finalAmount': finalAmount,
      },
    );
    
    return FinancialAdjustment(
      earlyPaymentDiscount: earlyDiscount,
      lateFee: lateFee,
      finalAmount: finalAmount,
      description: description,
    );
  }
  
  /// Obtiene la duración en días según el ciclo de facturación
  int _getDurationFromBillingCycle(client_user.BillingCycle billingCycle) {
    switch (billingCycle) {
      case client_user.BillingCycle.monthly:
        return 30;
      case client_user.BillingCycle.quarterly:
        return 90;
      case client_user.BillingCycle.biannual:
        return 180;
      case client_user.BillingCycle.annual:
        return 365;
    }
  }
  
  /// Calcula las fechas de inicio y fin según el modo de facturación
  BillingDateCalculation calculateBillingDates({
    required DateTime paymentDate,
    DateTime? requestedStartDate,
    required SubscriptionPlanModel plan,
    required PaymentConfigModel config,
  }) {
    AppLogger.logInfo(
      'Calculando fechas de facturación',
      className: _className,
      functionName: 'calculateBillingDates',
      params: {
        'paymentDate': paymentDate.toString(),
        'requestedStartDate': requestedStartDate?.toString(),
        'billingMode': config.billingMode.displayName,
        'planDuration': plan.durationInDays,
      },
    );
    
    DateTime startDate;
    DateTime endDate;
    
    switch (config.billingMode) {
      case BillingMode.advance:
        // Pago por adelantado: el servicio comienza después del pago
        if (requestedStartDate != null) {
          // Validar si se permite fecha manual
          if (!config.allowManualStartDateInPrepaid) {
            return BillingDateCalculation(
              startDate: paymentDate,
              endDate: calculateEndDate(paymentDate, plan),
              isValidConfiguration: false,
              validationMessage: 'No se permite seleccionar fecha de inicio diferente a la fecha de pago en modo prepago',
            );
          }
          
          // Validar que la fecha solicitada no sea anterior al pago
          if (requestedStartDate.isBefore(paymentDate)) {
            return BillingDateCalculation(
              startDate: paymentDate,
              endDate: calculateEndDate(paymentDate, plan),
              isValidConfiguration: false,
              validationMessage: 'La fecha de inicio no puede ser anterior a la fecha de pago',
            );
          }
          
          startDate = requestedStartDate;
        } else {
          startDate = paymentDate;
        }
        endDate = calculateEndDate(startDate, plan);
        break;
        
      case BillingMode.current:
        // Pago del mes en curso: el servicio ya está activo
        startDate = requestedStartDate ?? paymentDate;
        endDate = calculateEndDate(startDate, plan);
        break;
        
      case BillingMode.arrears:
        // Pago mes vencido: se paga por un período ya consumido
        endDate = paymentDate;
        startDate = endDate.subtract(Duration(days: plan.durationInDays));
        break;
    }
    
    return BillingDateCalculation(
      startDate: startDate,
      endDate: endDate,
      isValidConfiguration: true,
    );
  }
  
  /// Calcula las fechas de inicio y fin según el modo de facturación (versión para ClientUserModel)
  BillingDateCalculation calculateBillingDatesFromClientPlan({
    required DateTime paymentDate,
    DateTime? requestedStartDate,
    required client_user.SubscriptionPlanModel plan,
    required PaymentConfigModel config,
  }) {
    final durationInDays = _getDurationFromBillingCycle(plan.billingCycle);
    
    AppLogger.logInfo(
      'Calculando fechas de facturación desde plan de cliente',
      className: _className,
      functionName: 'calculateBillingDatesFromClientPlan',
      params: {
        'paymentDate': paymentDate.toString(),
        'requestedStartDate': requestedStartDate?.toString(),
        'billingMode': config.billingMode.displayName,
        'planDuration': durationInDays,
        'planName': plan.name,
      },
    );
    
    DateTime startDate;
    DateTime endDate;
    
    switch (config.billingMode) {
      case BillingMode.advance:
        // Pago por adelantado: el servicio comienza después del pago
        if (requestedStartDate != null) {
          // Validar si se permite fecha manual
          if (!config.allowManualStartDateInPrepaid) {
            return BillingDateCalculation(
              startDate: paymentDate,
              endDate: calculateEndDateFromClientPlan(paymentDate, plan),
              isValidConfiguration: false,
              validationMessage: 'No se permite seleccionar fecha de inicio diferente a la fecha de pago en modo prepago',
            );
          }
          
          // Validar que la fecha solicitada no sea anterior al pago
          if (requestedStartDate.isBefore(paymentDate)) {
            return BillingDateCalculation(
              startDate: paymentDate,
              endDate: calculateEndDateFromClientPlan(paymentDate, plan),
              isValidConfiguration: false,
              validationMessage: 'La fecha de inicio no puede ser anterior a la fecha de pago',
            );
          }
          
          startDate = requestedStartDate;
        } else {
          startDate = paymentDate;
        }
        endDate = calculateEndDateFromClientPlan(startDate, plan);
        break;
        
      case BillingMode.current:
        // Pago del mes en curso: el servicio ya está activo
        startDate = requestedStartDate ?? paymentDate;
        endDate = calculateEndDateFromClientPlan(startDate, plan);
        break;
        
      case BillingMode.arrears:
        // Pago mes vencido: se paga por un período ya consumido
        endDate = paymentDate;
        startDate = endDate.subtract(Duration(days: durationInDays));
        break;
    }
    
    return BillingDateCalculation(
      startDate: startDate,
      endDate: endDate,
      isValidConfiguration: true,
    );
  }
  
  /// Valida las fechas según la política de facturación
  void _validateStartDate(
    DateTime startDate,
    DateTime paymentDate,
    PaymentConfigModel config,
    BillingMode billingMode,
  ) {
    AppLogger.logInfo(
      'Validando fecha de inicio',
      className: _className,
      functionName: '_validateStartDate',
      params: {
        'startDate': startDate.toString(),
        'paymentDate': paymentDate.toString(),
        'billingMode': billingMode.displayName,
        'allowManualStartDate': config.allowManualStartDateInPrepaid,
      },
    );
    
    switch (billingMode) {
      case BillingMode.advance:
        // En prepago, validar si se permite fecha manual
        if (!config.allowManualStartDateInPrepaid && !_isSameDay(startDate, paymentDate)) {
          throw const BillingValidationException(
            'No se permite seleccionar fecha de inicio diferente a la fecha de pago en modo prepago'
          );
        }
        
        // La fecha de inicio no puede ser anterior al pago
        if (startDate.isBefore(paymentDate)) {
          throw const BillingValidationException(
            'La fecha de inicio no puede ser anterior a la fecha de pago'
          );
        }
        break;
        
      case BillingMode.current:
        // En mes en curso, más flexibilidad pero con límites razonables
        final maxFutureDate = paymentDate.add(const Duration(days: 30));
        if (startDate.isAfter(maxFutureDate)) {
          throw const BillingValidationException(
            'La fecha de inicio no puede ser más de 30 días en el futuro'
          );
        }
        break;
        
      case BillingMode.arrears:
        // En mes vencido, la fecha de inicio se calcula automáticamente
        // No se permite modificación manual
        break;
    }
  }
  
  /// Valida si un pago está dentro del período de gracia para renovaciones
  void validateGracePeriod(
    DateTime expectedDueDate,
    DateTime paymentDate,
    PaymentConfigModel config,
  ) {
    if (config.gracePeriodDays <= 0) return; // Sin período de gracia
    
    final daysDifference = paymentDate.difference(expectedDueDate).inDays;
    
    if (daysDifference > config.gracePeriodDays) {
      throw BillingValidationException(
        'El pago está fuera del período de gracia permitido (${config.gracePeriodDays} días). '
        'Días de retraso: $daysDifference'
      );
    }
    
    AppLogger.logInfo(
      'Pago dentro del período de gracia',
      className: _className,
      functionName: 'validateGracePeriod',
      params: {
        'expectedDueDate': expectedDueDate.toString(),
        'paymentDate': paymentDate.toString(),
        'gracePeriodDays': config.gracePeriodDays,
        'daysDifference': daysDifference,
      },
    );
  }
  
  /// Calcula el descuento por pronto pago si aplica
  double calculateEarlyPaymentDiscount(
    DateTime paymentDate,
    DateTime dueDate,
    double amount,
    PaymentConfigModel config,
  ) {
    if (!config.earlyPaymentDiscount || config.earlyPaymentDays <= 0) {
      return 0.0;
    }
    
    final daysEarly = dueDate.difference(paymentDate).inDays;
    
    if (daysEarly >= config.earlyPaymentDays) {
      final discount = amount * (config.earlyPaymentDiscountPercent / 100);
      
      AppLogger.logInfo(
        'Aplicando descuento por pronto pago',
        className: _className,
        functionName: 'calculateEarlyPaymentDiscount',
        params: {
          'daysEarly': daysEarly,
          'discountPercent': config.earlyPaymentDiscountPercent,
          'originalAmount': amount,
          'discountAmount': discount,
        },
      );
      
      return discount;
    }
    
    return 0.0;
  }
  
  /// Calcula el recargo por pago tardío si aplica
  double calculateLateFee(
    DateTime paymentDate,
    DateTime dueDate,
    double amount,
    PaymentConfigModel config,
  ) {
    if (!config.lateFeeEnabled || config.lateFeePercent <= 0) {
      return 0.0;
    }
    
    final daysLate = paymentDate.difference(dueDate).inDays;
    
    if (daysLate > 0) {
      final lateFee = amount * (config.lateFeePercent / 100);
      
      AppLogger.logInfo(
        'Aplicando recargo por pago tardío',
        className: _className,
        functionName: 'calculateLateFee',
        params: {
          'daysLate': daysLate,
          'lateFeePercent': config.lateFeePercent,
          'originalAmount': amount,
          'lateFeeAmount': lateFee,
        },
      );
      
      return lateFee;
    }
    
    return 0.0;
  }
  
  /// Verifica si dos fechas son el mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
} 