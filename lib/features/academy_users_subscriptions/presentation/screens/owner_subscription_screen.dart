import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/app_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Pantalla que muestra la suscripción actual de un propietario.
class OwnerSubscriptionScreen extends ConsumerWidget {
  final String ownerId;

  const OwnerSubscriptionScreen({
    super.key,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener la suscripción actual del propietario
    final subscriptionAsync = ref.watch(appSubscriptionProvider(ownerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Suscripción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(appSubscriptionProvider(ownerId).notifier).refreshSubscription();
            },
          ),
        ],
      ),
      body: subscriptionAsync.when(
        data: (subscription) {
          if (subscription == null) {
            return _buildNoSubscription(context);
          }
          return _buildSubscriptionDetails(context, ref, subscription);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error al cargar la suscripción: $error'),
        ),
      ),
    );
  }

  Widget _buildNoSubscription(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.card_membership_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes una suscripción activa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suscríbete a un plan para poder crear academias',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navegar a la pantalla de planes
              Navigator.pushNamed(context, '/subscription-plans');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Ver Planes Disponibles'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(
    BuildContext context,
    WidgetRef ref,
    AppSubscriptionModel subscription,
  ) {
    final plan = subscription.plan;
    if (plan == null) {
      return const Center(
        child: Text('Información del plan no disponible'),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, plan),
          const SizedBox(height: 24),
          _buildInfoCard(
            context,
            'Detalles de la Suscripción',
            [
              _buildInfoRow('Estado', _getStatusLabel(subscription.status)),
              _buildInfoRow(
                'Fecha de inicio',
                dateFormat.format(subscription.startDate),
              ),
              _buildInfoRow(
                'Fecha de renovación',
                dateFormat.format(subscription.endDate),
              ),
              if (subscription.lastPaymentDate != null)
                _buildInfoRow(
                  'Último pago',
                  dateFormat.format(subscription.lastPaymentDate!),
                ),
              _buildInfoRow(
                'Academias creadas',
                '${subscription.currentAcademyCount} / ${plan.maxAcademies}',
              ),
              _buildInfoRow(
                'Usuarios totales',
                '${subscription.totalUserCount} usuarios',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            'Características Incluidas',
            plan.features.map((feature) => _buildFeatureItem(feature)).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navegar a la pantalla de historial de pagos
                    // Navigator.pushNamed(context, '/payment-history', arguments: ownerId);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Historial de Pagos'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navegar a la pantalla de cambio de plan
                    Navigator.pushNamed(context, '/subscription-plans');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: _getPlanColor(plan.planType),
                  ),
                  child: const Text('Cambiar Plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppSubscriptionPlanModel plan) {
    final currencyFormat = NumberFormat.currency(
      symbol: plan.currency == 'USD' ? '\$' : plan.currency,
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getPlanColor(plan.planType).withAlpha(178),
              _getPlanColor(plan.planType),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.planType.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${currencyFormat.format(plan.price)} / mes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(feature.displayName)),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Activa';
      case 'expired':
        return 'Expirada';
      case 'cancelled':
        return 'Cancelada';
      case 'trial':
        return 'Período de prueba';
      default:
        return 'Desconocido';
    }
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