import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';

/// Widget Shell para el rol Propietario.
///
/// Construye la estructura base de UI para las pantallas del propietario.
class OwnerShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;

  /// Crea una instancia de [OwnerShell].
  const OwnerShell({super.key, required this.child});

  @override
  ConsumerState<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends ConsumerState<OwnerShell> {
  int _selectedIndex = 0;
  bool _isAppBarExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && _isAppBarExpanded) {
      setState(() {
        _isAppBarExpanded = false;
      });
    } else if (_scrollController.offset <= 0 && !_isAppBarExpanded) {
      setState(() {
        _isAppBarExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario actual
    final authState = ref.watch(authStateNotifierProvider);
    final userId = authState.user?.id;
    
    // Si no hay usuario, mostrar un indicador de carga
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Obtener las academias del propietario
    final academiesAsync = ref.watch(ownerAcademiesProvider(userId));
    
    // Obtener la academia actual seleccionada
    final currentAcademyId = ref.watch(currentAcademyIdProvider);

    return Scaffold(
      drawer: _buildDrawer(context),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Arcinus'),
              pinned: true,
              floating: true,
              expandedHeight: _isAppBarExpanded ? 200.0 : kToolbarHeight,
              forceElevated: innerBoxIsScrolled,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Implementar notificaciones
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    context.go('/owner/profile');
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: academiesAsync.when(
                  data: (academies) {
                    if (academies.isEmpty) {
                      return const Center(
                        child: Text('No tienes academias creadas'),
                      );
                    }
                    
                    // Encuentra el índice de la academia actual
                    int initialPage = 0;
                    if (currentAcademyId != null) {
                      final index = academies.indexWhere(
                        (academy) => academy.id == currentAcademyId
                      );
                      if (index >= 0) initialPage = index;
                    }
                    
                    return PageView.builder(
                      itemCount: academies.length,
                      controller: PageController(initialPage: initialPage),
                      onPageChanged: (index) {
                        ref.read(currentAcademyIdProvider.notifier)
                            .state = academies[index].id;
                      },
                      itemBuilder: (context, index) {
                        final academy = academies[index];
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                academy.name,
                                style: const TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: () {
                                      context.go('/owner/academy/${academy.id}/edit');
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.info, color: Colors.white),
                                    onPressed: () {
                                      context.go('/owner/academy/${academy.id}');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ),
          ];
        },
        body: widget.child,
      ),
    );
  }

  // Drawer estándar para pantallas pequeñas
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                context.go('/owner/profile');
              },
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Academia Deportiva',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Propietario',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerNavItems(context),
        ],
      ),
    );
  }

  // Elementos de navegación para ambos drawers
  Widget _buildDrawerNavItems(BuildContext context) {
    // Mapeamos las rutas principales para la selección
    final currentRoute = GoRouterState.of(context).uri.toString();
    _selectedIndex = _getSelectedIndex(currentRoute);

    return Column(
      children: [
        // --- Sección Implementada ---
        ListTile(
          leading: const Icon(Icons.account_balance_rounded),
          title: const Text('Academia'),
          // selected: _selectedIndex == X, // Determinar índice si es necesario
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/academy_details'); // O la ruta raíz de academia
          },
        ),
        ListTile(
          leading: const Icon(Icons.groups_rounded),
          title: const Text('Miembros'),
          selected: _selectedIndex == 1,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 1, '/owner/members');
          },
        ),
        ListTile(
          leading: const Icon(Icons.paid_rounded),
          title: const Text('Pagos'),
          selected: _selectedIndex == 3,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 3, '/owner/payments');
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
          selected: _selectedIndex == 0,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 0, '/owner/dashboard');
          },
          enabled: false, // Deshabilitar temporalmente
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month_rounded),
          title: const Text('Horarios'),
          selected: _selectedIndex == 2,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 2, '/owner/schedule');
          },
           enabled: false, // Deshabilitar temporalmente
        ),
        ListTile(
          leading: const Icon(Icons.insights_rounded),
          title: const Text('Estadísticas'),
          selected: _selectedIndex == 4,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 4, '/owner/stats');
          },
           enabled: false, // Deshabilitar temporalmente
        ),
        ListTile(
          leading: const Icon(Icons.group_work_rounded),
          title: const Text('Grupos/Equipos'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/groups');
          },
           enabled: false, // Deshabilitar temporalmente
        ),
        ListTile(
          leading: const Icon(Icons.fitness_center_rounded),
          title: const Text('Entrenamientos'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/trainings');
          },
           enabled: false, // Deshabilitar temporalmente
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuración'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/settings');
          },
           enabled: false, // Deshabilitar temporalmente
        ),
         ListTile(
          leading: const Icon(Icons.more_horiz),
          title: const Text('Más'),
          selected: _selectedIndex == 5,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 5, '/owner/more');
          },
          enabled: false, // Deshabilitar temporalmente
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar Sesión'),
          onTap: () {
            Navigator.pop(context);
             context.go('/auth/login');
          },
        ),
      ],
    );
  }

  // Función auxiliar para determinar el índice seleccionado basado en la ruta
  int _getSelectedIndex(String currentRoute) {
    if (currentRoute.startsWith('/owner/dashboard')) return 0;
    if (currentRoute.startsWith('/owner/members')) return 1;
    if (currentRoute.startsWith('/owner/schedule')) return 2;
    if (currentRoute.startsWith('/owner/payments')) return 3;
    if (currentRoute.startsWith('/owner/stats')) return 4;
    if (currentRoute.startsWith('/owner/more')) return 5;
    return -1;
  }

  // Navegar a la página seleccionada y actualizar el índice
  void _navigateToPage(BuildContext context, int index, String route) {
    context.go(route);
  }
}