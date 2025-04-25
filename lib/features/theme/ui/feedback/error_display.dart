import 'package:flutter/material.dart';

/// Un widget reutilizable para mostrar un mensaje de error con un icono
/// y un botón opcional para reintentar una acción.
class ErrorDisplay extends StatelessWidget {
  /// Crea un widget de visualización de error.
  const ErrorDisplay({
    required this.error, 
    super.key,
    this.onRetry,
  });

  /// El mensaje de error específico a mostrar.
  final String error;
  /// Callback opcional a ejecutar cuando se presiona el botón "Reintentar".
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error, 
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un error',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface, 
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant, 
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error, 
                  foregroundColor: colorScheme.onError, 
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, 
                    vertical: 12,
                    ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
