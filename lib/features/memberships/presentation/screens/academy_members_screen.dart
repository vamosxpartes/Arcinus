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

class AcademyMembersScreen extends ConsumerStatefulWidget {
  final String academyId;

  const AcademyMembersScreen({super.key, required this.academyId});

  @override
  ConsumerState<AcademyMembersScreen> createState() => _AcademyMembersScreenState();
}

class _AcademyMembersScreenState extends ConsumerState<AcademyMembersScreen> with SingleTickerProviderStateMixin {
  // Controlador para las pestañas
  late TabController _tabController;
  
  // Filtro activo de rol
  AppRole? _activeRoleFilter;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de pestañas con 4 pestañas
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    // Actualizar el título en el OwnerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentScreenTitleProvider.notifier).state = 'Miembros de la Academia';
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  // Manejar cambio de pestaña para actualizar el filtro
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _activeRoleFilter = null; // Todos
            break;
          case 1:
            _activeRoleFilter = AppRole.atleta;
            break;
          case 2:
            _activeRoleFilter = AppRole.colaborador;
            break;
          case 3:
            _activeRoleFilter = AppRole.padre;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el valor actual del término de búsqueda
    final searchTerm = ref.watch(searchTermNotifierProvider);
    
    // Dependiendo de si hay un término de búsqueda, mostramos resultados de búsqueda o la lista normal
    Widget membersListWidget;
    
    if (searchTerm.isNotEmpty) {
      // Si hay término de búsqueda, mostramos resultados de la búsqueda
      final searchResults = ref.watch(academyUsersSearchProvider(widget.academyId));
      membersListWidget = _buildSearchResultsList(searchResults);
    } else if (_tabController.index == 2) { // Colaboradores (desarrollo)
      membersListWidget = const ScreenUnderDevelopment(
        message: 'Próximamente podrás gestionar colaboradores\npara tu academia deportiva.',
      );
    } else if (_tabController.index == 3) { // Padres (desarrollo)
      membersListWidget = const ScreenUnderDevelopment(
        message: 'Próximamente podrás gestionar padres y tutores\npara los atletas de tu academia.',
      );
    } else if (_activeRoleFilter == null) {
      // Obtener todos los usuarios
      final usersAsyncValue = ref.watch(academyUsersProvider(widget.academyId));
      membersListWidget = _buildUsersList(usersAsyncValue);
    } else {
      // Obtener usuarios filtrados por rol
      final usersAsyncValue = ref.watch(academyUsersByRoleProvider(widget.academyId, _activeRoleFilter!));
      membersListWidget = _buildUsersList(usersAsyncValue);
    }

    return Scaffold(
      body: Column(
        children: [
          // TabBar para filtrar por rol
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
          // Barra de búsqueda y botón de añadir
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar miembro...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchTerm.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                ref.read(searchTermNotifierProvider.notifier).clearSearchTerm();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                    ),
                    onChanged: (value) {
                      ref.read(searchTermNotifierProvider.notifier).updateSearchTerm(value);
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/owner/academy/${widget.academyId}/members/add-athlete');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de miembros
          Expanded(
            child: membersListWidget,
          ),
        ],
      ),
    );
  }
  
  // Widget para construir la lista de resultados de búsqueda
  Widget _buildSearchResultsList(AsyncValue<List<AcademyUserModel>> searchResultsAsyncValue) {
    final searchTerm = ref.watch(searchTermNotifierProvider);
    
    return searchResultsAsyncValue.when(
      data: (List<AcademyUserModel> users) {
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No se encontraron resultados para "$searchTerm"'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(searchTermNotifierProvider.notifier).clearSearchTerm();
                  },
                  child: const Text('Limpiar búsqueda'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final AcademyUserModel user = users[index];
            return _buildUserCard(context, user);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error al buscar: $error'),
      ),
    );
  }
  
  // Widget para construir la lista de usuarios
  Widget _buildUsersList(AsyncValue<List<AcademyUserModel>> usersAsyncValue) {
    return usersAsyncValue.when(
      data: (List<AcademyUserModel> users) {
        if (users.isEmpty) {
          if (_activeRoleFilter != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No hay usuarios con el rol ${_getRoleName(_activeRoleFilter!)}'),
                  const SizedBox(height: 16),
                  if (_activeRoleFilter == AppRole.colaborador || _activeRoleFilter == AppRole.padre)
                    const Text('Esta funcionalidad está en desarrollo'),
                ],
              ),
            );
          }
          return const Center(
            child: Text('No hay usuarios en esta academia'),
          );
        }
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final AcademyUserModel user = users[index];
            return _buildUserCard(context, user);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error al cargar usuarios: $error'),
      ),
    );
  }
  
  // Widget para construir la tarjeta de un usuario
  Widget _buildUserCard(BuildContext context, AcademyUserModel user) {
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
          trailing: _buildUserTrailingWidgets(context, user),
          onTap: () {
            // Navegar a la pantalla de detalles del usuario
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AcademyUserDetailsScreen(
                  academyId: widget.academyId,
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

  /// Construye los widgets de acción para cada usuario según su rol
  Widget _buildUserTrailingWidgets(BuildContext context, AcademyUserModel user) {
    final actions = <Widget>[];
    
    final userRole = user.role != null 
        ? AppRole.values.firstWhere(
            (r) => r.name == user.role,
            orElse: () => AppRole.atleta,
          ) 
        : AppRole.atleta;
    
    // Añadir botón de mensajes o acciones específicas según el rol
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
    
    // Añadir botón para editar
    actions.add(
      PermissionGate(
        academyId: widget.academyId,
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
    
    // Si hay múltiples acciones, devolvemos una fila de iconos
    if (actions.length > 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: actions,
      );
    } 
    // Si solo hay una acción, la devolvemos directamente
    else if (actions.isNotEmpty) {
      return actions.first;
    } 
    // Si no hay acciones, devolvemos un widget vacío
    else {
      return const SizedBox.shrink();
    }
  }
  
  // Obtener un nombre amigable para el rol
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
  
  // Obtener un color para cada rol
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
  
  // Formato simple para la fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 