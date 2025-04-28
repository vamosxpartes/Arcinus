import 'package:flutter/material.dart';

/// Un widget reutilizable para mostrar un estado vacío o sin datos,
/// con un icono, mensaje, sugerencia opcional y botón de acción.
class EmptyState extends StatelessWidget {
  /// Crea un widget de estado vacío.
  const EmptyState({
    required this.icon,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
    this.suggestion,
  });

  /// El icono a mostrar.
  final IconData icon;

  /// El mensaje principal que describe el estado vacío.
  final String message;

  /// Etiqueta para el botón de acción.
  final String? actionLabel;

  /// Callback a ejecutar cuando se presiona el botón de acción.
  final VoidCallback? onAction;

  /// Un mensaje secundario opcional con una sugerencia.
  final String? suggestion;

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
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (suggestion != null) ...[
              const SizedBox(height: 8),
              Text(
                suggestion!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
