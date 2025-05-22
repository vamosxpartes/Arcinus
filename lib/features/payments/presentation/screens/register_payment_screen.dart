import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';

part 'register_payment_screen.g.dart';

/// Pantalla para registrar un nuevo pago
class RegisterPaymentScreen extends ConsumerStatefulWidget {
  /// ID del atleta para el cual se registrará el pago
  final String? athleteId;
  
  /// Datos pre-cargados para el formulario (opcional)
  final Map<String, dynamic>? preloadedData;

  /// Constructor
  const RegisterPaymentScreen({
    super.key, 
    this.athleteId,
    this.preloadedData
  });

  @override
  RegisterPaymentScreenState createState() => RegisterPaymentScreenState();
}

class RegisterPaymentScreenState extends ConsumerState<RegisterPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planFormKey = GlobalKey<FormState>();

  String? _selectedAthleteId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  String _selectedCurrency = 'COP';
  String _selectedPaymentMethod = 'Efectivo';
  bool _isPartialPayment = false;
  double? _totalPlanAmount;
  String? _subscriptionPlanId;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // Variables para asignación de plan
  String? _selectedPlanId;
  DateTime _startDate = DateTime.now();
  bool _isSubmittingPlan = false;
  
  // Configuración de pagos
  PaymentConfigModel? _paymentConfig;
  ClientUserModel? _clientUser;
  AcademyUserModel? _academyUser;

  final List<String> _currencies = ['COP', 'MXN', 'USD', 'EUR'];
  final List<String> _paymentMethods = [
    'Efectivo',
    'Transferencia',
    'Tarjeta de crédito',
    'Tarjeta de débito',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'Inicializando pantalla de registro de pago',
      className: 'RegisterPaymentScreenState',
      functionName: 'initState',
      params: {'athleteId': widget.athleteId, 'preloadedData': widget.preloadedData != null},
    );
    
    // Si se proporciona un ID de atleta, utilizarlo
    if (widget.athleteId != null) {
      _selectedAthleteId = widget.athleteId;
    }
    
    // Procesar datos preloadedData si existen
    if (widget.preloadedData != null) {
      _processPreloadedData();
    }
    
    // Inicialización asíncrona completa después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAsync();
    });
  }
  
  Future<void> _initializeAsync() async {
    if (_isInitialized) return;
    
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) {
      _showError('No se pudo determinar la academia actual');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 1. Cargar la configuración de pagos
      final paymentConfigAsync = await ref.read(paymentConfigProvider(academyId).future);
      
      // 2. Si tenemos un atleta seleccionado, cargar sus datos
      if (_selectedAthleteId != null) {
        final clientUserAsync = await ref.read(clientUserProvider(_selectedAthleteId!).future);
        
        // 3. También cargar la información del usuario de la academia
        try {
          final repository = AcademyUsersRepository();
          final academyUser = await repository.getUserById(academyId, _selectedAthleteId!);
          
          setState(() {
            _paymentConfig = paymentConfigAsync;
            _clientUser = clientUserAsync;
            _academyUser = academyUser;
            _isInitialized = true;
            
            // Configurar el formulario basado en los datos obtenidos
            _setupFormFromUserAndConfig();
          });
        } catch (e) {
          AppLogger.logError(
            message: 'Error al cargar datos del usuario de academia',
            error: e,
            className: 'RegisterPaymentScreenState',
            functionName: '_initializeAsync',
          );
          setState(() {
            _paymentConfig = paymentConfigAsync;
            _clientUser = clientUserAsync;
            _isInitialized = true;
            _setupFormFromUserAndConfig();
          });
        }
      } else {
        setState(() {
          _paymentConfig = paymentConfigAsync;
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al inicializar datos',
        error: e,
        className: 'RegisterPaymentScreenState',
        functionName: '_initializeAsync',
      );
      _showError('Error al cargar datos: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _setupFormFromUserAndConfig() {
    if (_clientUser == null || _paymentConfig == null) return;
    
    // Si hay un plan de suscripción, utilizar sus datos
    if (_clientUser!.subscriptionPlan != null) {
      final plan = _clientUser!.subscriptionPlan!;
      
      // Autocompletar monto si está vacío
      if (_amountController.text.isEmpty) {
        _amountController.text = plan.amount.toString();
      }
      
      // Autocompletar concepto si está vacío
      if (_conceptController.text.isEmpty) {
        _conceptController.text = 'Pago plan: ${plan.name}';
      }
      
      // Usar moneda del plan
      if (plan.currency.isNotEmpty) {
        _selectedCurrency = plan.currency;
      }
      
      // Guardar ID del plan y monto total
      _subscriptionPlanId = _clientUser!.subscriptionPlanId;
      _totalPlanAmount = plan.amount;
      
      // Verificar si es un pago parcial
      if (_amountController.text.isNotEmpty) {
        final amount = double.tryParse(_amountController.text) ?? 0;
        _isPartialPayment = amount < _totalPlanAmount!;
      }
    } else {
      // Si no hay plan, verificar si se permiten pagos sin plan
      if (!_paymentConfig!.allowPartialPayments) {
        _showError('El atleta no tiene un plan de suscripción asignado y no se permiten pagos parciales');
      }
    }
  }

  void _processPreloadedData() {
    final data = widget.preloadedData!;
    
    if (data.containsKey('preselectedAthleteId')) {
      _selectedAthleteId = data['preselectedAthleteId'] as String?;
    }

    if (data.containsKey('paymentAmount')) {
      _amountController.text = data['paymentAmount'].toString();
    }

    if (data.containsKey('paymentConcept')) {
      _conceptController.text = data['paymentConcept'] as String;
    }

    if (data.containsKey('paymentCurrency')) {
      _selectedCurrency = data['paymentCurrency'] as String;
    }

    if (data.containsKey('isPartialPayment')) {
      _isPartialPayment = data['isPartialPayment'] as bool;
    }

    if (data.containsKey('subscriptionPlanId')) {
      _subscriptionPlanId = data['subscriptionPlanId'] as String?;
    }

    if (data.containsKey('totalPlanAmount')) {
      _totalPlanAmount = data['totalPlanAmount'] as double?;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }
  
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAthleteId == null) {
        _showError('Debes seleccionar un atleta');
        return;
      }

      final academyId = ref.read(currentAcademyProvider)?.id;
      if (academyId == null) {
        _showError('No se pudo determinar la academia actual');
        return;
      }

      // Verificar si se permiten pagos parciales cuando es necesario
      if (_isPartialPayment && _paymentConfig != null && !_paymentConfig!.allowPartialPayments) {
        _showError('No se permiten pagos parciales según la configuración de la academia');
        return;
      }

      final amount = double.tryParse(_amountController.text) ?? 0;
      
      // Usar el método submitPayment del PaymentFormNotifier
      final notifier = ref.read(paymentFormNotifierProvider.notifier);
      
      notifier.submitPayment(
        athleteId: _selectedAthleteId!,
        amount: amount,
        currency: _selectedCurrency,
        paymentDate: _paymentDate,
        concept: _conceptController.text,
        notes: _notesController.text,
        isPartialPayment: _isPartialPayment,
        subscriptionPlanId: _subscriptionPlanId,
        totalPlanAmount: _totalPlanAmount
      );
    }
  }
  
  Future<void> _savePlan() async {
    if (!_planFormKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedPlanId == null) {
      _showError('Debes seleccionar un plan');
      return;
    }

    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null || _selectedAthleteId == null) {
      _showError('Información incompleta');
      return;
    }

    setState(() {
      _isSubmittingPlan = true;
    });

    try {
      final repository = ref.read(clientUserRepositoryProvider);

      // Asignar nuevo plan
      final result = await repository.assignSubscriptionPlan(
        academyId,
        _selectedAthleteId!,
        _selectedPlanId!,
        _startDate,
      );

      result.fold(
        (failure) {
          _showError('Error al asignar plan: ${failure.message}');
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan asignado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Refrescar datos
          ref.invalidate(clientUserProvider(_selectedAthleteId!));
          _initializeAsync(); // Recargar datos para mostrar el plan asignado
        },
      );
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      setState(() {
        _isSubmittingPlan = false;
      });
    }
  }
  
  void _showPlanEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar plan de suscripción'),
        content: _buildPlanForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _savePlan();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Observar el estado del formulario para manejar respuestas de la API
    ref.listen(paymentFormNotifierProvider, (previous, current) {
      if (!_isLoading && current.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }

      if (!_isLoading && current.failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              current.failure!.maybeWhen(
                serverError: (message) => message,
                orElse: () => 'Error al registrar el pago',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = current.isSubmitting;
      });
    });

    final hasPlan = _clientUser?.subscriptionPlan != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pagos'),
        actions: [
          if (hasPlan)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Cambiar plan',
              onPressed: _showPlanEditDialog,
            ),
        ],
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del atleta
                  if (_selectedAthleteId != null) _buildSelectedAthleteInfo(),
                  
                  const SizedBox(height: 16),
                  
                  // Si no hay atleta seleccionado, mostrar selector
                  if (_selectedAthleteId == null) _buildAthleteSelector(),
                  if (_selectedAthleteId == null) const SizedBox(height: 16),
                  
                  // Mostrar formulario según si tiene plan o no
                  if (_selectedAthleteId != null) 
                    hasPlan 
                      ? _buildPaymentForm() 
                      : _buildAssignPlanForm(),
                ],
              ),
            ),
    );
  }
  
  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Pago',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Monto y moneda
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de monto
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un monto';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Monto inválido';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Verificar si el pago es parcial
                    if (_totalPlanAmount != null) {
                      final amount = double.tryParse(value) ?? 0;
                      setState(() {
                        _isPartialPayment = amount < _totalPlanAmount!;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Selector de moneda
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Moneda',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCurrency,
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Concepto
          TextFormField(
            controller: _conceptController,
            decoration: const InputDecoration(
              labelText: 'Concepto',
              prefixIcon: Icon(Icons.subject),
              border: OutlineInputBorder(),
              hintText: 'Ej: Mensualidad Octubre',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa un concepto para el pago';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Fecha de pago
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de Pago',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_paymentDate)),
            ),
          ),
          const SizedBox(height: 16),
          
          // Método de pago
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Método de Pago',
              prefixIcon: Icon(Icons.payment),
              border: OutlineInputBorder(),
            ),
            value: _selectedPaymentMethod,
            items: _paymentMethods.map((method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Indicador de pago parcial y advertencias
          _buildPaymentWarnings(),
          const SizedBox(height: 16),

          // Notas
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              prefixIcon: Icon(Icons.note),
              border: OutlineInputBorder(),
              hintText: 'Notas adicionales sobre el pago',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Botón de registro
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPayment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Registrar Pago'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssignPlanForm() {
    return Form(
      key: _planFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.amber.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Atleta sin Plan de Suscripción',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para realizar pagos, primero debes asignar un plan de suscripción al atleta.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Asignar Plan de Suscripción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildPlanForm(),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmittingPlan ? null : _savePlan,
              child: _isSubmittingPlan
                  ? const CircularProgressIndicator()
                  : const Text('Asignar Plan'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanForm() {
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) {
      return const Text('No se pudo determinar la academia actual');
    }
    
    return Consumer(
      builder: (context, ref, _) {
        final plansAsync = ref.watch(activeSubscriptionPlansProvider(academyId));
        
        return plansAsync.when(
          data: (plans) {
            if (plans.isEmpty) {
              return const Text(
                'No hay planes de suscripción disponibles.',
                style: TextStyle(color: Colors.red),
              );
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
                  ),
                  hint: const Text('Selecciona un plan'),
                  value: _selectedPlanId,
                  items: [
                    // Opción para no seleccionar plan
                    ...plans.map((plan) {
                      return DropdownMenuItem<String>(
                        value: plan.id,
                        child: Text(
                          '${plan.name} - ${plan.amount} ${plan.currency}',
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPlanId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona un plan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Fecha de inicio
                Row(
                  children: [
                    const Text('Fecha de inicio:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectStartDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text(
            'Error al cargar planes: $error',
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
  
  Widget _buildSelectedAthleteInfo() {
    if (_academyUser != null) {
      // Si tenemos datos de usuario de academia, usar esos
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.courtGreen,
                    backgroundImage: _academyUser!.profileImageUrl != null
                        ? NetworkImage(_academyUser!.profileImageUrl!)
                        : null,
                    child: _academyUser!.profileImageUrl == null
                        ? const Icon(Icons.person, size: 30, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _academyUser!.fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _clientUser?.subscriptionPlan != null
                              ? 'Plan: ${_clientUser!.subscriptionPlan!.name}'
                              : 'Sin plan de suscripción',
                          style: TextStyle(
                            color: _clientUser?.subscriptionPlan != null ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_clientUser?.subscriptionPlan != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estado: ${_clientUser!.paymentStatus.displayName}'),
                    if (_clientUser!.nextPaymentDate != null)
                      Text('Próximo pago: ${DateFormat('dd/MM/yyyy').format(_clientUser!.nextPaymentDate!)}'),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    // Si solo tenemos datos de cliente, mostrar esa información
    return Consumer(
      builder: (context, ref, _) {
        final clientUserAsync = ref.watch(clientUserProvider(_selectedAthleteId!));
        
        return clientUserAsync.when(
          data: (clientUser) {
            if (clientUser == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No se encontró información del atleta'),
                ),
              );
            }
            
            final hasSubscription = clientUser.subscriptionPlan != null;
            
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
                                'Atleta ID: ${clientUser.userId}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasSubscription
                                    ? 'Plan: ${clientUser.subscriptionPlan!.name}'
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
                          Text('Estado: ${clientUser.paymentStatus.displayName}'),
                          if (clientUser.nextPaymentDate != null)
                            Text('Próximo pago: ${DateFormat('dd/MM/yyyy').format(clientUser.nextPaymentDate!)}'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, __) => Card(
            color: Colors.red.shade100,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error al cargar información del atleta'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAthleteSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final athletesAsyncValue = ref.watch(academyAthletesProvider);
        
        return athletesAsyncValue.when(
          data: (athletes) {
            if (athletes.isEmpty) {
              return const Text(
                'No hay atletas registrados en la academia',
                style: TextStyle(color: Colors.red),
              );
            }

            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Atleta',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              value: _selectedAthleteId,
              items: athletes.map((athlete) {
                return DropdownMenuItem<String>(
                  value: athlete.id,
                  child: Text(athlete.displayName ?? athlete.email),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAthleteId = value;
                    // Reiniciar inicialización con el nuevo atleta
                    _isInitialized = false;
                    _initializeAsync();
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debes seleccionar un atleta';
                }
                return null;
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text(
            'Error al cargar la lista de atletas',
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
  
  Widget _buildPaymentWarnings() {
    final widgets = <Widget>[];
    
    // Advertencia de pago parcial
    if (_isPartialPayment && _totalPlanAmount != null) {
      widgets.add(
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esto es un pago parcial. El monto total del plan es ${_totalPlanAmount!} $_selectedCurrency',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
      
      // Añadir advertencia si no se permiten pagos parciales
      if (_paymentConfig != null && !_paymentConfig!.allowPartialPayments) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'La academia no permite pagos parciales según su configuración',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    // Advertencia de descuento por pronto pago
    if (_paymentConfig != null && _paymentConfig!.earlyPaymentDiscount && _clientUser != null) {
      final paymentDate = _paymentDate;
      final nextPaymentDate = _clientUser!.nextPaymentDate;
      
      if (nextPaymentDate != null) {
        final daysBeforePayment = nextPaymentDate.difference(paymentDate).inDays;
        
        if (daysBeforePayment >= _paymentConfig!.earlyPaymentDays) {
          widgets.add(const SizedBox(height: 8));
          widgets.add(
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este pago califica para un descuento por pronto pago del ${_paymentConfig!.earlyPaymentDiscountPercent}%',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    
    return Column(children: widgets);
  }
}

/// Provider para obtener los atletas de la academia actual
@riverpod
Future<List<UserModel>> academyAthletes(Ref ref) async {
  // Devolver una lista vacía temporalmente para evitar errores
  AppLogger.logWarning(
    'ADVERTENCIA: academyAthletesProvider está devolviendo una lista vacía.',
    className: 'academyAthletes',
    functionName: 'build',
  );
  return Future.value([]);
}
