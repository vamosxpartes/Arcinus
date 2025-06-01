import 'package:arcinus/features/payments/presentation/providers/payment_providers.dart';
import 'package:arcinus/features/users/presentation/providers/client_user_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/payments/presentation/providers/payment_config_provider.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/features/payments/presentation/providers/subscription_billing_provider.dart';

// Importar todos los widgets modulares
import 'package:arcinus/features/payments/presentation/ui/widgets/widgets.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';

part 'register_payment_screen.g.dart';

/// Pantalla modularizada para registrar un nuevo pago
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
  RegisterPaymentScreenModularState createState() => RegisterPaymentScreenModularState();
}

class RegisterPaymentScreenModularState extends ConsumerState<RegisterPaymentScreen> {
  // Claves de formularios
  final _formKey = GlobalKey<FormState>();
  final _planFormKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Estado del formulario
  String? _selectedAthleteId;
  DateTime _paymentDate = DateTime.now(); // Fecha automática, no editable
  String _selectedCurrency = 'COP';
  String _selectedPaymentMethod = 'Efectivo';
  bool _isPartialPayment = false;
  double? _totalPlanAmount;
  String? _subscriptionPlanId;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _titlePushed = false;
  
  // Variables para asignación de plan
  String? _selectedPlanId;
  bool _isSubmittingPlan = false;
  
  // Variables para fechas separadas
  DateTime? _serviceStartDate;
  DateTime? _serviceEndDate;
  bool _showStartDateSelector = false;
  
  // Configuración de pagos
  PaymentConfigModel? _paymentConfig;
  ClientUserModel? _clientUser;
  AcademyUserModel? _academyUser;

  // Constantes
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
      'Inicializando pantalla modular de registro de pago',
      className: 'RegisterPaymentScreenModularState',
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
    
