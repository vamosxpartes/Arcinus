import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/shared/navigation/navigation_service.dart';
import 'package:arcinus/ui/features/auth/screens/athlete_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/athlete_list_screen.dart';
import 'package:arcinus/ui/features/auth/screens/coach_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/coach_list_screen.dart';
import 'package:arcinus/ui/features/auth/screens/manager_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/manager_list_screen.dart';
import 'package:arcinus/ui/features/auth/screens/parent_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/parent_list_screen.dart';
import 'package:arcinus/ui/features/auth/widgets/forms/user_form_container.dart';
import 'package:arcinus/ui/features/auth/widgets/user_tabs/athlete_tab.dart';
import 'package:arcinus/ui/features/auth/widgets/user_tabs/coach_tab.dart';
import 'package:arcinus/ui/features/auth/widgets/user_tabs/group_tab.dart';
import 'package:arcinus/ui/features/auth/widgets/user_tabs/manager_tab.dart';
import 'package:arcinus/ui/features/auth/widgets/user_tabs/owner_tab.dart';
import 'package:arcinus/ui/features/auth/widgets/user_tabs/parent_tab.dart';
import 'package:arcinus/ui/shared/widgets/custom_navigation_bar.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/auth/providers/user_management_provider.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
    
  // Instancia del servicio de navegación
  final NavigationService _navigationService = NavigationService();
  
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
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isSuperAdmin = user?.role == UserRole.superAdmin;
    final userManagementState = ref.watch(userManagementProvider);
    
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [            
            // TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TabBar(
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
            
            // Contenido principal
            Expanded(
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
                  
                  // Formulario de invitación deslizable
                  if (userManagementState.showInviteForm)
                    UserFormContainer(
                      canManageAllUsers: user?.role == UserRole.owner || user?.role == UserRole.manager,
                      onCancel: () => ref.read(userManagementProvider.notifier).toggleInviteForm(),
                      onSubmit: (UserRole role) {
                        // Cerrar el formulario y mostrar mensaje de éxito
                        ref.read(userManagementProvider.notifier).toggleInviteForm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario creado correctamente')),
                        );
                        
                        // Refrescar datos según el rol
                        _refreshDataByRole(role);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Usar el componente centralizado para la barra de navegación
      bottomNavigationBar: CustomNavigationBar(
        pinnedItems: _navigationService.pinnedItems,
        allItems: NavigationItems.allItems,
        activeRoute: '/users-management',
        onItemTap: (item) => _navigationService.navigateToRoute(context, item.destination),
        onItemLongPress: (item) {
          if (_navigationService.togglePinItem(item, context: context)) {
            setState(() {
              // Actualizar la UI para reflejar cambios en elementos fijados
            });
          }
        },
        onAddButtonTap: () {
          // Dependiendo de la pestaña seleccionada, mostrar la pantalla de creación correspondiente
          final currentRole = ref.read(userManagementProvider).selectedRole;
          _showCreateUserForm(currentRole);
        },
      ),
    );
  }

  // Método para mostrar el formulario de creación de usuario según el rol
  void _showCreateUserForm(UserRole role) {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay academia seleccionada')),
      );
      return;
    }
    
    switch (role) {
      case UserRole.athlete:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AthleteFormScreen(
              mode: AthleteFormMode.create,
              academyId: currentAcademy.id,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshDataByRole(role);
          }
        });
        break;
      case UserRole.coach:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachFormScreen(
              mode: CoachFormMode.create,
              academyId: currentAcademy.id,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshDataByRole(role);
          }
        });
        break;
      case UserRole.manager:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManagerFormScreen(
              mode: ManagerFormMode.create,
              academyId: currentAcademy.id,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshDataByRole(role);
          }
        });
        break;
      case UserRole.parent:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParentFormScreen(
              mode: ParentFormMode.create,
              academyId: currentAcademy.id,
            ),
          ),
        ).then((result) {
          if (result == true) {
            _refreshDataByRole(role);
          }
        });
        break;
      default:
        // Para otros roles, mostrar mensaje de no implementado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creación de este tipo de usuario no implementada aún')),
        );
        break;
    }
  }

  // Refrescar datos según el rol
  void _refreshDataByRole(UserRole role) {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;

    // Invalidar los providers correspondientes según el rol
    switch (role) {
      case UserRole.athlete:
        ref.invalidate(athletesProvider(currentAcademy.id));
        break;
      case UserRole.coach:
        ref.invalidate(coachesProvider(currentAcademy.id));
        break;
      case UserRole.manager:
        ref.invalidate(managersProvider(currentAcademy.id));
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