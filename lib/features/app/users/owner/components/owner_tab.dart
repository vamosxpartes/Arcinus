import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_management_provider.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/theme/components/inputs/user_search_bar.dart';
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

} 