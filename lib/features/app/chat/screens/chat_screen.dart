import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      // Aquí implementaremos el envío del mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Envío de mensajes en desarrollo')),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.group),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grupo de Entrenamiento'),
                Text(
                  '5 participantes',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Mostrar información del chat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: _buildMessageList(),
          ),
          
          // Caja de entrada de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    // Simulamos algunos mensajes de ejemplo
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: 10, // Simulado: tendríamos una lista de mensajes real
      itemBuilder: (context, index) {
        // Alternamos mensajes enviados y recibidos para el wireframe
        final isSentByMe = index % 2 == 0;
        
        return _buildMessageBubble(
          message: 'Este es un mensaje de ejemplo #${index + 1}',
          timestamp: DateTime.now().subtract(Duration(minutes: 10 - index)),
          isSentByMe: isSentByMe,
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required DateTime timestamp,
    required bool isSentByMe,
  }) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSentByMe 
              ? theme.colorScheme.primary 
              : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isSentByMe 
                    ? Colors.white 
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isSentByMe 
                    ? Colors.white.withAlpha(200) 
                    : theme.colorScheme.onSecondaryContainer.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            offset: const Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón para adjuntar archivos
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Adjuntar archivos en desarrollo')),
              );
            },
          ),
          
          // Campo de entrada de texto
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          
          // Botón para enviar
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
} 