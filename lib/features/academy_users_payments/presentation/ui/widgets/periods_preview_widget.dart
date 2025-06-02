import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/academy_users_payments/presentation/ui/widgets/period_stepper_widget.dart';

/// Widget para mostrar la gestión y previsualización de períodos múltiples
/// Incluye controles para modificar períodos y fechas
class PeriodsPreviewWidget extends StatelessWidget {
  final List<PeriodPreview> periods;
  final BillingMode billingMode;
  final String currency;
  
  // Nuevos controles agregados
  final int selectedPeriods;
  final ValueChanged<int> onPeriodsChanged;
  final bool canSelectMultiplePeriods;
  final int maxPeriods;
  final bool showStartDateSelector;
  final VoidCallback? onSelectServiceStartDate;
  final DateTime? serviceStartDate;
  
  const PeriodsPreviewWidget({
    super.key,
    required this.periods,
    required this.billingMode,
    this.currency = 'COP',
    // Controles nuevos
    required this.selectedPeriods,
    required this.onPeriodsChanged,
    this.canSelectMultiplePeriods = true,
    this.maxPeriods = 12,
    this.showStartDateSelector = false,
    this.onSelectServiceStartDate,
    this.serviceStartDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.courtGreen.withAlpha(30),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Controles de períodos y fecha
            _buildControls(),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Timeline de períodos solo si hay períodos para mostrar
            if (periods.isNotEmpty) ...[
              _buildPeriodsTimeline(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildSummary(),
            ],
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
            color: AppTheme.courtGreen.withAlpha(10),
            borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          ),
          child: const Icon(
            Icons.timeline,
            color: AppTheme.courtGreen,
            size: 22,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Períodos',
                style: TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
              Text(
                '${periods.length} ${periods.length == 1 ? 'período' : 'períodos'} - Modo ${billingMode.displayName}',
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

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.spacingMd),
        border: Border.all(
          color: AppTheme.courtGreen.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de controles
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppTheme.courtGreen,
                size: 16,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Configuración de Períodos',
                style: TextStyle(
                  fontSize: AppTheme.bodySize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Fila de controles
          Row(
            children: [
              // Selector de número de períodos
              if (canSelectMultiplePeriods) ...[
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Número de períodos',
                        style: TextStyle(
                          fontSize: AppTheme.secondarySize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightGray,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Row(
                        children: [
                          PeriodStepperWidget(
                            value: selectedPeriods,
                            onChanged: onPeriodsChanged,
                            maxValue: maxPeriods,
                            enabled: true,
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Text(
                              selectedPeriods > 1 
                                  ? '$selectedPeriods períodos seleccionados'
                                  : '1 período seleccionado',
                              style: TextStyle(
                                fontSize: AppTheme.secondarySize,
                                color: AppTheme.lightGray,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLg),
              ],
              
              // Selector de fecha de inicio
              if (showStartDateSelector) ...[
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de inicio',
                        style: TextStyle(
                          fontSize: AppTheme.secondarySize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightGray,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      ElevatedButton.icon(
                        onPressed: onSelectServiceStartDate,
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: Text(
                          serviceStartDate != null 
                              ? _formatDate(serviceStartDate!)
                              : 'Seleccionar fecha',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.courtGreen.withAlpha(20),
                          foregroundColor: AppTheme.courtGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMd,
                            vertical: AppTheme.spacingSm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                            side: BorderSide(
                              color: AppTheme.courtGreen.withAlpha(50),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodsTimeline() {
    return Column(
      children: periods.asMap().entries.map((entry) {
        final index = entry.key;
        final period = entry.value;
        final isLast = index == periods.length - 1;
        
        return Column(
          children: [
            _buildPeriodCard(period, index + 1),
            if (!isLast) _buildConnector(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPeriodCard(PeriodPreview period, int periodNumber) {
    final isActive = period.status == PeriodStatus.active;
    final isFuture = period.status == PeriodStatus.future;
    
    Color cardColor = AppTheme.darkGray;
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
    }
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(AppTheme.spacingXs),
                ),
                child: Text(
                  'Período $periodNumber',
                  style: const TextStyle(
                    fontSize: AppTheme.captionSize,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.magnoliaWhite,
                  ),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(period.status),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _buildDateInfo(
                  'Inicio',
                  period.startDate,
                  Icons.play_circle_outline,
                  accentColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _buildDateInfo(
                  'Fin',
                  period.endDate,
                  Icons.stop_circle_outlined,
                  accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duración: ${period.durationDays} días',
                style: TextStyle(
                  fontSize: AppTheme.captionSize,
                  color: AppTheme.lightGray,
                ),
              ),
              Text(
                '${period.amount.toStringAsFixed(0)} $currency',
                style: TextStyle(
                  fontSize: AppTheme.bodySize,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.courtGreen.withAlpha(70),
                  AppTheme.goldTrophy.withAlpha(70),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Icon(
            Icons.arrow_downward,
            color: AppTheme.lightGray.withAlpha(70),
            size: 16,
          ),
        ],
      ),
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

  Widget _buildStatusBadge(PeriodStatus status) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case PeriodStatus.active:
        badgeColor = AppTheme.courtGreen;
        statusText = 'Activo';
        statusIcon = Icons.check_circle;
        break;
      case PeriodStatus.future:
        badgeColor = AppTheme.goldTrophy;
        statusText = 'Futuro';
        statusIcon = Icons.schedule;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.spacingXs),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: badgeColor, size: 12),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            statusText,
            style: TextStyle(
              fontSize: AppTheme.captionSize,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final totalAmount = periods.fold<double>(0, (sum, period) => sum + period.amount);
    final totalDays = periods.fold<int>(0, (sum, period) => sum + period.durationDays);
    final endDate = periods.isNotEmpty ? periods.last.endDate : DateTime.now();
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: AppTheme.bonfireRed.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total del pago:',
                style: TextStyle(
                  fontSize: AppTheme.bodySize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
              Text(
                '${totalAmount.toStringAsFixed(0)} $currency',
                style: const TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.goldTrophy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duración total:',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  color: AppTheme.lightGray,
                ),
              ),
              Text(
                '$totalDays días',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vence el:',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  color: AppTheme.lightGray,
                ),
              ),
              Text(
                _formatDate(endDate),
                style: const TextStyle(
                  fontSize: AppTheme.secondarySize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.courtGreen,
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
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Modelo para previsualizar un período
class PeriodPreview {
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final PeriodStatus status;
  
  PeriodPreview({
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.status,
  });
  
  int get durationDays => endDate.difference(startDate).inDays;
}

/// Estados de un período para previsualización
enum PeriodStatus {
  active,
  future,
} 