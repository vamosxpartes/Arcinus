import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:intl/intl.dart';

/// Widget de tarjeta para mostrar un plan de suscripción
class PlanCardWidget extends StatelessWidget {
  /// Plan de suscripción a mostrar
  final AppSubscriptionPlanModel plan;
  
  /// Función para editar el plan
  final VoidCallback? onEdit;
  
  /// Función para alternar el estado del plan
  final VoidCallback? onToggleStatus;
  
  /// Función para eliminar el plan
  final VoidCallback? onDelete;
  
  /// Función para ver detalles del plan
  final VoidCallback? onViewDetails;

  const PlanCardWidget({
    super.key,
    required this.plan,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.elevationLow,
      margin: EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con nombre y estado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: AppTheme.h3Size,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.magnoliaWhite,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingXs),
                        Row(
                          children: [
                            _buildPlanTypeChip(),
                            SizedBox(width: AppTheme.spacingXs),
                            _buildStatusChip(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menú de acciones
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.lightGray,
                    ),
                    color: AppTheme.darkGray,
                    onSelected: (value) {
                      // Verificar que el plan tenga un ID válido antes de ejecutar acciones
                      if (plan.id == null || plan.id!.isEmpty) {
                        // Mostrar snackbar indicando error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Error: El plan no tiene un ID válido'),
                            backgroundColor: AppTheme.bonfireRed,
                          ),
                        );
                        return;
                      }
                      
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'toggle':
                          onToggleStatus?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                        case 'details':
                          onViewDetails?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      // Verificar si el plan tiene ID válido para habilitar/deshabilitar opciones
                      final hasValidId = plan.id != null && plan.id!.isNotEmpty;
                      
                      return [
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.lightGray),
                              SizedBox(width: AppTheme.spacingXs),
                              Text(
                                'Ver detalles',
                                style: TextStyle(color: AppTheme.magnoliaWhite),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          enabled: hasValidId,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit, 
                                color: hasValidId ? AppTheme.lightGray : AppTheme.disabledGray,
                              ),
                              SizedBox(width: AppTheme.spacingXs),
                              Text(
                                'Editar',
                                style: TextStyle(
                                  color: hasValidId ? AppTheme.magnoliaWhite : AppTheme.disabledGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          enabled: hasValidId,
                          child: Row(
                            children: [
                              Icon(
                                plan.isActive ? Icons.pause : Icons.play_arrow,
                                color: hasValidId ? AppTheme.lightGray : AppTheme.disabledGray,
                              ),
                              SizedBox(width: AppTheme.spacingXs),
                              Text(
                                plan.isActive ? 'Desactivar' : 'Activar',
                                style: TextStyle(
                                  color: hasValidId ? AppTheme.magnoliaWhite : AppTheme.disabledGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          enabled: hasValidId,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete, 
                                color: hasValidId ? AppTheme.bonfireRed : AppTheme.disabledGray,
                              ),
                              SizedBox(width: AppTheme.spacingXs),
                              Text(
                                'Eliminar', 
                                style: TextStyle(
                                  color: hasValidId ? AppTheme.bonfireRed : AppTheme.disabledGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              
              SizedBox(height: AppTheme.spacingSm),
              
              // Información del precio
              Row(
                children: [
                  Text(
                    _formatPrice(plan.price, plan.currency),
                    style: TextStyle(
                      fontSize: AppTheme.h2Size,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.bonfireRed,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingXs),
                  Text(
                    '/ ${plan.billingCycle.displayName}',
                    style: TextStyle(
                      fontSize: AppTheme.bodySize,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppTheme.spacingSm),
              
              // Límites del plan
              Row(
                children: [
                  Expanded(
                    child: _buildLimitInfo(
                      'Academias',
                      plan.maxAcademies == 999 ? 'Ilimitadas' : plan.maxAcademies.toString(),
                      Icons.business,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: _buildLimitInfo(
                      'Usuarios/Academia',
                      plan.maxUsersPerAcademy.toString(),
                      Icons.people,
                    ),
                  ),
                ],
              ),
              
              // Características principales
              if (plan.features.isNotEmpty) ...[
                SizedBox(height: AppTheme.spacingSm),
                Wrap(
                  spacing: AppTheme.spacingXs,
                  runSpacing: AppTheme.spacingXs,
                  children: plan.features.take(3).map((feature) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXs,
                      vertical: AppTheme.spacingXs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bonfireRed.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius),
                    ),
                    child: Text(
                      feature.displayName,
                      style: TextStyle(
                        fontSize: AppTheme.captionSize,
                        color: AppTheme.bonfireRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
              
              // Mostrar si hay más características
              if (plan.features.length > 3) ...[
                SizedBox(height: AppTheme.spacingXs),
                Text(
                  '+${plan.features.length - 3} características más',
                  style: TextStyle(
                    fontSize: AppTheme.captionSize,
                    color: AppTheme.lightGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTypeChip() {
    Color chipColor;
    switch (plan.planType) {
      case AppSubscriptionPlanType.free:
        chipColor = AppTheme.lightGray;
        break;
      case AppSubscriptionPlanType.basic:
        chipColor = AppTheme.nbaBluePrimary;
        break;
      case AppSubscriptionPlanType.pro:
        chipColor = AppTheme.goldTrophy;
        break;
      case AppSubscriptionPlanType.enterprise:
        chipColor = AppTheme.embers;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: AppTheme.spacingXs / 2,
      ),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(30),
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
      ),
      child: Text(
        plan.planType.displayName,
        style: TextStyle(
          fontSize: AppTheme.captionSize,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: AppTheme.spacingXs / 2,
      ),
      decoration: BoxDecoration(
        color: plan.isActive 
            ? AppTheme.courtGreen.withAlpha(30)
            : AppTheme.disabledGray.withAlpha(30),
        borderRadius: BorderRadius.circular(AppTheme.inputRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            plan.isActive ? Icons.check_circle : Icons.pause_circle,
            size: AppTheme.captionSize,
            color: plan.isActive ? AppTheme.courtGreen : AppTheme.disabledGray,
          ),
          SizedBox(width: AppTheme.spacingXs / 2),
          Text(
            plan.isActive ? 'Activo' : 'Inactivo',
            style: TextStyle(
              fontSize: AppTheme.captionSize,
              fontWeight: FontWeight.w500,
              color: plan.isActive ? AppTheme.courtGreen : AppTheme.disabledGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppTheme.bodySize,
          color: AppTheme.lightGray,
        ),
        SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTheme.captionSize,
                  color: AppTheme.lightGray,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppTheme.bodySize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
            ],
          ),
        ),
      ],
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
} 