    // Actualizar el título del ManagerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_titlePushed) {
        ref.read(titleManagerProvider.notifier).pushTitle('Gestión de Pagos');
        _titlePushed = true;
      }
    });
    
    // Inicialización asíncrona completa después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAsync();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _notesController.dispose();
    super.dispose();
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
            className: 'RegisterPaymentScreenModularState',
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
        className: 'RegisterPaymentScreenModularState',
        functionName: '_initializeAsync',
      );
      _showError('Error al cargar datos: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _setupFormFromUserAndConfig() {
    if (_clientUser == null || _paymentConfig == null) return;
    
    AppLogger.logInfo(
      'Configurando formulario con datos del usuario y configuración',
      className: 'RegisterPaymentScreenModularState',
      functionName: '_setupFormFromUserAndConfig',
      params: {
        'userId': _clientUser!.userId,
        'hasPlan': _clientUser!.subscriptionPlan != null,
        'planId': _clientUser!.subscriptionPlanId,
        'allowPartialPayments': _paymentConfig!.allowPartialPayments,
        'earlyPaymentDiscount': _paymentConfig!.earlyPaymentDiscount,
        'billingMode': _paymentConfig!.billingMode.displayName,
        'allowManualStartDate': _paymentConfig!.allowManualStartDateInPrepaid,
      },
    );
    
    // Determinar si mostrar selector de fecha de inicio
    _showStartDateSelector = _paymentConfig!.billingMode == BillingMode.advance && 
                            _paymentConfig!.allowManualStartDateInPrepaid;
    
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
      
      // Calcular fechas de servicio usando el servicio de facturación
      _calculateServiceDates();
      
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

  void _calculateServiceDates() {
    if (_clientUser?.subscriptionPlan == null || _paymentConfig == null) return;
    
    final billingService = ref.read(subscriptionBillingServiceProvider);
    final plan = _clientUser!.subscriptionPlan!;
    
    final calculation = billingService.calculateBillingDatesFromClientPlan(
      paymentDate: _paymentDate,
      requestedStartDate: _serviceStartDate,
      plan: plan,
      config: _paymentConfig!,
    );
    
    setState(() {
      _serviceStartDate = calculation.startDate;
      _serviceEndDate = calculation.endDate;
    });
    
    AppLogger.logInfo(
      'Fechas de servicio calculadas',
      className: 'RegisterPaymentScreenModularState',
      functionName: '_calculateServiceDates',
      params: {
        'paymentDate': _paymentDate.toString(),
        'serviceStartDate': _serviceStartDate.toString(),
        'serviceEndDate': _serviceEndDate.toString(),
        'billingMode': _paymentConfig!.billingMode.displayName,
        'isValidConfiguration': calculation.isValidConfiguration,
        'validationMessage': calculation.validationMessage,
      },
    );
    
    // Mostrar advertencia si hay problemas de configuración
    if (!calculation.isValidConfiguration && calculation.validationMessage != null) {
      _showError(calculation.validationMessage!);
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

  // Métodos de selección de fechas
  // NOTA: _selectDate removido - la fecha de pago ahora es automática y no editable
  

  
  Future<void> _selectServiceStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _serviceStartDate ?? _paymentDate,
      firstDate: _paymentDate.subtract(const Duration(days: 1)),
      lastDate: _paymentDate.add(const Duration(days: 30)),
    );
    if (picked != null && picked != _serviceStartDate) {
      setState(() {
        _serviceStartDate = picked;
      });
      // Recalcular fechas cuando cambie la fecha de inicio
      _calculateServiceDates();
    }
  }

  // Métodos de envío
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
      
      // Actualizar la fecha de pago al momento exacto del registro
      setState(() {
        _paymentDate = DateTime.now();
      });
      
      AppLogger.logInfo(
        'Enviando pago',
        className: 'RegisterPaymentScreenModularState',
        functionName: '_submitPayment',
        params: {
          'athleteId': _selectedAthleteId,
          'amount': amount,
          'currency': _selectedCurrency,
          'concept': _conceptController.text,
          'paymentDate': _paymentDate.toString(),
          'isPartialPayment': _isPartialPayment,
          'subscriptionPlanId': _subscriptionPlanId,
          'totalPlanAmount': _totalPlanAmount,
        },
      );
      
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
        totalPlanAmount: _totalPlanAmount,
        periodStartDate: _serviceStartDate,
        periodEndDate: _serviceEndDate,
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

      // Asignar nuevo plan sin fecha de inicio específica
      final result = await repository.assignSubscriptionPlan(
        academyId,
        _selectedAthleteId!,
        _selectedPlanId!,
        null, // La fecha de inicio se establecerá al registrar el primer pago
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
          // Invalidar múltiples providers para asegurar actualización completa
          ref.invalidate(clientUserProvider(_selectedAthleteId!));
          
          // También invalidar providers relacionados con academy members si existen
          try {
            ref.invalidate(academyUsersProvider(academyId));
          } catch (e) {
            // Si no existe el provider, no hacer nada
          }
          
          // Reinicializar datos de forma asíncrona para reconstruir la pantalla
          _reinitializeAfterPlanAssignment();
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

  Future<void> _reinitializeAfterPlanAssignment() async {
    // Marcar como no inicializado para forzar recarga completa
    _isInitialized = false;
    
    // Limpiar datos actuales
    _clientUser = null;
    _paymentConfig = null;
    
    // Esperar un frame para que se procesen las invalidaciones
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Reinicializar de forma asíncrona
    if (mounted) {
      await _initializeAsync();
    }
  }

  void _showPlanEditDialog() {
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar plan de suscripción'),
        content: SizedBox(
          width: double.maxFinite,
          child: PlanAssignmentForm(
            formKey: _planFormKey,
            selectedPlanId: _selectedPlanId,
            isSubmitting: _isSubmittingPlan,
            plansAsync: ref.watch(activeSubscriptionPlansProvider(academyId)),
            onPlanChanged: (value) {
              setState(() {
                _selectedPlanId = value;
              });
            },
            onSavePlan: _savePlan,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _invalidateProvidersAfterPayment() {
    // Invalidar providers adicionales para asegurar que academy_members_screen se actualice
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (_selectedAthleteId != null) {
      // *** CRÍTICO: Invalidar específicamente el provider optimizado con caché ***
      ref.invalidate(clientUserCachedProvider(_selectedAthleteId!));
      ref.invalidate(clientUserProvider(_selectedAthleteId!));
      
      // Además, forzar refresco del notifier si existe
      try {
        final notifier = ref.read(clientUserCachedProvider(_selectedAthleteId!).notifier);
        
        // El método invalidateAfterPayment ya verifica internamente si está mounted
        notifier.invalidateAfterPayment();
        
        AppLogger.logInfo(
          'ClientUserCachedProvider invalidado manualmente desde RegisterPaymentScreen',
          className: 'RegisterPaymentScreenModularState',
          functionName: '_invalidateProvidersAfterPayment',
          params: {'athleteId': _selectedAthleteId!}
        );
      } catch (e) {
        AppLogger.logWarning(
          'No se pudo refrescar manualmente el ClientUserCachedProvider desde RegisterPaymentScreen',
          className: 'RegisterPaymentScreenModularState',
          functionName: '_invalidateProvidersAfterPayment',
          params: {'athleteId': _selectedAthleteId!, 'error': e.toString()}
        );
      }
    }
    
    if (academyId != null) {
      ref.invalidate(academyUsersProvider(academyId));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar el estado del formulario para manejar respuestas de la API
    ref.listen(paymentFormNotifierProvider, (previous, current) {
      if (!_isLoading && current.isSuccess) {
        // Invalidar providers adicionales para asegurar que academy_members_screen se actualice
        _invalidateProvidersAfterPayment();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Restaurar el título anterior antes de navegar
        if (_titlePushed) {
          ref.read(titleManagerProvider.notifier).popTitle();
        }
        
        // Esperar un poco para que se procesen las invalidaciones antes de navegar
        final navigator = Navigator.of(context);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            navigator.pop();
          }
        });
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _titlePushed) {
          // Restaurar el título anterior cuando se hace pop manualmente
          ref.read(titleManagerProvider.notifier).popTitle();
        }
      },
      child: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del atleta
                  if (_selectedAthleteId != null) 
                    AthleteInfoCard(
                      clientUser: _clientUser,
                      academyUser: _academyUser,
                      onEditPlan: hasPlan ? _showPlanEditDialog : null,
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Si no hay atleta seleccionado, mostrar selector
                  if (_selectedAthleteId == null) 
                    AthleteSelector(
                      selectedAthleteId: _selectedAthleteId,
                      onAthleteChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedAthleteId = value;
                            // Reiniciar inicialización con el nuevo atleta
                            _isInitialized = false;
                            _initializeAsync();
                          });
                        }
                      },
                      athletesAsyncValue: ref.watch(academyAthletesProvider),
                    ),
                  
                  if (_selectedAthleteId == null) const SizedBox(height: 16),
                  
                  // Mostrar formulario según el estado del atleta
                  if (_selectedAthleteId != null) 
                    _buildMainSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildMainSection() {
    final hasPlan = _clientUser?.subscriptionPlan != null;
    final isPendingFirstPayment = _clientUser?.metadata['isPendingFirstPayment'] == true;
    
    if (!hasPlan) {
      // No tiene plan asignado - mostrar formulario de asignación
      return _buildPlanAssignmentSection();
    } else if (isPendingFirstPayment) {
      // Tiene plan pero está pendiente del primer pago - mostrar ambos formularios
      return _buildUnifiedSection();
    } else {
      // Tiene plan y ya ha realizado pagos - mostrar solo formulario de pago
      return _buildPaymentSection();
    }
  }

  Widget _buildUnifiedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información sobre el estado actual
        Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Plan Asignado - Pendiente Primer Pago',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'El atleta tiene un plan asignado (${_clientUser?.subscriptionPlan?.name}) pero aún no ha realizado el primer pago. '
                  'La fecha de inicio del plan se establecerá automáticamente cuando registres el primer pago.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showPlanEditDialog,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Cambiar Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Formulario de pago
        _buildPaymentSection(),
      ],
    );
  }

  Widget _buildPaymentSection() {
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Formulario de pago
        PaymentForm(
          formKey: _formKey,
          amountController: _amountController,
          conceptController: _conceptController,
          notesController: _notesController,
          paymentDate: _paymentDate,
          selectedCurrency: _selectedCurrency,
          selectedPaymentMethod: _selectedPaymentMethod,
          isPartialPayment: _isPartialPayment,
          totalPlanAmount: _totalPlanAmount,
          clientUser: _clientUser,
          paymentConfig: _paymentConfig,
          currencies: _currencies,
          paymentMethods: _paymentMethods,
          onCurrencyChanged: (value) {
            setState(() {
              _selectedCurrency = value;
            });
          },
          onPaymentMethodChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
          onAmountChanged: (value) {
            // Verificar si el pago es parcial
            if (_totalPlanAmount != null) {
              final amount = double.tryParse(value) ?? 0;
              setState(() {
                _isPartialPayment = amount < _totalPlanAmount!;
              });
            }
          },
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        
        // Información de configuración de facturación
        if (_paymentConfig != null) 
          BillingConfigInfo(paymentConfig: _paymentConfig!),
        const SizedBox(height: 16),
        
        // Fechas de servicio
        ServiceDatesSection(
          serviceStartDate: _serviceStartDate,
          serviceEndDate: _serviceEndDate,
          showStartDateSelector: _showStartDateSelector,
          onSelectServiceStartDate: () => _selectServiceStartDate(context),
        ),
        const SizedBox(height: 16),

        // Advertencias de pago
        PaymentWarnings(
          isPartialPayment: _isPartialPayment,
          totalPlanAmount: _totalPlanAmount,
          currentAmount: double.tryParse(_amountController.text) ?? 0,
          selectedCurrency: _selectedCurrency,
          paymentDate: _paymentDate,
          clientUser: _clientUser,
          paymentConfig: _paymentConfig,
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
    );
  }

  Widget _buildPlanAssignmentSection() {
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) return const SizedBox.shrink();

    return PlanAssignmentForm(
      formKey: _planFormKey,
      selectedPlanId: _selectedPlanId,
      isSubmitting: _isSubmittingPlan,
      plansAsync: ref.watch(activeSubscriptionPlansProvider(academyId)),
      onPlanChanged: (value) {
        setState(() {
          _selectedPlanId = value;
        });
      },
      onSavePlan: _savePlan,
    );
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