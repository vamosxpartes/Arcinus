import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/presentation/providers/edit_permissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla para editar los permisos de un colaborador.
class EditPermissionsScreen extends ConsumerWidget {
  final String academyId;
  final String membershipId;
  final MembershipModel membership;

  const EditPermissionsScreen({
    super.key,
    required this.academyId,
    required this.membershipId,
    required this.membership,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar el provider con la membresía actual
    final editPermissionsState = ref.watch(
      editPermissionsProvider((
        membershipId: membershipId,
        academyId: academyId,
        initialMembership: membership,
      )),
    );
    
    final notifier = ref.read(
      editPermissionsProvider((
        membershipId: membershipId,
        academyId: academyId,
        initialMembership: membership,
      )).notifier,
    );
    
    // Escuchar cambios de estado para mostrar mensajes
    ref.listen(
      editPermissionsProvider((
        membershipId: membershipId,
        academyId: academyId,
        initialMembership: membership,
      )),
      (previous, current) {
        // Mostrar SnackBar según el estado
        if (current.status == EditPermissionsStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permisos actualizados correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Resetear el estado después de mostrar el mensaje
          Future.delayed(const Duration(seconds: 1), () {
            notifier.resetStatus();
          });
        } else if (current.status == EditPermissionsStatus.error && 
                  current.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${current.error!.message}'),
              backgroundColor: Colors.red,
            ),
          );
          // Resetear el estado después de mostrar el mensaje
          Future.delayed(const Duration(seconds: 3), () {
            notifier.resetStatus();
          });
        }
      },
    );

    // Agrupar permisos por categoría para mejor visualización
    final groupedPermissions = AppPermissions.getGroupedPermissions();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Permisos'),
        actions: [
          // Botón de guardar
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: editPermissionsState.status == EditPermissionsStatus.loading
                ? null // Deshabilitar mientras carga
                : () => notifier.savePermissions(),
          ),
        ],
      ),
      body: editPermissionsState.status == EditPermissionsStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Información del colaborador
                if (membership.role.name == 'colaborador')
                  _buildCollaboratorInfo(context, membership),
                
                const SizedBox(height: 16),
                
                // Secciones de permisos agrupados por categoría
                ...groupedPermissions.entries.map((entry) {
                  final category = entry.key;
                  final permissions = entry.value;
                  
                  return _buildPermissionCategory(
                    context, 
                    category, 
                    permissions, 
                    editPermissionsState.selectedPermissions,
                    notifier,
                  );
                }),
              ],
            ),
    );
  }
  
  /// Construye el widget de información del colaborador
  Widget _buildCollaboratorInfo(BuildContext context, MembershipModel membership) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Colaborador',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${membership.userId}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Miembro desde: ${membership.addedAt?.toString().split(' ')[0] ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construye una categoría de permisos con sus checkboxes
  Widget _buildPermissionCategory(
    BuildContext context,
    String category,
    List<String> permissions,
    List<String> selectedPermissions,
    EditPermissionsNotifier notifier,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la categoría
            Text(
              category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Lista de permisos en esta categoría
            ...permissions.map((permission) {
              final isSelected = selectedPermissions.contains(permission);
              final description = AppPermissions.getDescription(permission);
              
              return CheckboxListTile(
                title: Text(description),
                value: isSelected,
                onChanged: (value) {
                  notifier.togglePermission(permission);
                },
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
          ],
        ),
      ),
    );
  }
} 