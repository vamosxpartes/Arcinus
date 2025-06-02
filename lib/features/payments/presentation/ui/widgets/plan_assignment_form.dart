import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';

/// Widget para el formulario de asignación de planes de suscripción
/// Simplificado para solo seleccionar el plan, sin fecha de inicio
class PlanAssignmentForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final String? selectedPlanId;
  final bool isSubmitting;
  final AsyncValue<List<SubscriptionPlanModel>> plansAsync;
  final ValueChanged<String?> onPlanChanged;
  final VoidCallback onSavePlan;

  const PlanAssignmentForm({
    super.key,
    required this.formKey,
    this.selectedPlanId,
    required this.isSubmitting,
    required this.plansAsync,
    required this.onPlanChanged,
    required this.onSavePlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          
          const Text(
            'Asignar Plan de Suscripción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildPlanSelector(),
          
          const SizedBox(height: 24),
          
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Asignación de Plan Simplificada',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona un plan para el atleta. La fecha de inicio se establecerá automáticamente cuando se registre el primer pago.',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Una vez asignado el plan, podrás registrar pagos y la fecha de inicio se calculará automáticamente.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

  Widget _buildPlanSelector() {
    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return _buildNoPlanAvailableCard();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de plan
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Plan de Suscripción',
                prefixIcon: Icon(Icons.card_membership),
                border: OutlineInputBorder(),
                hintText: 'Selecciona un plan...',
              ),
              value: selectedPlanId,
              items: plans.map((plan) {
                return DropdownMenuItem<String>(
                  value: plan.id,
                  child: _buildPlanDropdownItem(plan),
                );
              }).toList(),
              onChanged: onPlanChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecciona un plan';
                }
                return null;
              },
              isExpanded: true,
              menuMaxHeight: 300,
            ),
            const SizedBox(height: 16),
            
            // Mostrar detalles del plan seleccionado
            if (selectedPlanId != null) _buildSelectedPlanDetails(plans),
          ],
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Cargando planes disponibles...'),
            ],
          ),
        ),
      ),
      error: (error, _) => Card(
        color: Colors.red.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Error al cargar planes',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPlanAvailableCard() {
    return Card(
      color: Colors.red.shade100,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No hay planes disponibles',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No hay planes de suscripción activos en la academia. Contacta al administrador.',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDropdownItem(SubscriptionPlanModel plan) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getPlanColor(plan.billingCycle),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plan.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                '${plan.amount} ${plan.currency} - ${plan.billingCycle.displayName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPlanDetails(List<SubscriptionPlanModel> plans) {
    final selectedPlan = plans.firstWhere((plan) => plan.id == selectedPlanId);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Detalles del Plan Seleccionado',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Nombre', selectedPlan.name),
              ),
              Expanded(
                child: _buildDetailItem('Precio', '${selectedPlan.amount} ${selectedPlan.currency}'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Ciclo', selectedPlan.billingCycle.displayName),
              ),
              Expanded(
                child: _buildDetailItem('Duración', '${selectedPlan.durationInDays} días'),
              ),
            ],
          ),
          
          if (selectedPlan.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _buildDetailItem('Descripción', selectedPlan.description!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : onSavePlan,
        icon: isSubmitting 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save),
        label: Text(isSubmitting ? 'Asignando Plan...' : 'Asignar Plan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Color _getPlanColor(BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return Colors.green;
      case BillingCycle.quarterly:
        return Colors.orange;
      case BillingCycle.biannual:
        return Colors.purple;
      case BillingCycle.annual:
        return Colors.blue;
    }
  }
} 