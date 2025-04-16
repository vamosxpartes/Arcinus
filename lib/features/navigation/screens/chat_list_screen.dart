import 'package:flutter/material.dart';

// Pantalla de lista de chats (Ejemplo)
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 10,  // Chats de ejemplo
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text('Chat ${index + 1}'),
              subtitle: Text(index % 2 == 0 
                  ? 'Último mensaje recibido' 
                  : 'Tú: Último mensaje enviado'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '12:${index * 5}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  if (index % 3 == 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                // Navegación a chat individual
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat individual en desarrollo')),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Crear nuevo chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear chat en desarrollo')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 