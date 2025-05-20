import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';
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
    // Usar un notifier para las actualizaciones
    final notifier = ref.read(
      paymentConfigNotifierProvider(academyId).notifier,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración de Pagos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Sección: Modo de Facturación
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modo de Facturación',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Define cuándo se deben realizar los pagos de las suscripciones:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Opciones de Modo de Facturación
                  _buildRadioOption<BillingMode>(
                    title: 'Por adelantado',
                    subtitle: 'El atleta paga al inicio del período',
                    value: BillingMode.advance,
                    groupValue: config.billingMode,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateBillingMode(value);
                      }
                    },
                  ),

                  _buildRadioOption<BillingMode>(
                    title: 'Mes en curso',
                    subtitle: 'El atleta paga durante el período actual',
                    value: BillingMode.current,
                    groupValue: config.billingMode,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateBillingMode(value);
                      }
                    },
                  ),

                  _buildRadioOption<BillingMode>(
                    title: 'Mes vencido',
                    subtitle: 'El atleta paga al final del período',
                    value: BillingMode.arrears,
                    groupValue: config.billingMode,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateBillingMode(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sección: Opciones de Pago
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Opciones de Pago',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Pagos Parciales
                  SwitchListTile(
                    title: const Text('Permitir Pagos Parciales'),
                    subtitle: const Text(
                      'Los atletas pueden realizar abonos a su suscripción',
                    ),
                    value: config.allowPartialPayments,
                    onChanged: (value) {
                      notifier.updateAllowPartialPayments(value);
                    },
                  ),

                  // Días de Gracia
                  ListTile(
                    title: const Text('Días de Gracia'),
                    subtitle: Text(
                      config.gracePeriodDays > 0
                          ? '${config.gracePeriodDays} días después de la fecha de vencimiento'
                          : 'Sin días de gracia',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              config.gracePeriodDays > 0
                                  ? () {
                                    notifier.updateGracePeriodDays(
                                      config.gracePeriodDays - 1,
                                    );
                                  }
                                  : null,
                        ),
                        Text('${config.gracePeriodDays}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            notifier.updateGracePeriodDays(
                              config.gracePeriodDays + 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Renovación Automática
                  SwitchListTile(
                    title: const Text('Renovación Automática'),
                    subtitle: const Text(
                      'Renovar suscripciones automáticamente al vencimiento',
                    ),
                    value: config.autoRenewal,
                    onChanged: (value) {
                      notifier.updateAutoRenewal(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sección: Descuentos y Recargos
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descuentos y Recargos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Descuento por Pronto Pago
                  ExpansionTile(
                    title: const Text('Descuento por Pronto Pago'),
                    subtitle: Text(
                      config.earlyPaymentDiscount
                          ? 'Activo: ${config.earlyPaymentDiscountPercent}% de descuento si paga ${config.earlyPaymentDays} días antes'
                          : 'Desactivado',
                    ),
                    children: [
                      SwitchListTile(
                        title: const Text('Habilitar Descuento'),
                        value: config.earlyPaymentDiscount,
                        onChanged: (value) {
                          notifier.updateEarlyPaymentDiscount(enabled: value);
                        },
                      ),

                      if (config.earlyPaymentDiscount) ...[
                        ListTile(
                          title: const Text('Porcentaje de Descuento'),
                          trailing: SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                suffix: Text('%'),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              controller: TextEditingController(
                                text:
                                    config.earlyPaymentDiscountPercent
                                        .toString(),
                              ),
                              onSubmitted: (value) {
                                final percent = double.tryParse(value);
                                if (percent != null) {
                                  notifier.updateEarlyPaymentDiscount(
                                    enabled: true,
                                    discountPercent: percent,
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        ListTile(
                          title: const Text('Días de Anticipación'),
                          trailing: SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                suffix: Text('días'),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              controller: TextEditingController(
                                text: config.earlyPaymentDays.toString(),
                              ),
                              onSubmitted: (value) {
                                final days = int.tryParse(value);
                                if (days != null) {
                                  notifier.updateEarlyPaymentDiscount(
                                    enabled: true,
                                    daysBeforeLimit: days,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Recargo por Pago Tardío
                  ExpansionTile(
                    title: const Text('Recargo por Pago Tardío'),
                    subtitle: Text(
                      config.lateFeeEnabled
                          ? 'Activo: ${config.lateFeePercent}% de recargo si paga después de la fecha límite'
                          : 'Desactivado',
                    ),
                    children: [
                      SwitchListTile(
                        title: const Text('Habilitar Recargo'),
                        value: config.lateFeeEnabled,
                        onChanged: (value) {
                          notifier.updateLateFee(enabled: value);
                        },
                      ),

                      if (config.lateFeeEnabled)
                        ListTile(
                          title: const Text('Porcentaje de Recargo'),
                          trailing: SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                suffix: Text('%'),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              controller: TextEditingController(
                                text: config.lateFeePercent.toString(),
                              ),
                              onSubmitted: (value) {
                                final percent = double.tryParse(value);
                                if (percent != null) {
                                  notifier.updateLateFee(
                                    enabled: true,
                                    feePercent: percent,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppTheme.bonfireRed,
      ),
      onTap: () {
        onChanged(value);
      },
    );
  }
}
