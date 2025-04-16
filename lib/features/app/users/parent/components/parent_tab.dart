import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/parent/core/services/parent_providers.dart';
import 'package:arcinus/features/app/users/parent/screens/parent_form_screen.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_management_provider.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/theme/components/inputs/user_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParentTab extends ConsumerWidget {
  final TextEditingController searchController;

  const ParentTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagement = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    return Column(
      children: [
        // Barra de búsqueda
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar padres...',
          onSearch: (query) => userManagementNotifier.updateSearchQuery(query),
        ),
        const Divider(),
        // Lista de padres construida aquí
        Expanded(
          child: _buildParentList(context, ref, userManagement.searchQuery),
        ),
      ],
    );
  }

  // Método para construir la lista de padres (movido y adaptado de ParentListScreen)
  Widget _buildParentList(BuildContext context, WidgetRef ref, String searchQuery) {
    final parentsAsync = ref.watch(parentsProvider);

    return parentsAsync.when(
      data: (parents) {
        final filteredParents = searchQuery.isNotEmpty
            ? parents.where((parent) =>
                parent.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                parent.email.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList()
            : parents;

        if (filteredParents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No hay padres registrados'
                      : 'No se encontraron padres con "$searchQuery"',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(parentsProvider),
          child: ListView.builder(
            itemCount: filteredParents.length,
            itemBuilder: (context, index) {
              final parent = filteredParents[index];
              return _buildParentCard(context, ref, parent);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error al cargar padres: $e', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(parentsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir la tarjeta de padre (movido de ParentListScreen)
  Widget _buildParentCard(BuildContext context, WidgetRef ref, User parent) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final currentAcademy = ref.watch(currentAcademyProvider);
    final canEdit = currentUser != null && currentAcademy != null &&
        (currentUser.role == UserRole.owner ||
         currentUser.role == UserRole.manager ||
         currentUser.role == UserRole.superAdmin);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
         leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.person),
          ),
          title: Text(parent.name),
          subtitle: Text(parent.email),
           trailing: canEdit ? PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _navigateToEditParent(context, ref, parent);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, ref, parent);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Eliminar', style: TextStyle(color: Colors.red)))
              ),
            ],
          ) : null,
          onTap: canEdit ? () => _navigateToEditParent(context, ref, parent) : null,
      )
    );
  }

  // Método para navegar a la pantalla de edición (movido de ParentListScreen)
  void _navigateToEditParent(BuildContext context, WidgetRef ref, User parent) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentFormScreen(
          mode: ParentFormMode.edit,
          userId: parent.id,
          academyId: currentAcademy.academyId,
        ),
      ),
    );

    if (result == true) {
      ref.invalidate(parentsProvider);
    }
  }

  // Método para mostrar confirmación de eliminación (movido de ParentListScreen)
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, User parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Padre/Madre'),
        content: Text('¿Estás seguro de que deseas eliminar a ${parent.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteParent(context, ref, parent);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Método para eliminar padre (movido de ParentListScreen)
  Future<void> _deleteParent(BuildContext context, WidgetRef ref, User parent) async {
    try {
      final currentAcademy = ref.read(currentAcademyProvider);
      if (currentAcademy == null) return;

      final userService = ref.read(userServiceProvider);
      // Asumiendo que existe deleteParent en userService, si no, ajustar a deleteUser
      await userService.deleteParent(parent.id, currentAcademy.academyId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Padre/Madre eliminado correctamente')),
        );
        ref.invalidate(parentsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
} 