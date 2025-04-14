import 'package:arcinus/features/app/chat/screens/messages_screen.dart';
import 'package:arcinus/features/app/dashboard/screens/dashboard_screen.dart';
import 'package:arcinus/features/app/groups/screen/group_list_screen.dart';
import 'package:arcinus/features/app/users/user/screens/profile_screen.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: _buildBody(),
      onAddButtonTap: () {
        _handleAddButtonTap();
      },
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ProfileScreen();
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