import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/super_admin/presentation/providers/super_admin_dashboard_provider.dart';

/// Widget para mostrar alertas del sistema
class SystemAlertsCard extends ConsumerWidget {
  const SystemAlertsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(superAdminDashboardProvider);
    final alerts = dashboardState.systemAlerts;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alertas del Sistema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: alerts.isNotEmpty ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: alerts.isNotEmpty ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (alerts.isEmpty) 
              _buildNoAlertsMessage()
            else
              _buildAlertsList(context, ref, alerts),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAlertsMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No hay alertas del sistema en este momento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, WidgetRef ref, List<SystemAlert> alerts) {
    return Column(
      children: alerts.take(3).map((alert) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAlertItem(context, ref, alert),
        )
      ).toList(),
    );
  }

  Widget _buildAlertItem(BuildContext context, WidgetRef ref, SystemAlert alert) {
    final alertColors = _getAlertColors(alert.type);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColors['background'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColors['border']!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: alertColors['iconBackground'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAlertIcon(alert.type),
              color: alertColors['icon'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: alertColors['text'],
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(alert.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (alert.actionUrl != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _handleAlertAction(context, alert),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              iconSize: 16,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
          IconButton(
            onPressed: () => ref.read(superAdminDashboardProvider.notifier).markAlertAsRead(alert.id),
            icon: const Icon(Icons.close, size: 16),
            iconSize: 16,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getAlertColors(SystemAlertType type) {
    switch (type) {
      case SystemAlertType.critical:
        return {
          'background': Colors.red.shade50,
          'border': Colors.red.shade200,
          'iconBackground': Colors.red.shade100,
          'icon': Colors.red.shade700,
          'text': Colors.red.shade800,
        };
      case SystemAlertType.warning:
        return {
          'background': Colors.orange.shade50,
          'border': Colors.orange.shade200,
          'iconBackground': Colors.orange.shade100,
          'icon': Colors.orange.shade700,
          'text': Colors.orange.shade800,
        };
      case SystemAlertType.info:
        return {
          'background': Colors.blue.shade50,
          'border': Colors.blue.shade200,
          'iconBackground': Colors.blue.shade100,
          'icon': Colors.blue.shade700,
          'text': Colors.blue.shade800,
        };
      case SystemAlertType.success:
        return {
          'background': Colors.green.shade50,
          'border': Colors.green.shade200,
          'iconBackground': Colors.green.shade100,
          'icon': Colors.green.shade700,
          'text': Colors.green.shade800,
        };
    }
  }

  IconData _getAlertIcon(SystemAlertType type) {
    switch (type) {
      case SystemAlertType.critical:
        return Icons.error_outline;
      case SystemAlertType.warning:
        return Icons.warning_amber_outlined;
      case SystemAlertType.info:
        return Icons.info_outline;
      case SystemAlertType.success:
        return Icons.check_circle_outline;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  void _handleAlertAction(BuildContext context, SystemAlert alert) {
    // TODO: Implementar navegación basada en actionUrl
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a: ${alert.actionUrl}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 