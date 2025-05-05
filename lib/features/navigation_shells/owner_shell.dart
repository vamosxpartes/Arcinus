import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget Shell para el rol Propietario.
///
/// Construye la estructura base de UI para las pantallas del propietario.
class OwnerShell extends StatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;

  /// Crea una instancia de [OwnerShell].
  const OwnerShell({super.key, required this.child});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _selectedIndex = 0;
  bool _isSearchActive = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: !_isSearchActive ? const Text('Arcinus') : _buildSearchField(),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          // Selector de academia (si el propietario tiene más de una)
          IconButton(
            icon: const Icon(Icons.school_rounded),
            onPressed: () {
              // TODO: Implementar selector de academia
            },
          ),
          // Notificaciones
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
          // Avatar o perfil
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade200,
              child: const Icon(Icons.person),
            ),
          ),
        ],
      ),
      
      // Drawer para navegación en pantallas grandes
      drawer: _buildDrawer(context),
      
      // En pantallas grandes, usamos un layout con el drawer permanente a la izquierda
      body: widget.child,
    );
  }

  // Widget de campo de búsqueda para el AppBar
  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Buscar...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      onSubmitted: (value) {
        // TODO: Implementar búsqueda
        setState(() {
          _isSearchActive = false;
        });
      },
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
        ListTile(
          leading: const Icon(Icons.dashboard_rounded),
          title: const Text('Dashboard'),
          selected: _selectedIndex == 0,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 0, '/owner/dashboard');
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
          leading: const Icon(Icons.calendar_month_rounded),
          title: const Text('Horarios'),
          selected: _selectedIndex == 2,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 2, '/owner/schedule');
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
        ListTile(
          leading: const Icon(Icons.insights_rounded),
          title: const Text('Estadísticas'),
          selected: _selectedIndex == 4,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 4, '/owner/stats');
          },
        ),
        ListTile(
          leading: const Icon(Icons.group_work_rounded),
          title: const Text('Grupos/Equipos'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/groups');
          },
        ),
        ListTile(
          leading: const Icon(Icons.fitness_center_rounded),
          title: const Text('Entrenamientos'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/trainings');
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_rounded),
          title: const Text('Academia'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/academy_details');
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuración'),
          onTap: () {
            Navigator.pop(context);
            context.go('/owner/settings');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar Sesión'),
          onTap: () {
            Navigator.pop(context);
            context.go('/auth');
          },
        ),
        ListTile(
          leading: const Icon(Icons.more_horiz),
          title: const Text('Más'),
          selected: _selectedIndex == 5,
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, 5, '/owner/more');
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