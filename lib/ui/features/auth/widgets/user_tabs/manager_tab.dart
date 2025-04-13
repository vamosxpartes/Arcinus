import 'package:arcinus/ui/features/auth/screens/manager_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/manager_list_screen.dart';
import 'package:arcinus/ui/features/auth/widgets/shared/user_search_bar.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/user_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagerTab extends ConsumerWidget {
  final TextEditingController searchController;

  const ManagerTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagement = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    return Column(
      children: [
        // Barra de búsqueda con botón de agregar gerente
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar gerentes...',
          onSearch: (query) => userManagementNotifier.updateSearchQuery(query),
        ),
        
        const Divider(),
        
        // Lista de gerentes
        Expanded(
          child: _buildManagerList(context, ref, userManagement.searchQuery),
        ),
      ],
    );
  }

  Widget _buildManagerList(BuildContext context, WidgetRef ref, String searchQuery) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    if (currentAcademy == null) {
      return const Center(
        child: Text('No hay academia seleccionada'),
      );
    }
    
    final managersData = ref.watch(managersProvider(currentAcademy.id));
    
    return managersData.when(
      data: (managers) {
        // Filtrar gerentes según búsqueda
        final filteredManagers = managers.where((manager) => 
            manager.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        
        if (filteredManagers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No hay gerentes registrados'
                      : 'No se encontraron gerentes con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: filteredManagers.length,
          itemBuilder: (context, index) {
            final manager = filteredManagers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: manager.profileImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            manager.profileImageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.admin_panel_settings, color: Colors.white),
                ),
                title: Text(manager.name),
                subtitle: Text(manager.email),
                onTap: () => _editManager(context, ref, manager.id, currentAcademy.id),
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


  void _editManager(BuildContext context, WidgetRef ref, String managerId, String academyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerFormScreen(
          mode: ManagerFormMode.edit,
          userId: managerId,
          academyId: academyId,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refrescar datos
        ref.invalidate(managersProvider(academyId));
      }
    });
  }
} 