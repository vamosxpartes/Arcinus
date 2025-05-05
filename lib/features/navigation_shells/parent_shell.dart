import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget Shell para el rol Padre/Responsable.
///
/// Construye la estructura base de UI para las pantallas del padre/responsable.
class ParentShell extends StatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;

  /// Crea una instancia de [ParentShell].
  const ParentShell({super.key, required this.child});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int _selectedIndex = 0;
  bool _isSearchActive = false;

  // Lista de íconos para el bottom navigation (para pantallas pequeñas)
  final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: '/parent/dashboard',
    ),
    BottomNavItem(
      icon: Icons.sports_rounded,
      label: 'Atletas',
      route: '/parent/athletes',
    ),
    BottomNavItem(
      icon: Icons.calendar_month_rounded,
      label: 'Horarios',
      route: '/parent/schedule',
    ),
    BottomNavItem(
      icon: Icons.paid_rounded,
      label: 'Pagos',
      route: '/parent/payments',
    ),
    BottomNavItem(
      icon: Icons.more_horiz,
      label: 'Más',
      route: '/parent/more',
    ),
  ];

  // Determinar si estamos en una pantalla grande o pequeña
  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: !_isSearchActive ? const Text('Arcinus - Familiar') : _buildSearchField(),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
              });
            },
          ),
          // Selector de atleta (si el padre tiene varios hijos registrados)
          IconButton(
            icon: const Icon(Icons.family_restroom),
            onPressed: () {
            },
          ),
          // Notificaciones
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
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
      drawer: isLargeScreen ? null : _buildDrawer(context),
      
      // En pantallas grandes, usamos un layout con el drawer permanente a la izquierda
      body: isLargeScreen
          ? Row(
              children: [
                _buildPermanentDrawer(context),
                Expanded(child: widget.child),
              ],
            )
          : widget.child,
      
      // Bottom Navigation para pantallas pequeñas
      bottomNavigationBar: isLargeScreen ? null : _buildBottomNavBar(context),
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
                  'Nombre del Padre/Responsable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Responsable de 2 atletas',
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

  // Panel lateral permanente para pantallas grandes
  Widget _buildPermanentDrawer(BuildContext context) {
    return Container(
      width: 240,
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 130,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person, size: 24),
                ),
                SizedBox(height: 10),
                Text(
                  'Nombre del Padre/Responsable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Responsable de 2 atletas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard_rounded),
          title: const Text('Dashboard'),
          selected: _selectedIndex == 0,
          onTap: () => _navigateToPage(context, 0, '/parent/dashboard'),
        ),
        ListTile(
          leading: const Icon(Icons.sports_rounded),
          title: const Text('Mis Atletas'),
          selected: _selectedIndex == 1,
          onTap: () => _navigateToPage(context, 1, '/parent/athletes'),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month_rounded),
          title: const Text('Horarios'),
          selected: _selectedIndex == 2,
          onTap: () => _navigateToPage(context, 2, '/parent/schedule'),
        ),
        ListTile(
          leading: const Icon(Icons.paid_rounded),
          title: const Text('Pagos'),
          selected: _selectedIndex == 3,
          onTap: () => _navigateToPage(context, 3, '/parent/payments'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.messenger_outline),
          title: const Text('Mensajes'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.fitness_center_rounded),
          title: const Text('Entrenamientos'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.star_rounded),
          title: const Text('Evaluaciones'),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person_rounded),
          title: const Text('Mi Perfil'),
          onTap: () => _navigateToPage(context, -1, '/parent/profile'),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configuración'),
          onTap: () {},
        ),
      ],
    );
  }

  // Bottom Navigation Bar para pantallas pequeñas
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Para más de 3 ítems
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      showUnselectedLabels: true,
      items: _bottomNavItems.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
      onTap: (index) {
        if (index != _selectedIndex) {
          _navigateToPage(context, index, _bottomNavItems[index].route);
        }
      },
    );
  }

  // Navegar a la página seleccionada
  void _navigateToPage(BuildContext context, int index, String route) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(route);
  }
}

/// Clase para representar un ítem del Bottom Navigation
class BottomNavItem {
  final IconData icon;
  final String label;
  final String route;

  BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
} 