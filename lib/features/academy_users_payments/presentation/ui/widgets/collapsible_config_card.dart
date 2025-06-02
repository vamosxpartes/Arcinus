import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_payments/data/models/payment_config_model.dart';

/// Card de configuración colapsable para mostrar detalles de facturación
/// Actúa como un botón de información que se puede expandir para ver detalles
class CollapsibleConfigCard extends StatefulWidget {
  final PaymentConfigModel? config;

  const CollapsibleConfigCard({
    super.key,
    this.config,
  });

  @override
  State<CollapsibleConfigCard> createState() => _CollapsibleConfigCardState();
}

class _CollapsibleConfigCardState extends State<CollapsibleConfigCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config == null) {
      return _buildNoConfigCard();
    }

    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.nbaBluePrimary.withAlpha(30),
          width: 1.5,
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

  Widget _buildNoConfigCard() {
    return Card(
      color: AppTheme.mediumGray,
      elevation: AppTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.lightGray.withAlpha(30),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.lightGray,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text(
              'Sin configuración de pagos',
              style: TextStyle(
                fontSize: AppTheme.bodySize,
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final config = widget.config!;
    
    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.cardRadius),
        bottom: _isExpanded 
            ? Radius.zero 
            : Radius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.nbaBluePrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              ),
              child: Icon(
                Icons.settings,
                color: AppTheme.nbaBluePrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración de Facturación',
                    style: TextStyle(
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.magnoliaWhite,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    'Modo: ${config.billingMode.displayName}',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isExpanded) ...[
                  _buildQuickStatusBadge(config),
                  const SizedBox(width: AppTheme.spacingSm),
                ],
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.expand_more,
                    color: AppTheme.lightGray,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatusBadge(PaymentConfigModel config) {
    final isFlexible = config.allowPartialPayments && config.earlyPaymentDiscount;
    final badgeColor = isFlexible ? AppTheme.courtGreen : AppTheme.goldTrophy;
    final badgeText = isFlexible ? 'FLEXIBLE' : 'ESTÁNDAR';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: badgeColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: AppTheme.captionSize,
          fontWeight: FontWeight.w700,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    final config = widget.config!;
    
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
            _buildConfigSection(
              'Modo de Facturación',
              config.billingMode.displayName,
              Icons.schedule,
              _getBillingModeDescription(config.billingMode),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildFeaturesList(config),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildAdditionalInfo(config),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection(String title, String value, IconData icon, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.nbaBluePrimary, size: 18),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              title,
              style: TextStyle(
                fontSize: AppTheme.secondarySize,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          description,
          style: TextStyle(
            fontSize: AppTheme.captionSize,
            color: AppTheme.lightGray,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(PaymentConfigModel config) {
    final features = <Map<String, dynamic>>[
      {
        'title': 'Pagos parciales',
        'enabled': config.allowPartialPayments,
        'icon': Icons.pie_chart,
      },
      {
        'title': 'Descuentos por anticipación',
        'enabled': config.earlyPaymentDiscount,
        'icon': Icons.discount,
      },
      {
        'title': 'Fecha manual (prepago)',
        'enabled': config.allowManualStartDateInPrepaid,
        'icon': Icons.edit_calendar,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Características:',
          style: TextStyle(
            fontSize: AppTheme.secondarySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightGray,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        ...features.map((feature) => _buildFeatureItem(
          feature['title'] as String,
          feature['enabled'] as bool,
          feature['icon'] as IconData,
        )),
      ],
    );
  }

  Widget _buildFeatureItem(String title, bool enabled, IconData icon) {
    final color = enabled ? AppTheme.courtGreen : AppTheme.lightGray;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            title,
            style: TextStyle(
              fontSize: AppTheme.secondarySize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(PaymentConfigModel config) {
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.lightGray,
                size: 16,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Información adicional',
                style: TextStyle(
                  fontSize: AppTheme.secondarySize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            _getAdditionalInfoText(config),
            style: TextStyle(
              fontSize: AppTheme.captionSize,
              color: AppTheme.lightGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getBillingModeDescription(BillingMode mode) {
    switch (mode) {
      case BillingMode.advance:
        return 'Los pagos se realizan por adelantado antes del período de servicio';
      case BillingMode.current:
        return 'Los pagos se realizan durante el período de servicio actual';
      case BillingMode.arrears:
        return 'Los pagos se realizan después del período de servicio vencido';
    }
  }

  String _getAdditionalInfoText(PaymentConfigModel config) {
    final features = <String>[];
    
    if (config.allowPartialPayments) {
      features.add('Se permiten pagos parciales para mayor flexibilidad');
    }
    
    if (config.earlyPaymentDiscount) {
      features.add('Descuentos disponibles para pagos anticipados');
    }
    
    if (config.allowManualStartDateInPrepaid && config.billingMode == BillingMode.advance) {
      features.add('Fecha de inicio personalizable en modo prepago');
    }
    
    if (features.isEmpty) {
      return 'Configuración estándar sin características especiales habilitadas.';
    }
    
    return '${features.join('. ')}.';
  }
} 