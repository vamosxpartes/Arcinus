import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/subscriptions/domain/repositories/subscription_repository_impl.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Pantalla para gestionar planes de suscripción de una academia
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  final String academyId;

  const SubscriptionPlansScreen({
    super.key,
    required this.academyId,
  });

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  bool _showInactivePlans = false;
  
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'SubscriptionPlansScreen inicializado',
      className: 'SubscriptionPlansScreen',
      functionName: 'initState',
      params: {
        'academyId': widget.academyId,
      },
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Establecer el título de la pantalla
      AppLogger.logInfo(
        'Estableciendo título en SubscriptionPlansScreen',
        className: 'SubscriptionPlansScreen',
        functionName: 'initState.postFrame',
        params: {
          'título': 'Planes de Suscripción',
        },
      );
      ref.read(currentScreenTitleProvider.notifier).state = 'Planes de Suscripción';
    });
  }

  @override
  Widget build(BuildContext context) {
    final plansAsyncValue = ref.watch(subscriptionPlansProvider(widget.academyId));
    
    return Column(
      children: [
        // Filtros y controles
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Switch para mostrar planes inactivos
              Row(
                children: [
                  Switch(
                    value: _showInactivePlans,
                    onChanged: (value) {
                      setState(() {
                        _showInactivePlans = value;
                      });
                    },
                  ),
                  Text('Mostrar inactivos'),
                ],
              ),
              
              const Spacer(),
              
              // Botón para crear nuevo plan
              SizedBox(
                width: 120,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('nuevo'),
                  onPressed: () {
                    _showPlanForm(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bonfireRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Lista de planes
        Expanded(
          child: plansAsyncValue.when(
            data: (plans) {
              // Filtrar planes según el estado del switch
              final filteredPlans = _showInactivePlans
                  ? plans
                  : plans.where((plan) => plan.isActive).toList();
              
              if (filteredPlans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.subscriptions_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No hay planes ${_showInactivePlans ? "" : "activos"} disponibles',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Crear primer plan'),
                        onPressed: () {
                          _showPlanForm(context);
                        },
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: filteredPlans.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final plan = filteredPlans[index];
                  return _buildPlanCard(context, plan);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error al cargar planes: $error'),
            ),
          ),
        ),
      ],
    );
  }
  
  // Widget para mostrar un plan individual
  Widget _buildPlanCard(BuildContext context, SubscriptionPlanModel plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del plan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: plan.isActive ? AppTheme.bonfireRed.withAlpha(220) : Colors.grey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  plan.formattedPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Cuerpo del plan
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                if (plan.description != null && plan.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(plan.description!),
                  ),
                
                // Beneficios
                if (plan.benefits.isNotEmpty) ...[
                  const Text(
                    'Beneficios incluidos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...plan.benefits.map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(benefit),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
                
                // Información adicional
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Duración: ${plan.durationInDays} días'),
                          const SizedBox(height: 4),
                          if (plan.discountDisplay.isNotEmpty)
                            Text(
                              plan.discountDisplay,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Botones de acción
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showPlanForm(context, plan: plan);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            plan.isActive ? Icons.visibility_off : Icons.visibility,
                            color: plan.isActive ? Colors.grey : Colors.green,
                          ),
                          onPressed: () {
                            _togglePlanStatus(plan);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Mostrar formulario para crear/editar plan
  void _showPlanForm(BuildContext context, {SubscriptionPlanModel? plan}) {
    final isEditing = plan != null;
    final nameController = TextEditingController(text: plan?.name ?? '');
    final amountController = TextEditingController(text: plan?.amount.toString() ?? '');
    final currencyController = TextEditingController(text: plan?.currency ?? 'COP');
    final descriptionController = TextEditingController(text: plan?.description ?? '');
    
    // Valor inicial del ciclo de facturación
    BillingCycle selectedCycle = plan?.billingCycle ?? BillingCycle.monthly;
    
    // Lista editable de beneficios
    final benefitsList = List<String>.from(plan?.benefits ?? []);
    final benefitController = TextEditingController();
    
    // Estado de activación
    bool isActive = plan?.isActive ?? true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.blackSwarm,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título del formulario
                  Text(
                    isEditing ? 'Editar Plan' : 'Nuevo Plan de Suscripción',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Nombre del plan
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Plan *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Precio y moneda
                  Row(
                    children: [
                      // Precio
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Moneda
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: currencyController,
                          decoration: const InputDecoration(
                            labelText: 'Moneda *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ciclo de facturación
                  DropdownButtonFormField<BillingCycle>(
                    value: selectedCycle,
                    decoration: const InputDecoration(
                      labelText: 'Ciclo de Facturación *',
                      border: OutlineInputBorder(),
                    ),
                    items: BillingCycle.values.map((cycle) {
                      return DropdownMenuItem<BillingCycle>(
                        value: cycle,
                        child: Text(cycle.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCycle = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Descripción
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      hintText: 'Descripción detallada del plan...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Beneficios
                  const Text(
                    'Beneficios Incluidos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Lista de beneficios
                  ...benefitsList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final benefit = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(benefit)),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                benefitsList.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  // Agregar beneficio
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: benefitController,
                          decoration: const InputDecoration(
                            hintText: 'Agregar beneficio...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (benefitController.text.isNotEmpty) {
                            setState(() {
                              benefitsList.add(benefitController.text);
                              benefitController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Estado (activo/inactivo)
                  SwitchListTile(
                    title: const Text('Plan Activo'),
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox( 
                        width: 120,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Validar campos obligatorios
                            if (nameController.text.isEmpty || amountController.text.isEmpty || currencyController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor, completa los campos obligatorios')),
                              );
                              return;
                            }
                            
                            // Validar que el monto sea un número válido
                            double? amount;
                            try {
                              amount = double.parse(amountController.text);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('El precio debe ser un número válido')),
                              );
                              return;
                            }
                            
                            // Crear o actualizar el plan
                            final updatedPlan = (plan != null)
                                ? plan.copyWith(
                                    name: nameController.text,
                                    amount: amount,
                                    currency: currencyController.text,
                                    billingCycle: selectedCycle,
                                    description: descriptionController.text,
                                    benefits: benefitsList,
                                    isActive: isActive,
                                    updatedAt: DateTime.now(),
                                  )
                                : SubscriptionPlanModel(
                                    name: nameController.text,
                                    amount: amount,
                                    currency: currencyController.text,
                                    billingCycle: selectedCycle,
                                    description: descriptionController.text,
                                    benefits: benefitsList,
                                    isActive: isActive,
                                    createdAt: DateTime.now(),
                                  );
                            
                            // Guardar el plan
                            _savePlan(updatedPlan, isEditing);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bonfireRed,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(isEditing ? 'Actualizar' : 'Crear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  // Guardar el plan en la base de datos
  void _savePlan(SubscriptionPlanModel plan, bool isEditing) {
    final repository = ref.read(subscriptionRepositoryProvider);
    
    if (isEditing && plan.id != null) {
      repository.updateSubscriptionPlan(widget.academyId, plan.id!, plan).then((result) {
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar plan: ${failure.message}')),
          ),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan actualizado correctamente')),
            );
            // Refrescar la lista de planes
            ref.invalidate(subscriptionPlansProvider(widget.academyId));
          },
        );
      });
    } else {
      repository.createSubscriptionPlan(widget.academyId, plan).then((result) {
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear plan: ${failure.message}')),
          ),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan creado correctamente')),
            );
            // Refrescar la lista de planes
            ref.invalidate(subscriptionPlansProvider(widget.academyId));
          },
        );
      });
    }
  }
  
  // Cambiar el estado de un plan (activo/inactivo)
  void _togglePlanStatus(SubscriptionPlanModel plan) {
    if (plan.id == null) return;
    
    final updatedPlan = plan.copyWith(
      isActive: !plan.isActive,
      updatedAt: DateTime.now(),
    );
    
    final repository = ref.read(subscriptionRepositoryProvider);
    repository.updateSubscriptionPlan(widget.academyId, plan.id!, updatedPlan).then((result) {
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: ${failure.message}')),
        ),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plan ${updatedPlan.isActive ? "activado" : "desactivado"}')),
          );
          // Refrescar la lista de planes
          ref.invalidate(subscriptionPlansProvider(widget.academyId));
        },
      );
    });
  }
} 