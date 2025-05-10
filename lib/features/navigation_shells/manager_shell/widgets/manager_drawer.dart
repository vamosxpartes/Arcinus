import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';

/// Drawer para la navegación en el shell de gestión (propietarios y colaboradores)
class ManagerDrawer extends ConsumerWidget {
  /// Contexto de la aplicación
  final BuildContext context;
  
  /// Rol del usuario actual
  final AppRole? userRole;

  /// Crea una instancia de [ManagerDrawer].
  const ManagerDrawer({
    required this.context,
    required this.userRole,
    super.key,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verificar que el rol es de gestión
    final isManager = userRole == AppRole.propietario || userRole == AppRole.colaborador;
    if (!isManager) {
      AppLogger.logWarning(
        'Usuario no gestor intentando acceder a ManagerDrawer',
        className: 'ManagerDrawer',
        functionName: 'build',
        params: {'role': userRole?.name ?? 'desconocido'},
      );
      return const Drawer(
        child: Center(child: Text('Acceso no autorizado')),
      );
    }
    
    // Información del usuario actual
    final user = ref.watch(authStateNotifierProvider).user;
    final name = user?.name ?? 'Usuario';
    final email = user?.email ?? '';
    
    // Obtener la academia actual
    final currentAcademy = ref.watch(currentAcademyProvider);
    final academyName = currentAcademy?.name;
    final academyId = currentAcademy?.id;
    
    return Drawer(
      child: Column(
        children: [
          // Cabecera del drawer
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
            // Mostrar nombre de academia si hay una seleccionada
            otherAccountsPictures: academyName != null
                ? [
                    Tooltip(
                      message: academyName,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: const Icon(Icons.school, size: 18),
                      ),
                    ),
                  ]
                : null,
            // Color diferente según el rol
            decoration: BoxDecoration(
              color: userRole == AppRole.propietario ? Colors.indigo : Colors.blue,
            ),
          ),
          
          // Lista de opciones de navegación
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Dashboard
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () {
                    _navigateTo(context, '/manager/dashboard');
                  },
                ),
                
                const Divider(),
                
                // Academia seleccionada
                if (academyId != null && academyName != null)
                  ExpansionTile(
                    leading: const Icon(Icons.school),
                    title: Text('Academia: $academyName'),
                    children: [
                      // Detalles de academia
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Detalles'),
                        onTap: () {
                          _navigateTo(context, '/manager/academy/$academyId');
                        },
                      ),
                      // Editar academia (solo propietarios)
                      if (userRole == AppRole.propietario)
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Editar Academia'),
                          onTap: () {
                            _navigateTo(context, '/manager/academy/$academyId/edit');
                          },
                        ),
                      // Miembros
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Miembros'),
                        onTap: () {
                          _navigateTo(context, '/manager/academy/$academyId/members');
                        },
                      ),
                      // Pagos
                      ListTile(
                        leading: const Icon(Icons.payments),
                        title: const Text('Pagos'),
                        onTap: () {
                          _navigateTo(context, '/manager/academy/$academyId/payments');
                        },
                      ),
                    ],
                  ),
                
                const Divider(),
                
                // Sección Funciones Principales
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('GESTIÓN', style: TextStyle(color: Colors.grey)),
                ),
                
                // Miembros
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Miembros'),
                  onTap: () {
                    _navigateTo(context, '/manager/members');
                  },
                ),
                
                // Pagos
                ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text('Pagos'),
                  onTap: () {
                    _navigateTo(context, '/manager/payments');
                  },
                ),
                
                // Horarios
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Horarios'),
                  onTap: () {
                    _navigateTo(context, '/manager/schedule');
                  },
                ),
                
                // Estadísticas (solo propietarios o colaboradores con permiso)
                if (userRole == AppRole.propietario) // Expandir para añadir permiso de colaboradores
                  ListTile(
                    leading: const Icon(Icons.bar_chart),
                    title: const Text('Estadísticas'),
                    onTap: () {
                      _navigateTo(context, '/manager/stats');
                    },
                  ),
                
                const Divider(),
                
                // Sección Configuración
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('AJUSTES', style: TextStyle(color: Colors.grey)),
                ),
                
                // Perfil
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mi Perfil'),
                  onTap: () {
                    _navigateTo(context, '/manager/profile');
                  },
                ),
                
                // Configuración
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  onTap: () {
                    _navigateTo(context, '/manager/settings');
                  },
                ),
                
                // Cerrar sesión
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar Sesión'),
                  onTap: () {
                    _confirmSignOut(context, ref);
                  },
                ),
              ],
            ),
          ),
          
          // Pie de drawer con información de versión
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            child: const Text(
              'Arcinus v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
  
  // Navegación con cierre de drawer
  void _navigateTo(BuildContext context, String route) {
    // Cerrar el drawer primero
    Navigator.pop(context);
    // Luego navegar
    context.go(route);
    
    AppLogger.logInfo(
      'Navegando desde drawer',
      className: 'ManagerDrawer',
      functionName: '_navigateTo',
      params: {'route': route},
    );
  }
  
  // Diálogo de confirmación para cerrar sesión
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
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
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar drawer
              
              // Ejecutar cierre de sesión
              ref.read(authStateNotifierProvider.notifier).signOut().then((_) {
                AppLogger.logInfo(
                  'Sesión cerrada exitosamente',
                  className: 'ManagerDrawer',
                  functionName: '_confirmSignOut',
                );
              }).catchError((error) {
                AppLogger.logError(
                  message: 'Error al cerrar sesión',
                  error: error,
                  className: 'ManagerDrawer',
                  functionName: '_confirmSignOut',
                );
                
                // Mostrar mensaje de error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al cerrar sesión')),
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