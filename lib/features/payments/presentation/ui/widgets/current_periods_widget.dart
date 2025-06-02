import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';

/// Widget para mostrar los períodos actuales de un atleta
/// Mantiene coherencia visual con el estilo NBA del app
class CurrentPeriodsWidget extends StatelessWidget {
  final List<SubscriptionAssignmentModel> activePeriods;
  final SubscriptionAssignmentModel? currentPeriod;
  final int totalRemainingDays;
  final String currency;
  
  const CurrentPeriodsWidget({
    super.key,
    required this.activePeriods,
    this.currentPeriod,
    required this.totalRemainingDays,
    this.currency = 'COP',
  });

  @override
  Widget build(BuildContext context) {
    if (activePeriods.isEmpty) {
      return _buildNoPeriods();
    }
    
    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.nbaBluePrimary.withAlpha(30),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildSummaryCard(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildPeriodsInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPeriods() {
    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationLow,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.disabledGray.withAlpha(10),
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              child: const Icon(
                Icons.event_busy,
                color: AppTheme.disabledGray,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sin períodos activos',
                    style: TextStyle(
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  Text(
                    'El atleta no tiene períodos de suscripción activos',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: AppTheme.nbaBluePrimary.withAlpha(10),
            borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          ),
          child: const Icon(
            Icons.event_available,
            color: AppTheme.nbaBluePrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Períodos Actuales',
                style: TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
              Text(
                '${activePeriods.length} ${activePeriods.length == 1 ? 'período activo' : 'períodos activos'}',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final daysColor = _getDaysRemainingColor(totalRemainingDays);
    final statusIcon = _getDaysRemainingIcon(totalRemainingDays);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            daysColor.withAlpha(10),
            daysColor.withAlpha(5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: daysColor.withAlpha(30), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: daysColor, size: 28),
              const SizedBox(width: AppTheme.spacingSm),
              Column(
                children: [
                  Text(
                    '$totalRemainingDays',
                    style: TextStyle(
                      fontSize: AppTheme.statsSize,
                      fontWeight: FontWeight.w900,
                      color: daysColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    'DÍAS RESTANTES',
                    style: TextStyle(
                      fontSize: AppTheme.captionSize,
                      fontWeight: FontWeight.w700,
                      color: daysColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildStatusMessage(totalRemainingDays),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(int days) {
    String message;
    Color messageColor;
    
    if (days <= 7) {
      message = '⚠️ Renovación urgente requerida';
      messageColor = AppTheme.bonfireRed;
    } else if (days <= 15) {
      message = '⏰ Renovación próxima recomendada';
      messageColor = AppTheme.goldTrophy;
    } else {
      message = '✅ Suscripción en buen estado';
      messageColor = AppTheme.courtGreen;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: messageColor.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(color: messageColor.withAlpha(30), width: 1),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: AppTheme.secondarySize,
          fontWeight: FontWeight.w600,
          color: messageColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPeriodsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles de Períodos:',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        ...activePeriods.map((period) => _buildPeriodItem(period)),
      ],
    );
  }

  Widget _buildPeriodItem(SubscriptionAssignmentModel period) {
    final isCurrentPeriod = currentPeriod?.id == period.id;
    final remainingDays = period.daysRemaining;
    final accentColor = isCurrentPeriod 
        ? AppTheme.courtGreen 
        : AppTheme.lightGray;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: isCurrentPeriod 
            ? AppTheme.courtGreen.withAlpha(10)
            : AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: accentColor.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isCurrentPeriod)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.courtGreen,
                    borderRadius: BorderRadius.circular(AppTheme.spacingXs),
                  ),
                  child: const Text(
                    'ACTUAL',
                    style: TextStyle(
                      fontSize: AppTheme.captionSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                ),
              if (isCurrentPeriod) const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  'Período ${_formatDateRange(period.startDate, period.endDate)}',
                  style: TextStyle(
                    fontSize: AppTheme.secondarySize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.magnoliaWhite,
                  ),
                ),
              ),
              Text(
                '$remainingDays días',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hasta: ${_formatDate(period.endDate)}',
                style: TextStyle(
                  fontSize: AppTheme.captionSize,
                  color: AppTheme.lightGray,
                ),
              ),
              Text(
                '${period.amountPaid.toStringAsFixed(0)} $currency',
                style: TextStyle(
                  fontSize: AppTheme.captionSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  Color _getDaysRemainingColor(int days) {
    if (days <= 7) return AppTheme.bonfireRed;
    if (days <= 15) return AppTheme.goldTrophy;
    return AppTheme.courtGreen;
  }

  IconData _getDaysRemainingIcon(int days) {
    if (days <= 7) return Icons.warning;
    if (days <= 15) return Icons.schedule;
    return Icons.check_circle;
  }
} 