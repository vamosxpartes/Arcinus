import 'package:flutter/material.dart';

/// Widget que muestra la página de notificaciones del dashboard
class NotificationsPage extends StatelessWidget {
  /// Función a ejecutar cuando se desea navegar al dashboard
  final VoidCallback onNavigateToDashboard;

  /// Constructor que requiere la callback de navegación
  const NotificationsPage({
    super.key, 
    required this.onNavigateToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Notificaciones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Desliza a la derecha para ir al Dashboard'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onNavigateToDashboard,
            child: const Text('Ir al Dashboard'),
          ),
        ],
      ),
    );
  }
} 