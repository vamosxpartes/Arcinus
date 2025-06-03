import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/constants/app_colors.dart';
import 'package:arcinus/core/widgets/custom_elevated_button.dart';
import 'package:arcinus/core/widgets/custom_text_field.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/super_admin/presentation/providers/global_plans_provider.dart';

/// Pantalla para crear o editar planes de suscripción
class PlanEditorScreen extends ConsumerStatefulWidget {
  /// Plan a editar (null para crear nuevo)
  final AppSubscriptionPlanModel? plan;
  
  const PlanEditorScreen({super.key, this.plan});

  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController();
  final _maxAcademiesController = TextEditingController();
  final _maxUsersController = TextEditingController();
  
  AppSubscriptionPlanType _selectedPlanType = AppSubscriptionPlanType.basic;
  BillingCycle _selectedBillingCycle = BillingCycle.monthly;
  List<AppFeature> _selectedFeatures = [];
  List<String> _benefits = [];
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.plan != null) {
      final plan = widget.plan!;
      _nameController.text = plan.name;
      _priceController.text = plan.price.toString();
      _currencyController.text = plan.currency;
      _maxAcademiesController.text = plan.maxAcademies.toString();
      _maxUsersController.text = plan.maxUsersPerAcademy.toString();
      _selectedPlanType = plan.planType;
      _selectedBillingCycle = plan.billingCycle;
      _selectedFeatures = List.from(plan.features);
      _benefits = List.from(plan.benefits);
      _isActive = plan.isActive;
    } else {
      // Valores por defecto para nuevo plan
      _currencyController.text = 'USD';
      _maxAcademiesController.text = '1';
      _maxUsersController.text = '50';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _maxAcademiesController.dispose();
    _maxUsersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.plan != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Plan' : 'Crear Plan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información básica
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _nameController,
                labelText: 'Nombre del Plan *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Tipo de plan
              DropdownButtonFormField<AppSubscriptionPlanType>(
                value: _selectedPlanType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Plan *',
                  border: OutlineInputBorder(),
                ),
                items: AppSubscriptionPlanType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPlanType = value);
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Precio y facturación
              _buildSectionTitle('Precio y Facturación'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: 'Precio *',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Precio inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _currencyController,
                      labelText: 'Moneda *',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La moneda es requerida';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Ciclo de facturación
              DropdownButtonFormField<BillingCycle>(
                value: _selectedBillingCycle,
                decoration: const InputDecoration(
                  labelText: 'Ciclo de Facturación *',
                  border: OutlineInputBorder(),
                ),
                items: BillingCycle.values.map((cycle) {
                  return DropdownMenuItem(
                    value: cycle,
                    child: Text(cycle.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedBillingCycle = value);
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Límites
              _buildSectionTitle('Límites'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _maxAcademiesController,
                      labelText: 'Máx. Academias *',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _maxUsersController,
                      labelText: 'Máx. Usuarios/Academia *',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Características
              _buildSectionTitle('Características'),
              const SizedBox(height: 16),
              
              _buildFeaturesSection(),
              
              const SizedBox(height: 24),
              
              // Beneficios
              _buildSectionTitle('Beneficios'),
              const SizedBox(height: 16),
              
              _buildBenefitsSection(),
              
              const SizedBox(height: 24),
              
              // Estado
              SwitchListTile(
                title: const Text('Plan Activo'),
                subtitle: Text(_isActive ? 'El plan está disponible para suscripción' : 'El plan está deshabilitado'),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
                activeColor: AppColors.primary,
              ),
              
              const SizedBox(height: 32),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      text: 'Cancelar',
                      backgroundColor: Colors.grey,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomElevatedButton(
                      text: isEditing ? 'Actualizar' : 'Crear',
                      isLoading: _isLoading,
                      onPressed: _savePlan,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona las características incluidas:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: AppFeature.values.map((feature) {
            final isSelected = _selectedFeatures.contains(feature);
            return FilterChip(
              label: Text(feature.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFeatures.add(feature);
                  } else {
                    _selectedFeatures.remove(feature);
                  }
                });
              },
              selectedColor: AppColors.primary.withAlpha(51), // 20% opacity
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Beneficios del plan:')),
            IconButton(
              onPressed: _addBenefit,
              icon: const Icon(Icons.add),
              tooltip: 'Agregar beneficio',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._benefits.asMap().entries.map((entry) {
          final index = entry.key;
          final benefit = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: benefit,
                    decoration: InputDecoration(
                      labelText: 'Beneficio ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _benefits[index] = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeBenefit(index),
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  tooltip: 'Eliminar beneficio',
                ),
              ],
            ),
          );
        }),
        if (_benefits.isEmpty)
          const Text(
            'No hay beneficios agregados',
            style: TextStyle(color: Colors.grey),
          ),
      ],
    );
  }

  void _addBenefit() {
    setState(() {
      _benefits.add('');
    });
  }

  void _removeBenefit(int index) {
    setState(() {
      _benefits.removeAt(index);
    });
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final plan = AppSubscriptionPlanModel(
        id: widget.plan?.id,
        name: _nameController.text.trim(),
        planType: _selectedPlanType,
        price: double.parse(_priceController.text),
        currency: _currencyController.text.trim().toUpperCase(),
        billingCycle: _selectedBillingCycle,
        maxAcademies: int.parse(_maxAcademiesController.text),
        maxUsersPerAcademy: int.parse(_maxUsersController.text),
        features: _selectedFeatures,
        benefits: _benefits.where((b) => b.trim().isNotEmpty).toList(),
        isActive: _isActive,
      );

      bool success;
      if (widget.plan != null) {
        // Actualizar plan existente
        success = await ref.read(globalPlansProvider.notifier).updatePlan(widget.plan!.id!, plan);
      } else {
        // Crear nuevo plan
        success = await ref.read(globalPlansProvider.notifier).createPlan(plan);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.plan != null 
                  ? 'Plan actualizado exitosamente' 
                  : 'Plan creado exitosamente'
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el plan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 