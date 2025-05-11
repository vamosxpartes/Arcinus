import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/app_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Pantalla para mostrar y seleccionar planes de suscripción de la aplicación.
class AppSubscriptionPlansScreen extends ConsumerWidget {
  const AppSubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener todos los planes disponibles
    final plansAsync = ref.watch(availablePlansProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
      ),
      body: plansAsync.when(
        data: (plans) => _buildPlansList(context, ref, plans),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar planes: $error'),
        ),
      ),
    );
  }

  Widget _buildPlansList(
    BuildContext context,
    WidgetRef ref,
    List<AppSubscriptionPlanModel> plans,
  ) {
    if (plans.isEmpty) {
      return const Center(
        child: Text('No hay planes disponibles'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildPlanCard(context, ref, plan),
        );
      },
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    WidgetRef ref,
    AppSubscriptionPlanModel plan,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: plan.currency == 'USD' ? '\$' : plan.currency,
      decimalDigits: 0,
    );

    // Obtener el texto del ciclo de facturación
    String billingCycleText = '';
    switch (plan.billingCycle) {
      case BillingCycle.monthly:
        billingCycleText = 'Mensual';
        break;
      case BillingCycle.quarterly:
        billingCycleText = 'Trimestral';
        break;
      case BillingCycle.biannual:
        billingCycleText = 'Semestral';
        break;
      case BillingCycle.annual:
        billingCycleText = 'Anual';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabecera del plan
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getPlanColor(plan.planType),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${currencyFormat.format(plan.price)} / $billingCycleText',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        // Detalles del plan
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlanDetail('Academias', '${plan.maxAcademies}'),
              _buildPlanDetail('Usuarios por Academia', '${plan.maxUsersPerAcademy}'),
              const SizedBox(height: 16),
              const Text(
                'Características:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...plan.features.map((feature) => _buildFeatureItem(feature)),
              if (plan.benefits.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Beneficios:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...plan.benefits.map(
                  (benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(benefit)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _subscribeToPlan(context, ref, plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPlanColor(plan.planType),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Seleccionar Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(AppFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(feature.displayName)),
        ],
      ),
    );
  }

  void _subscribeToPlan(
    BuildContext context,
    WidgetRef ref,
    AppSubscriptionPlanModel plan,
  ) {
    // Implementar lógica para suscribirse al plan
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suscribirse a ${plan.name}'),
        content: Text(
          '¿Estás seguro de que deseas suscribirte al plan ${plan.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí se implementaría la lógica para suscribirse al plan
              Navigator.pop(context);
              // Ejemplo: mostrar confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Suscripción a ${plan.name} realizada con éxito'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPlanColor(plan.planType),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Color _getPlanColor(AppSubscriptionPlanType planType) {
    switch (planType) {
      case AppSubscriptionPlanType.free:
        return Colors.grey;
      case AppSubscriptionPlanType.basic:
        return Colors.blue;
      case AppSubscriptionPlanType.pro:
        return Colors.purple;
      case AppSubscriptionPlanType.enterprise:
        return Colors.orange;
    }
  }
} 