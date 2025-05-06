import 'package:arcinus/core/models/user_model.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('Usuario no autenticado.')),
      );
    }

    final userProfileAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            // Alternativamente, si siempre quieres volver al dashboard del owner:
            // import 'package:go_router/go_router.dart';
            // context.go('/owner/dashboard');
          },
        ),
      ),
      body: userProfileAsync.when(
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('No se pudo cargar el perfil.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileHeader(context, userProfile),
              const SizedBox(height: 24),
              _buildProfileDetailItem(
                icon: Icons.person_outline,
                label: 'Nombre Completo',
                value: userProfile.name ?? 'No especificado',
              ),
              _buildProfileDetailItem(
                icon: Icons.email_outlined,
                label: 'Correo Electrónico',
                value: userProfile.email, // email es requerido, no necesita ??
              ),
              // TODO: Descomentar cuando UserModel tenga el campo 'phone'
              // _buildProfileDetailItem(
              //   icon: Icons.phone_outlined,
              //   label: 'Teléfono',
              //   value: userProfile.phone ?? 'No especificado',
              // ),
              // TODO: Descomentar y ajustar cuando UserModel tenga el campo 'role'/'roles'
              // _buildProfileDetailItem(
              //   icon: Icons.badge_outlined,
              //   label: 'Rol Principal',
              //   value: userProfile.role?.displayName ?? 'No especificado',
              // ),
              // if (userProfile.roles != null && userProfile.roles!.length > 1)
              //   _buildProfileDetailItem(
              //     icon: Icons.group_work_outlined,
              //     label: 'Otros Roles',
              //     value: userProfile.roles!
              //         .where((role) => role != userProfile.role)
              //         .map((role) => role.displayName)
              //         .join(', '),
              //   ),
              _buildProfileDetailItem(
                icon: Icons.calendar_today_outlined,
                label: 'Miembro desde',
                value: userProfile.createdAt?.toLocal().toString().split(' ')[0] ?? 'No especificado',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar Perfil'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: Editar Perfil')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout_outlined),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  await ref.read(authStateNotifierProvider.notifier).signOut();
                  // La navegación se manejará por el redirector de GoRouter
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar el perfil: $error'),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel userProfile) {
    Widget avatarChild;
    if (userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.network(
          userProfile.profilePictureUrl!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          },
        ),
      );
    } else {
      avatarChild = Text(
        userProfile.name?.isNotEmpty == true ? userProfile.name![0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: avatarChild,
        ),
        const SizedBox(height: 16),
        Text(
          userProfile.name ?? 'Nombre de Usuario',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          userProfile.email, // email es requerido
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileDetailItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 