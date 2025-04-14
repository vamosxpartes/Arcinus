import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda de chats
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Búsqueda en desarrollo')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar creación de nuevo chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear nuevo chat en desarrollo')),
          );
        },
        child: const Icon(Icons.chat),
      ),
      body: _buildChatsList(context),
    );
  }
  
  Widget _buildChatsList(BuildContext context) {
    // Por ahora mostramos elementos simulados
    final dummyChats = [
      _ChatPreview(
        name: 'Grupo de Entrenamiento',
        lastMessage: 'Recuerden la clase de mañana a las 10:00 AM',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isGroup: true,
        unreadCount: 2,
      ),
      _ChatPreview(
        name: 'Laura García',
        lastMessage: 'Gracias por la clase de hoy',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isGroup: false,
        unreadCount: 0,
      ),
      _ChatPreview(
        name: 'Carlos Rodríguez',
        lastMessage: 'Necesito cambiar mi horario para mañana',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isGroup: false,
        unreadCount: 1,
      ),
      _ChatPreview(
        name: 'Atletas Avanzados',
        lastMessage: 'Ana: ¿Alguien tiene las rutinas?',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isGroup: true,
        unreadCount: 0,
      ),
    ];
    
    return ListView.separated(
      itemCount: dummyChats.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = dummyChats[index];
        
        return ListTile(
          leading: CircleAvatar(
            child: Icon(chat.isGroup ? Icons.group : Icons.person),
          ),
          title: Text(
            chat.name,
            style: TextStyle(
              fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(chat.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: chat.unreadCount > 0 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey,
                  fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              if (chat.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/chat');
          },
        );
      },
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      // Si es de hoy, mostrar la hora
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      // Si fue ayer
      return 'Ayer';
    } else {
      // Si fue otro día, mostrar la fecha
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class _ChatPreview {
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final bool isGroup;
  final int unreadCount;
  
  _ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.isGroup,
    required this.unreadCount,
  });
} 