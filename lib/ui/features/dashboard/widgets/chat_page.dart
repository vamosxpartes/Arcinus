import 'package:flutter/material.dart';

/// Widget que muestra la página de chat del dashboard
class ChatPage extends StatelessWidget {
  /// Función a ejecutar cuando se desea navegar al dashboard
  final VoidCallback onNavigateToDashboard;

  /// Constructor que requiere la callback de navegación
  const ChatPage({
    super.key, 
    required this.onNavigateToDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Chat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Desliza a la izquierda para ir al Dashboard'),
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