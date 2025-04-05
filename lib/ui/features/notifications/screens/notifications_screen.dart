import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              // Marcar todas como leídas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marcado de notificaciones en desarrollo'),
                ),
              );
            },
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: _buildNotificationsList(context),
    );
  }
  
  Widget _buildNotificationsList(BuildContext context) {
    // Por ahora mostramos notificaciones simuladas
    final theme = Theme.of(context);
    final notifications = _getDummyNotifications();
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: theme.colorScheme.primary.withAlpha(125),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes notificaciones',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Las notificaciones importantes aparecerán aquí',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification.type).withAlpha(60),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: notification.isRead 
                      ? Colors.grey 
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(notification.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () {
            // Navegar a la pantalla correspondiente según el tipo de notificación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Acción para notificación de tipo ${notification.type}'),
              ),
            );
          },
          tileColor: notification.isRead ? null : theme.colorScheme.primary.withAlpha(15),
        );
      },
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'info':
        return Icons.info_outline;
      case 'payment':
        return Icons.payment;
      case 'event':
        return Icons.event;
      case 'message':
        return Icons.message;
      case 'attendance':
        return Icons.fact_check;
      case 'invitation':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'info':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'event':
        return Colors.orange;
      case 'message':
        return Colors.purple;
      case 'attendance':
        return Colors.teal;
      case 'invitation':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
  
  List<_NotificationPreview> _getDummyNotifications() {
    return [
      _NotificationPreview(
        title: 'Clase de entrenamiento',
        body: 'Recuerda que tienes una clase programada para mañana a las 10:00 AM.',
        type: 'event',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      _NotificationPreview(
        title: 'Pago recibido',
        body: 'El pago de la mensualidad ha sido procesado correctamente.',
        type: 'payment',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      _NotificationPreview(
        title: 'Nuevo mensaje',
        body: 'Tienes un nuevo mensaje de Laura García.',
        type: 'message',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      _NotificationPreview(
        title: 'Registro de asistencia',
        body: 'Tu asistencia ha sido registrada para la clase de hoy.',
        type: 'attendance',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      _NotificationPreview(
        title: 'Actualización de entrenamiento',
        body: 'El entrenador ha actualizado la rutina para esta semana.',
        type: 'info',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      _NotificationPreview(
        title: 'Invitación a grupo',
        body: 'Has sido invitado al grupo "Entrenamiento Avanzado".',
        type: 'invitation',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }
}

class _NotificationPreview {
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  
  _NotificationPreview({
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
} 