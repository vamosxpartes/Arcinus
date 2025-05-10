import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:arcinus/features/memberships/presentation/providers/academy_users_providers.dart';
import 'package:arcinus/features/memberships/presentation/screens/academy_user_details_screen.dart';
import 'package:arcinus/features/memberships/presentation/widgets/permission_widget.dart';
import 'package:arcinus/features/navigation_shells/owner_shell/owner_shell.dart';
import 'package:arcinus/features/utils/screens/screen_under_development.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Helper functions (antes eran métodos de _AcademyMembersScreenState)

String _getRoleName(AppRole role) {
  switch (role) {
    case AppRole.propietario:
      return 'Propietario';
    case AppRole.colaborador:
      return 'Colaborador';
    case AppRole.atleta:
      return 'Atleta';
    case AppRole.padre:
      return 'Padre/Responsable';
    case AppRole.superAdmin:
      return 'Administrador';
    default:
      return 'Desconocido';
  }
}

Color _getRoleColor(AppRole role) {
  switch (role) {
    case AppRole.propietario:
      return Colors.purple;
    case AppRole.colaborador:
      return Colors.blue;
    case AppRole.atleta:
      return Colors.green;
    case AppRole.padre:
      return Colors.orange;
    case AppRole.superAdmin:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

Widget _buildUserTrailingWidgets(BuildContext context, WidgetRef ref, AcademyUserModel user, String academyId) {
  final actions = <Widget>[];

  final userRole = user.role != null
      ? AppRole.values.firstWhere(
          (r) => r.name == user.role,
          orElse: () => AppRole.atleta,
        )
      : AppRole.atleta;

  switch (userRole) {
    case AppRole.atleta:
      actions.add(
        IconButton(
          icon: const Icon(Icons.fitness_center),
          tooltip: 'Ver entrenamientos',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función en desarrollo: Entrenamientos del atleta')),
            );
          },
        ),
      );
      break;
    case AppRole.colaborador:
      actions.add(
        IconButton(
          icon: const Icon(Icons.schedule),
          tooltip: 'Ver horarios',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función en desarrollo: Horarios del colaborador')),
            );
          },
        ),
      );
      break;
    default:
      break;
  }

  actions.add(
    PermissionGate(
      academyId: academyId,
      requiredPermission: AppPermissions.manageMemberships,
      child: IconButton(
        icon: const Icon(Icons.edit),
        tooltip: 'Editar usuario',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función en desarrollo: Editar usuario')),
          );
        },
      ),
    ),
  );

  if (actions.length > 1) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions,
    );
  } else if (actions.isNotEmpty) {
    return actions.first;
  } else {
    return const SizedBox.shrink();
  }
}

Widget _buildUserCard(BuildContext context, WidgetRef ref, AcademyUserModel user, String academyId) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Hero(
          tag: 'user_avatar_${user.id}',
          child: CircleAvatar(
            backgroundColor: _getRoleColor(user.role != null ? AppRole.values.firstWhere(
              (r) => r.name == user.role,
              orElse: () => AppRole.atleta,
            ) : AppRole.atleta),
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        ),
        title: Text(user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.position != null && user.position!.isNotEmpty)
              Text(
                'Posición: ${user.position}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Text(
              'Rol: ${_getRoleName(user.role != null ? AppRole.values.firstWhere(
                (r) => r.name == user.role,
                orElse: () => AppRole.atleta,
              ) : AppRole.atleta)}',
              style: TextStyle(
                color: _getRoleColor(user.role != null ? AppRole.values.firstWhere(
                  (r) => r.name == user.role,
                  orElse: () => AppRole.atleta,
                ) : AppRole.atleta),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Miembro desde: ${_formatDate(user.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: _buildUserTrailingWidgets(context, ref, user, academyId),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AcademyUserDetailsScreen(
                academyId: academyId,
                userId: user.id,
                initialUserData: user,
              ),
            ),
          );
        },
      ),
    ),
  );
}


// Nuevo provider para búsqueda específica por pestaña
final membersScreenSearchProvider = FutureProvider.family<List<AcademyUserModel>, ({String academyId, String searchTerm, AppRole? role})>(
  (ref, params) async {
    final repository = ref.watch(academyUsersRepositoryProvider);
    // Si getAcademyUsers devuelve un Stream, tomamos el primer evento para que sea un Future.
    final List<AcademyUserModel> allUsers = await repository.getAcademyUsers(params.academyId).first;
    
    List<AcademyUserModel> filteredUsers = allUsers;

    if (params.role != null) {
      filteredUsers = filteredUsers.where((user) => user.role == params.role!.name).toList();
    }

    if (params.searchTerm.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        final searchTermLower = params.searchTerm.toLowerCase();
        // Asumimos que AcademyUserModel tiene fullName. Si tuviera email y quisiéramos buscar por él:
        // return user.fullName.toLowerCase().contains(searchTermLower) ||
        //        (user.email?.toLowerCase().contains(searchTermLower) ?? false);
        // Por ahora, solo por fullName ya que user.email no está definido según el error.
        return user.fullName.toLowerCase().contains(searchTermLower);
      }).toList();
    }
    return filteredUsers;
  }
);


class AcademyMembersScreen extends ConsumerStatefulWidget {
  final String academyId;

  const AcademyMembersScreen({super.key, required this.academyId});

