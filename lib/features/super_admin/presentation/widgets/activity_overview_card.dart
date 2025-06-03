import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/super_admin/presentation/providers/super_admin_dashboard_provider.dart';

/// Widget para mostrar un resumen de actividad de la plataforma
class ActivityOverviewCard extends ConsumerWidget {
  const ActivityOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(superAdminDashboardProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 200,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resumen de Actividad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En línea',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Sesiones activas
                    _buildActivityItem(
                      context,
                      icon: Icons.people_alt_outlined,
                      title: 'Sesiones Activas',
                      value: '${dashboardState.activeSessions}',
                      subtitle: 'usuarios conectados',
                      color: Colors.blue,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tiempo promedio de sesión
                    _buildActivityItem(
                      context,
                      icon: Icons.access_time_outlined,
                      title: 'Tiempo Promedio',
                      value: '${dashboardState.averageSessionTime.toStringAsFixed(1)}min',
                      subtitle: 'por sesión',
                      color: Colors.purple,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Nuevos usuarios este mes
                    _buildActivityItem(
                      context,
                      icon: Icons.person_add_outlined,
                      title: 'Nuevos Usuarios',
                      value: '${dashboardState.newUsersThisMonth}',
                      subtitle: 'este mes',
                      color: Colors.green,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Features más utilizadas
                    _buildTopFeatures(context, dashboardState),
                    
                    const SizedBox(height: 20),
                    
                    // Estado del sistema
                    _buildSystemStatus(context, dashboardState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopFeatures(BuildContext context, SuperAdminDashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features Más Utilizadas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...state.topFeatures.take(3).map((feature) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatus(BuildContext context, SuperAdminDashboardState state) {
    final uptimeColor = state.systemUptime >= 99.0 ? Colors.green : 
                      state.systemUptime >= 95.0 ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado del Sistema',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: uptimeColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Uptime ${state.systemUptime.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: uptimeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                state.criticalErrors == 0 ? Icons.check_circle_outline : Icons.error_outline,
                size: 16,
                color: state.criticalErrors == 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                state.criticalErrors == 0 
                  ? 'Sin errores críticos'
                  : '${state.criticalErrors} errores críticos',
                style: TextStyle(
                  fontSize: 13,
                  color: state.criticalErrors == 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          if (state.lastUpdate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Última actualización: ${_formatLastUpdate(state.lastUpdate!)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}';
    }
  }
} 