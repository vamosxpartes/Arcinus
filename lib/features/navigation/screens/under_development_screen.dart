import 'package:flutter/material.dart';

// Pantalla para secciones en desarrollo
class UnderDevelopmentScreen extends StatelessWidget {
  final String title;
  
  const UnderDevelopmentScreen({
    super.key,
    required this.title,
  });

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
                'En desarrollo',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'La funcionalidad "$title" se encuentra actualmente en desarrollo. ¡Vuelve pronto!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                   // Intentar hacer pop, si no es posible, no hacer nada (evita errores si es la primera pantalla)
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 