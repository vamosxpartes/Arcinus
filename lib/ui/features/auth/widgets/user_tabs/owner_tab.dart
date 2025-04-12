import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ui/features/auth/widgets/shared/user_search_bar.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/auth/providers/user_management_provider.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de owners
final ownersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getUsersByRole(UserRole.owner);
});

class OwnerTab extends ConsumerWidget {
  final TextEditingController searchController;

  const OwnerTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagement = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    return Column(
      children: [
        // Barra de búsqueda con botón de agregar dueño
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar propietarios...',
          onSearch: (query) => userManagementNotifier.updateSearchQuery(query),
          onAddPressed: () => _showAddOwnerDialog(context, ref),
          addButtonTooltip: 'Agregar Propietario',
        ),
        
        const Divider(),
        
        // Lista de propietarios
        Expanded(
          child: _buildOwnerList(context, ref, userManagement.searchQuery),
        ),
      ],
    );
  }

  Widget _buildOwnerList(BuildContext context, WidgetRef ref, String searchQuery) {
    final ownersData = ref.watch(ownersProvider);
    
    return ownersData.when(
      data: (owners) {
        // Filtrar propietarios según búsqueda
        final filteredOwners = owners.where((owner) => 
            owner.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        
        if (filteredOwners.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No hay propietarios registrados'
                      : 'No se encontraron propietarios con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: filteredOwners.length,
          itemBuilder: (context, index) {
            final owner = filteredOwners[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: owner.profileImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            owner.profileImageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.business, color: Colors.white),
                ),
                title: Text(owner.name),
                subtitle: Text(owner.email),
                trailing: owner.academyIds.length > 1
                    ? Chip(
                        label: Text('${owner.academyIds.length} academias'),
                        backgroundColor: Colors.amber[100],
                      )
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }

  void _showAddOwnerDialog(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(authStateProvider).valueOrNull;
    if (currentUser?.role != UserRole.superAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes permisos para agregar propietarios')),
      );
      return;
    }
    
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Propietario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                hintText: 'Nombre del propietario',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'email@ejemplo.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isEmpty || nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debes completar todos los campos')),
                );
                return;
              }
              
              // Lógica para crear el owner
              // Esto sería implementado con un servicio real
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Propietario agregado correctamente')),
              );
              
              // Refrescar la lista
              ref.invalidate(ownersProvider);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
} 