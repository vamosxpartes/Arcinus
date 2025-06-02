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
import 'package:arcinus/features/payments/data/models/payment_model.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/features/users/domain/repositories/client_user_repository_impl.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/athlete_periods_info_provider.dart';

// Importar widgets modulares
import 'package:arcinus/features/payments/presentation/ui/widgets/widgets.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';

// Importar provider de períodos
import 'package:arcinus/features/subscriptions/presentation/providers/period_providers.dart';

// Importar el nuevo provider y widget
import 'package:arcinus/features/subscriptions/presentation/providers/period_actions_provider.dart';
import 'package:arcinus/features/payments/presentation/ui/widgets/period_edit_dialog.dart';

// *** NUEVO: Importar el provider del EnhancedPaymentService ***
import 'package:arcinus/features/payments/presentation/providers/enhanced_payment_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';

part 'register_payment_screen.g.dart';

/// Pantalla refactorizada para gestión de períodos y pagos
/// NUEVO DISEÑO:
/// 1. Header de usuario (reemplaza card)
/// 2. Card de configuración colapsable
/// 3. ListView de períodos existentes + card de agregar período
/// 4. Bottom sheet de pago cuando se requiere
class RegisterPaymentScreen extends ConsumerStatefulWidget {
  final String? athleteId;
  final Map<String, dynamic>? preloadedData;

  const RegisterPaymentScreen({
    super.key, 
    this.athleteId,
    this.preloadedData
  });

  @override
  RegisterPaymentScreenState createState() => RegisterPaymentScreenState();
}

class RegisterPaymentScreenState extends ConsumerState<RegisterPaymentScreen> {
  // Claves de formularios
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Estado del formulario
  String? _selectedAthleteId;
  DateTime _paymentDate = DateTime.now();
  String _selectedCurrency = 'COP';
  String _selectedPaymentMethod = 'Efectivo';
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _titlePushed = false;
  
  // Configuración de pagos
  PaymentConfigModel? _paymentConfig;
  ClientUserModel? _clientUser;
  AcademyUserModel? _academyUser;

  // Nuevas variables para la refactorización
  List<SubscriptionAssignmentModel> _existingPeriods = [];
  int _totalRemainingDays = 0;
  bool _showPaymentForm = false;
  
  // Variables para nuevo período en configuración
  Map<String, dynamic>? _newPeriodConfig;
  
