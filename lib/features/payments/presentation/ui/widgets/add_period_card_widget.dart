import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:intl/intl.dart';

/// Controlador para manejar el estado del AddPeriodCardWidget desde el exterior
class AddPeriodCardController {
  _AddPeriodCardWidgetState? _state;
  
  /// Vincula el controlador con el estado del widget
  void _attachState(_AddPeriodCardWidgetState state) {
    _state = state;
  }
  
  /// Desvincular el controlador cuando el widget se destruye
  void _detachState() {
    _state = null;
  }
  
  /// Resetea el widget al estado inicial
  void resetToInitial() {
    _state?.resetToInitial();
  }
  
  /// Indica que el pago está siendo procesado
  void setPaymentPending() {
    _state?.setPaymentPending();
  }
  
  /// Indica que el pago fue exitoso
  void setPaymentSuccess() {
    _state?.setPaymentSuccess();
  }
  
  /// Indica que hubo un error en el pago
  void setPaymentError(String? errorMessage) {
    _state?.setPaymentError(errorMessage);
  }
  
  /// Verifica si el controlador está vinculado a un widget activo
  bool get isAttached => _state != null;
  
  /// Obtiene el estado actual del widget (si está vinculado)
  AddPeriodState? get currentState => _state?._currentState;
}

/// Estados del widget de agregar período con state machine mejorado
enum AddPeriodState {
  initial,         // Estado inicial: botón de agregar
  expanding,       // Transición: expandiendo el contenido
  configuring,     // Configurando: selección de plan, períodos, fecha
  validating,      // Validando: verificando configuración
  readyToPay,      // Listo para pago: configuración completada
  paymentPending,  // Pago pendiente: esperando procesamiento
  success,         // Éxito: pago procesado exitosamente
  error,           // Error: problema en el proceso
  collapsing,      // Transición: colapsando hacia estado inicial
}

/// Información de cada estado del state machine
class StateInfo {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isTransition;
  final bool showCloseButton;
  final bool isExpandedState;

  const StateInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isTransition = false,
    this.showCloseButton = true,
    this.isExpandedState = true,
  });
}

/// Widget para agregar nuevos períodos con state machine optimizado
class AddPeriodCardWidget extends ConsumerStatefulWidget {
  final String academyId;
  final PaymentConfigModel? config;
  final String currency;
  final ValueChanged<Map<String, dynamic>>? onPeriodConfigured;
  final VoidCallback? onPaymentRequired;
  final VoidCallback? onStateChanged; // Nuevo callback para notificar cambios de estado
  final AddPeriodCardController? controller; // Nuevo controlador

  const AddPeriodCardWidget({
    super.key,
    required this.academyId,
    this.config,
    this.currency = 'COP',
    this.onPeriodConfigured,
    this.onPaymentRequired,
    this.onStateChanged,
    this.controller,
  });

  @override
  ConsumerState<AddPeriodCardWidget> createState() => _AddPeriodCardWidgetState();
}

