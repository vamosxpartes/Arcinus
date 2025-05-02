import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/presentation/providers/membership_providers.dart';
import 'package:arcinus/features/memberships/presentation/widgets/permission_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AcademyMembersScreen extends ConsumerWidget {
  final String academyId;

  const AcademyMembersScreen({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsyncValue = ref.watch(academyMembersProvider(academyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros de la Academia'),
        // Podríamos añadir un botón para 'Invitar Miembro' aquí en el futuro
      ),
      body: membersAsyncValue.when(
        data: (members) {
          if (members.isEmpty) {
            return const Center(
              child: Text('Aún no hay miembros en esta academia.'),
            );
          }
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              // TODO: Cargar detalles del usuario (nombre, email) usando member.userId
              // Por ahora, mostramos datos básicos de la membresía.
              return ListTile(
                leading: CircleAvatar(child: Text(member.role.name[0].toUpperCase())), // Inicial del Rol
                title: Text('User ID: ${member.userId}'), 
                subtitle: Text('Rol: ${member.role.name}'),
                trailing: _buildTrailingWidgets(context, member),
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
        academyId: academyId,
        requiredPermission: AppPermissions.inviteMembers,
        child: FloatingActionButton(
          onPressed: () {
            // Navegar a la pantalla de invitar miembro usando la ruta definida
            context.push('/academies/$academyId/members/invite');
          },
          tooltip: 'Invitar Miembro',
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }
  
  /// Construye los widgets de acción para cada miembro según su rol y permisos
  Widget _buildTrailingWidgets(BuildContext context, MembershipModel member) {
    // Si es un colaborador, mostrar botón para editar permisos
    if (member.role == AppRole.colaborador) {
      return PermissionGate(
        academyId: academyId,
        requiredPermission: AppPermissions.manageMemberships,
        child: IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          tooltip: 'Editar permisos',
          onPressed: () {
            // Navegar a la pantalla de editar permisos
            final membershipId = member.id ?? 'unknown';
            context.push('/academies/$academyId/members/$membershipId/permissions');
          },
        ),
      );
    }
    
    // Para otros roles podríamos añadir otras acciones en el futuro
    return const SizedBox.shrink();
  }
} 