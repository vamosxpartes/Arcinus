import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/widgets/custom_elevated_button.dart';
import 'package:arcinus/core/widgets/custom_text_field.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/utils/app_subscription_initializer.dart';
import 'package:arcinus/features/super_admin/presentation/providers/global_plans_provider.dart';
import 'package:arcinus/features/super_admin/presentation/widgets/plan_card_widget.dart';
import 'package:arcinus/features/super_admin/presentation/screens/plan_editor_screen.dart';
import 'package:intl/intl.dart';

/// Pantalla principal de gestión de planes de suscripción globales
class GlobalSubscriptionPlansScreen extends ConsumerStatefulWidget {
  static const String routeName = '/super-admin/global-plans';
  
  const GlobalSubscriptionPlansScreen({super.key});

  @override
  ConsumerState<GlobalSubscriptionPlansScreen> createState() => _GlobalSubscriptionPlansScreenState();
}

class _GlobalSubscriptionPlansScreenState extends ConsumerState<GlobalSubscriptionPlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  AppSubscriptionPlanType? _selectedPlanType;
  BillingCycle? _selectedBillingCycle;
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    // Cargar planes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalPlansProvider.notifier).loadPlans();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plansState = ref.watch(globalPlansProvider);

    return Scaffold(
      backgroundColor: AppTheme.blackSwarm,
      appBar: AppBar(
        title: const Text('Gestión de Planes Globales'),
        backgroundColor: AppTheme.bonfireRed,
        foregroundColor: AppTheme.magnoliaWhite,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de filtros y búsqueda
          _buildFilterBar(),
          
          // Lista de planes
          Expanded(
            child: plansState.when(
              data: (plans) => _buildPlansList(plans),
              loading: () => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.bonfireRed),
                ),
              ),
              error: (error, stackTrace) {
                AppLogger.logError(
                  message: 'Error al cargar planes: $error',
                  error: error,
                  stackTrace: stackTrace,
                  className: 'GlobalSubscriptionPlansScreen',
                  functionName: 'build',
                );
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline, 
                        size: 64, 
                        color: AppTheme.bonfireRed,
                      ),
                      SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'Error al cargar los planes: $error',
                        style: TextStyle(
                          color: AppTheme.magnoliaWhite,
                          fontSize: AppTheme.bodySize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.spacingMd),
                      CustomElevatedButton(
                        text: 'Reintentar',
                        onPressed: () => ref.read(globalPlansProvider.notifier).loadPlans(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePlanDialog,
        backgroundColor: AppTheme.bonfireRed,
        foregroundColor: AppTheme.magnoliaWhite,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Plan'),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      color: AppTheme.mediumGray,
      child: Column(
        children: [
          // Barra de búsqueda
          CustomTextField(
            controller: _searchController,
            labelText: 'Buscar planes...',
            prefixIcon: Icon(Icons.search, color: AppTheme.lightGray),
            onChanged: (value) {
              ref.read(globalPlansProvider.notifier).filterPlans(
                searchQuery: value,
                planType: _selectedPlanType,
                billingCycle: _selectedBillingCycle,
                isActive: _activeFilter,
              );
            },
          ),
          
          SizedBox(height: AppTheme.spacingSm),
          
          // Filtros
          Row(
            children: [
              // Filtro por tipo de plan
              Expanded(
                child: DropdownButtonFormField<AppSubscriptionPlanType?>(
                  value: _selectedPlanType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Plan',
                    labelStyle: TextStyle(color: AppTheme.lightGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.lightGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.bonfireRed),
                    ),
                    filled: true,
                    fillColor: AppTheme.darkGray,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm, 
                      vertical: AppTheme.spacingXs,
                    ),
                  ),
                  dropdownColor: AppTheme.darkGray,
                  style: TextStyle(color: AppTheme.magnoliaWhite),
                  items: [
                    DropdownMenuItem<AppSubscriptionPlanType?>(
                      value: null,
                      child: Text(
                        'Todos los tipos',
                        style: TextStyle(color: AppTheme.magnoliaWhite),
                      ),
                    ),
                    ...AppSubscriptionPlanType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.displayName,
                          style: TextStyle(color: AppTheme.magnoliaWhite),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPlanType = value);
                    _applyFilters();
                  },
                ),
              ),
              
              SizedBox(width: AppTheme.spacingSm),
              
              // Filtro por ciclo de facturación
              Expanded(
                child: DropdownButtonFormField<BillingCycle?>(
                  value: _selectedBillingCycle,
                  decoration: InputDecoration(
                    labelText: 'Ciclo',
                    labelStyle: TextStyle(color: AppTheme.lightGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.lightGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.bonfireRed),
                    ),
                    filled: true,
                    fillColor: AppTheme.darkGray,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm, 
                      vertical: AppTheme.spacingXs,
                    ),
                  ),
                  dropdownColor: AppTheme.darkGray,
                  style: TextStyle(color: AppTheme.magnoliaWhite),
                  items: [
                    DropdownMenuItem<BillingCycle?>(
                      value: null,
                      child: Text(
                        'Todos los ciclos',
                        style: TextStyle(color: AppTheme.magnoliaWhite),
                      ),
                    ),
                    ...BillingCycle.values.map(
                      (cycle) => DropdownMenuItem(
                        value: cycle,
                        child: Text(
                          cycle.displayName,
                          style: TextStyle(color: AppTheme.magnoliaWhite),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedBillingCycle = value);
                    _applyFilters();
                  },
                ),
              ),
              
              SizedBox(width: AppTheme.spacingSm),
              
              // Filtro por estado activo
              Expanded(
                child: DropdownButtonFormField<bool?>(
                  value: _activeFilter,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    labelStyle: TextStyle(color: AppTheme.lightGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.lightGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                      borderSide: BorderSide(color: AppTheme.bonfireRed),
                    ),
                    filled: true,
                    fillColor: AppTheme.darkGray,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm, 
                      vertical: AppTheme.spacingXs,
                    ),
                  ),
                  dropdownColor: AppTheme.darkGray,
                  style: TextStyle(color: AppTheme.magnoliaWhite),
                  items: [
                    DropdownMenuItem<bool?>(
                      value: null,
                      child: Text(
                        'Todos',
                        style: TextStyle(color: AppTheme.magnoliaWhite),
                      ),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text(
                        'Activos',
                        style: TextStyle(color: AppTheme.magnoliaWhite),
                      ),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text(
                        'Inactivos',
                        style: TextStyle(color: AppTheme.magnoliaWhite),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _activeFilter = value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList(List<AppSubscriptionPlanModel> plans) {
    if (plans.isEmpty) {
      return Container(
        color: AppTheme.blackSwarm,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined, 
                size: 64, 
                color: AppTheme.lightGray,
              ),
              SizedBox(height: AppTheme.spacingMd),
              Text(
                'No se encontraron planes',
                style: TextStyle(
                  fontSize: AppTheme.h3Size,
                  color: AppTheme.magnoliaWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppTheme.spacingXs),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                child: Text(
                  'Crea el primer plan de suscripción o inicializa con datos predeterminados',
                  style: TextStyle(
                    color: AppTheme.lightGray,
                    fontSize: AppTheme.bodySize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    text: 'Inicializar Datos',
                    onPressed: _initializeDefaultPlans,
                    backgroundColor: AppTheme.nbaBluePrimary,
                  ),
                  SizedBox(width: AppTheme.spacingMd),
                  CustomElevatedButton(
                    text: 'Crear Nuevo Plan',
                    onPressed: _showCreatePlanDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppTheme.blackSwarm,
      child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(globalPlansProvider.notifier).loadPlans();
        },
        backgroundColor: AppTheme.mediumGray,
        color: AppTheme.bonfireRed,
        child: ListView.builder(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: PlanCardWidget(
                plan: plan,
                onEdit: () => _showEditPlanDialog(plan),
                onToggleStatus: () => _togglePlanStatus(plan),
                onDelete: () => _showDeleteConfirmation(plan),
                onViewDetails: () => _showPlanDetails(plan),
              ),
            );
          },
        ),
      ),
    );
  }

  void _applyFilters() {
    ref.read(globalPlansProvider.notifier).filterPlans(
      searchQuery: _searchController.text,
      planType: _selectedPlanType,
      billingCycle: _selectedBillingCycle,
      isActive: _activeFilter,
    );
  }

  void _showCreatePlanDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PlanEditorScreen(),
      ),
    ).then((_) {
      // Recargar planes después de crear
      ref.read(globalPlansProvider.notifier).loadPlans();
    });
  }

  void _showEditPlanDialog(AppSubscriptionPlanModel plan) {
    // Verificar que el plan tenga un ID válido antes de mostrar el editor
    if (plan.id == null || plan.id!.isEmpty) {
      AppLogger.logError(
        message: 'No se puede editar el plan: ID es null o vacío',
        className: 'GlobalSubscriptionPlansScreen',
        functionName: '_showEditPlanDialog',
        params: {'planName': plan.name},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error: El plan no tiene un ID válido para editar'),
            backgroundColor: AppTheme.bonfireRed,
          ),
        );
      }
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlanEditorScreen(plan: plan),
      ),
    ).then((_) {
      // Recargar planes después de editar
      ref.read(globalPlansProvider.notifier).loadPlans();
    });
  }

  void _togglePlanStatus(AppSubscriptionPlanModel plan) async {
    // Verificar que el plan tenga un ID válido
    if (plan.id == null || plan.id!.isEmpty) {
      AppLogger.logError(
        message: 'No se puede cambiar el estado del plan: ID es null o vacío',
        className: 'GlobalSubscriptionPlansScreen',
        functionName: '_togglePlanStatus',
        params: {'planName': plan.name},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error: El plan no tiene un ID válido'),
            backgroundColor: AppTheme.bonfireRed,
          ),
        );
      }
      return;
    }
    
    final success = await ref.read(globalPlansProvider.notifier).togglePlanStatus(plan.id!);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            plan.isActive ? 'Plan desactivado exitosamente' : 'Plan activado exitosamente'
          ),
          backgroundColor: AppTheme.courtGreen,
        ),
      );
    }
  }

  void _showDeleteConfirmation(AppSubscriptionPlanModel plan) {
    // Verificar que el plan tenga un ID válido antes de mostrar el diálogo
    if (plan.id == null || plan.id!.isEmpty) {
      AppLogger.logError(
        message: 'No se puede eliminar el plan: ID es null o vacío',
        className: 'GlobalSubscriptionPlansScreen',
        functionName: '_showDeleteConfirmation',
        params: {'planName': plan.name},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error: El plan no tiene un ID válido para eliminar'),
            backgroundColor: AppTheme.bonfireRed,
          ),
        );
      }
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.mediumGray,
          title: Text(
            'Confirmar eliminación',
            style: TextStyle(color: AppTheme.magnoliaWhite),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar el plan "${plan.name}"?\n\n'
            'Esta acción no se puede deshacer y afectará todas las suscripciones activas asociadas.',
            style: TextStyle(color: AppTheme.lightGray),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.lightGray),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Obtener referencias antes del await
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                
                // Verificar nuevamente el ID antes de proceder
                if (plan.id == null || plan.id!.isEmpty) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Error: Plan sin ID válido'),
                      backgroundColor: AppTheme.bonfireRed,
                    ),
                  );
                  return;
                }
                
                navigator.pop();
                final success = await ref.read(globalPlansProvider.notifier).deletePlan(plan.id!);
                
                if (success && mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Plan eliminado exitosamente'),
                      backgroundColor: AppTheme.courtGreen,
                    ),
                  );
                } else if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Error al eliminar el plan'),
                      backgroundColor: AppTheme.bonfireRed,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.bonfireRed),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showPlanDetails(AppSubscriptionPlanModel plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.mediumGray,
          title: Text(
            plan.name,
            style: TextStyle(color: AppTheme.magnoliaWhite),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Tipo', plan.planType.displayName),
                _buildDetailRow('Precio', _formatPrice(plan.price, plan.currency)),
                _buildDetailRow('Ciclo', plan.billingCycle.displayName),
                _buildDetailRow('Máx. Academias', plan.maxAcademies.toString()),
                _buildDetailRow('Máx. Usuarios/Academia', plan.maxUsersPerAcademy.toString()),
                _buildDetailRow('Estado', plan.isActive ? 'Activo' : 'Inactivo'),
                
                if (plan.features.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Características:', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXs),
                  ...plan.features.map((feature) => Padding(
                    padding: EdgeInsets.only(left: AppTheme.spacingMd, bottom: AppTheme.spacingXs),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check, 
                          size: AppTheme.bodySize, 
                          color: AppTheme.courtGreen,
                        ),
                        SizedBox(width: AppTheme.spacingXs),
                        Expanded(
                          child: Text(
                            feature.displayName,
                            style: TextStyle(color: AppTheme.lightGray),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                if (plan.benefits.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Beneficios:', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXs),
                  ...plan.benefits.map((benefit) => Padding(
                    padding: EdgeInsets.only(left: AppTheme.spacingMd, bottom: AppTheme.spacingXs),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star, 
                          size: AppTheme.bodySize, 
                          color: AppTheme.goldTrophy,
                        ),
                        SizedBox(width: AppTheme.spacingXs),
                        Expanded(
                          child: Text(
                            benefit,
                            style: TextStyle(color: AppTheme.lightGray),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: AppTheme.bonfireRed),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.magnoliaWhite),
            ),
          ),
        ],
      ),
    );
  }

  /// Formatea el precio según la moneda
  String _formatPrice(double price, String currency) {
    if (currency == 'COP') {
      // Formato colombiano: usar puntos como separadores de miles
      if (price == 0) {
        return 'Gratis';
      }
      
      // Convertir a entero para eliminar decimales
      final priceInt = price.toInt();
      
      // Formatear con puntos como separadores de miles
      final formatter = NumberFormat('#,###', 'es_CO');
      final formattedNumber = formatter.format(priceInt);
      
      // Reemplazar comas por puntos (formato colombiano)
      final colombianFormat = formattedNumber.replaceAll(',', '.');
      
      return '\$$colombianFormat COP';
    } else if (currency == 'USD') {
      // Formato estadounidense para USD
      final formatter = NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 2,
        locale: 'en_US',
      );
      return formatter.format(price);
    } else {
      // Formato genérico para otras monedas
      return '\$${price.toStringAsFixed(2)} $currency';
    }
  }

  void _initializeDefaultPlans() async {
    bool dialogShown = false;
    
    try {
      // Mostrar indicador de carga
      if (mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.mediumGray,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.bonfireRed),
                ),
                SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Text(
                    'Inicializando planes predeterminados...',
                    style: TextStyle(color: AppTheme.magnoliaWhite),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      AppLogger.logInfo(
        'Iniciando inicialización de planes predeterminados desde UI',
        className: 'GlobalSubscriptionPlansScreen',
        functionName: '_initializeDefaultPlans',
      );

      // Inicializar datos usando el provider
      final initializer = ref.read(appSubscriptionInitializerProvider);
      await initializer.initializeDefaultPlans();

      AppLogger.logInfo(
        'Inicialización completada, cerrando diálogo y recargando planes',
        className: 'GlobalSubscriptionPlansScreen',
        functionName: '_initializeDefaultPlans',
      );

      // Cerrar indicador de carga
      if (mounted && dialogShown) {
        Navigator.of(context).pop();
        dialogShown = false;
      }

      // Recargar planes
      if (mounted) {
        await ref.read(globalPlansProvider.notifier).loadPlans();
      }

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Planes predeterminados inicializados exitosamente'),
            backgroundColor: AppTheme.courtGreen,
          ),
        );
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al inicializar planes predeterminados: $e',
        error: e,
        className: 'GlobalSubscriptionPlansScreen',
        functionName: '_initializeDefaultPlans',
      );

      // Cerrar indicador de carga si está abierto
      if (mounted && dialogShown) {
        Navigator.of(context).pop();
        dialogShown = false;
      }

      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar planes: $e'),
            backgroundColor: AppTheme.bonfireRed,
          ),
        );
      }
    }
  }
} 