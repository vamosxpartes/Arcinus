import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';

/// Widget unificado para selección de plan, períodos y fechas de servicio
/// Combina toda la funcionalidad relacionada con la configuración del pago
class UnifiedPaymentSelector extends ConsumerWidget {
  // Selección de plan
  final String? selectedPlanId;
  final ValueChanged<String?> onPlanChanged;
  final String academyId;
  
  // Selección de períodos
  final int selectedPeriods;
  final ValueChanged<int> onPeriodsChanged;
  final bool canSelectMultiplePeriods;
  
  // Fechas de servicio
  final DateTime? serviceStartDate;
  final DateTime? serviceEndDate;
  final bool showStartDateSelector;
  final VoidCallback? onSelectServiceStartDate;
  
  // Configuración
  final PaymentConfigModel? config;
  final String currency;
  
  // Estado de protección
  final bool hasActivePeriods;
  final bool canEditPlans;

  const UnifiedPaymentSelector({
    super.key,
    required this.selectedPlanId,
    required this.onPlanChanged,
    required this.academyId,
    required this.selectedPeriods,
    required this.onPeriodsChanged,
    required this.canSelectMultiplePeriods,
    this.serviceStartDate,
    this.serviceEndDate,
    this.showStartDateSelector = false,
    this.onSelectServiceStartDate,
    this.config,
    this.currency = 'COP',
    this.hasActivePeriods = false,
    this.canEditPlans = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(activeSubscriptionPlansProvider(academyId));
    
    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.bonfireRed.withAlpha(30),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header principal
            _buildMainHeader(),
            const SizedBox(height: AppTheme.spacingLg),
            
            // Banner de protección si hay períodos activos
            if (hasActivePeriods && !canEditPlans) ...[
              _buildProtectionBanner(),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            
            // Selección de plan y períodos en fila
            _buildPlanAndPeriodsRow(plansAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.bonfireRed, AppTheme.embers],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.spacingMd),
          ),
          child: const Icon(
            Icons.payment,
            color: AppTheme.magnoliaWhite,
            size: 24,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        const Expanded(
          child: Text(
            'Configuración del Pago',
            style: TextStyle(
              fontSize: AppTheme.h2Size,
              fontWeight: FontWeight.w700,
              color: AppTheme.magnoliaWhite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProtectionBanner() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.nbaBluePrimary.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.spacingMd),
        border: Border.all(
          color: AppTheme.nbaBluePrimary.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: AppTheme.nbaBluePrimary,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Expanded(
            child: Text(
              'Períodos activos detectados. Selecciona un plan solo para este pago.',
              style: TextStyle(
                fontSize: AppTheme.secondarySize,
                color: AppTheme.lightGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanAndPeriodsRow(AsyncValue<List<SubscriptionPlanModel>> plansAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtítulo
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.goldTrophy,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            const Text(
              'Plan de Suscripción',
              style: TextStyle(
                fontSize: AppTheme.subtitleSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.magnoliaWhite,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        
        // Solo el selector de plan
        _buildPlanDropdown(plansAsync),
      ],
    );
  }

  Widget _buildPlanDropdown(AsyncValue<List<SubscriptionPlanModel>> plansAsync) {
    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.darkGray,
              borderRadius: BorderRadius.circular(AppTheme.spacingMd),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: AppTheme.spacingMd),
                Text(
                  'No hay planes disponibles',
                  style: TextStyle(color: AppTheme.lightGray),
                ),
              ],
            ),
          );
        }
        
        return DropdownButtonFormField<String>(
          value: selectedPlanId,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.darkGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingMd),
              borderSide: BorderSide(color: AppTheme.lightGray.withAlpha(30)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingMd),
              borderSide: BorderSide(color: AppTheme.lightGray.withAlpha(30)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingMd),
              borderSide: const BorderSide(color: AppTheme.bonfireRed),
            ),
            prefixIcon: const Icon(Icons.subscriptions, color: AppTheme.lightGray),
            hintText: 'Selecciona un plan',
            hintStyle: const TextStyle(color: AppTheme.lightGray),
          ),
          dropdownColor: AppTheme.darkGray,
          style: const TextStyle(color: AppTheme.magnoliaWhite),
          isExpanded: true, // Maneja overflow
          menuMaxHeight: 300, // Limita altura del menú
          items: plans.map((plan) {
            return DropdownMenuItem<String>(
              value: plan.id,
              child: Container(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.magnoliaWhite,
                      ),
                      overflow: TextOverflow.ellipsis, // Maneja overflow de texto
                      maxLines: 1,
                    ),
                    Text(
                      '${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(plan.amount)} ${plan.currency} - ${plan.billingCycle.displayName}',
                      style: TextStyle(
                        fontSize: AppTheme.secondarySize,
                        color: AppTheme.lightGray,
                      ),
                      overflow: TextOverflow.ellipsis, // Maneja overflow de texto
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: onPlanChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Debes seleccionar un plan';
            }
            return null;
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(10),
          borderRadius: BorderRadius.circular(AppTheme.spacingMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Text(
                'Error al cargar planes: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}