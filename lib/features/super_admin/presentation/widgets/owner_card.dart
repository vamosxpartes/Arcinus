import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/super_admin/presentation/providers/owners_management_provider.dart';

/// Tarjeta que muestra información de un propietario
/// 
/// Diseñada para ser utilizada en listas y grids,
/// proporciona información clave y acciones rápidas.
class OwnerCard extends StatelessWidget {
  const OwnerCard({
    super.key,
    required this.owner,
    this.onStatusChanged,
    this.onTap,
  });

  final OwnerData owner;
  final Function(OwnerStatus)? onStatusChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con avatar y estado
              Row(
                children: [
                  // Avatar del propietario
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.deepPurple.shade100,
                    backgroundImage: owner.profileImageUrl != null
                        ? NetworkImage(owner.profileImageUrl!)
                        : null,
                    child: owner.profileImageUrl == null
                        ? Text(
                            _getInitials(),
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Información básica
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${owner.firstName} ${owner.lastName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          owner.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Badge de estado
                  _buildStatusBadge(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Información de la academia
              if (owner.academy != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.magnoliaWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: Colors.deepPurple.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Academia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        owner.academy!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.sports_soccer_outlined,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            owner.academy!.sport,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${owner.academy!.city}, ${owner.academy!.country}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Métricas rápidas
              Row(
                children: [
                  _buildMetricItem(
                    icon: Icons.people_outline,
                    label: 'Usuarios',
                    value: '${owner.activeUsers}/${owner.totalUsers}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildMetricItem(
                    icon: Icons.attach_money_outlined,
                    label: 'Ingresos',
                    value: _formatCurrency(owner.monthlyRevenue),
                    color: Colors.green,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información de actividad
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Registrado: ${_formatDate(owner.createdAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  if (owner.lastLoginAt != null)
                    Text(
                      'Último acceso: ${_formatRelativeTime(owner.lastLoginAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Acciones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToDetails(context),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('Ver Detalles'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusActionButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el badge de estado
  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (owner.status) {
      case OwnerStatus.active:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Activo';
        icon = Icons.check_circle_outline;
        break;
      case OwnerStatus.inactive:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Inactivo';
        icon = Icons.pause_circle_outline;
        break;
      case OwnerStatus.suspended:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Suspendido';
        icon = Icons.block_outlined;
        break;
      case OwnerStatus.pending:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Pendiente';
        icon = Icons.hourglass_empty_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un item de métrica
  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye el botón de acción de estado
  Widget _buildStatusActionButton() {
    if (owner.status == OwnerStatus.pending) {
      return const SizedBox.shrink(); // No mostrar acciones para pendientes
    }

    return PopupMenuButton<OwnerStatus>(
      tooltip: 'Cambiar Estado',
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey.shade600,
      ),
      onSelected: (status) {
        AppLogger.logInfo(
          'Solicitando cambio de estado',
          className: 'OwnerCard',
          functionName: '_buildStatusActionButton',
          params: {
            'ownerId': owner.id,
            'currentStatus': owner.status.toString(),
            'newStatus': status.toString(),
          },
        );
        onStatusChanged?.call(status);
      },
      itemBuilder: (context) => [
        if (owner.status != OwnerStatus.active)
          PopupMenuItem(
            value: OwnerStatus.active,
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 8),
                const Text('Activar'),
              ],
            ),
          ),
        if (owner.status != OwnerStatus.inactive)
          PopupMenuItem(
            value: OwnerStatus.inactive,
            child: Row(
              children: [
                Icon(Icons.pause_circle_outline, color: Colors.orange.shade600, size: 16),
                const SizedBox(width: 8),
                const Text('Desactivar'),
              ],
            ),
          ),
        if (owner.status != OwnerStatus.suspended)
          PopupMenuItem(
            value: OwnerStatus.suspended,
            child: Row(
              children: [
                Icon(Icons.block_outlined, color: Colors.red.shade600, size: 16),
                const SizedBox(width: 8),
                const Text('Suspender'),
              ],
            ),
          ),
      ],
    );
  }

  /// Navega a los detalles del propietario
  void _navigateToDetails(BuildContext context) {
    AppLogger.logInfo(
      'Navegando a detalles del propietario',
      className: 'OwnerCard',
      functionName: '_navigateToDetails',
      params: {'ownerId': owner.id},
    );

    context.push('/superadmin/owners/${owner.id}');
  }

  /// Obtiene las iniciales del nombre
  String _getInitials() {
    return '${owner.firstName.isNotEmpty ? owner.firstName[0] : ''}${owner.lastName.isNotEmpty ? owner.lastName[0] : ''}'.toUpperCase();
  }

  /// Formatea la fecha de registro
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea el tiempo relativo
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return 'hace un momento';
    }
  }

  /// Formatea la moneda
  String _formatCurrency(double amount) {
    if (amount == 0) return '\$0';
    
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
} 