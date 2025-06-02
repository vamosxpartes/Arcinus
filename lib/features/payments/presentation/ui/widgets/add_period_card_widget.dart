import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/payments/data/models/payment_config_model.dart';
import 'package:arcinus/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:intl/intl.dart';

/// Estados del widget de agregar período
enum AddPeriodState {
  initial,     // Estado inicial: botón de agregar
  configuring, // Configurando: selección de plan, períodos, fecha
  payment,     // Modo pago: formulario de pago
}

/// Widget para agregar nuevos períodos que cambia de estado
class AddPeriodCardWidget extends ConsumerStatefulWidget {
  final String academyId;
  final PaymentConfigModel? config;
  final String currency;
  final ValueChanged<Map<String, dynamic>>? onPeriodConfigured;
  final VoidCallback? onPaymentRequired;

  const AddPeriodCardWidget({
    super.key,
    required this.academyId,
    this.config,
    this.currency = 'COP',
    this.onPeriodConfigured,
    this.onPaymentRequired,
  });

  @override
  ConsumerState<AddPeriodCardWidget> createState() => _AddPeriodCardWidgetState();
}

class _AddPeriodCardWidgetState extends ConsumerState<AddPeriodCardWidget>
    with SingleTickerProviderStateMixin {
  AddPeriodState _currentState = AddPeriodState.initial;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // Variables de configuración
  String? _selectedPlanId;
  SubscriptionPlanModel? _selectedPlan;
  int _numberOfPeriods = 1;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeState(AddPeriodState newState) {
    setState(() {
      _currentState = newState;
      if (newState == AddPeriodState.initial) {
        _animationController.reverse();
        _resetConfiguration();
      } else {
        _animationController.forward();
      }
    });
  }

  void _resetConfiguration() {
    _selectedPlanId = null;
    _selectedPlan = null;
    _numberOfPeriods = 1;
    _startDate = null;
    _endDate = null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.mediumGray,
      elevation: _currentState == AddPeriodState.initial 
          ? AppTheme.elevationLow 
          : AppTheme.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: _getBorderColor(),
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
    );
  }

  Color _getBorderColor() {
    switch (_currentState) {
      case AddPeriodState.initial:
        return AppTheme.goldTrophy.withAlpha(50);
      case AddPeriodState.configuring:
        return AppTheme.nbaBluePrimary.withAlpha(50);
      case AddPeriodState.payment:
        return AppTheme.bonfireRed.withAlpha(50);
    }
  }

  Widget _buildHeader() {
    IconData headerIcon;
    String headerTitle;
    String headerSubtitle;
    Color headerColor;

    switch (_currentState) {
      case AddPeriodState.initial:
        headerIcon = Icons.add_circle_outline;
        headerTitle = 'Agregar Período';
        headerSubtitle = 'Toca para agregar un nuevo período de suscripción';
        headerColor = AppTheme.goldTrophy;
        break;
      case AddPeriodState.configuring:
        headerIcon = Icons.settings;
        headerTitle = 'Configurar Período';
        headerSubtitle = 'Selecciona plan, duración y fecha de inicio';
        headerColor = AppTheme.nbaBluePrimary;
        break;
      case AddPeriodState.payment:
        headerIcon = Icons.payment;
        headerTitle = 'Registrar Pago';
        headerSubtitle = 'Completa la información del pago';
        headerColor = AppTheme.bonfireRed;
        break;
    }

    return InkWell(
      onTap: _currentState == AddPeriodState.initial 
          ? () => _changeState(AddPeriodState.configuring)
          : null,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.cardRadius),
        bottom: _currentState == AddPeriodState.initial 
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
                    headerColor,
                    headerColor.withAlpha(200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              child: Icon(
                headerIcon,
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
                    headerTitle,
                    style: const TextStyle(
                      fontSize: AppTheme.subtitleSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    headerSubtitle,
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            if (_currentState != AddPeriodState.initial)
              IconButton(
                onPressed: () => _changeState(AddPeriodState.initial),
                icon: const Icon(
                  Icons.close,
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
        return const SizedBox.shrink();
      case AddPeriodState.configuring:
        return _buildConfigurationContent();
      case AddPeriodState.payment:
        return _buildPaymentContent();
    }
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
            onPressed: () => _changeState(AddPeriodState.initial),
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
            onPressed: isConfigComplete ? _proceedToPayment : null,
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

  Widget _buildPaymentContent() {
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
            Center(
              child: Text(
                'Configuración completada. El pago se procesará con la información del formulario principal.',
                style: TextStyle(
                  fontSize: AppTheme.bodySize,
                  color: AppTheme.lightGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: () => _changeState(AddPeriodState.configuring),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.nbaBluePrimary,
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

  void _proceedToPayment() {
    if (_selectedPlan == null || _startDate == null || _endDate == null) return;
    
    // Notificar configuración completada
    widget.onPeriodConfigured?.call({
      'planId': _selectedPlanId!,
      'plan': _selectedPlan!,
      'numberOfPeriods': _numberOfPeriods,
      'startDate': _startDate!,
      'endDate': _endDate!,
      'totalAmount': _selectedPlan!.amount * _numberOfPeriods,
    });
    
    // Cambiar a estado de pago
    _changeState(AddPeriodState.payment);
    
    // Notificar que se requiere pago
    widget.onPaymentRequired?.call();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 