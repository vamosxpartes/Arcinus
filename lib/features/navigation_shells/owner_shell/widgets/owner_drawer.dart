import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';

const String _createNewAcademyValue = '__CREATE_NEW_ACADEMY__';

/// Widget que construye el drawer de navegación para el propietario.
class OwnerDrawer extends ConsumerWidget {
  const OwnerDrawer({super.key, required BuildContext context});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              context.go('/owner/profile');
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
                      const Text(
                        'Propietario',
                        style: TextStyle(
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

                // Añadir opción para crear nueva academia
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

                // Establecer automáticamente la primera academia como valor predeterminado
                if (currentAcademy == null && academies.isNotEmpty) {
                  // Usar Future.microtask para evitar actualizar el estado durante la construcción
                  Future.microtask(() {
                    // Establecer la academia completa
                    ref.read(currentAcademyProvider.notifier).state = academies.first;
                  });
                }

                if (academies.isEmpty) {
                  // Si no hay academias, solo mostrar el botón de crear (como antes)
                  // o podríamos directamente usar el dropdown con solo la opción de crear.
                  // Por consistencia con el cambio anterior, si está vacío, ofrecemos el botón.
                  // No obstante, el dropdown ahora siempre tendrá al menos la opción de crear.
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Crear Academia'),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/owner/academy/create');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(60),
                      foregroundColor: Colors.white,
                    ),
                  );
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
                      dropdownColor: Theme.of(context).colorScheme.primary.withAlpha(240),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      hint: const Text('Seleccionar Academia', style: TextStyle(color: Colors.white70)),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          if (newValue == _createNewAcademyValue) {
                            Navigator.pop(context); // Cerrar el drawer
                            context.go('/owner/academy/create');
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
    final selectedIndex = _getSelectedIndex(currentRoute);

    return Column(
      children: [
        // --- Sección Implementada ---
        ListTile(
          leading: const Icon(Icons.account_balance_rounded),
          title: const Text('Academia'),
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
               context.go('/owner/academy/${currentAcademy.id}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Por favor, selecciona o crea una academia primero.')),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.groups_rounded),
          title: const Text('Miembros'),
          selected: selectedIndex == 1,
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              _navigateToPage(context, 1, '/owner/academy/${currentAcademy.id}/members');
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Por favor, selecciona una academia para ver sus miembros.')),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.paid_rounded),
          title: const Text('Pagos'),
          selected: selectedIndex == 3,
          onTap: () {
            Navigator.pop(context);
            final currentAcademy = ref.read(currentAcademyProvider);
            if (currentAcademy != null && currentAcademy.id != null && currentAcademy.id!.isNotEmpty) {
              _navigateToPage(context, 3, '/owner/academy/${currentAcademy.id}/payments');
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Por favor, selecciona una academia para gestionar sus pagos.')),
              );
            }
          },
        ),
        const Divider(),

        // --- Sección Por Implementar ---
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Por Implementar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard_rounded),
          title: const Text('Dashboard'),
          selected: selectedIndex == 0,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 0, '/owner/dashboard');
          },
          enabled: false,
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month_rounded),
          title: const Text('Horarios'),
          selected: selectedIndex == 2,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 2, '/owner/schedule');
          },
           enabled: false,
        ),
        ListTile(
          leading: const Icon(Icons.insights_rounded),
          title: const Text('Estadísticas'),
          selected: selectedIndex == 4,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 4, '/owner/stats');
          },
           enabled: false,
        ),
        ListTile(
          leading: const Icon(Icons.group_work_rounded),
          title: const Text('Grupos/Equipos'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/groups');
          },
           enabled: false,
        ),
        ListTile(
          leading: const Icon(Icons.fitness_center_rounded),
          title: const Text('Entrenamientos'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/trainings');
          },
           enabled: false,
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuración'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/settings');
          },
           enabled: false,
        ),
         ListTile(
          leading: const Icon(Icons.more_horiz),
          title: const Text('Más'),
          selected: selectedIndex == 5,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 5, '/owner/more');
          },
          enabled: false,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar Sesión'),
          onTap: () {
            Navigator.pop(context);
            ref.read(authStateNotifierProvider.notifier).signOut();
          },
        ),
      ],
    );
  }

  // Función auxiliar para determinar el índice seleccionado basado en la ruta
  int _getSelectedIndex(String currentRoute) {
    if (currentRoute.startsWith('/owner/dashboard')) return 0;
    if (currentRoute.contains('/members')) return 1;
    if (currentRoute.startsWith('/owner/schedule')) return 2;
    if (currentRoute.contains('/payments')) return 3;
    if (currentRoute.startsWith('/owner/stats')) return 4;
    if (currentRoute.startsWith('/owner/more')) return 5;
    if (currentRoute.contains('/academy/') && !currentRoute.contains('/members') && !currentRoute.contains('/payments')) return -1;
    return -1;
  }

  // Navegar a la página seleccionada y actualizar el índice
  void _navigateToPage(BuildContext context, int index, String route) {
    context.go(route);
  }
} 