  @override
  ConsumerState<AcademyMembersScreen> createState() => _AcademyMembersScreenState();
}

class _AcademyMembersScreenState extends ConsumerState<AcademyMembersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenTitleProvider.notifier).state = 'Miembros de la Academia';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: 'Atletas'),
              Tab(text: 'Colaboradores'),
              Tab(text: 'Padres'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MembersContentPage(
                  key: const ValueKey('todos_tab'),
                  academyId: widget.academyId,
                  roleFilter: null,
                  showAddButton: false,
                ),
                _MembersContentPage(
                  key: const ValueKey('atletas_tab'),
                  academyId: widget.academyId,
                  roleFilter: AppRole.atleta,
                  showAddButton: true,
                  addRoute: '/owner/academy/${widget.academyId}/members/add-athlete',
                  isAddFormUnderDevelopment: false,
                ),
                _MembersContentPage(
                  key: const ValueKey('colaboradores_tab'),
                  academyId: widget.academyId,
                  roleFilter: AppRole.colaborador,
                  showAddButton: true,
                  isAddFormUnderDevelopment: true,
                  addFormScreenTitle: 'Añadir Colaborador',
                  addFormUnderDevelopmentMessage: 'Próximamente podrás añadir colaboradores a esta academia.',
                  isTabContentUnderDevelopment: true,
                  tabContentUnderDevelopmentMessage: 'Próximamente podrás gestionar colaboradores\npara tu academia deportiva.',
                ),
                _MembersContentPage(
                  key: const ValueKey('padres_tab'),
                  academyId: widget.academyId,
                  roleFilter: AppRole.padre,
                  showAddButton: true,
                  isAddFormUnderDevelopment: true,
                  addFormScreenTitle: 'Añadir Padre/Tutor',
                  addFormUnderDevelopmentMessage: 'Próximamente podrás añadir padres o tutores para los atletas.',
                  isTabContentUnderDevelopment: true,
                  tabContentUnderDevelopmentMessage: 'Próximamente podrás gestionar padres y tutores\npara los atletas de tu academia.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersContentPage extends ConsumerStatefulWidget {
  final String academyId;
  final AppRole? roleFilter;
  final bool showAddButton;
  final String? addRoute;
  final bool isAddFormUnderDevelopment;
  final String? addFormScreenTitle;
  final String? addFormUnderDevelopmentMessage;
  final bool isTabContentUnderDevelopment;
  final String? tabContentUnderDevelopmentMessage;

  const _MembersContentPage({
    super.key,
    required this.academyId,
    this.roleFilter,
    required this.showAddButton,
    this.addRoute,
    this.isAddFormUnderDevelopment = false,
    this.addFormScreenTitle,
    this.addFormUnderDevelopmentMessage,
    this.isTabContentUnderDevelopment = false,
    this.tabContentUnderDevelopmentMessage,
  });

  @override
  ConsumerState<_MembersContentPage> createState() => _MembersContentPageState();
}

class _MembersContentPageState extends ConsumerState<_MembersContentPage> {
  late TextEditingController _searchController;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchTerm = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
     if (mounted) {
      setState(() {
        _searchTerm = '';
      });
    }
  }
  
  Widget _buildList(AsyncValue<List<AcademyUserModel>> asyncUsers) {
    return asyncUsers.when(
      data: (users) {
        if (users.isEmpty) {
          if (_searchTerm.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No se encontraron resultados para "$_searchTerm"'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _clearSearch,
                    child: const Text('Limpiar búsqueda'),
                  ),
                ],
              ),
            );
          }
          if (widget.roleFilter != null) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No hay usuarios con el rol ${_getRoleName(widget.roleFilter!)}'),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
          return const Center(child: Text('No hay usuarios en esta academia'));
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(context, ref, user, widget.academyId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error al cargar usuarios: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTabContentUnderDevelopment) {
      return ScreenUnderDevelopment(
        message: widget.tabContentUnderDevelopmentMessage ?? 'Funcionalidad en desarrollo.',
        title: widget.roleFilter != null ? _getRoleName(widget.roleFilter!) : 'En desarrollo',
      );
    }

    final AsyncValue<List<AcademyUserModel>> usersAsyncValue;
    if (_searchTerm.isNotEmpty) {
      usersAsyncValue = ref.watch(membersScreenSearchProvider(
        (
          academyId: widget.academyId,
          searchTerm: _searchTerm,
          role: widget.roleFilter
        ),
      ));
    } else if (widget.roleFilter == null) {
      usersAsyncValue = ref.watch(academyUsersProvider(widget.academyId));
    } else {
      usersAsyncValue = ref.watch(academyUsersByRoleProvider(widget.academyId, widget.roleFilter!));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar miembro...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                  ),
                  // onChanged ya está manejado por el listener del controller
                ),
              ),
              if (widget.showAddButton) ...[
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 120, // Ancho fijo para el botón
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.isAddFormUnderDevelopment) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ScreenUnderDevelopment(
                            title: widget.addFormScreenTitle ?? 'Añadir Miembro',
                            message: widget.addFormUnderDevelopmentMessage ?? 'Este formulario está en desarrollo.',
                          ),
                        ));
                      } else if (widget.addRoute != null) {
                        context.push(widget.addRoute!);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _buildList(usersAsyncValue),
        ),
      ],
    );
  }
} 