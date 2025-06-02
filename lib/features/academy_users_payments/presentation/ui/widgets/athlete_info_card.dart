import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/features/academy_users/data/repositories/academy_users_repository.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/athlete_periods_info_provider.dart';

/// Widget para mostrar la información del atleta seleccionado
class AthleteInfoCard extends StatelessWidget {
  final AcademyMemberUserModel? clientUser;
  final AcademyUserModel? academyUser;
  final AthleteCompleteInfo? athleteInfo;
  final VoidCallback? onEditPlan;

  const AthleteInfoCard({
    super.key,
    this.clientUser,
    this.academyUser,
    this.athleteInfo,
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
    final hasActivePlan = athleteInfo?.hasActivePlan ?? false;
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
                  child: _buildAthleteBasicInfo(hasActivePlan, isActive),
                ),
                if (hasActivePlan && onEditPlan != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Cambiar plan',
                    onPressed: onEditPlan,
                  ),
              ],
            ),
            if (hasActivePlan) ...[
              const SizedBox(height: 16),
              _buildSubscriptionDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientUserInfo() {
    final hasActivePlan = athleteInfo?.hasActivePlan ?? false;

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
                        hasActivePlan
                            ? 'Tiene plan activo'
                            : 'Sin plan de suscripción',
                        style: TextStyle(
                          color: hasActivePlan ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasActivePlan) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estado: ${clientUser!.paymentStatus.displayName}'),
                  if (athleteInfo?.nextPaymentDate != null)
                    Text('Próximo pago: ${DateFormat('dd/MM/yyyy').format(athleteInfo!.nextPaymentDate!)}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAthleteAvatar() {
    final hasActivePlan = athleteInfo?.hasActivePlan ?? false;
    final isActive = clientUser?.paymentStatus.name == 'active';
    
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
              color: hasActivePlan && isActive 
                  ? Colors.green 
                  : Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              hasActivePlan && isActive 
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

  Widget _buildAthleteBasicInfo(bool hasActivePlan, bool isActive) {
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
              hasActivePlan ? Icons.card_membership : Icons.warning,
              size: 16,
              color: hasActivePlan ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              hasActivePlan
                  ? 'Plan activo'
                  : 'Sin plan de suscripción',
              style: TextStyle(
                color: hasActivePlan ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (hasActivePlan) ...[
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
    final totalValue = athleteInfo?.totalValue ?? 0.0;
    final nextPaymentDate = athleteInfo?.nextPaymentDate;
    
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
                  const Text('Valor Total Períodos', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(totalValue),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (nextPaymentDate != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Próximo Vencimiento', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      DateFormat('dd/MM/yyyy').format(nextPaymentDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          // Mostrar días restantes si hay fecha de próximo pago
          if (nextPaymentDate != null) ...[
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
    final nextPaymentDate = athleteInfo?.nextPaymentDate;
    if (nextPaymentDate == null) {
      return const SizedBox.shrink();
    }
    
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