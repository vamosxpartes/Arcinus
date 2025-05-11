import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/models/user_model.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MemberDetailsScreen extends ConsumerStatefulWidget {
  final String academyId;
  final MembershipModel membership;
  final UserModel? userProfile;

  const MemberDetailsScreen({
    super.key,
    required this.academyId,
    required this.membership,
    this.userProfile,
  });

  @override
  ConsumerState<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends ConsumerState<MemberDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Actualizar el título en el OwnerShell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final memberName = widget.userProfile?.name ?? 'Usuario ${widget.membership.userId}';
      ref.read(currentScreenTitleProvider.notifier).state = 'Detalles de $memberName';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nota: No añadir AppBar aquí, ya viene del OwnerShell
    return Scaffold(
      body: Column(
        children: [
          // Botones de acción en la parte superior
          if (widget.membership.role == AppRole.colaborador)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Editar Permisos',
                    onPressed: () {
                      final membershipId = widget.membership.id ?? 'unknown';
                      context.push('/owner/academy/${widget.academyId}/members/$membershipId/permissions');
                    },
                  ),
                ],
              ),
            ),
          
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del perfil en una tarjeta
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: _getRoleColor(widget.membership.role),
                              child: Text(
                                widget.userProfile?.name != null && widget.userProfile!.name!.isNotEmpty
                                    ? widget.userProfile!.name![0].toUpperCase()
                                    : widget.membership.role.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (widget.userProfile != null) ...[
                            if (widget.userProfile!.name != null)
                              Center(
                                child: Text(
                                  widget.userProfile!.name!,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Center(
                              child: Text(
                                widget.userProfile!.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                          ],
                          
                          // Información del miembro
                          const SizedBox(height: 16),
                          const Text(
                            'Información del Miembro',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('ID Usuario: ${widget.membership.userId}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Rol: '),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(widget.membership.role).withAlpha(60),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getRoleName(widget.membership.role),
                                  style: TextStyle(
                                    color: _getRoleColor(widget.membership.role),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Miembro desde: ${_formatDate(widget.membership.addedAt)}'),
                        ],
                      ),
                    ),
                  ),
                  
                  // Sección de permisos si tiene
                  if (widget.membership.permissions.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Permisos',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${widget.membership.permissions.length} permisos asignados',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...widget.membership.permissions.map((permission) => 
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(AppPermissions.getDescription(permission)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Secciones específicas según el rol
                  const SizedBox(height: 16),
                  _buildRoleSpecificSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
      // Botones de acción en la parte inferior
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de mensaje
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Mensaje'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función en desarrollo: Enviar mensaje')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Botón específico según rol
              Expanded(
                child: _buildRoleSpecificButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir sección específica según el rol
  Widget _buildRoleSpecificSection(BuildContext context) {
    switch (widget.membership.role) {
      case AppRole.atleta:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información de Atleta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Aquí iría la información específica del atleta
                const Text('Próximamente: Historial de entrenamientos y progreso del atleta'),
              ],
            ),
          ),
        );
      case AppRole.colaborador:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información de Colaborador',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Aquí iría la información específica del colaborador
                const Text('Próximamente: Horarios y clases asignadas'),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink(); // Para otros roles no mostramos nada específico aún
    }
  }

  // Construir botón específico según el rol
  Widget _buildRoleSpecificButton(BuildContext context) {
    switch (widget.membership.role) {
      case AppRole.atleta:
        return ElevatedButton.icon(
          icon: const Icon(Icons.fitness_center),
          label: const Text('Ver Entrenamientos'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función en desarrollo: Ver entrenamientos del atleta')),
            );
          },
        );
      case AppRole.colaborador:
        return ElevatedButton.icon(
          icon: const Icon(Icons.schedule),
          label: const Text('Ver Horarios'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función en desarrollo: Ver horarios del colaborador')),
            );
          },
        );
      default:
        return ElevatedButton.icon(
          icon: const Icon(Icons.info),
          label: const Text('Más Información'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Función en desarrollo: Más información')),
            );
          },
        );
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