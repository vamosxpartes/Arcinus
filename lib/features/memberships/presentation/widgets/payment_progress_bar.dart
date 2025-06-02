import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// MIGRACIÓN: Importar nuevos providers y helpers
import 'package:arcinus/features/subscriptions/presentation/providers/athlete_periods_info_provider.dart';

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

/// Widget que muestra una barra de progreso del estado de pago del usuario
/// MIGRACIÓN: Ahora usa información de períodos en lugar de campos del usuario
class PaymentProgressBar extends ConsumerWidget {
  final ClientUserModel clientUser;
  final String academyId;
  final DateTime? nextPaymentDate; // OBSOLETO - para compatibilidad temporal

  const PaymentProgressBar({
    super.key,
    required this.clientUser,
    required this.academyId,
    this.nextPaymentDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.logInfo(
      'Construyendo PaymentProgressBar',
      className: 'PaymentProgressBar',
      functionName: 'build',
      params: {
        'userId': clientUser.userId,
        'paymentStatus': clientUser.paymentStatus.name,
        'clientType': clientUser.clientType.name,
      },
    );

    // MIGRACIÓN: Usar el nuevo provider de información completa del atleta
    final athleteInfoAsync = ref.watch(athleteCompleteInfoProvider((
      academyId: academyId,
      athleteId: clientUser.userId,
    )));

    return athleteInfoAsync.when(
      data: (athleteInfo) => _buildProgressBar(context, athleteInfo),
      loading: () => _buildLoadingProgressBar(),
      error: (error, stackTrace) {
        AppLogger.logError(
          message: 'Error al cargar información del atleta para progress bar',
          error: error,
          stackTrace: stackTrace,
          className: 'PaymentProgressBar',
          functionName: 'build',
        );
        return _buildErrorProgressBar();
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, AthleteCompleteInfo athleteInfo) {
    try {
      AppLogger.logInfo(
        'Calculando datos de progreso de pago',
        className: 'PaymentProgressBar',
        functionName: '_buildProgressBar',
        params: {
          'hasActivePlan': athleteInfo.hasActivePlan,
          'remainingDays': athleteInfo.remainingDays,
          'nextPaymentDate': athleteInfo.nextPaymentDate?.toString(),
          'activePeriods': athleteInfo.periodsInfo.activePeriodsCount,
        },
      );

      // Si no hay plan activo, mostrar barra inactiva
      if (!athleteInfo.hasActivePlan) {
        AppLogger.logInfo(
          'Mostrando barra inactiva: no hay plan activo',
          className: 'PaymentProgressBar',
          functionName: '_buildProgressBar',
          params: {'userId': clientUser.userId},
        );
        return _buildInactiveProgressBar();
      }

      // Calcular datos de progreso usando la información de períodos
      final progressData = _calculateProgressFromPeriods(athleteInfo);
      
      AppLogger.logInfo(
        'Datos de progreso calculados',
        className: 'PaymentProgressBar',
        functionName: '_buildProgressBar',
        params: {
          'daysRemaining': progressData.daysRemaining,
          'totalDays': progressData.totalDays,
          'progress': progressData.progress,
          'isOverdue': progressData.isOverdue,
          'nextPaymentDate_calculated': progressData.nextPaymentDate?.toString(),
        },
      );

      // Determinar color basado en días restantes
      Color progressColor;
      if (progressData.isOverdue) {
        progressColor = Colors.red;
      } else if (progressData.daysRemaining <= 5) {
        progressColor = Colors.orange;
      } else if (progressData.daysRemaining <= 15) {
        progressColor = Colors.yellow[700]!;
      } else {
        progressColor = Colors.green;
      }

      return _buildActiveProgressBar(
        context: context,
        athleteInfo: athleteInfo,
        progressData: progressData,
        progressColor: progressColor,
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error calculando progreso de pago',
        error: e,
        className: 'PaymentProgressBar',
        functionName: '_buildProgressBar',
      );
      return _buildErrorProgressBar();
    }
  }

  Widget _buildActiveProgressBar({
    required BuildContext context,
    required AthleteCompleteInfo athleteInfo,
    required ProgressData progressData,
    required Color progressColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: progressData.progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Información de estado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progressData.isOverdue
                  ? 'Vencido: ${_formatDate(progressData.nextPaymentDate!)}'
                  : 'Próximo: ${_formatDate(progressData.nextPaymentDate!)}',
              style: TextStyle(
                fontSize: 12,
                color: progressColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${progressData.daysRemaining} días',
              style: TextStyle(
                fontSize: 12,
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInactiveProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sin plan activo',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cargando...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Error al cargar datos',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Calcula datos de progreso basado en información de períodos
  ProgressData _calculateProgressFromPeriods(AthleteCompleteInfo athleteInfo) {
    final now = DateTime.now();
    final nextPaymentDate = athleteInfo.nextPaymentDate ?? now.add(const Duration(days: 30));
    final daysRemaining = nextPaymentDate.difference(now).inDays;
    final isOverdue = daysRemaining < 0;
    
    // Calcular el total de días en el ciclo actual
    // Usar el período activo más cercano a vencer como referencia
    int totalDaysInCycle = 30; // Valor por defecto
    
    if (athleteInfo.periodsInfo.currentPeriod != null) {
      final currentPeriod = athleteInfo.periodsInfo.currentPeriod!;
      totalDaysInCycle = currentPeriod.endDate.difference(currentPeriod.startDate).inDays;
    } else if (athleteInfo.periodsInfo.activePeriods.isNotEmpty) {
      final activePeriod = athleteInfo.periodsInfo.activePeriods.first;
      totalDaysInCycle = activePeriod.endDate.difference(activePeriod.startDate).inDays;
    }
    
    // Calcular progreso (invertido: 1.0 = recién pagado, 0.0 = próximo a vencer)
    final progress = isOverdue ? 0.0 : (daysRemaining / totalDaysInCycle);
    
    return ProgressData(
      daysRemaining: daysRemaining.abs(),
      totalDays: totalDaysInCycle,
      progress: progress,
      isOverdue: isOverdue,
      nextPaymentDate: nextPaymentDate,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

/// Datos calculados para el progreso de pago
class ProgressData {
  final int daysRemaining;
  final int totalDays;
  final double progress;
  final bool isOverdue;
  final DateTime nextPaymentDate;
  
  const ProgressData({
    required this.daysRemaining,
    required this.totalDays,
    required this.progress,
    required this.isOverdue,
    required this.nextPaymentDate,
  });
} 