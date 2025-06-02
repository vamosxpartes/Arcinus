import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/academy_users_payments/presentation/providers/payment_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla para configurar las opciones de pagos de una academia
class PaymentConfigScreen extends ConsumerWidget {
  final String academyId;

  /// Constructor
  const PaymentConfigScreen({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(paymentConfigProvider(academyId));

    return configAsync.when(
      data: (config) => _buildConfigForm(context, ref, config),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error al cargar configuración: $error')),
    );
  }

  Widget _buildConfigForm(
    BuildContext context,
    WidgetRef ref,
    PaymentConfigModel config,
  ) {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Formulario principal
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración de pagos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Modo de facturación
                  _buildSectionTitle('Modo de facturación'),
                  _buildBillingModeSelector(context, ref, config),
                  const SizedBox(height: 16),

                  // Opciones de pagos parciales
                  _buildSectionTitle('Pagos parciales'),
                  _buildSwitch(
                    'Permitir pagos parciales (abonos)',
                    config.allowPartialPayments,
                    (value) => _updateConfig(ref, config.copyWith(
                      allowPartialPayments: value,
                    )),
                  ),
                  const SizedBox(height: 16),

                  // Periodo de gracia
                  _buildSectionTitle('Periodo de gracia'),
                  _buildNumberField(
                    'Días de gracia después del vencimiento',
                    config.gracePeriodDays.toString(),
                    (value) {
                      final days = int.tryParse(value) ?? 0;
                      _updateConfig(ref, config.copyWith(
                        gracePeriodDays: days,
                      ));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descuentos por pronto pago
                  _buildSectionTitle('Descuento por pronto pago'),
                  _buildSwitch(
                    'Habilitar descuento por pronto pago',
                    config.earlyPaymentDiscount,
                    (value) => _updateConfig(ref, config.copyWith(
                      earlyPaymentDiscount: value,
                    )),
                  ),
                  if (config.earlyPaymentDiscount) ...[
                    const SizedBox(height: 8),
                    _buildNumberField(
                      'Porcentaje de descuento (%)',
                      config.earlyPaymentDiscountPercent.toString(),
                      (value) {
                        final percent = double.tryParse(value) ?? 0.0;
                        _updateConfig(ref, config.copyWith(
                          earlyPaymentDiscountPercent: percent,
                        ));
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildNumberField(
                      'Días de anticipación para aplicar descuento',
                      config.earlyPaymentDays.toString(),
                      (value) {
                        final days = int.tryParse(value) ?? 0;
                        _updateConfig(ref, config.copyWith(
                          earlyPaymentDays: days,
                        ));
                      },
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Recargos por pago tardío
                  _buildSectionTitle('Recargo por pago tardío'),
                  _buildSwitch(
                    'Habilitar recargo por pago tardío',
                    config.lateFeeEnabled,
                    (value) => _updateConfig(ref, config.copyWith(
                      lateFeeEnabled: value,
                    )),
                  ),
                  if (config.lateFeeEnabled) ...[
                    const SizedBox(height: 8),
                    _buildNumberField(
                      'Porcentaje de recargo (%)',
                      config.lateFeePercent.toString(),
                      (value) {
                        final percent = double.tryParse(value) ?? 0.0;
                        _updateConfig(ref, config.copyWith(
                          lateFeePercent: percent,
                        ));
                      },
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Renovación automática
                  _buildSectionTitle('Renovación automática'),
                  _buildSwitch(
                    'Habilitar renovación automática de planes',
                    config.autoRenewal,
                    (value) => _updateConfig(ref, config.copyWith(
                      autoRenewal: value,
                    )),
                  ),
                  const SizedBox(height: 16),

                  // Configuración avanzada de fechas
                  _buildSectionTitle('Configuración avanzada'),
                  _buildSwitch(
                    'Permitir fecha de inicio manual en planes prepagados',
                    config.allowManualStartDateInPrepaid,
                    (value) => _updateConfig(ref, config.copyWith(
                      allowManualStartDateInPrepaid: value,
                    )),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando está habilitado, permite a los administradores seleccionar una fecha de inicio diferente a la fecha de pago en planes prepagados.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.embers,
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(label),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 40,
            child: TextFormField(
              initialValue: value,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingModeSelector(
    BuildContext context,
    WidgetRef ref,
    PaymentConfigModel config,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final mode in BillingMode.values)
          RadioListTile<BillingMode>(
            title: Text(mode.displayName),
            value: mode,
            groupValue: config.billingMode,
            onChanged: (value) {
              if (value != null) {
                _updateConfig(ref, config.copyWith(billingMode: value));
              }
            },
            activeColor: AppTheme.embers,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }

  void _updateConfig(WidgetRef ref, PaymentConfigModel updatedConfig) {
    ref.read(paymentConfigProvider(academyId).notifier).updateConfig(updatedConfig);
  }
}
