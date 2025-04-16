import 'package:flutter/material.dart';

// Pantalla de notificaciones (Ejemplo)
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 15, // Notificaciones de ejemplo
          itemBuilder: (context, index) {
            // Alternamos tipos de notificaciones para el ejemplo
            final notificationType = index % 4;
            IconData icon;
            Color color;
            String title;
            String time = '${index + 1}h';
            
            switch (notificationType) {
              case 0:
                icon = Icons.calendar_today;
                color = Colors.blue;
                title = 'Nueva clase programada';
                break;
              case 1:
                icon = Icons.person_add;
                color = Colors.green;
                title = 'Nuevo usuario registrado';
                break;
              case 2:
                icon = Icons.money;
                color = Colors.orange;
                title = 'Pago registrado';
                break;
              default:
                icon = Icons.announcement;
                color = Colors.red;
                title = 'Anuncio importante';
            }
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withAlpha(60),
                  child: Icon(icon, color: color),
                ),
                title: Text(title),
                subtitle: Text('Detalles de la notificación ${index + 1}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hace $time',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    if (index < 5)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // Acción al pulsar en la notificación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Abrir notificación $index')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
} 