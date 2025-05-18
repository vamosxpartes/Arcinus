import 'package:flutter/material.dart';

/// {@template loading_indicator}
/// Un widget que muestra un indicador de progreso circular
/// con un mensaje opcional debajo.
/// {@endtemplate}
class LoadingIndicator extends StatelessWidget {
  /// {@macro loading_indicator}
  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 48.0,
    this.message,
  });

  /// El color del indicador de progreso circular.
  /// Si es nulo, utiliza el color primario del tema.
  final Color? color;

  /// El tamaño (alto y ancho) del indicador de progreso.
  final double size;

  /// El mensaje opcional a mostrar debajo del indicador.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
