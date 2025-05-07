import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/models/user_model.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/presentation/providers/membership_providers.dart';
import 'package:arcinus/features/memberships/presentation/screens/member_details_screen.dart';
import 'package:arcinus/features/memberships/presentation/widgets/permission_widget.dart';
import 'package:arcinus/features/navigation_shells/owner_shell/owner_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AcademyMembersListScreen extends ConsumerStatefulWidget {
  final String academyId;

  const AcademyMembersListScreen({super.key, required this.academyId});

  @override
  ConsumerState<AcademyMembersListScreen> createState() => _AcademyMembersListScreenState();
}

class _AcademyMembersListScreenState extends ConsumerState<AcademyMembersListScreen> with SingleTickerProviderStateMixin {
  // Controlador para las pestañas
  late TabController _tabController;
  
  // Filtro activo de rol
  AppRole? _activeRoleFilter;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de pestañas con 5 pestañas
    _tabController = TabController(length: 5, vsync: this);
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
            _activeRoleFilter = AppRole.propietario;
            break;
          case 4:
            _activeRoleFilter = AppRole.padre;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos directamente el provider de miembros y filtramos en la UI
    final membersAsyncValue = ref.watch(academyMembersProvider(widget.academyId));

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
              Tab(text: 'Propietarios'),
              Tab(text: 'Padres'),
            ],
          ),
          // Lista de miembros
          Expanded(
            child: membersAsyncValue.when(
              data: (List<MembershipModel> allMembers) {
                // Filtramos los miembros según el rol seleccionado
                final List<MembershipModel> members = _activeRoleFilter == null 
                    ? allMembers 
                    : allMembers.where((member) => member.role == _activeRoleFilter).toList();
                
                if (members.isEmpty) {
                  return Center(
                    child: Text('No hay miembros${_activeRoleFilter != null ? ' con el rol ${_getRoleName(_activeRoleFilter!)}' : ' en esta academia'}.'),
                  );
                }
                
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final MembershipModel member = members[index];
                    
                    // Observer para el perfil del usuario
                    return Consumer(
                      builder: (context, ref, child) {
                        final profileAsync = ref.watch(userProfileProvider(member.userId));
                        
                        return profileAsync.when(
                          data: (UserModel? profile) {
                            return _buildMemberCard(context, member, profile);
                          },
                          loading: () => _buildLoadingMemberCard(context, member),
                          error: (error, stackTrace) => _buildErrorMemberCard(context, member),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error al cargar miembros: $error'),
              ),
            ),
          ),
        ],
      ),
      // Botón para invitar miembros
      floatingActionButton: PermissionGate(
        academyId: widget.academyId,
        requiredPermission: AppPermissions.inviteMembers,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/owner/academy/${widget.academyId}/members/invite');
          },
          tooltip: 'Invitar Miembro',
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  // Construir card para miembro con datos
  Widget _buildMemberCard(BuildContext context, MembershipModel member, UserModel? profile) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getRoleColor(member.role),
            child: Text(
              // Mostrar inicial del nombre si hay perfil, o del rol
              profile?.name != null && profile!.name!.isNotEmpty
                  ? profile.name![0].toUpperCase()
                  : member.role.name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            // Mostrar nombre o ID
            profile?.name ?? 'Usuario ID: ${member.userId}',
          ), 
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar email si disponible
              if (profile?.email != null)
                Text(
                  profile!.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Text(
                'Rol: ${_getRoleName(member.role)}',
                style: TextStyle(
                  color: _getRoleColor(member.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (member.permissions.isNotEmpty)
                Text(
                  'Permisos: ${member.permissions.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Text(
                'Miembro desde: ${_formatDate(member.addedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: _buildTrailingWidgets(context, member),
          onTap: () {
            // Navegar a la pantalla de detalles del miembro
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemberDetailsScreen(
                  academyId: widget.academyId,
                  membership: member,
                  userProfile: profile,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Construir card para miembro en estado de carga
  Widget _buildLoadingMemberCard(BuildContext context, MembershipModel member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getRoleColor(member.role),
            child: Text(
              member.role.name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: const Text('Cargando usuario...'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${member.userId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Rol: ${_getRoleName(member.role)}',
                style: TextStyle(
                  color: _getRoleColor(member.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  // Construir card para miembro con error
  Widget _buildErrorMemberCard(BuildContext context, MembershipModel member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getRoleColor(member.role),
            child: Text(
              member.role.name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text('Usuario ID: ${member.userId}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rol: ${_getRoleName(member.role)}',
                style: TextStyle(
                  color: _getRoleColor(member.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Error cargando perfil',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          trailing: _buildTrailingWidgets(context, member),
        ),
      ),
    );
  }

  /// Construye los widgets de acción para cada miembro según su rol y permisos
  Widget _buildTrailingWidgets(BuildContext context, MembershipModel member) {
    final actions = <Widget>[];
    
    // Si es un colaborador, mostrar botón para editar permisos
    if (member.role == AppRole.colaborador) {
      actions.add(
        PermissionGate(
          academyId: widget.academyId,
          requiredPermission: AppPermissions.manageMemberships,
          child: IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Editar permisos',
            onPressed: () {
              // Navegar a la pantalla de editar permisos
              final membershipId = member.id ?? 'unknown';
              context.push('/owner/academy/${widget.academyId}/members/$membershipId/permissions');
            },
          ),
        ),
      );
    }
    
    // Añadir botón de mensajes o acciones específicas según el rol
    switch (member.role) {
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