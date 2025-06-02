import 'package:flutter/material.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

/// Widget para mostrar la información de configuración de facturación
/// Diseño moderno y prominente para usar como primer elemento
class BillingConfigInfo extends StatelessWidget {
  final PaymentConfigModel paymentConfig;

  const BillingConfigInfo({
    super.key,
    required this.paymentConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.nbaBluePrimary.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          gradient: LinearGradient(
            colors: [
              AppTheme.nbaBluePrimary.withAlpha(10),
              AppTheme.mediumGray,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingLg),
              _buildBillingModeInfo(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildAdditionalConfigurations(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.nbaBluePrimary, AppTheme.nbaBluePrimary.withAlpha(180)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.spacingMd),
          ),
          child: const Icon(
            Icons.settings_applications,
            color: AppTheme.magnoliaWhite,
            size: 24,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        const Expanded(
          child: Text(
            'Configuración de Facturación',
            style: TextStyle(
              fontSize: AppTheme.h2Size,
              fontWeight: FontWeight.w700,
              color: AppTheme.magnoliaWhite,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.goldTrophy, AppTheme.goldTrophy.withAlpha(200)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.spacingLg),
          ),
          child: Text(
            paymentConfig.billingMode.displayName,
            style: const TextStyle(
              color: AppTheme.mediumGray,
              fontSize: AppTheme.bodySize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingModeInfo() {
    final modeColor = _getBillingModeColor(paymentConfig.billingMode);
    final modeIcon = _getBillingModeIcon(paymentConfig.billingMode);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: modeColor.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.spacingMd),
        border: Border.all(
          color: modeColor.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: modeColor.withAlpha(20),
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
            ),
            child: Icon(
              modeIcon,
              color: modeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo de Facturación',
                  style: TextStyle(
                    fontSize: AppTheme.secondarySize,
                    color: AppTheme.lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getBillingModeDescription(paymentConfig.billingMode),
                  style: TextStyle(
                    fontSize: AppTheme.bodySize,
                    fontWeight: FontWeight.w600,
                    color: modeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalConfigurations() {
    final configurations = <Widget>[];

    // Período de gracia
    if (paymentConfig.gracePeriodDays > 0) {
      configurations.add(_buildConfigurationChip(
        Icons.schedule,
        AppTheme.courtGreen,
        'Gracia: ${paymentConfig.gracePeriodDays}d',
      ));
    }

    // Descuento por pronto pago
    if (paymentConfig.earlyPaymentDiscount) {
      configurations.add(_buildConfigurationChip(
        Icons.discount,
        AppTheme.goldTrophy,
        'Descuento: ${paymentConfig.earlyPaymentDiscountPercent}%',
      ));
    }

    // Recargo por pago tardío
    if (paymentConfig.lateFeeEnabled) {
      configurations.add(_buildConfigurationChip(
        Icons.warning,
        AppTheme.bonfireRed,
        'Recargo: ${paymentConfig.lateFeePercent}%',
      ));
    }

    // Pagos parciales
    if (paymentConfig.allowPartialPayments) {
      configurations.add(_buildConfigurationChip(
        Icons.payments,
        AppTheme.nbaBluePrimary,
        'Pagos parciales',
      ));
    }

    // Renovación automática
    if (paymentConfig.autoRenewal) {
      configurations.add(_buildConfigurationChip(
        Icons.autorenew,
        AppTheme.embers,
        'Auto-renovación',
      ));
    }

    // Fecha manual en prepago
    if (paymentConfig.billingMode == BillingMode.advance && 
        paymentConfig.allowManualStartDateInPrepaid) {
      configurations.add(_buildConfigurationChip(
        Icons.edit_calendar,
        AppTheme.lightGray,
        'Fecha manual',
      ));
    }

    if (configurations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Configuraciones Activas',
              style: TextStyle(
                fontSize: AppTheme.secondarySize,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingSm,
          children: configurations,
        ),
      ],
    );
  }

  Widget _buildConfigurationChip(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppTheme.spacingLg),
        border: Border.all(
          color: color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            text,
            style: TextStyle(
              fontSize: AppTheme.secondarySize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBillingModeColor(BillingMode mode) {
    switch (mode) {
      case BillingMode.advance:
        return AppTheme.courtGreen;
      case BillingMode.current:
        return AppTheme.goldTrophy;
      case BillingMode.arrears:
        return AppTheme.bonfireRed;
    }
  }

  IconData _getBillingModeIcon(BillingMode mode) {
    switch (mode) {
      case BillingMode.advance:
        return Icons.fast_forward;
      case BillingMode.current:
        return Icons.today;
      case BillingMode.arrears:
        return Icons.history;
    }
  }

  String _getBillingModeDescription(BillingMode mode) {
    switch (mode) {
      case BillingMode.advance:
        return 'Prepago: El servicio comienza después del pago';
      case BillingMode.current:
        return 'Mes en curso: El servicio ya está activo';
      case BillingMode.arrears:
        return 'Mes vencido: Se paga por período ya consumido';
    }
  }
} 