import 'package:flutter/material.dart';

/// Pantalla que indica que la funcionalidad está en desarrollo.
class UnderDevelopmentScreen extends StatelessWidget {

  /// Crea una pantalla de desarrollo con el [title] proporcionado.
  const UnderDevelopmentScreen({
    required this.title, super.key,
  });
  /// El título principal que se muestra en la pantalla.
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Esta funcionalidad se encuentra actualmente ' 
                  'en desarrollo. ¡Vuelve pronto!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