class _AddPeriodCardWidgetState extends ConsumerState<AddPeriodCardWidget>
    with TickerProviderStateMixin {
  
  // ==================== VARIABLES DE ESTADO ====================
  AddPeriodState _currentState = AddPeriodState.initial;
  late AnimationController _expandController;
  late AnimationController _pulseController;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;
  
  // Variables de configuración
  String? _selectedPlanId;
  SubscriptionPlanModel? _selectedPlan;
  int _numberOfPeriods = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _errorMessage;
  
  // ==================== CONFIGURACIÓN DEL STATE MACHINE ====================
  static const Map<AddPeriodState, StateInfo> _stateInfoMap = {
    AddPeriodState.initial: StateInfo(
      icon: Icons.add_circle_outline,
      title: 'Agregar Período',
      subtitle: 'Toca para agregar un nuevo período de suscripción',
      color: AppTheme.goldTrophy,
      showCloseButton: false,
      isExpandedState: false,
    ),
    AddPeriodState.expanding: StateInfo(
      icon: Icons.expand_more,
      title: 'Expandiendo...',
      subtitle: 'Preparando configuración',
      color: AppTheme.nbaBluePrimary,
      isTransition: true,
      isExpandedState: true,
    ),
    AddPeriodState.configuring: StateInfo(
      icon: Icons.settings,
      title: 'Configurar Período',
      subtitle: 'Selecciona plan, duración y fecha de inicio',
      color: AppTheme.nbaBluePrimary,
      isExpandedState: true,
    ),
    AddPeriodState.validating: StateInfo(
      icon: Icons.check_circle_outline,
      title: 'Validando...',
      subtitle: 'Verificando configuración',
      color: AppTheme.courtGreen,
      isTransition: true,
      isExpandedState: true,
    ),
    AddPeriodState.readyToPay: StateInfo(
      icon: Icons.payment,
      title: 'Listo para Pago',
      subtitle: 'Configuración completada, procede al pago',
      color: AppTheme.bonfireRed,
      isExpandedState: true,
    ),
    AddPeriodState.paymentPending: StateInfo(
      icon: Icons.hourglass_empty,
      title: 'Procesando Pago...',
      subtitle: 'Registrando el pago y creando períodos',
      color: AppTheme.goldTrophy,
      isTransition: true,
      showCloseButton: false,
      isExpandedState: true,
    ),
    AddPeriodState.success: StateInfo(
      icon: Icons.check_circle,
      title: '¡Pago Exitoso!',
      subtitle: 'El período ha sido creado correctamente',
      color: AppTheme.courtGreen,
      isTransition: true,
      showCloseButton: false,
      isExpandedState: true,
    ),
    AddPeriodState.error: StateInfo(
      icon: Icons.error_outline,
      title: 'Error en el Proceso',
      subtitle: 'Ha ocurrido un problema, intenta nuevamente',
      color: AppTheme.bonfireRed,
      isExpandedState: true,
    ),
    AddPeriodState.collapsing: StateInfo(
      icon: Icons.expand_less,
      title: 'Finalizando...',
      subtitle: 'Regresando al estado inicial',
      color: AppTheme.lightGray,
      isTransition: true,
      showCloseButton: false,
      isExpandedState: false,
    ),
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.controller != null) {
      widget.controller!._attachState(this);
    }
  }

  void _initializeAnimations() {
    // Animación de expansión/contracción
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );

    // Animación de pulso para estados de transición
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _expandController.dispose();
    _pulseController.dispose();
    if (widget.controller != null) {
      widget.controller!._detachState();
    }
    super.dispose();
  }

  // ==================== MÉTODOS PÚBLICOS ====================
  
  /// Método público para resetear el widget al estado inicial
  void resetToInitial() {
    _transitionToState(AddPeriodState.collapsing);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _transitionToState(AddPeriodState.initial);
      }
    });
  }

  /// Método público para indicar que el pago está siendo procesado
  void setPaymentPending() {
    _transitionToState(AddPeriodState.paymentPending);
  }

  /// Método público para indicar que el pago fue exitoso
  void setPaymentSuccess() {
    _transitionToState(AddPeriodState.success);
    
    // Auto-reset después de 2 segundos
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        resetToInitial();
      }
    });
  }

  /// Método público para indicar que hubo un error en el pago
  void setPaymentError(String? errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
    });
    _transitionToState(AddPeriodState.error);
  }

  // ==================== MÉTODOS PRIVADOS DE ESTADO ====================
  
  void _transitionToState(AddPeriodState newState) {
    if (_currentState == newState) return;
    
    final wasExpanded = _stateInfoMap[_currentState]?.isExpandedState ?? false;
    final willBeExpanded = _stateInfoMap[newState]?.isExpandedState ?? false;
    
    setState(() {
      _currentState = newState;
    });
    
    // Manejar animaciones según transición
    _handleStateAnimations(wasExpanded, willBeExpanded, newState);
    
    // Resetear configuración si volvemos al estado inicial
    if (newState == AddPeriodState.initial) {
      _resetConfiguration();
    }
    
    // Notificar cambio de estado al padre
    widget.onStateChanged?.call();
  }

  void _handleStateAnimations(bool wasExpanded, bool willBeExpanded, AddPeriodState newState) {
    // Detener animación de pulso si no es estado de transición
    if (!(_stateInfoMap[newState]?.isTransition ?? false)) {
      _pulseController.stop();
      _pulseController.reset();
    }
    
    // Manejar expansión/contracción
    if (!wasExpanded && willBeExpanded) {
      _expandController.forward();
    } else if (wasExpanded && !willBeExpanded) {
      _expandController.reverse();
    }
    
    // Iniciar pulso para estados de transición
    if (_stateInfoMap[newState]?.isTransition ?? false) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _resetConfiguration() {
    _selectedPlanId = null;
    _selectedPlan = null;
    _numberOfPeriods = 1;
    _startDate = null;
    _endDate = null;
    _errorMessage = null;
  }

  // ==================== MÉTODOS DE INTERACCIÓN ====================
  
  void _handleInitialTap() {
    if (_currentState == AddPeriodState.initial) {
      _transitionToState(AddPeriodState.expanding);
      
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _transitionToState(AddPeriodState.configuring);
        }
      });
    }
  }

  void _handleCloseTap() {
    if (_currentState == AddPeriodState.error) {
      // Desde error, permitir volver a configurar
      _transitionToState(AddPeriodState.configuring);
    } else {
      // Desde cualquier otro estado, volver al inicial
      resetToInitial();
    }
  }

  void _validateAndProceed() {
    final isConfigComplete = _selectedPlan != null && 
                            _startDate != null && 
                            _endDate != null;
    
    if (!isConfigComplete) {
      setState(() {
        _errorMessage = 'Debes completar toda la configuración antes de continuar';
      });
      _transitionToState(AddPeriodState.error);
      return;
    }
    
    // Transición a validando
    _transitionToState(AddPeriodState.validating);
    
    // Simular validación
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _proceedToPayment();
      }
    });
  }

  void _proceedToPayment() {
    if (_selectedPlan == null || _startDate == null || _endDate == null) {
      _transitionToState(AddPeriodState.error);
      return;
    }
    
    try {
      // Notificar configuración completada
      widget.onPeriodConfigured?.call({
        'planId': _selectedPlanId!,
        'plan': _selectedPlan!,
        'numberOfPeriods': _numberOfPeriods,
        'startDate': _startDate!,
        'endDate': _endDate!,
        'totalAmount': _selectedPlan!.amount * _numberOfPeriods,
      });
      
      // Cambiar a estado listo para pago
      _transitionToState(AddPeriodState.readyToPay);
      
      // Notificar que se requiere pago
      widget.onPaymentRequired?.call();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al configurar el período: ${e.toString()}';
      });
      _transitionToState(AddPeriodState.error);
    }
  }

  // ==================== MÉTODOS DE UI ====================

  StateInfo get _currentStateInfo => _stateInfoMap[_currentState]!;

  Color get _borderColor => _currentStateInfo.color.withAlpha(50);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: (_stateInfoMap[_currentState]?.isTransition ?? false) 
              ? _pulseAnimation.value 
              : 1.0,
          child: Card(
            color: AppTheme.mediumGray,
            elevation: _currentState == AddPeriodState.initial 
                ? AppTheme.elevationLow 
                : AppTheme.elevationMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              side: BorderSide(
                color: _borderColor,
                width: _currentState == AddPeriodState.initial ? 2 : 1.5,
              ),
            ),
            child: Column(
              children: [
                _buildHeader(),
                AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: _expandAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildExpandedContent(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final stateInfo = _currentStateInfo;
    
    return InkWell(
      onTap: _currentState == AddPeriodState.initial ? _handleInitialTap : null,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.cardRadius),
        bottom: !stateInfo.isExpandedState 
            ? Radius.circular(AppTheme.cardRadius)
            : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    stateInfo.color,
                    stateInfo.color.withAlpha(200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              child: stateInfo.isTransition
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.magnoliaWhite),
                        ),
                      ),
                    )
                  : Icon(
                      stateInfo.icon,
                      color: AppTheme.magnoliaWhite,
                      size: 24,
                    ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stateInfo.title,
                    style: const TextStyle(
                      fontSize: AppTheme.subtitleSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    _currentState == AddPeriodState.error && _errorMessage != null
                        ? _errorMessage!
                        : stateInfo.subtitle,
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: _currentState == AddPeriodState.error 
                          ? AppTheme.bonfireRed 
                          : AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            if (stateInfo.showCloseButton && _currentState != AddPeriodState.initial)
              IconButton(
                onPressed: _handleCloseTap,
                icon: Icon(
                  _currentState == AddPeriodState.error ? Icons.refresh : Icons.close,
                  color: AppTheme.lightGray,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    switch (_currentState) {
      case AddPeriodState.initial:
      case AddPeriodState.collapsing:
        return const SizedBox.shrink();
        
      case AddPeriodState.expanding:
      case AddPeriodState.validating:
      case AddPeriodState.paymentPending:
      case AddPeriodState.success:
        return _buildTransitionContent();
        
      case AddPeriodState.configuring:
      case AddPeriodState.error:
        return _buildConfigurationContent();
        
      case AddPeriodState.readyToPay:
        return _buildReadyToPayContent();
    }
  }

  Widget _buildTransitionContent() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.darkGray.withAlpha(50),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.cardRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_currentStateInfo.color),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                _currentStateInfo.subtitle,
                style: TextStyle(
                  fontSize: AppTheme.bodySize,
                  color: AppTheme.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyToPayContent() {
    if (_selectedPlan == null || _startDate == null || _endDate == null) {
      return const SizedBox.shrink();
    }

    final totalAmount = _selectedPlan!.amount * _numberOfPeriods;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.darkGray.withAlpha(50),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.cardRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.bonfireRed.withAlpha(20),
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                border: Border.all(
                  color: AppTheme.bonfireRed.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.payment,
                    color: AppTheme.bonfireRed,
                    size: 32,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Configuración Completada',
                    style: TextStyle(
                      fontSize: AppTheme.subtitleSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    'Total a pagar: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(totalAmount)} ${widget.currency}',
                    style: TextStyle(
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.goldTrophy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    'Completa el formulario de pago para finalizar',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: AppTheme.lightGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: () => _transitionToState(AddPeriodState.configuring),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.nbaBluePrimary,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
              ),
              child: const Text(
                'Volver a Configuración',
                style: TextStyle(color: AppTheme.magnoliaWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationContent() {
    final plansAsync = ref.watch(activeSubscriptionPlansProvider(widget.academyId));
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.darkGray.withAlpha(50),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.cardRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanSelector(plansAsync),
            
            if (_selectedPlan != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              _buildPeriodsSelector(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildDateSelector(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildConfigurationSummary(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelector(AsyncValue<List<SubscriptionPlanModel>> plansAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan de Suscripción',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightGray,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        plansAsync.when(
          data: (plans) => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingSm,
              ),
            ),
            value: _selectedPlanId,
            hint: const Text('Selecciona un plan'),
            items: plans.map((plan) {
              return DropdownMenuItem<String>(
                value: plan.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.courtGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Flexible(
                      child: Text(
                        plan.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(plan.amount),
                      style: TextStyle(
                        fontSize: AppTheme.captionSize,
                        color: AppTheme.lightGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final plan = plans.firstWhere((p) => p.id == value);
                setState(() {
                  _selectedPlanId = value;
                  _selectedPlan = plan;
                });
                _calculateDates();
              }
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }

  Widget _buildPeriodsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número de Períodos',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightGray,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            IconButton(
              onPressed: _numberOfPeriods > 1 
                  ? () {
                      setState(() => _numberOfPeriods--);
                      _calculateDates();
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppTheme.bonfireRed,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppTheme.nbaBluePrimary,
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              child: Text(
                '$_numberOfPeriods',
                style: const TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
            ),
            IconButton(
              onPressed: _numberOfPeriods < 12 
                  ? () {
                      setState(() => _numberOfPeriods++);
                      _calculateDates();
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.courtGreen,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              '$_numberOfPeriods ${_numberOfPeriods == 1 ? 'período' : 'períodos'}',
              style: TextStyle(
                fontSize: AppTheme.secondarySize,
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Inicio',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightGray,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        InkWell(
          onTap: () => _selectStartDate(context),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray.withAlpha(50)),
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.courtGreen,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  _startDate != null 
                      ? _formatDate(_startDate!)
                      : 'Seleccionar fecha de inicio',
                  style: TextStyle(
                    color: _startDate != null 
                        ? AppTheme.magnoliaWhite 
                        : AppTheme.lightGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationSummary() {
    if (_selectedPlan == null || _startDate == null || _endDate == null) {
      return const SizedBox.shrink();
    }

    final totalAmount = _selectedPlan!.amount * _numberOfPeriods;
    final totalDays = _endDate!.difference(_startDate!).inDays;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: AppTheme.lightGray.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Período',
            style: TextStyle(
              fontSize: AppTheme.bodySize,
              fontWeight: FontWeight.w600,
              color: AppTheme.magnoliaWhite,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          _buildSummaryRow('Plan:', _selectedPlan!.name),
          _buildSummaryRow('Períodos:', '$_numberOfPeriods'),
          _buildSummaryRow('Desde:', _formatDate(_startDate!)),
          _buildSummaryRow('Hasta:', _formatDate(_endDate!)),
          _buildSummaryRow('Duración:', '$totalDays días'),
          const SizedBox(height: AppTheme.spacingSm),
          Divider(color: AppTheme.lightGray.withAlpha(30)),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
              Text(
                '${NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(totalAmount)} ${widget.currency}',
                style: const TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.goldTrophy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.secondarySize,
              color: AppTheme.lightGray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.secondarySize,
              fontWeight: FontWeight.w600,
              color: AppTheme.magnoliaWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isConfigComplete = _selectedPlan != null && 
                            _startDate != null && 
                            _endDate != null;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _transitionToState(AddPeriodState.initial),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.lightGray),
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isConfigComplete ? _validateAndProceed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.courtGreen,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            ),
            child: const Text(
              'Continuar al Pago',
              style: TextStyle(color: AppTheme.magnoliaWhite),
            ),
          ),
        ),
      ],
    );
  }

  void _calculateDates() {
    if (_selectedPlan == null || _startDate == null) return;
    
    final durationInDays = _getDurationFromBillingCycle(_selectedPlan!.billingCycle);
    final totalDurationDays = durationInDays * _numberOfPeriods;
    
    setState(() {
      _endDate = _startDate!.add(Duration(days: totalDurationDays));
    });
  }

  int _getDurationFromBillingCycle(BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return 30;
      case BillingCycle.quarterly:
        return 90;
      case BillingCycle.biannual:
        return 180;
      case BillingCycle.annual:
        return 365;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _calculateDates();
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 