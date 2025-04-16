import 'package:arcinus/features/app/chat/screens/messages_screen.dart';
import 'package:arcinus/features/app/dashboard/screens/dashboard_screen.dart';
import 'package:arcinus/features/app/groups/screen/group_list_screen.dart';
import 'package:arcinus/features/app/users/user/screens/profile_screen.dart';
import 'package:arcinus/features/navigation/components/custom_navigation_bar.dart';
import 'package:arcinus/features/navigation/components/navigation_items.dart';
import 'package:arcinus/features/navigation/core/models/navigation_item.dart';
import 'package:arcinus/features/navigation/core/providers/navigation_providers.dart';
import 'package:arcinus/features/navigation/core/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentTab = 0;
  
  final Map<int, String> _tabRoutes = {
    0: '/dashboard',
    1: '/calendar',
    2: '/groups',
    3: '/chats',
    4: '/profile',
  };

  void _onTabTapped(int index) {
    final route = _tabRoutes[index] ?? '/dashboard'; 
    setState(() {
      _currentTab = index;
    });
    ref.read(currentRouteProvider.notifier).state = route;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
       navigator.popUntil((route) => route.isFirst);
       WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
               ref.read(currentRouteProvider.notifier).state = route;
           }
       });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String activeRoute = ref.watch(currentRouteProvider);
    final List<NavigationItem> pinnedItems = ref.watch(pinnedItemsProvider);
    final navigationService = ref.read(navigationServiceProvider);
    
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildCustomNavigationBar(activeRoute, pinnedItems, navigationService),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const Center(child: Text('Pantalla Calendario (Pendiente)'));
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

  Widget _buildCustomNavigationBar(String activeRoute, List<NavigationItem> pinnedItems, NavigationService navigationService) {
    return CustomNavigationBar(
      pinnedItems: pinnedItems,
      allItems: NavigationItems.allItems,
      activeRoute: activeRoute,
      onItemTap: (item) {
        final route = item.destination;
        final tabIndex = _tabRoutes.entries.firstWhere(
          (entry) => entry.value == route,
          orElse: () => const MapEntry(-1, ''),
        ).key;

        if (tabIndex != -1) {
          _onTabTapped(tabIndex);
        } else {
          navigationService.navigateToRoute(context, route);
        }
      },
      onItemLongPress: (item) {
        navigationService.togglePinItem(item, context: context);
      },
      onAddButtonTap: () {
        _handleAddButtonTap(activeRoute, navigationService);
      },
    );
  }
  
  void _handleAddButtonTap(String activeRoute, NavigationService navigationService) {
    switch (activeRoute) {
      case '/trainings':
        Navigator.pushNamed(context, '/trainings/new');
        break;
      case '/users-management':
        _showAddUserDialog();
        break;
      case '/academies':
        Navigator.pushNamed(context, '/create-academy');
        break;
      default:
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
} 