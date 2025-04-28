import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart';
import 'package:arcinus/features/memberships/presentation/providers/invite_member_provider.dart';
import 'package:arcinus/features/memberships/presentation/providers/state/invite_member_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InviteMemberScreen extends ConsumerWidget {
  final String academyId;

  const InviteMemberScreen({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(inviteMemberProvider(academyId).notifier);
    final state = ref.watch(inviteMemberProvider(academyId));

    // Lista de roles que se pueden asignar desde esta pantalla
    final assignableRoles = AppRole.values
        .where((role) =>
            role != AppRole.superAdmin &&
            role != AppRole.propietario &&
            role != AppRole.desconocido)
        .toList();

    // Escuchar cambios para mostrar SnackBar de éxito/error
    ref.listen<InviteMemberState>(inviteMemberProvider(academyId), (_, next) {
       next.maybeWhen(
        success: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Miembro invitado con éxito')));
          // Opcional: Podrías cerrar esta pantalla
          // Navigator.of(context).pop();
        },
        error: (failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Invitar Miembro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Sección de Búsqueda ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: notifier.emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email del Usuario',
                      hintText: 'Introduce el email a buscar...',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: state.maybeWhen(
                       searching: () => false,
                       creatingMembership: () => false,
                       orElse: () => true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: state.maybeWhen(
                     searching: () => null,
                     creatingMembership: () => null,
                     orElse: () => notifier.searchUserByEmail,
                  ),
                   tooltip: 'Buscar Usuario',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Widgets condicionales usando maybeWhen ---
            state.maybeWhen(
              searching: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
              userNotFound: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Usuario no encontrado.'))),
              userFound: (user) => _buildUserFoundSection(context, user, notifier, assignableRoles),
              // Para los demás estados (initial, creating, success, error), no mostrar nada aquí o mostrar espacio.
              orElse: () => const SizedBox.shrink(), 
            ),
             
             // Espaciador (podría ajustarse o eliminarse dependiendo del diseño)
             const SizedBox(height: 100),

            const SizedBox(height: 32),
            // --- Botón de Invitar/Crear Membresía ---
            ElevatedButton(
              // Habilitar solo si se encontró usuario y se seleccionó rol
              onPressed: state.maybeWhen(
                 userFound: (_) => notifier.selectedRole != null 
                    ? () => notifier.createMembershipForFoundUser() 
                    : null, // Deshabilitado si no hay rol
                 creatingMembership: () => null, // Deshabilitado mientras se crea
                 orElse: () => null, // Deshabilitado en otros estados
              ),
              child: state.maybeWhen(
                creatingMembership: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                orElse: () => const Text('Añadir Miembro'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar la información del usuario encontrado y la selección de rol.
  Widget _buildUserFoundSection(BuildContext context, UserModel user, InviteMemberNotifier notifier, List<AppRole> assignableRoles) {
    // Usar un StatefulWidget interno o reconstruir con Consumer/Selector 
    // si necesitamos actualizar el Dropdown sin afectar todo el build.
    // Por simplicidad ahora, reconstruimos.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text('Usuario Encontrado:', style: Theme.of(context).textTheme.titleMedium),
        ListTile(
          leading: CircleAvatar(child: Text(user.displayName?.substring(0, 1).toUpperCase() ?? user.email[0].toUpperCase())),
          title: Text(user.displayName ?? 'Nombre no disponible'),
          subtitle: Text(user.email),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<AppRole>(
          value: notifier.selectedRole,
          decoration: const InputDecoration(
            labelText: 'Asignar Rol',
            border: OutlineInputBorder(),
          ),
          hint: const Text('Selecciona un rol'),
          items: assignableRoles.map((AppRole role) {
            return DropdownMenuItem<AppRole>(
              value: role,
              child: Text(role.name), // Podríamos tener nombres más amigables
            );
          }).toList(),
          onChanged: notifier.selectRole,
          validator: (value) => value == null ? 'Debes seleccionar un rol' : null,
        ),
      ],
    );
  }
} 