  // Cache de nombres de planes para mostrar en las cards
  Map<String, String> _planNamesCache = {};
  
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
      'Inicializando pantalla refactorizada de gestión de períodos',
      className: 'RegisterPaymentScreenState',
      functionName: 'initState',
      params: {'athleteId': widget.athleteId, 'preloadedData': widget.preloadedData != null},
    );
    
    if (widget.athleteId != null) {
      _selectedAthleteId = widget.athleteId;
    }
    
    if (widget.preloadedData != null) {
      _processPreloadedData();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_titlePushed) {
        ref.read(titleManagerProvider.notifier).pushTitle('Gestión de Períodos');
        _titlePushed = true;
      }
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
      // Cargar configuración de pagos
      final paymentConfigAsync = await ref.read(paymentConfigProvider(academyId).future);
      
      if (_selectedAthleteId != null) {
        // Cargar datos del atleta
        final clientUserAsync = await ref.read(clientUserProvider(_selectedAthleteId!).future);
        
        // Cargar información del usuario de la academia
        try {
          final repository = AcademyUsersRepository();
          final academyUser = await repository.getUserById(academyId, _selectedAthleteId!);
          
          // Cargar períodos existentes
          await _loadExistingPeriods(academyId);
          
          setState(() {
            _paymentConfig = paymentConfigAsync;
            _clientUser = clientUserAsync;
            _academyUser = academyUser;
            _isInitialized = true;
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

  Future<void> _loadExistingPeriods(String academyId) async {
    if (_selectedAthleteId == null) return;
    
    try {
      AppLogger.logInfo(
        'DIAGNÓSTICO: Iniciando carga de períodos existentes',
        className: 'RegisterPaymentScreenState',
        functionName: '_loadExistingPeriods',
        params: {
          'academyId': academyId,
          'athleteId': _selectedAthleteId!,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final activePeriods = await ref.read(athleteActivePeriodsProvider((
        academyId: academyId, 
        athleteId: _selectedAthleteId!
      )).future);
      
      AppLogger.logInfo(
        'DIAGNÓSTICO: Consulta de provider completada',
        className: 'RegisterPaymentScreenState',
        functionName: '_loadExistingPeriods',
        params: {
          'periodsFoundByProvider': activePeriods.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      final totalRemainingDays = _calculateTotalRemainingDays(activePeriods);
      
      setState(() {
        _existingPeriods = activePeriods;
        _totalRemainingDays = totalRemainingDays;
      });
      
      // Cargar nombres de planes para los períodos existentes
      await _loadPlanNamesForPeriods(academyId, activePeriods);
      
      // Sincronizar información del usuario con los datos de períodos
      await _updateUserInfoFromPeriods();
      
      AppLogger.logInfo(
        'Períodos existentes cargados',
        className: 'RegisterPaymentScreenState',
        functionName: '_loadExistingPeriods',
        params: {
          'periodsCount': activePeriods.length,
          'totalRemainingDays': totalRemainingDays,
        },
      );
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al cargar períodos existentes',
        error: e,
        className: 'RegisterPaymentScreenState',
        functionName: '_loadExistingPeriods',
      );
    }
  }

  /// Carga los nombres de los planes para los períodos existentes
  Future<void> _loadPlanNamesForPeriods(String academyId, List<SubscriptionAssignmentModel> periods) async {
    try {
      final planIds = periods.map((p) => p.subscriptionPlanId).toSet();
      final newPlanNames = <String, String>{};
      
      for (final planId in planIds) {
        if (!_planNamesCache.containsKey(planId)) {
          try {
            final planProvider = subscriptionPlanProvider((
              academyId: academyId,
              planId: planId,
            ));
            
            final plan = await ref.read(planProvider.future);
            if (plan != null) {
              newPlanNames[planId] = plan.name;
            }
          } catch (e) {
            AppLogger.logWarning(
              'No se pudo cargar el nombre del plan',
              className: 'RegisterPaymentScreenState',
              functionName: '_loadPlanNamesForPeriods',
              params: {'planId': planId, 'error': e.toString()},
            );
            newPlanNames[planId] = 'Plan no disponible';
          }
        }
      }
      
      if (newPlanNames.isNotEmpty) {
        setState(() {
          _planNamesCache.addAll(newPlanNames);
        });
      }
      
      AppLogger.logInfo(
        'Nombres de planes cargados',
        className: 'RegisterPaymentScreenState',
        functionName: '_loadPlanNamesForPeriods',
        params: {'loadedPlans': newPlanNames.length},
      );
      
    } catch (e) {
      AppLogger.logError(
        message: 'Error al cargar nombres de planes',
        error: e,
        className: 'RegisterPaymentScreenState',
        functionName: '_loadPlanNamesForPeriods',
      );
    }
  }

  int _calculateTotalRemainingDays(List<SubscriptionAssignmentModel> periods) {
    if (periods.isEmpty) return 0;
    final now = DateTime.now();
    return periods
        .where((p) => p.endDate.isAfter(now))
        .map((p) => p.endDate.difference(now).inDays)
        .fold(0, (suma, days) => suma + days);
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
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ==================== MANEJADORES DE EVENTOS ====================

  void _onAthleteChanged(String? athleteId) {
    if (athleteId != null) {
      setState(() {
        _selectedAthleteId = athleteId;
        _isInitialized = false;
        _existingPeriods = [];
        _totalRemainingDays = 0;
        _showPaymentForm = false;
        _newPeriodConfig = null;
        _planNamesCache = {};
      });
      _initializeAsync();
    }
  }

  void _onPeriodConfigured(Map<String, dynamic> config) {
    setState(() {
      _newPeriodConfig = config;
      
      // Auto-completar campos del formulario
      final plan = config['plan'] as SubscriptionPlanModel;
      final numberOfPeriods = config['numberOfPeriods'] as int;
      final totalAmount = config['totalAmount'] as double;
      
      _amountController.text = totalAmount.toString();
      _conceptController.text = numberOfPeriods > 1 
          ? 'Pago de $numberOfPeriods períodos - ${plan.name}'
          : 'Pago plan: ${plan.name}';
      _selectedCurrency = plan.currency.isNotEmpty ? plan.currency : _selectedCurrency;
    });
    
    AppLogger.logInfo(
      'Período configurado para pago',
      className: 'RegisterPaymentScreenState',
      functionName: '_onPeriodConfigured',
      params: config,
    );
  }

  void _onPaymentRequired() {
    setState(() {
      _showPaymentForm = true;
    });
  }

  void _onHidePaymentForm() {
    setState(() {
      _showPaymentForm = false;
      _newPeriodConfig = null;
    });
  }

  void _onPeriodCardTapped(SubscriptionAssignmentModel period) {
    _showPeriodDetailsBottomSheet(period);
  }

  void _showPeriodDetailsBottomSheet(SubscriptionAssignmentModel period) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.mediumGray,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.cardRadius),
            ),
            border: Border.all(
              color: AppTheme.courtGreen.withAlpha(50),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Handle del bottom sheet
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: AppTheme.courtGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: AppTheme.courtGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    const Text(
                      'Detalles del Período',
                      style: TextStyle(
                        fontSize: AppTheme.subtitleSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.magnoliaWhite,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: _buildPeriodDetailsContent(period),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodDetailsContent(SubscriptionAssignmentModel period) {
    final now = DateTime.now();
    final isActive = period.startDate.isBefore(now) && period.endDate.isAfter(now);
    final isFuture = period.startDate.isAfter(now);
    final isPast = period.endDate.isBefore(now);
    final remainingDays = period.endDate.difference(now).inDays;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado del período
        _buildPeriodStatusSection(period, isActive, isFuture, isPast, remainingDays),
        const SizedBox(height: AppTheme.spacingLg),
        
        // Información del plan
        _buildPlanInfoSection(period),
        const SizedBox(height: AppTheme.spacingLg),
        
        // Fechas y duración
        _buildDatesSection(period),
        const SizedBox(height: AppTheme.spacingLg),
        
        // Información de pago
        _buildPaymentInfoSection(period),
        const SizedBox(height: AppTheme.spacingLg),
        
        // Acciones disponibles
        if (isActive || isFuture)
          _buildPeriodActions(period, isActive, isFuture),
      ],
    );
  }

  Widget _buildPeriodStatusSection(SubscriptionAssignmentModel period, bool isActive, bool isFuture, bool isPast, int remainingDays) {
    Color statusColor = AppTheme.lightGray;
    String statusText = 'Desconocido';
    IconData statusIcon = Icons.help_outline;
    
    if (isActive) {
      statusColor = AppTheme.courtGreen;
      statusText = 'Período Activo';
      statusIcon = Icons.play_circle_filled;
    } else if (isFuture) {
      statusColor = AppTheme.goldTrophy;
      statusText = 'Período Programado';
      statusIcon = Icons.schedule;
    } else if (isPast) {
      statusColor = AppTheme.lightGray;
      statusText = 'Período Finalizado';
      statusIcon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: statusColor.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: AppTheme.subtitleSize,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                if (isActive && remainingDays > 0)
                  Text(
                    'Quedan $remainingDays días',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: statusColor,
                    ),
                  )
                else if (isFuture)
                  Text(
                    'Inicia en ${period.startDate.difference(DateTime.now()).inDays} días',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: statusColor,
                    ),
                  )
                else if (isPast)
                  Text(
                    'Finalizó hace ${DateTime.now().difference(period.endDate).inDays} días',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: statusColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoSection(SubscriptionAssignmentModel period) {
    final planName = _planNamesCache[period.subscriptionPlanId];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información del Plan',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
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
            children: [
              if (planName != null && planName.isNotEmpty)
                _buildDetailRow('Nombre del Plan', planName),
              _buildDetailRow('ID del Plan', period.subscriptionPlanId),
              if (period.notes != null && period.notes!.isNotEmpty)
                _buildDetailRow('Notas', period.notes!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatesSection(SubscriptionAssignmentModel period) {
    final totalDays = period.endDate.difference(period.startDate).inDays;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fechas y Duración',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
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
            children: [
              _buildDetailRow('Inicio', _formatDate(period.startDate)),
              _buildDetailRow('Fin', _formatDate(period.endDate)),
              _buildDetailRow('Duración', '$totalDays días'),
              _buildDetailRow('Fecha de Pago', _formatDate(period.paymentDate)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoSection(SubscriptionAssignmentModel period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de Pago',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
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
            children: [
              _buildDetailRow(
                'Monto Pagado', 
                '${NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(period.amountPaid)} ${period.currency}'
              ),
              if (period.totalPlanAmount != null)
                _buildDetailRow(
                  'Monto Total del Plan', 
                  '${NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(period.totalPlanAmount!)} ${period.currency}'
                ),
              _buildDetailRow(
                'Tipo de Pago', 
                period.isPartialPayment ? 'Pago Parcial' : 'Pago Completo'
              ),
              if (period.paymentId != null)
                _buildDetailRow('ID de Pago', period.paymentId!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.secondarySize,
                color: AppTheme.lightGray,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTheme.secondarySize,
                fontWeight: FontWeight.w500,
                color: AppTheme.magnoliaWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodActions(SubscriptionAssignmentModel period, bool isActive, bool isFuture) {
    final isPaused = period.status == SubscriptionAssignmentStatus.paused;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Disponibles',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            if (isActive) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pausePeriod(period),
                  icon: const Icon(Icons.pause, color: AppTheme.goldTrophy),
                  label: const Text(
                    'Pausar',
                    style: TextStyle(color: AppTheme.goldTrophy),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.goldTrophy),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
            ],
            if (isPaused) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reactivatePeriod(period),
                  icon: const Icon(Icons.play_arrow, color: AppTheme.courtGreen),
                  label: const Text(
                    'Reactivar',
                    style: TextStyle(color: AppTheme.courtGreen),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.courtGreen),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
            ],
            if (isFuture) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelPeriod(period),
                  icon: const Icon(Icons.cancel, color: AppTheme.bonfireRed),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.bonfireRed),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.bonfireRed),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _editPeriod(period),
                icon: const Icon(Icons.edit, color: AppTheme.magnoliaWhite),
                label: const Text(
                  'Editar',
                  style: TextStyle(color: AppTheme.magnoliaWhite),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.courtGreen,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pausePeriod(SubscriptionAssignmentModel period) {
    Navigator.of(context).pop();
    
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) {
      _showSnackBar('No se pudo determinar la academia actual');
      return;
    }

    // Mostrar diálogo de confirmación
    _showConfirmationDialog(
      title: '¿Pausar período?',
      message: 'El período se pausará temporalmente. Podrás reactivarlo más tarde.',
      confirmText: 'Pausar',
      onConfirm: () {
        ref.read(periodActionsProvider.notifier).pausePeriod(academyId, period);
      },
    );
  }

  void _reactivatePeriod(SubscriptionAssignmentModel period) {
    Navigator.of(context).pop();
    
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) {
      _showSnackBar('No se pudo determinar la academia actual');
      return;
    }

    // Mostrar diálogo de confirmación
    _showConfirmationDialog(
      title: '¿Reactivar período?',
      message: 'El período se reactivará. Podrás pausarlo más tarde.',
      confirmText: 'Reactivar',
      onConfirm: () {
        ref.read(periodActionsProvider.notifier).reactivatePeriod(academyId, period);
      },
    );
  }

  void _cancelPeriod(SubscriptionAssignmentModel period) {
    Navigator.of(context).pop();
    
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) {
      _showSnackBar('No se pudo determinar la academia actual');
      return;
    }

    // Mostrar diálogo de confirmación
    _showConfirmationDialog(
      title: '¿Cancelar período?',
      message: 'Esta acción no se puede deshacer. El período se marcará como cancelado.',
      confirmText: 'Cancelar Período',
      isDestructive: true,
      onConfirm: () {
        ref.read(periodActionsProvider.notifier).cancelPeriod(academyId, period);
      },
    );
  }

  void _editPeriod(SubscriptionAssignmentModel period) {
    Navigator.of(context).pop();
    
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) {
      _showSnackBar('No se pudo determinar la academia actual');
      return;
    }

    // Mostrar diálogo de edición
    showDialog(
      context: context,
      builder: (context) => PeriodEditDialog(
        period: period,
        onSave: (startDate, endDate, notes) {
          ref.read(periodActionsProvider.notifier).editPeriodDates(
            academyId,
            period,
            startDate,
            endDate,
            notes: notes,
          );
        },
      ),
    );
  }

  /// Muestra un diálogo de confirmación personalizable
  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mediumGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: AppTheme.subtitleSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            color: AppTheme.lightGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppTheme.lightGray,
                fontSize: AppTheme.bodySize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppTheme.bonfireRed : AppTheme.courtGreen,
            ),
            child: Text(
              confirmText,
              style: TextStyle(
                color: AppTheme.magnoliaWhite,
                fontSize: AppTheme.bodySize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.courtGreen,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    _observePaymentState();
    
    return PopScope(
      onPopInvokedWithResult: _handlePopNavigation,
      child: Scaffold(
        body: _buildMainContent(),
        bottomSheet: _showPaymentForm ? _buildPaymentBottomSheet() : null,
      ),
    );
  }

  void _observePaymentState() {
    // Observar el estado del EnhancedPaymentNotifier
    ref.listen(enhancedPaymentNotifierProvider, (previous, current) {
      current.when(
        data: (enhancedResult) {
          if (enhancedResult != null) {
            // Pago exitoso
            setState(() => _isLoading = false);
            _handlePaymentSuccess();
          }
        },
        loading: () {
          setState(() => _isLoading = true);
        },
        error: (error, stackTrace) {
          setState(() => _isLoading = false);
          _handlePaymentFailure(error);
        },
      );
    });

    // Observar el estado de las acciones de períodos
    ref.listen(periodActionsProvider, (previous, current) {
      if (current.hasSuccess) {
        _showSnackBar(current.successMessage!, isError: false);
        
        // Recargar períodos después de una acción exitosa
        final academyId = ref.read(currentAcademyProvider)?.id;
        if (academyId != null && _selectedAthleteId != null) {
          _loadExistingPeriods(academyId);
        }
        
        // Resetear el estado después de mostrar el mensaje
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ref.read(periodActionsProvider.notifier).resetState();
          }
        });
      }

      if (current.hasError) {
        _showSnackBar(current.errorMessage!);
        
        // Resetear el estado después de mostrar el error
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            ref.read(periodActionsProvider.notifier).resetState();
          }
        });
      }
    });
  }

  void _handlePopNavigation(bool didPop, dynamic result) {
    if (didPop && _titlePushed) {
      ref.read(titleManagerProvider.notifier).popTitle();
    }
  }

  Widget _buildMainContent() {
    if (_isLoading && !_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header de usuario
          _buildUserHeader(),
          const SizedBox(height: AppTheme.spacingMd),
          
          // 2. Card de configuración colapsable
          if (_paymentConfig != null)
            CollapsibleConfigCard(config: _paymentConfig),
          const SizedBox(height: AppTheme.spacingMd),
          
          // 3. Lista de períodos + agregar período
          if (_selectedAthleteId != null) ...[
            _buildPeriodsSection(),
            
            // Padding adicional para el bottom sheet
            if (_showPaymentForm)
              const SizedBox(height: 300), // Espacio para el bottom sheet
          ],
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    if (_selectedAthleteId == null) {
      return Column(
        children: [
          UserHeaderWidget(), // Mostrará el prompt de selección
          const SizedBox(height: AppTheme.spacingMd),
          AthleteSelector(
            selectedAthleteId: _selectedAthleteId,
            onAthleteChanged: _onAthleteChanged,
            athletesAsyncValue: ref.watch(academyAthletesProvider),
          ),
        ],
      );
    }
    
    // Usar AthleteCompleteInfo si está disponible
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId != null) {
      final athleteInfoAsync = ref.watch(athleteCompleteInfoProvider((
        academyId: academyId,
        athleteId: _selectedAthleteId!,
      )));
      
      return athleteInfoAsync.when(
        data: (athleteInfo) => UserHeaderWidget(
          clientUser: athleteInfo.clientUser,
          academyUser: _academyUser,
          hasActivePlan: athleteInfo.hasActivePlan,
          totalRemainingDays: athleteInfo.remainingDays,
        ),
        loading: () => UserHeaderWidget(
          clientUser: _clientUser,
          academyUser: _academyUser,
          hasActivePlan: _existingPeriods.isNotEmpty,
          totalRemainingDays: _totalRemainingDays,
        ),
        error: (error, stack) => UserHeaderWidget(
          clientUser: _clientUser,
          academyUser: _academyUser,
          hasActivePlan: _existingPeriods.isNotEmpty,
          totalRemainingDays: _totalRemainingDays,
        ),
      );
    }
    
    return UserHeaderWidget(
      clientUser: _clientUser,
      academyUser: _academyUser,
      hasActivePlan: _existingPeriods.isNotEmpty,
      totalRemainingDays: _totalRemainingDays,
    );
  }

  Widget _buildPeriodsSection() {
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) return const SizedBox.shrink();

    // Ordenar períodos de más reciente a más antigua
    final sortedPeriods = List<SubscriptionAssignmentModel>.from(_existingPeriods);
    sortedPeriods.sort((a, b) {
      // Primero intentar ordenar por fecha de pago (más reciente primero)
      final aDate = a.paymentDate;
      final bDate = b.paymentDate;
      return bDate.compareTo(aDate);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.courtGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text(
              'Períodos de Suscripción',
              style: TextStyle(
                fontSize: AppTheme.h3Size,
                fontWeight: FontWeight.w700,
                color: AppTheme.magnoliaWhite,
              ),
            ),
            const Spacer(),
            if (_existingPeriods.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.courtGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                ),
                child: Text(
                  '${_existingPeriods.length} activos',
                  style: TextStyle(
                    fontSize: AppTheme.captionSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.courtGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        
        // Card de agregar período (PRIMERO)
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: AddPeriodCardWidget(
            academyId: academyId,
            config: _paymentConfig,
            currency: _selectedCurrency,
            onPeriodConfigured: _onPeriodConfigured,
            onPaymentRequired: _onPaymentRequired,
          ),
        ),
        
        // Lista de períodos existentes ordenados (más reciente a más antigua)
        ...sortedPeriods.map((period) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
          child: PeriodCardWidget(
            period: period,
            currency: _selectedCurrency,
            onTap: () => _onPeriodCardTapped(period),
            planName: _planNamesCache.containsKey(period.subscriptionPlanId) ? _planNamesCache[period.subscriptionPlanId] : '',
          ),
        )),
      ],
    );
  }

  Widget? _buildPaymentBottomSheet() {
    if (!_showPaymentForm || _newPeriodConfig == null) return null;
    
    // Obtener información completa del atleta para el formulario
    final academyId = ref.read(currentAcademyProvider)?.id;
    AthleteCompleteInfo? athleteInfo;
    
    if (academyId != null && _selectedAthleteId != null) {
      final athleteInfoAsync = ref.watch(athleteCompleteInfoProvider((
        academyId: academyId,
        athleteId: _selectedAthleteId!,
      )));
      
      athleteInfoAsync.whenData((info) => athleteInfo = info);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.mediumGray,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.cardRadius),
        ),
        border: Border.all(
          color: AppTheme.bonfireRed.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle del bottom sheet
          Container(
            margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header del bottom sheet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.bonfireRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: AppTheme.bonfireRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                const Text(
                  'Registrar Pago',
                  style: TextStyle(
                    fontSize: AppTheme.subtitleSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.magnoliaWhite,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _onHidePaymentForm,
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.lightGray,
                  ),
                ),
              ],
            ),
          ),
          
          // Formulario de pago
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: PaymentForm(
              formKey: _formKey,
              amountController: _amountController,
              conceptController: _conceptController,
              notesController: _notesController,
              paymentDate: _paymentDate,
              selectedCurrency: _selectedCurrency,
              selectedPaymentMethod: _selectedPaymentMethod,
              isPartialPayment: false, // Los períodos configurados no son parciales
              totalPlanAmount: _newPeriodConfig!['totalAmount'] as double,
              clientUser: _clientUser,
              paymentConfig: _paymentConfig,
              athleteInfo: athleteInfo, // Pasar información completa del atleta
              currencies: _currencies,
              paymentMethods: _paymentMethods,
              onCurrencyChanged: (value) => setState(() => _selectedCurrency = value),
              onPaymentMethodChanged: (value) => setState(() => _selectedPaymentMethod = value),
              onAmountChanged: (value) {}, // No cambiar el monto en períodos configurados
              isLoading: _isLoading,
            ),
          ),
          
          // Botón de envío
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (_newPeriodConfig == null) return const SizedBox.shrink();
    
    final numberOfPeriods = _newPeriodConfig!['numberOfPeriods'] as int;
    final totalAmount = _newPeriodConfig!['totalAmount'] as double;
    final canSubmit = !_isLoading;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        gradient: canSubmit 
            ? LinearGradient(
                colors: [AppTheme.bonfireRed, AppTheme.embers],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: !canSubmit ? AppTheme.mediumGray : null,
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? _submitPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.magnoliaWhite),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  const Text(
                    'Procesando pago...',
                    style: TextStyle(
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    numberOfPeriods > 1 
                        ? 'Registrar Pago de $numberOfPeriods Períodos'
                        : 'Registrar Pago del Período',
                    style: const TextStyle(
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    'Total: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO').format(totalAmount)} $_selectedCurrency',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: AppTheme.magnoliaWhite.withAlpha(200),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate() && _newPeriodConfig != null) {
      if (_selectedAthleteId == null) {
        _showError('Debes seleccionar un atleta');
        return;
      }

      final academyId = ref.read(currentAcademyProvider)?.id;
      if (academyId == null) {
        _showError('No se pudo determinar la academia actual');
        return;
      }

      final userId = ref.read(authStateNotifierProvider).user?.id;
      if (userId == null) {
        _showError('No se pudo determinar el usuario actual');
        return;
      }

      final amount = double.tryParse(_amountController.text) ?? 0;
      final plan = _newPeriodConfig!['plan'] as SubscriptionPlanModel;
      final startDate = _newPeriodConfig!['startDate'] as DateTime;
      final endDate = _newPeriodConfig!['endDate'] as DateTime;
      final numberOfPeriods = _newPeriodConfig!['numberOfPeriods'] as int? ?? 1;
      
      setState(() {
        _paymentDate = DateTime.now();
        _isLoading = true;
      });
      
      AppLogger.logInfo(
        'Enviando pago para período configurado usando EnhancedPaymentService',
        className: 'RegisterPaymentScreenState',
        functionName: '_submitPayment',
        params: {
          'athleteId': _selectedAthleteId,
          'planId': plan.id,
          'amount': amount,
          'currency': _selectedCurrency,
          'concept': _conceptController.text,
          'paymentDate': _paymentDate.toString(),
          'startDate': startDate.toString(),
          'endDate': endDate.toString(),
          'numberOfPeriods': numberOfPeriods,
        },
      );
      
      // Crear el modelo de pago
      final payment = PaymentModel(
        academyId: academyId,
        athleteId: _selectedAthleteId!,
        amount: amount,
        currency: _selectedCurrency,
        concept: _conceptController.text,
        paymentDate: _paymentDate,
        notes: _notesController.text,
        registeredBy: userId,
        createdAt: DateTime.now(),
        subscriptionPlanId: plan.id,
        isPartialPayment: false,
        totalPlanAmount: plan.amount,
        periodStartDate: startDate,
        periodEndDate: endDate,
      );
      
      // Usar EnhancedPaymentNotifier para registrar el pago con períodos
      final notifier = ref.read(enhancedPaymentNotifierProvider.notifier);
      
      notifier.registerPaymentWithPeriods(
        payment: payment,
        plan: plan,
        config: _paymentConfig!,
        numberOfPeriods: numberOfPeriods,
        requestedStartDate: startDate,
      );
    }
  }

  // ==================== MANEJADORES DE ESTADO ====================

  void _handlePaymentSuccess() {
    _invalidateProvidersAfterPayment();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pago registrado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Resetear estado
    setState(() {
      _showPaymentForm = false;
      _newPeriodConfig = null;
    });
    
    // *** CRÍTICO: Invalidación y recarga inmediata de períodos ***
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId != null && _selectedAthleteId != null) {
      // 1. Invalidar INMEDIATAMENTE todos los providers de períodos
      ref.invalidate(athleteActivePeriodsProvider((
        academyId: academyId, 
        athleteId: _selectedAthleteId!
      )));
      
      ref.invalidate(athleteCurrentPeriodProvider((
        academyId: academyId, 
        athleteId: _selectedAthleteId!
      )));
      
      ref.invalidate(athletePeriodsProvider((
        academyId: academyId, 
        athleteId: _selectedAthleteId!,
        status: null
      )));
      
      AppLogger.logInfo(
        'DIAGNÓSTICO: Providers invalidados inmediatamente tras pago exitoso',
        className: 'RegisterPaymentScreenState',
        functionName: '_handlePaymentSuccess',
        params: {
          'academyId': academyId,
          'athleteId': _selectedAthleteId!,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      // 2. Recargar períodos con múltiples intentos si es necesario
      _retryLoadExistingPeriods(academyId, maxAttempts: 3);
    }
  }

  void _handlePaymentFailure(dynamic failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al registrar el pago'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _invalidateProvidersAfterPayment() {
    final academyId = ref.read(currentAcademyProvider)?.id;
    
    if (_selectedAthleteId != null) {
      ref.invalidate(clientUserCachedProvider(_selectedAthleteId!));
      ref.invalidate(clientUserProvider(_selectedAthleteId!));
      
      // *** CRÍTICO: Invalidar TODOS los providers de períodos ***
      ref.invalidate(athleteActivePeriodsProvider((
        academyId: academyId!, 
        athleteId: _selectedAthleteId!
      )));
      
      ref.invalidate(athleteCurrentPeriodProvider((
        academyId: academyId, 
        athleteId: _selectedAthleteId!
      )));
      
      ref.invalidate(athletePeriodsProvider((
        academyId: academyId, 
        athleteId: _selectedAthleteId!,
        status: null
      )));
      
      try {
        final notifier = ref.read(clientUserCachedProvider(_selectedAthleteId!).notifier);
        notifier.invalidateAfterPayment();
        
        AppLogger.logInfo(
          'Providers invalidados correctamente incluyendo períodos',
          className: 'RegisterPaymentScreenState',
          functionName: '_invalidateProvidersAfterPayment',
          params: {'athleteId': _selectedAthleteId!}
        );
      } catch (e) {
        AppLogger.logWarning(
          'Error al invalidar provider caché',
          className: 'RegisterPaymentScreenState',
          functionName: '_invalidateProvidersAfterPayment',
          params: {'error': e.toString()}
        );
      }
    }
    
    if (academyId != null) {
      ref.invalidate(academyUsersProvider(academyId));
    }
  }

  /// Actualiza la información del usuario con datos de períodos para mantener consistencia
  Future<void> _updateUserInfoFromPeriods() async {
    if (_selectedAthleteId == null || _existingPeriods.isEmpty) return;
    
    final academyId = ref.read(currentAcademyProvider)?.id;
    if (academyId == null) return;
    
    try {
      // Encontrar el período más próximo a vencer
      final now = DateTime.now();
      final activePeriods = _existingPeriods.where((p) => p.endDate.isAfter(now)).toList();
      
      if (activePeriods.isNotEmpty) {
        activePeriods.sort((a, b) => a.endDate.compareTo(b.endDate));
        final nextExpiringPeriod = activePeriods.first;
        
        final remainingDays = nextExpiringPeriod.endDate.difference(now).inDays;
        
        AppLogger.logInfo(
          'Sincronizando información de usuario con datos de períodos',
          className: 'RegisterPaymentScreenState',
          functionName: '_updateUserInfoFromPeriods',
          params: {
            'athleteId': _selectedAthleteId!,
            'nextExpirationDate': nextExpiringPeriod.endDate.toString(),
            'remainingDays': remainingDays,
            'totalActivePeriods': activePeriods.length,
          },
        );
        
        // Actualizar datos del usuario para mantener consistencia
        final repository = ref.read(clientUserRepositoryProvider);
        await repository.updateClientUser(
          academyId,
          _selectedAthleteId!,
          {
            'nextPaymentDate': Timestamp.fromDate(nextExpiringPeriod.endDate),
            'remainingDays': remainingDays,
            'isEstimatedDays': false, // Son días reales basados en períodos
          },
        );
        
        // Invalidar providers para reflejar los cambios
        ref.invalidate(clientUserProvider(_selectedAthleteId!));
        ref.invalidate(clientUserCachedProvider(_selectedAthleteId!));
      }
    } catch (e) {
      AppLogger.logError(
        message: 'Error al sincronizar información de usuario con períodos',
        error: e,
        className: 'RegisterPaymentScreenState',
        functionName: '_updateUserInfoFromPeriods',
      );
    }
  }

  /// Recarga períodos con reintentos en caso de que no aparezcan inmediatamente
  Future<void> _retryLoadExistingPeriods(String academyId, {int maxAttempts = 3}) async {
    int attempt = 1;
    
    while (attempt <= maxAttempts) {
      AppLogger.logInfo(
        'DIAGNÓSTICO: Intento de recarga de períodos',
        className: 'RegisterPaymentScreenState',
        functionName: '_retryLoadExistingPeriods',
        params: {
          'attempt': attempt,
          'maxAttempts': maxAttempts,
          'academyId': academyId,
          'athleteId': _selectedAthleteId!,
        },
      );
      
      try {
        await _loadExistingPeriods(academyId);
        
        // Si encontramos períodos, salir del loop
        if (_existingPeriods.isNotEmpty) {
          AppLogger.logInfo(
            'DIAGNÓSTICO: Períodos encontrados en intento $attempt',
            className: 'RegisterPaymentScreenState',
            functionName: '_retryLoadExistingPeriods',
            params: {
              'foundPeriods': _existingPeriods.length,
              'attempt': attempt,
            },
          );
          break;
        }
        
        // Si no encontramos períodos y no es el último intento, esperar antes del próximo
        if (attempt < maxAttempts) {
          final delayMs = attempt * 1000; // 1s, 2s, 3s...
          AppLogger.logInfo(
            'DIAGNÓSTICO: No se encontraron períodos, esperando antes del próximo intento',
            className: 'RegisterPaymentScreenState',
            functionName: '_retryLoadExistingPeriods',
            params: {
              'attempt': attempt,
              'delayMs': delayMs,
            },
          );
          
          await Future.delayed(Duration(milliseconds: delayMs));
        }
        
      } catch (e) {
        AppLogger.logError(
          message: 'Error en intento $attempt de recargar períodos',
          error: e,
          className: 'RegisterPaymentScreenState',
          functionName: '_retryLoadExistingPeriods',
        );
        
        if (attempt == maxAttempts) {
          // En el último intento, mostrar error al usuario
          if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al recargar períodos: ${e.toString()}'),
              backgroundColor: Colors.orange,
            ),
          );
          }
        }
      }
      
      attempt++;
    }
    
    // Log final del resultado
    AppLogger.logInfo(
      'DIAGNÓSTICO: Proceso de recarga de períodos completado',
      className: 'RegisterPaymentScreenState',
      functionName: '_retryLoadExistingPeriods',
      params: {
        'finalPeriodsCount': _existingPeriods.length,
        'totalAttempts': attempt - 1,
        'wasSuccessful': _existingPeriods.isNotEmpty,
      },
    );
  }
}

/// Provider temporal para atletas de la academia
@riverpod
Future<List<UserModel>> academyAthletes(Ref ref) async {
  AppLogger.logWarning(
    'ADVERTENCIA: academyAthletesProvider está devolviendo una lista vacía.',
    className: 'academyAthletes',
    functionName: 'build',
  );
  return Future.value([]);
} 