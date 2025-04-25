import 'package:flutter/material.dart';

/// {@template loading_overlay}
/// Un widget que muestra una superposición de carga sobre 
/// su widget hijo [child] cuando [isLoading] es verdadero.
/// {@endtemplate}
class LoadingOverlay extends StatelessWidget {
  /// {@macro loading_overlay}
  const LoadingOverlay({
    required this.child,
    required this.isLoading,
    super.key,
    this.overlayColor,
    this.progressColor,
    this.message,
  });

  /// El widget hijo sobre el cual se mostrará la superposición.
  final Widget child;
  
  /// Indica si la superposición de carga está activa.
  final bool isLoading;
  
  /// El color de la superposición. 
  /// Si es nulo, usa `colorScheme.scrim.withAlpha(125)`.
  final Color? overlayColor;
  
  /// El color del indicador de progreso. 
  /// Si es nulo, usa `colorScheme.primary`.
  final Color? progressColor;
  
  /// El mensaje opcional a mostrar debajo del indicador de progreso.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: overlayColor ?? colorScheme.scrim.withAlpha(125),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressColor ?? colorScheme.primary,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary, 
                        // Assuming background is dark
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
} 
