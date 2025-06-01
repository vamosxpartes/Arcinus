import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Clase para encapsular los datos calculados de pago
class PaymentCalculationData {
  final int daysRemaining;
  final bool isOverdue;
  final double progressValue;
  final DateTime? nextPaymentDate;

  const PaymentCalculationData({
    required this.daysRemaining,
    required this.isOverdue,
    required this.progressValue,
    this.nextPaymentDate,
  });
}

class PaymentProgressBar extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const PaymentProgressBar({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<PaymentProgressBar> createState() => _PaymentProgressBarState();
}

class _PaymentProgressBarState extends ConsumerState<PaymentProgressBar> {
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'PaymentProgressBar initState',
      className: 'PaymentProgressBar',
      params: {
        'userId': widget.userId,
        'userName': widget.userName,
      }
    );
  }

  @override
  void dispose() {
    AppLogger.logInfo(
      'PaymentProgressBar dispose',
      className: 'PaymentProgressBar',
      params: {
        'userId': widget.userId,
        'userName': widget.userName,
      }
    );
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Asegurar que las operaciones gráficas se ejecuten en el hilo principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Callback vacío para asegurar que el widget tree esté construido
    });
    
    AppLogger.logProcessStart(
      'Construyendo PaymentProgressBar',
      className: 'PaymentProgressBar',
      params: {
        'userId': widget.userId,
        'userName': widget.userName,
        'timestamp': DateTime.now().toString(),
        'widget_hashCode': widget.hashCode,
        'state_hashCode': hashCode,
      }
    );
    
    // Usar el provider optimizado con caché
    final clientUserAsyncValue = ref.watch(clientUserCachedProvider(widget.userId));
    
    AppLogger.logInfo(
      'Estado actual del provider clientUserCachedProvider',
      className: 'PaymentProgressBar',
      params: {
        'userId': widget.userId,
        'isLoading': clientUserAsyncValue.isLoading,
        'hasValue': clientUserAsyncValue.hasValue,
        'hasError': clientUserAsyncValue.hasError,
        'error': clientUserAsyncValue.hasError ? clientUserAsyncValue.error.toString() : null,
        'provider_hashCode': clientUserAsyncValue.hashCode,
      }
    );
    
    return clientUserAsyncValue.when(
      data: (clientUser) {
        AppLogger.logInfo(
          'Datos recibidos en PaymentProgressBar',
          className: 'PaymentProgressBar',
          params: {
            'userId': widget.userId,
            'clientUser_found': clientUser != null,
            'paymentStatus': clientUser?.paymentStatus.toString(),
            'subscriptionPlan_null': clientUser?.subscriptionPlan == null,
            'nextPaymentDate': clientUser?.nextPaymentDate?.toString(),
            'remainingDays': clientUser?.remainingDays?.toString(),
          }
        );

        // Validar que tenemos datos válidos
        if (clientUser == null) {
          AppLogger.logWarning(
            'ClientUser es null en PaymentProgressBar',
            className: 'PaymentProgressBar',
            params: {'userId': widget.userId}
          );
          return const SizedBox.shrink();
        }

        // Si no hay plan de suscripción, mostrar barra inactiva
        if (clientUser.subscriptionPlan == null) {
          AppLogger.logInfo(
            'Mostrando barra inactiva: subscriptionPlan es null',
            className: 'PaymentProgressBar',
            params: {
              'userId': widget.userId,
              'paymentStatus': clientUser.paymentStatus.toString(),
            }
          );
          return _buildInactiveBar();
        }

        // Calcular días restantes de forma optimizada
        final calculatedData = _calculateOptimizedPaymentData(clientUser);
        
        AppLogger.logInfo(
          'Datos calculados para PaymentProgressBar',
          className: 'PaymentProgressBar',
          params: {
            'userId': widget.userId,
            'calculatedDaysRemaining': calculatedData.daysRemaining,
            'isOverdue': calculatedData.isOverdue,
            'progressValue': calculatedData.progressValue,
            'nextPaymentDate_calculated': calculatedData.nextPaymentDate?.toString(),
          }
        );

        return _buildActiveProgressBar(clientUser, calculatedData);
      },
      loading: () {
        AppLogger.logInfo(
          'PaymentProgressBar en estado de carga',
          className: 'PaymentProgressBar',
          params: {'userId': widget.userId}
        );
        return const SizedBox.shrink(); // No mostrar nada durante la carga
      },
      error: (error, stackTrace) {
        AppLogger.logError(
          message: 'Error en PaymentProgressBar',
          error: error,
          stackTrace: stackTrace,
          className: 'PaymentProgressBar',
          params: {'userId': widget.userId}
        );
        return const SizedBox.shrink(); // No mostrar nada en caso de error
      },
    );
  }

  /// Calcula los datos de pago de forma optimizada y consistente
  PaymentCalculationData _calculateOptimizedPaymentData(ClientUserModel clientUser) {
    final now = DateTime.now();
    
    // Determinar la fecha de próximo pago
    DateTime? nextPaymentDate = clientUser.nextPaymentDate;
    
    // Si no hay nextPaymentDate pero hay último pago, calcular basado en el ciclo del plan
    if (nextPaymentDate == null && 
        clientUser.lastPaymentDate != null && 
        clientUser.subscriptionPlan != null) {
      
      final lastPayment = clientUser.lastPaymentDate!;
      final billingCycle = clientUser.subscriptionPlan!.billingCycle;
      
      // Calcular próxima fecha basada en el ciclo de facturación
      nextPaymentDate = _calculateNextPaymentFromCycle(lastPayment, billingCycle);
      
      AppLogger.logInfo(
        'Calculando nextPaymentDate desde lastPaymentDate',
        className: 'PaymentProgressBar',
        params: {
          'userId': widget.userId,
          'lastPaymentDate': lastPayment.toString(),
          'billingCycle': billingCycle.toString(),
          'calculatedNextPayment': nextPaymentDate.toString(),
        }
      );
    }
    
    // Si aún no hay fecha, usar fecha por defecto (30 días desde ahora)
    nextPaymentDate ??= now.add(const Duration(days: 30));
    
    // Calcular días restantes
    final daysRemaining = nextPaymentDate.difference(now).inDays;
    final isOverdue = daysRemaining < 0;
    
    // Calcular progreso basado en el ciclo del plan
    double progressValue = 0.0;
    if (clientUser.subscriptionPlan != null && clientUser.lastPaymentDate != null) {
      final totalDaysInCycle = _getDaysInBillingCycle(clientUser.subscriptionPlan!.billingCycle);
      final daysSinceLastPayment = now.difference(clientUser.lastPaymentDate!).inDays;
      progressValue = (daysSinceLastPayment / totalDaysInCycle).clamp(0.0, 1.0);
    }
    
    return PaymentCalculationData(
      daysRemaining: daysRemaining,
      isOverdue: isOverdue,
      progressValue: progressValue,
      nextPaymentDate: nextPaymentDate,
    );
  }

  /// Calcula la próxima fecha de pago basada en el ciclo de facturación
  DateTime _calculateNextPaymentFromCycle(DateTime lastPayment, BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return DateTime(lastPayment.year, lastPayment.month + 1, lastPayment.day);
      case BillingCycle.quarterly:
        return DateTime(lastPayment.year, lastPayment.month + 3, lastPayment.day);
      case BillingCycle.biannual:
        return DateTime(lastPayment.year, lastPayment.month + 6, lastPayment.day);
      case BillingCycle.annual:
        return DateTime(lastPayment.year + 1, lastPayment.month, lastPayment.day);
    }
  }

  /// Obtiene el número de días en un ciclo de facturación
  int _getDaysInBillingCycle(BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return 30;
      case BillingCycle.quarterly:
        return 90;
      case BillingCycle.biannual:
        return 180;
      case BillingCycle.annual:
        return 365;
    }
  }

  /// Construye la barra de progreso activa
  Widget _buildActiveProgressBar(ClientUserModel clientUser, PaymentCalculationData calculatedData) {
    final progressColor = _getProgressColor(calculatedData.daysRemaining, calculatedData.isOverdue);
    
    AppLogger.logInfo(
      'Construyendo barra de progreso activa',
      className: 'PaymentProgressBar',
      params: {
        'userId': widget.userId,
        'daysRemaining': calculatedData.daysRemaining,
        'isOverdue': calculatedData.isOverdue,
        'progressValue': calculatedData.progressValue,
        'nextPaymentDate': calculatedData.nextPaymentDate?.toString(),
      }
    );
    
    return _buildProgressBarWidget(
      progress: calculatedData.progressValue,
      progressColor: progressColor,
      nextPaymentDate: calculatedData.nextPaymentDate!,
      daysRemaining: calculatedData.daysRemaining,
      isOverdue: calculatedData.isOverdue,
    );
  }

  /// Construye el widget de la barra de progreso con información de pago
  Widget _buildProgressBarWidget({
    required double progress,
    required Color progressColor,
    required DateTime nextPaymentDate,
    required int daysRemaining,
    required bool isOverdue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withAlpha(45),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 3,
            ),
          ),
          
          // Fecha de próximo pago
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverdue 
                    ? 'Vencido: ${formatDate(nextPaymentDate)}'
                    : 'Próximo: ${formatDate(nextPaymentDate)}',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.4,
                  color: _getTextColor(daysRemaining, isOverdue),
                ),
              ),
              Text(
                isOverdue 
                    ? 'Pago pendiente'
                    : '$daysRemaining días',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: _getTextColor(daysRemaining, isOverdue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye la barra de progreso inactiva
  Widget _buildInactiveBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra gris inactiva
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.0,
              backgroundColor: Colors.grey.withAlpha(45),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
              minHeight: 3,
            ),
          ),
          
          // Texto de inactivo
          const SizedBox(height: 4),
          const Text(
            'Usuario inactivo',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Determina el color de la barra de progreso
  Color _getProgressColor(int daysRemaining, bool isOverdue) {
    if (isOverdue) {
      return AppTheme.bonfireRed; // Rojo para vencido
    } else if (daysRemaining < 5) {
      return AppTheme.bonfireRed; // Rojo para casi vencido
    } else if (daysRemaining < 15) {
      return AppTheme.goldTrophy; // Amarillo/naranja para próximo a vencer
    } else {
      return AppTheme.courtGreen; // Verde para pago al día
    }
  }
  
  /// Determina el color del texto
  Color _getTextColor(int daysRemaining, bool isOverdue) {
    if (isOverdue || daysRemaining < 5) {
      return AppTheme.bonfireRed;
    }
    return AppTheme.lightGray;
  }
} 