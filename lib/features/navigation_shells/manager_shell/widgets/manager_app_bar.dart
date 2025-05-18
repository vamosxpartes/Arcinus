import 'package:flutter/material.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Un AppBar reutilizable para las pantallas de gestión (ManagerShell).
///
/// Ofrece una apariencia consistente y permite personalizar el color de fondo
/// y las acciones.
class ManagerAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// El título que se mostrará en el AppBar.
  final String title;
  
  /// El color de fondo del AppBar.
  final Color backgroundColor;
  
  /// Lista opcional de widgets para mostrar como acciones en el AppBar.
  /// Si es null, se usarán las acciones predeterminadas (notificaciones, mensajes).
  final List<Widget>? actions;

  final Color? iconColor; // Color para el ícono del drawer y acciones
  final Color? titleColor; // Color explícito para el título

  /// Crea una instancia de [ManagerAppBar].
  const ManagerAppBar({
    super.key,
    required this.title,
    this.backgroundColor = AppTheme.blackSwarm, // Color por defecto
    this.actions,
    this.iconColor = AppTheme.magnoliaWhite, // Default a blanco
    this.titleColor = AppTheme.magnoliaWhite, // Default a blanco
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.logInfo(
      'Construyendo ManagerAppBar',
      className: 'ManagerAppBar',
      functionName: 'build',
      params: {
        'title': title,
        'backgroundColor': backgroundColor.toString(),
        'customActions': actions != null ? 'presentes' : 'usando default',
        'iconColor': iconColor.toString(),
        'titleColor': titleColor.toString(),
      },
    );

    final defaultActions = [
      IconButton(
        icon: const Icon(Icons.notifications_none_outlined, size: 22),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Próximamente: Notificaciones')),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.message_outlined, size: 22), // Icono de mensajes
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Próximamente: Mensajes')),
          );
        },
      ),
    ];

    // Determinar el tema de íconos basado en iconColor
    final effectiveIconTheme = IconThemeData(color: iconColor, size: 22);

    return AppBar(
      // Usar iconTheme para el ícono del drawer (leading)
      iconTheme: effectiveIconTheme,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.25,
          color: titleColor, // Usar titleColor
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      elevation: 0,
      // Usar actionsIconTheme para los íconos de las acciones
      actionsIconTheme: effectiveIconTheme,
      actions: actions ?? defaultActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 