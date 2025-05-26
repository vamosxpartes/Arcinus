import 'package:flutter/material.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';

/// Widget para mostrar la información de configuración de facturación
class BillingConfigInfo extends StatelessWidget {
  final PaymentConfigModel paymentConfig;

  const BillingConfigInfo({
    super.key,
    required this.paymentConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildBillingModeInfo(),
            const SizedBox(height: 8),
            _buildAdditionalConfigurations(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.settings, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Configuración de Facturación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            paymentConfig.billingMode.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingModeInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            _getBillingModeIcon(paymentConfig.billingMode),
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getBillingModeDescription(paymentConfig.billingMode),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
      configurations.add(_buildConfigurationRow(
        Icons.schedule,
        Colors.orange,
        'Período de gracia: ${paymentConfig.gracePeriodDays} días',
      ));
    }

    // Descuento por pronto pago
    if (paymentConfig.earlyPaymentDiscount) {
      configurations.add(_buildConfigurationRow(
        Icons.discount,
        Colors.green,
        'Descuento por pronto pago: ${paymentConfig.earlyPaymentDiscountPercent}% (${paymentConfig.earlyPaymentDays} días antes)',
      ));
    }

    // Recargo por pago tardío
    if (paymentConfig.lateFeeEnabled) {
      configurations.add(_buildConfigurationRow(
        Icons.warning,
        Colors.red,
        'Recargo por pago tardío: ${paymentConfig.lateFeePercent}%',
      ));
    }

    // Pagos parciales
    if (paymentConfig.allowPartialPayments) {
      configurations.add(_buildConfigurationRow(
        Icons.payments,
        Colors.purple,
        'Pagos parciales permitidos',
      ));
    }

    // Renovación automática
    if (paymentConfig.autoRenewal) {
      configurations.add(_buildConfigurationRow(
        Icons.autorenew,
        Colors.teal,
        'Renovación automática habilitada',
      ));
    }

    // Fecha manual en prepago
    if (paymentConfig.billingMode == BillingMode.advance && 
        paymentConfig.allowManualStartDateInPrepaid) {
      configurations.add(_buildConfigurationRow(
        Icons.edit_calendar,
        Colors.indigo,
        'Fecha de inicio manual permitida en prepago',
      ));
    }

    return Column(
      children: configurations
          .map((config) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: config,
              ))
          .toList(),
    );
  }

  Widget _buildConfigurationRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
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