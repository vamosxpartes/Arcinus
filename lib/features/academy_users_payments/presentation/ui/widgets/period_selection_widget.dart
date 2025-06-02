import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_config_model.dart';

/// Widget para seleccionar el número de períodos a pagar
/// Mantiene coherencia visual con el estilo NBA del app
class PeriodSelectionWidget extends StatelessWidget {
  final int selectedPeriods;
  final ValueChanged<int> onPeriodsChanged;
  final SubscriptionPlanModel? plan;
  final PaymentConfigModel? config;
  final double? amountPerPeriod;
  final String currency;
  final bool canSelectMultiple;
  
  const PeriodSelectionWidget({
    super.key,
    required this.selectedPeriods,
    required this.onPeriodsChanged,
    this.plan,
    this.config,
    this.amountPerPeriod,
    this.currency = 'COP',
    this.canSelectMultiple = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!canSelectMultiple) {
      return _buildSinglePeriodInfo();
    }

    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.bonfireRed.withAlpha(30),
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
            _buildPeriodSelector(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildAmountSummary(),
            if (config != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              _buildBillingModeInfo(),
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
            color: AppTheme.bonfireRed.withAlpha(10),
            borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          ),
          child: const Icon(
            Icons.event_repeat,
            color: AppTheme.bonfireRed,
            size: 20,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        const Text(
          'Períodos a Pagar',
          style: TextStyle(
            fontSize: AppTheme.subtitleSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Número de períodos:',
              style: TextStyle(
                fontSize: AppTheme.bodySize,
                color: AppTheme.lightGray,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.bonfireRed,
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              child: Text(
                '$selectedPeriods',
                style: const TextStyle(
                  fontSize: AppTheme.h3Size,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _buildPeriodButtons(),
      ],
    );
  }

  Widget _buildPeriodButtons() {
    final maxPeriods = _getMaxAllowedPeriods();
    
    return Wrap(
      spacing: AppTheme.spacingSm,
      runSpacing: AppTheme.spacingSm,
      children: List.generate(maxPeriods, (index) {
        final periods = index + 1;
        final isSelected = periods == selectedPeriods;
        
        return GestureDetector(
          onTap: () => onPeriodsChanged(periods),
          child: Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.bonfireRed : AppTheme.darkGray,
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.bonfireRed 
                    : AppTheme.lightGray.withAlpha(30),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$periods',
                style: TextStyle(
                  fontSize: AppTheme.bodySize,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.magnoliaWhite : AppTheme.lightGray,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAmountSummary() {
    if (amountPerPeriod == null) return const SizedBox.shrink();
    
    final totalAmount = amountPerPeriod! * selectedPeriods;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: AppTheme.goldTrophy.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedPeriods ${selectedPeriods == 1 ? 'período' : 'períodos'}:',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  color: AppTheme.lightGray,
                ),
              ),
              Text(
                '${amountPerPeriod!.toStringAsFixed(0)} $currency c/u',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Divider(
            color: AppTheme.lightGray.withAlpha(30),
            thickness: 1,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar:',
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
        ],
      ),
    );
  }

  Widget _buildBillingModeInfo() {
    if (config == null) return const SizedBox.shrink();
    
    final modeColor = _getBillingModeColor(config!.billingMode);
    final modeIcon = _getBillingModeIcon(config!.billingMode);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: modeColor.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: modeColor.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            modeIcon,
            color: modeColor,
            size: 16,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              'Modo: ${config!.billingMode.displayName}',
              style: TextStyle(
                fontSize: AppTheme.secondarySize,
                fontWeight: FontWeight.w500,
                color: modeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePeriodInfo() {
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
                color: AppTheme.lightGray.withAlpha(10),
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              child: const Icon(
                Icons.event_note,
                color: AppTheme.lightGray,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pago de un período',
                    style: TextStyle(
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  if (config != null)
                    Text(
                      'Modo: ${config!.billingMode.displayName}',
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

  int _getMaxAllowedPeriods() {
    if (config == null) return 12;
    
    switch (config!.billingMode) {
      case BillingMode.advance:
        return 12; // Hasta 1 año por adelantado
      case BillingMode.current:
        return 6;  // Hasta 6 meses en mes en curso
      case BillingMode.arrears:
        return 3;  // Hasta 3 meses en mes vencido
    }
  }

  Color _getBillingModeColor(BillingMode mode) {
    switch (mode) {
      case BillingMode.advance:
        return AppTheme.courtGreen;
      case BillingMode.current:
        return AppTheme.goldTrophy;
      case BillingMode.arrears:
        return AppTheme.nbaBluePrimary;
    }
  }

  IconData _getBillingModeIcon(BillingMode mode) {
    switch (mode) {
      case BillingMode.advance:
        return Icons.schedule;
      case BillingMode.current:
        return Icons.access_time;
      case BillingMode.arrears:
        return Icons.history;
    }
  }
} 