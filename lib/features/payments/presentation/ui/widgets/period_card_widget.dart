import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';
import 'package:intl/intl.dart';

/// Widget para mostrar un período individual o actuar como botón de agregar período
class PeriodCardWidget extends StatelessWidget {
  final SubscriptionAssignmentModel? period;
  final bool isAddCard;
  final bool isSelected;
  final VoidCallback? onTap;
  final String currency;
  final String? planName; // Opcional: nombre del plan para mostrar

  const PeriodCardWidget({
    super.key,
    this.period,
    this.isAddCard = false,
    this.isSelected = false,
    this.onTap,
    this.currency = 'COP',
    this.planName,
  });

  @override
  Widget build(BuildContext context) {
    if (isAddCard) {
      return _buildAddPeriodCard();
    }

    return _buildPeriodCard();
  }

  Widget _buildAddPeriodCard() {
    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.goldTrophy.withAlpha(50),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.goldTrophy,
                      AppTheme.goldTrophy.withAlpha(200),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppTheme.magnoliaWhite,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              const Text(
                'Agregar Período',
                style: TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Toca para agregar un nuevo período de suscripción',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  color: AppTheme.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodCard() {
    if (period == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final isActive = period!.startDate.isBefore(now) && period!.endDate.isAfter(now);
    final isFuture = period!.startDate.isAfter(now);
    final isPast = period!.endDate.isBefore(now);
    final remainingDays = period!.endDate.difference(now).inDays;

    Color cardColor = AppTheme.mediumGray;
    Color borderColor = AppTheme.lightGray;
    Color accentColor = AppTheme.lightGray;

    if (isActive) {
      cardColor = AppTheme.courtGreen.withAlpha(10);
      borderColor = AppTheme.courtGreen;
      accentColor = AppTheme.courtGreen;
    } else if (isFuture) {
      cardColor = AppTheme.goldTrophy.withAlpha(10);
      borderColor = AppTheme.goldTrophy;
      accentColor = AppTheme.goldTrophy;
    } else if (isPast) {
      cardColor = AppTheme.lightGray.withAlpha(10);
      borderColor = AppTheme.lightGray;
      accentColor = AppTheme.lightGray;
    }

    return Card(
      color: cardColor,
      elevation: isSelected ? AppTheme.elevationHigh : AppTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: isSelected 
              ? accentColor 
              : borderColor.withAlpha(50),
          width: isSelected ? 2.5 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodHeader(accentColor, isActive, isFuture, isPast),
              const SizedBox(height: AppTheme.spacingMd),
              _buildDateRange(accentColor),
              const SizedBox(height: AppTheme.spacingMd),
              _buildStatusAndAmount(accentColor, remainingDays, isActive, isFuture, isPast),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodHeader(Color accentColor, bool isActive, bool isFuture, bool isPast) {
    String statusText = 'Período';
    IconData statusIcon = Icons.schedule;

    if (isActive) {
      statusText = 'ACTIVO';
      statusIcon = Icons.play_circle_filled;
    } else if (isFuture) {
      statusText = 'PRÓXIMO';
      statusIcon = Icons.schedule;
    } else if (isPast) {
      statusText = 'FINALIZADO';
      statusIcon = Icons.check_circle;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: AppTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                color: AppTheme.magnoliaWhite,
                size: 16,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                statusText,
                style: const TextStyle(
                  fontSize: AppTheme.captionSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
            ],
          ),
        ),
        if (planName != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.darkGray,
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              border: Border.all(
                color: accentColor.withAlpha(30),
                width: 1,
              ),
            ),
            child: Text(
              planName!,
              style: TextStyle(
                fontSize: AppTheme.captionSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightGray,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateRange(Color accentColor) {
    if (period == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildDateInfo(
            'Inicio',
            period!.startDate,
            Icons.play_circle_outline,
            accentColor,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: AppTheme.lightGray.withAlpha(30),
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
        ),
        Expanded(
          child: _buildDateInfo(
            'Fin',
            period!.endDate,
            Icons.stop_circle_outlined,
            accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.captionSize,
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          _formatDate(date),
          style: TextStyle(
            fontSize: AppTheme.secondarySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndAmount(Color accentColor, int remainingDays, bool isActive, bool isFuture, bool isPast) {
    if (period == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Información de duración/días restantes
        _buildDurationInfo(remainingDays, isActive, isFuture, isPast, accentColor),
        
        // Monto del período
        _buildAmountInfo(accentColor),
      ],
    );
  }

  Widget _buildDurationInfo(int remainingDays, bool isActive, bool isFuture, bool isPast, Color accentColor) {
    final totalDays = period!.endDate.difference(period!.startDate).inDays;
    
    String durationText;
    IconData durationIcon;
    
    if (isActive) {
      durationText = remainingDays > 0 
          ? '$remainingDays días restantes'
          : 'Vence hoy';
      durationIcon = Icons.timelapse;
    } else if (isFuture) {
      final daysUntilStart = period!.startDate.difference(DateTime.now()).inDays;
      durationText = 'Inicia en $daysUntilStart días';
      durationIcon = Icons.upcoming;
    } else {
      durationText = 'Duró $totalDays días';
      durationIcon = Icons.history;
    }

    return Row(
      children: [
        Icon(
          durationIcon,
          color: accentColor,
          size: 16,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          durationText,
          style: TextStyle(
            fontSize: AppTheme.secondarySize,
            fontWeight: FontWeight.w500,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo(Color accentColor) {
    final amount = period!.amountPaid;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: accentColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Text(
        '${NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(amount)} $currency',
        style: TextStyle(
          fontSize: AppTheme.secondarySize,
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 