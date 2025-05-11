import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/app_logger.dart';

const String _createNewAcademyValue = '__CREATE_NEW_ACADEMY__';

/// Widget que construye el drawer de navegación para roles de gestión.
class ManagerDrawer extends ConsumerWidget {
  /// El contexto desde donde se llama
  final BuildContext context;
  
  /// El rol del usuario actual
  final AppRole? userRole;

  /// Constructor para ManagerDrawer
  const ManagerDrawer({super.key, required this.context, required this.userRole});

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
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, ref),
          _buildDrawerNavItems(context, ref),
        ],
      ),
    );
  }

  // Header del drawer con información del usuario y selector de academia
  Widget _buildDrawerHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final userId = authState.user?.id;
    final userProfileAsyncValue = userId != null ? ref.watch(userProfileProvider(userId)) : null;
    final academiesAsync = userId != null ? ref.watch(ownerAcademiesProvider(userId)) : null;
    
    // Usar el provider que contiene el objeto completo
    final currentAcademy = ref.watch(currentAcademyProvider);

    return DrawerHeader(
      decoration: BoxDecoration(
        color: userRole == AppRole.propietario 
              ? Theme.of(context).colorScheme.primary
              : Colors.blue, // Diferente color para colaboradores
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              context.go('/manager/profile');
            },
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.person, size: 25),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (userId != null && userProfileAsyncValue != null)
                        userProfileAsyncValue.when(
                          data: (userProfile) => Text(
                            userProfile?.name?.isNotEmpty == true ? userProfile!.name! : (authState.user?.email ?? 'Usuario'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          loading: () => const Text(
                            'Cargando...',
                            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          error: (e, s) => Text(
                            authState.user?.email ?? 'Error al cargar nombre',
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Text(
                          authState.user?.email ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        userRole == AppRole.propietario ? 'Propietario' : 'Colaborador',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (userId != null && academiesAsync != null)
            academiesAsync.when(
              data: (academies) {
                List<DropdownMenuItem<String>> dropdownItems = academies
                    .map<DropdownMenuItem<String>>((AcademyModel academy) {
                  return DropdownMenuItem<String>(
                    value: academy.id,
                    child: Text(academy.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList();

                // Añadir opción para crear nueva academia solo para propietarios
                if (userRole == AppRole.propietario) {
                  dropdownItems.add(
                    const DropdownMenuItem<String>(
                      value: _createNewAcademyValue,
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Crear Nueva Academia'),
                        ],
                      ),
                    ),
                  );
                }

                // Establecer automáticamente la primera academia como valor predeterminado
                if (currentAcademy == null && academies.isNotEmpty) {
                  // Usar Future.microtask para evitar actualizar el estado durante la construcción
                  Future.microtask(() {
                    // Establecer la academia completa
                    ref.read(currentAcademyProvider.notifier).state = academies.first;
                  });
                }

                if (academies.isEmpty) {
                  // Si no hay academias y es propietario, mostrar botón de crear
                  if (userRole == AppRole.propietario) {
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Crear Academia'),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/manager/academy/create');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(60),
                        foregroundColor: Colors.white,
                      ),
                    );
                  } else {
                    // Para colaboradores sin academias
                    return const Center(
                      child: Text(
                        'No tienes academias asignadas',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentAcademy?.id ?? (academies.isNotEmpty ? academies.first.id : null),
                      isExpanded: true,
                      dropdownColor: userRole == AppRole.propietario
                          ? Theme.of(context).colorScheme.primary.withAlpha(240)
                          : Colors.blue.withAlpha(240),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      hint: const Text('Seleccionar Academia', style: TextStyle(color: Colors.white70)),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (newValue == _createNewAcademyValue) {
                            Navigator.pop(context); // Cerrar el drawer
                            context.go('/manager/academy/create');
                          } else {
                            // Buscar la academia completa por ID
                            final selectedAcademy = academies.firstWhere(
                              (academy) => academy.id == newValue,
                              orElse: () => throw Exception('Academia no encontrada: $newValue'),
                            );
                            // Establecer el objeto completo
                            ref.read(currentAcademyProvider.notifier).state = selectedAcademy;
                          }
                        }
                      },
                      items: dropdownItems,
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
              error: (error, stack) => Text('Error: $error', style: const TextStyle(color: Colors.white)),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  // Elementos de navegación
  Widget _buildDrawerNavItems(BuildContext context, WidgetRef ref) {
    // Mapeamos las rutas principales para la selección
    final currentRoute = GoRouterState.of(context).uri.toString();
    
    return Column(
      children: [
        // --- Dashboard ---
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () {
            _navigateTo(context, '/manager/dashboard');
          },
        ),
        
        const Divider(),
        
        // --- Academia ---
        ListTile(
          leading: const Icon(Icons.school),
          title: const Text('Academia'),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
               context.go('/manager/academy/${currentAcademy.id}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Por favor, selecciona o crea una academia primero.')),
              );
            }
          },
        ),
        
        // --- Miembros ---
        ListTile(
          leading: const Icon(Icons.groups),
          title: const Text('Miembros'),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              context.go('/manager/academy/${currentAcademy.id}/members');
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Por favor, selecciona una academia para ver sus miembros.')),
              );
            }
          },
        ),
        
        // --- Pagos ---
        ListTile(
          leading: const Icon(Icons.payments),
          title: const Text('Pagos'),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              context.go('/manager/academy/${currentAcademy.id}/payments');
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Por favor, selecciona una academia para gestionar pagos.')),
              );
            }
          },
        ),
        
        // --- Horarios ---
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Horarios'),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              context.go('/manager/academy/${currentAcademy.id}/schedule');
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Por favor, selecciona una academia para ver horarios.')),
              );
            }
          },
        ),
        
        // --- Estadísticas (solo propietarios) ---
        if (userRole == AppRole.propietario)
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Estadísticas'),
            onTap: () {
              Navigator.pop(context);
              final currentAcademy = ref.read(currentAcademyProvider);
              if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
                context.go('/manager/academy/${currentAcademy.id}/stats');
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Por favor, selecciona una academia para ver estadísticas.')),
                );
              }
            },
          ),
        
        const Divider(),
        
        // --- Perfil ---
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Mi Perfil'),
          onTap: () {
            _navigateTo(context, '/manager/profile');
          },
        ),
        
        // --- Ajustes ---
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuración'),
          onTap: () {
            _navigateTo(context, '/manager/settings');
          },
        ),
        
        // --- Cerrar Sesión ---
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar Sesión'),
          onTap: () {
            _confirmSignOut(context, ref);
          },
        ),
        
        // --- Pie del Drawer ---
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          child: const Text(
            'Arcinus v1.0.0',
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        ),
      ],
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
  
  // Confirmar cierre de sesión
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
              // Cerrar sesión
              ref.read(authStateNotifierProvider.notifier).signOut();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
} 