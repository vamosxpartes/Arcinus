import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/models/user_model.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/presentation/providers/membership_providers.dart';
import 'package:arcinus/features/memberships/presentation/widgets/permission_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Ya no creamos un provider personalizado, usaremos el academyMembersProvider directamente

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
    // Inicializar el controlador de pestañas con 5 pestañas (Todos, Atletas, Colaboradores, Propietarios, Padres)
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
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
      appBar: AppBar(
        title: const Text('Miembros de la Academia'),
        bottom: TabBar(
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
      ),
      body: membersAsyncValue.when(
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
                              // Al tocar un miembro, mostrar detalles con perfil
                              _showMemberDetails(context, member, profile);
                            },
                          ),
                        ),
                      );
                    },
                    loading: () => Card(
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
                    ),
                    error: (error, stackTrace) => Card(
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
                    ),
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
      // Añadir FloatingActionButton para invitar
      floatingActionButton: PermissionGate(
        academyId: widget.academyId,
        requiredPermission: AppPermissions.inviteMembers,
        child: FloatingActionButton(
          onPressed: () {
            // Navegar a la pantalla de invitar miembro usando la ruta definida
            context.push('/owner/academy/${widget.academyId}/members/invite');
          },
          tooltip: 'Invitar Miembro',
          child: const Icon(Icons.person_add),
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
              // TODO: Implementar navegación a entrenamientos del atleta
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
              // TODO: Implementar navegación a horarios del colaborador
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función en desarrollo: Horarios del colaborador')),
              );
            },
          ),
        );
        break;
      default:
        // Para otros roles no añadimos acciones específicas por ahora
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
  
  // Mostrar detalles del miembro en un diálogo
  void _showMemberDetails(BuildContext context, MembershipModel membership, UserModel? userProfile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Miembro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userProfile != null) ...[
                if (userProfile.name != null) 
                  Text('Nombre: ${userProfile.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Email: ${userProfile.email}'),
                const Divider(),
              ],
              Text('ID Usuario: ${membership.userId}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Rol: '),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(membership.role).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleName(membership.role),
                      style: TextStyle(
                        color: _getRoleColor(membership.role),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Miembro desde: ${_formatDate(membership.addedAt)}'),
              if (membership.permissions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Permisos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...membership.permissions.map((permission) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(AppPermissions.getDescription(permission)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          if (membership.role == AppRole.colaborador)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final membershipId = membership.id ?? 'unknown';
                context.push('/owner/academy/${widget.academyId}/members/$membershipId/permissions');
              },
              child: const Text('Editar Permisos'),
            ),
        ],
      ),
    );
  }
} 