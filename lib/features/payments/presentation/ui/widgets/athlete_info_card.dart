import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

/// Widget para mostrar la información del atleta seleccionado
class AthleteInfoCard extends StatelessWidget {
  final ClientUserModel? clientUser;
  final AcademyUserModel? academyUser;
  final VoidCallback? onEditPlan;

  const AthleteInfoCard({
    super.key,
    this.clientUser,
    this.academyUser,
    this.onEditPlan,
  });

  @override
  Widget build(BuildContext context) {
    if (academyUser != null) {
      return _buildAcademyUserInfo();
    } else if (clientUser != null) {
      return _buildClientUserInfo();
    } else {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No se encontró información del atleta'),
        ),
      );
    }
  }

  Widget _buildAcademyUserInfo() {
    final hasSubscription = clientUser?.subscriptionPlan != null;
    final isActive = clientUser?.paymentStatus.name == 'active';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAthleteAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAthleteBasicInfo(hasSubscription, isActive),
                ),
                if (hasSubscription && onEditPlan != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Cambiar plan',
                    onPressed: onEditPlan,
                  ),
              ],
            ),
            if (hasSubscription) ...[
              const SizedBox(height: 16),
              _buildSubscriptionDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientUserInfo() {
    final hasSubscription = clientUser!.subscriptionPlan != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.courtGreen,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atleta ID: ${clientUser!.userId}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasSubscription
                            ? 'Plan: ${clientUser!.subscriptionPlan!.name}'
                            : 'Sin plan de suscripción',
                        style: TextStyle(
                          color: hasSubscription ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasSubscription) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estado: ${clientUser!.paymentStatus.displayName}'),
                  if (clientUser!.nextPaymentDate != null)
                    Text('Próximo pago: ${DateFormat('dd/MM/yyyy').format(clientUser!.nextPaymentDate!)}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAthleteAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.courtGreen,
          backgroundImage: academyUser!.profileImageUrl != null
              ? NetworkImage(academyUser!.profileImageUrl!)
              : null,
          child: academyUser!.profileImageUrl == null
              ? const Icon(Icons.person, size: 30, color: Colors.white)
              : null,
        ),
        // Indicador de estado
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: clientUser?.subscriptionPlan != null && clientUser?.paymentStatus.name == 'active' 
                  ? Colors.green 
                  : Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              clientUser?.subscriptionPlan != null && clientUser?.paymentStatus.name == 'active' 
                  ? Icons.check 
                  : Icons.warning,
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteBasicInfo(bool hasSubscription, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          academyUser!.fullName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              hasSubscription ? Icons.card_membership : Icons.warning,
              size: 16,
              color: hasSubscription ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              hasSubscription
                  ? clientUser!.subscriptionPlan!.name
                  : 'Sin plan de suscripción',
              style: TextStyle(
                color: hasSubscription ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (hasSubscription) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              clientUser!.paymentStatus.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green.shade800 : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubscriptionDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monto del Plan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '${clientUser!.subscriptionPlan!.amount} ${clientUser!.subscriptionPlan!.currency}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (clientUser!.nextPaymentDate != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Próximo Pago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      DateFormat('dd/MM/yyyy').format(clientUser!.nextPaymentDate!),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          // Mostrar días restantes si hay fecha de próximo pago
          if (clientUser!.nextPaymentDate != null) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildDaysRemainingIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildDaysRemainingIndicator() {
    if (clientUser?.nextPaymentDate == null) {
      return const SizedBox.shrink();
    }
    
    final nextPaymentDate = clientUser!.nextPaymentDate!;
    final now = DateTime.now();
    final daysUntilPayment = nextPaymentDate.difference(now).inDays;
    
    Color indicatorColor;
    IconData indicatorIcon;
    String statusText;
    
    if (daysUntilPayment < 0) {
      // Pago vencido
      indicatorColor = Colors.red;
      indicatorIcon = Icons.error;
      statusText = 'Vencido hace ${(-daysUntilPayment)} días';
    } else if (daysUntilPayment == 0) {
      // Pago hoy
      indicatorColor = Colors.orange;
      indicatorIcon = Icons.today;
      statusText = 'Vence hoy';
    } else if (daysUntilPayment <= 7) {
      // Próximo a vencer
      indicatorColor = Colors.orange;
      indicatorIcon = Icons.warning;
      statusText = 'Vence en $daysUntilPayment días';
    } else {
      // Tiempo suficiente
      indicatorColor = Colors.green;
      indicatorIcon = Icons.check_circle;
      statusText = 'Vence en $daysUntilPayment días';
    }
    
    return Row(
      children: [
        Icon(indicatorIcon, color: indicatorColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: indicatorColor,
            ),
          ),
        ),
        // Barra de progreso visual
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey.shade300,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: daysUntilPayment <= 0 
                ? 1.0 
                : (daysUntilPayment >= 30 ? 0.0 : (30 - daysUntilPayment) / 30).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: indicatorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 