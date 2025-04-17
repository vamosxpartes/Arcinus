import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/groups/screen/group_tab.dart';
import 'package:arcinus/features/app/users/athlete/components/athlete_tab.dart';
import 'package:arcinus/features/app/users/athlete/core/services/athlete_providers.dart';
import 'package:arcinus/features/app/users/coach/components/coach_tab.dart';
import 'package:arcinus/features/app/users/coach/core/services/coach_providers.dart';
import 'package:arcinus/features/app/users/manager/components/manager_tab.dart';
import 'package:arcinus/features/app/users/manager/core/services/manager_providers.dart';
import 'package:arcinus/features/app/users/owner/components/owner_tab.dart';
import 'package:arcinus/features/app/users/parent/components/parent_tab.dart';
import 'package:arcinus/features/app/users/parent/core/services/parent_providers.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/models/user_form_container.dart';
import 'package:arcinus/features/app/users/user/core/services/user_management_provider.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/navigation/components/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Verificar si el usuario es superAdmin para determinar el número de tabs
    final user = ref.read(authStateProvider).valueOrNull;
    final isSuperAdmin = user?.role == UserRole.superAdmin;
    
    // Tabs: Managers, Coaches, Atletas, Grupos, Padres, (Owners solo para superAdmin)
    _tabController = TabController(
      length: isSuperAdmin ? 6 : 5, 
      vsync: this
    );
    
    // Escuchar cambios en las pestañas para actualizar el provider
    _tabController.addListener(() {
      // Solo actualizamos cuando el cambio de tab es por interacción del usuario
      if (!_tabController.indexIsChanging) {
        ref.read(userManagementProvider.notifier).setCurrentTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isSuperAdmin = user?.role == UserRole.superAdmin;
    final userManagementState = ref.watch(userManagementProvider);
    
    return AuthScaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Managers'),
            const Tab(text: 'Entrenadores'),
            const Tab(text: 'Atletas'),
            const Tab(text: 'Grupos'),
            const Tab(text: 'Padres'),
            if (isSuperAdmin) const Tab(text: 'Owners'),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                // Tab de Managers
                ManagerTab(searchController: _searchController),
                
                // Tab de Coaches
                CoachTab(searchController: _searchController),
                
                // Tab de Atletas
                AthleteTab(searchController: _searchController),
                
                // Tab de Grupos
                GroupTab(searchController: _searchController),
                
                // Tab de Padres
                ParentTab(searchController: _searchController),
                
                // Tab de Owners (condicional)
                if (isSuperAdmin) OwnerTab(searchController: _searchController),
              ],
            ),
            
            // Formulario de pre-registro deslizable
            if (userManagementState.showInviteForm)
              UserFormContainer(
                canManageAllUsers: user?.role == UserRole.owner || user?.role == UserRole.manager,
                onCancel: () => ref.read(userManagementProvider.notifier).toggleInviteForm(),
                onSubmit: (UserRole role) {
                  // Cerrar el formulario y mostrar mensaje de éxito
                  ref.read(userManagementProvider.notifier).toggleInviteForm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pre-registro creado correctamente')),
                  );
                  
                  // Refrescar datos según el rol
                  _refreshDataByRole(role);
                },
              ),
          ],
        ),
      ),
      onAddButtonTap: () {
        // Mostrar el formulario de pre-registro
        ref.read(userManagementProvider.notifier).toggleInviteForm();
      },
    );
  }

  // Refrescar datos según el rol
  void _refreshDataByRole(UserRole role) {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;

    // Invalidar los providers correspondientes según el rol
    switch (role) {
      case UserRole.athlete:
        ref.invalidate(athletesProvider(currentAcademy.academyId));
        break;
      case UserRole.coach:
        ref.invalidate(coachesProvider(currentAcademy.academyId));
        break;
      case UserRole.manager:
        ref.invalidate(managersProvider(currentAcademy.academyId));
        break;
      case UserRole.parent:
        ref.invalidate(parentsProvider);
        break;
      case UserRole.owner:
        ref.invalidate(ownersProvider);
        break;
      default:
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos de ${_getRoleName(role)} actualizados')),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return 'Gerente';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.athlete:
        return 'Atleta';
      case UserRole.parent:
        return 'Padre/Responsable';
      case UserRole.owner:
        return 'Owner';
      default:
        return '';
    }
  }
} 