import 'package:flutter/material.dart';

/// Widget que muestra una tarjeta con invitación para crear una academia
class CreateAcademyCard extends StatelessWidget {
  /// Callback que se ejecuta cuando se presiona el botón para crear academia
  final VoidCallback onCreateAcademy;

  /// Constructor que requiere la callback
  const CreateAcademyCard({
    super.key,
    required this.onCreateAcademy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Comenzamos!',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Para empezar a utilizar todas las funcionalidades, necesitas crear tu academia.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onCreateAcademy,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Crear mi academia'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nota: Como propietario, debes crear una academia para gestionar entrenadores, atletas y más.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 