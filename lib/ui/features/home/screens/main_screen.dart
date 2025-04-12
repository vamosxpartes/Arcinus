import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/shared/navigation/navigation_service.dart';
import 'package:arcinus/ui/features/auth/screens/profile_screen.dart';
import 'package:arcinus/ui/features/calendar/screens/calendar_screen.dart';
import 'package:arcinus/ui/features/dashboard/screens/dashboard_screen.dart';
import 'package:arcinus/ui/features/groups/screens/group_list_screen.dart';
import 'package:arcinus/ui/features/messages/screens/messages_screen.dart';
import 'package:arcinus/ui/shared/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentTab = 0;
  // Instancia del servicio de navegación
  final NavigationService _navigationService = NavigationService();
  
  void _onTabTapped(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildCustomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const CalendarScreen();
      case 2:
        return const GroupListScreen();
      case 3:
        return const MessagesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  Widget _buildCustomNavigationBar() {
    return CustomNavigationBar(
      pinnedItems: _navigationService.pinnedItems,
      allItems: NavigationItems.allItems,
      activeRoute: _getActiveRoute(),
      onItemTap: (item) {
        // Resolver la navegación basada en el índice de tab
        final route = item.destination;
        switch (route) {
          case '/dashboard':
            // Simplemente cambiar al tab de dashboard en lugar de crear una nueva instancia
            _onTabTapped(0);
            // Si ya estamos en alguna ruta dentro de la aplicación, regresamos a la raíz
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              // No usamos pushReplacementNamed para evitar crear una nueva instancia
            }
            break;
          case '/calendar':
            _onTabTapped(1);
            break;
          case '/groups':
            _onTabTapped(2);
            break;
          case '/chats':
            _onTabTapped(3);
            break;
          case '/profile':
            _onTabTapped(4);
            break;
          default:
            // Para otras rutas, navegar directamente
            _navigationService.navigateToRoute(context, route);
        }
      },
      onItemLongPress: (item) {
        if (_navigationService.togglePinItem(item, context: context)) {
          setState(() {
            // Actualizar la UI para reflejar cambios en elementos fijados
          });
        }
      },
      onAddButtonTap: () {
        _handleAddButtonTap();
      },
    );
  }
  
  void _handleAddButtonTap() {
    final String activeRoute = _getActiveRoute();
    
    switch (activeRoute) {
      case '/trainings':
        Navigator.pushNamed(context, '/trainings/new');
        break;
      case '/users-management':
        // Aquí podrías mostrar un diálogo para elegir qué tipo de usuario crear
        _showAddUserDialog();
        break;
      case '/academies':
        Navigator.pushNamed(context, '/create-academy');
        break;
      default:
        // Por defecto no hacer nada o mostrar un mensaje
        break;
    }
  }
  
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Atleta'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/athlete/new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports),
              title: const Text('Entrenador'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/coach/new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manager/new');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
  
  // Determinar la ruta activa basada en el tab actual
  String _getActiveRoute() {
    switch (_currentTab) {
      case 0:
        return '/dashboard';
      case 1:
        return '/calendar';
      case 2:
        return '/groups';
      case 3:
        return '/chats';
      case 4:
        return '/profile';
      default:
        return '/dashboard';
    }
  }
} 