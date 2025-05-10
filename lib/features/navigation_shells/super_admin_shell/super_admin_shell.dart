import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para manejar el título de la pantalla actual
final superAdminScreenTitleProvider = StateProvider<String>((ref) => 'Arcinus Admin');

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
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: Colors.deepPurple, // Color distintivo para superadmin
        actions: [
          // Badge para mostrar el rol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: const Text(
                'SuperAdmin',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: Colors.deepPurple.withOpacity(0.7),
              visualDensity: VisualDensity.compact,
            ),
          ),
          // Menú de opciones
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logs',
                child: Text('Ver logs'),
              ),
              const PopupMenuItem<String>(
                value: 'users',
                child: Text('Gestionar usuarios'),
              ),
              const PopupMenuItem<String>(
                value: 'academies',
                child: Text('Gestionar academias'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Configuración'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: _buildAdminDrawer(context),
      ),
      body: widget.child,
    );
  }
  
  // Construir el drawer de administrador
  Widget _buildAdminDrawer(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: Icon(Icons.admin_panel_settings, color: Colors.deepPurple, size: 30),
              ),
              const SizedBox(height: 10),
              const Text(
                'Panel de Administración',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                ref.read(authStateNotifierProvider).user?.email ?? 'Admin',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.pop(context); // Cerrar drawer
            // TODO: Implementar navegación
          },
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('GESTIÓN', style: TextStyle(color: Colors.grey)),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Usuarios'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Implementar navegación
          },
        ),
        ListTile(
          leading: const Icon(Icons.school),
          title: const Text('Academias'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Implementar navegación
          },
        ),
        ListTile(
          leading: const Icon(Icons.data_usage),
          title: const Text('Métricas'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Implementar navegación
          },
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('SISTEMA', style: TextStyle(color: Colors.grey)),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuración'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Implementar navegación
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar Sesión'),
          onTap: () {
            Navigator.pop(context);
            _confirmSignOut(context);
          },
        ),
      ],
    );
  }
  
  // Manejar selección de opciones del menú
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'logs':
        AppLogger.logInfo(
          'Navegando a logs',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación a logs
        break;
      case 'users':
        AppLogger.logInfo(
          'Navegando a gestión de usuarios',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación a gestión de usuarios
        break;
      case 'academies':
        AppLogger.logInfo(
          'Navegando a gestión de academias',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación a gestión de academias
        break;
      case 'settings':
        AppLogger.logInfo(
          'Navegando a configuración',
          className: 'SuperAdminShell',
          functionName: '_handleMenuSelection',
        );
        // TODO: Implementar navegación a configuración
        break;
      case 'signout':
        _confirmSignOut(context);
        break;
    }
  }
  
  // Diálogo de confirmación para cerrar sesión
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