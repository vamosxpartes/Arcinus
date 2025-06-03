import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcinus/core/navigation/routes/super_admin_routes.dart';

/// Provider para manejar el título de la pantalla actual
final superAdminScreenTitleProvider = StateProvider<String>((ref) => 'Panel de SuperAdmin');

/// Widget Shell para el rol SuperAdmin.
///
/// Construye la estructura base de UI para las pantallas del superadmin.
class SuperAdminShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;
  
  /// Título opcional para la pantalla
  final String? screenTitle;

  /// Crea una instancia de [SuperAdminShell].
  const SuperAdminShell({
    super.key, 
    required this.child,
    this.screenTitle,
  });

  @override
  ConsumerState<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends ConsumerState<SuperAdminShell> {
  @override
  void didUpdateWidget(SuperAdminShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el título cuando cambia el widget
    if (widget.screenTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(superAdminScreenTitleProvider.notifier).state = widget.screenTitle!;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtener el usuario actual
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.user;
    final userId = user?.id;
    final userRole = user?.role;

    // Si no hay usuario, mostrar un indicador de carga
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Verificar que el usuario es un superadmin
    if (userRole != AppRole.superAdmin) {
      AppLogger.logWarning(
        'Usuario con rol no autorizado intentando acceder a SuperAdminShell',
        className: 'SuperAdminShell',
        functionName: 'build',
        params: {
          'userId': userId,
          'role': userRole?.name ?? 'null',
        },
      );
      // Mostramos un mensaje de error en lugar de crashear
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso no autorizado'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text('No tienes permisos para acceder a esta sección'),
        ),
      );
    }
    
    // Obtener el título actual de la pantalla
    final String screenTitle = widget.screenTitle ?? ref.watch(superAdminScreenTitleProvider);
    
    return Scaffold(
      appBar: _buildSuperAdminAppBar(context, screenTitle),
      drawer: _buildSuperAdminDrawer(context),
      body: widget.child,
    );
  }
  
  /// Construir el AppBar específico del SuperAdmin
  PreferredSizeWidget _buildSuperAdminAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepPurple.shade700,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        // Badge para mostrar el rol
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 16,
                color: Colors.white.withAlpha(220),
              ),
              const SizedBox(width: 4),
              Text(
                'SuperAdmin',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(220),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Botón de notificaciones
        IconButton(
          onPressed: _showNotifications,
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Menú de opciones
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'system_status',
              child: ListTile(
                leading: Icon(Icons.monitor_heart_outlined),
                title: Text('Estado del Sistema'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'analytics',
              child: ListTile(
                leading: Icon(Icons.analytics_outlined),
                title: Text('Analytics Globales'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logs',
              child: ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text('Logs del Sistema'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Configuración'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'signout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Construir el drawer específico del SuperAdmin
  Widget _buildSuperAdminDrawer(BuildContext context) {
    final user = ref.read(authStateNotifierProvider).user;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del drawer
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade600,
                  Colors.deepPurple.shade800,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Panel de SuperAdmin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'admin@arcinus.com',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Dashboard
          _buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () => _navigateTo(context, SuperAdminRoutes.root),
          ),
          
          const Divider(),
          
          // Sección de Gestión
          _buildDrawerSection('GESTIÓN'),
          
          _buildDrawerItem(
            context,
            icon: Icons.person_outline,
            title: 'Propietarios',
            subtitle: 'Gestión y aprobación',
            onTap: () => _navigateTo(context, SuperAdminRoutes.owners),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.school_outlined,
            title: 'Academias',
            subtitle: 'Administración global',
            onTap: () => _navigateTo(context, SuperAdminRoutes.academies),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.subscriptions_outlined,
            title: 'Suscripciones',
            subtitle: 'Planes y facturación',
            onTap: () => _navigateTo(context, SuperAdminRoutes.subscriptions),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.sports_outlined,
            title: 'Deportes Globales',
            subtitle: 'Configuración deportiva',
            onTap: () => _navigateTo(context, SuperAdminRoutes.sports),
          ),
          
          const Divider(),
          
          // Sección del Sistema
          _buildDrawerSection('SISTEMA'),
          
          _buildDrawerItem(
            context,
            icon: Icons.backup_outlined,
            title: 'Respaldos',
            subtitle: 'Sistema de backups',
            onTap: () => _navigateTo(context, SuperAdminRoutes.systemBackups),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.security_outlined,
            title: 'Seguridad',
            subtitle: 'Auditoría y logs',
            onTap: () => _navigateTo(context, SuperAdminRoutes.security),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.analytics_outlined,
            title: 'Analytics',
            subtitle: 'Métricas de uso',
            onTap: () => _navigateTo(context, SuperAdminRoutes.analytics),
          ),
          
          const Divider(),
          
          // Configuración y salida
          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Configuración',
            onTap: () => _navigateTo(context, SuperAdminRoutes.settings),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _confirmSignOut(context);
            },
          ),
        ],
      ),
    );
  }
  
  /// Construir una sección del drawer
  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  /// Construir un item del drawer
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            )
          : null,
      onTap: onTap,
      dense: subtitle != null,
    );
  }
  
  /// Navegar a una ruta específica
  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Cerrar drawer
    context.go(route);
    
    AppLogger.logInfo(
      'Navegando desde SuperAdmin Shell',
      className: 'SuperAdminShell',
      functionName: '_navigateTo',
      params: {'route': route},
    );
  }
  
  /// Mostrar notificaciones
  void _showNotifications() {
    AppLogger.logInfo(
      'Mostrando notificaciones del SuperAdmin',
      className: 'SuperAdminShell',
      functionName: '_showNotifications',
    );
    // TODO: Implementar panel de notificaciones
  }
  
  /// Manejar selección de opciones del menú
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'system_status':
        AppLogger.logInfo(
          'Navegando a estado del sistema',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación
        break;
      case 'analytics':
        AppLogger.logInfo(
          'Navegando a analytics globales',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación
        break;
      case 'logs':
        AppLogger.logInfo(
          'Navegando a logs del sistema',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación
        break;
      case 'settings':
        AppLogger.logInfo(
          'Navegando a configuración',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación
        break;
      case 'signout':
        _confirmSignOut(context);
        break;
    }
  }
  
  /// Diálogo de confirmación para cerrar sesión
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Ejecutar cierre de sesión
              ref.read(authStateNotifierProvider.notifier).signOut().then((_) {
                AppLogger.logInfo(
                  'Sesión cerrada exitosamente',
                  className: 'SuperAdminShell',
                  functionName: '_confirmSignOut',
                );
              }).catchError((error) {
                AppLogger.logError(
                  message: 'Error al cerrar sesión',
                  error: error,
                  className: 'SuperAdminShell',
                  functionName: '_confirmSignOut',
                );
              });
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
} 