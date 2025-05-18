import 'package:flutter/material.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

/// Una pantalla genérica para indicar que una sección está en desarrollo.
class ScreenUnderDevelopment extends StatelessWidget {
  /// El título a mostrar en la AppBar (opcional).
  final String? title;
  
  /// El mensaje personalizado a mostrar.
  final String message;
  
  /// Icono opcional para personalizar la pantalla.
  final IconData icon;
  
  /// Color primario para personalizar la pantalla.
  final Color? primaryColor;
  
  /// Descripción adicional opcional.
  final String? description;
  
  /// Si se debe mostrar un botón de regreso.
  final bool showBackButton;
  
  /// Si se debe mostrar un AppBar.
  final bool showAppBar;

  /// Crea una instancia de [ScreenUnderDevelopment].
  const ScreenUnderDevelopment({
    this.title,
    required this.message,
    this.icon = Icons.construction,
    this.primaryColor,
    this.description,
    this.showBackButton = true,
    this.showAppBar = true,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? AppTheme.blackSwarm;
    
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: Text(title ?? 'Próximamente'),
        automaticallyImplyLeading: showBackButton,
      ) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppTheme.blackSwarm.withAlpha(15),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono principal
                Icon(
                  icon,
                  size: 80,
                  color: color,
                ),
                const SizedBox(height: 24),
                
                // Mensaje principal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Descripción secundaria
                if (description != null)
                  Text(
                    description!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                
                const SizedBox(height: 32),
                
                // Mensaje de desarrollo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.engineering, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Esta sección está en desarrollo',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Botón de retorno opcional
                if (showBackButton && !showAppBar)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
