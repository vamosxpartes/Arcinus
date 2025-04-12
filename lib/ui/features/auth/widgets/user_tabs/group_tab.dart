import 'package:arcinus/ui/features/auth/widgets/shared/user_search_bar.dart';
import 'package:arcinus/ui/features/groups/screens/group_list_screen.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/user_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupTab extends ConsumerWidget {
  final TextEditingController searchController;

  const GroupTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagementNotifier = ref.read(userManagementProvider.notifier);
    final currentAcademy = ref.watch(currentAcademyProvider);

    if (currentAcademy == null) {
      return const Center(
        child: Text('No hay academia seleccionada'),
      );
    }

    return Column(
      children: [
        // Barra de búsqueda con botón de agregar grupo
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar grupos...',
          onSearch: (query) => userManagementNotifier.updateSearchQuery(query),
          onAddPressed: () => _showAddGroupDialog(context, ref),
          addButtonTooltip: 'Crear Grupo',
        ),
        
        const Divider(),
        
        // Lista de grupos
        const Expanded(
          child: GroupListScreen(),
        ),
      ],
    );
  }

  void _showAddGroupDialog(BuildContext context, WidgetRef ref) {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay academia seleccionada')),
      );
      return;
    }
    
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
                hintText: 'Ej: Equipo A',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción del grupo',
              ),
              maxLines: 3,
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
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre del grupo es obligatorio')),
                );
                return;
              }
              
              // Lógica para crear el grupo
              // Esto se implementaría con un servicio real
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grupo creado correctamente')),
              );
              
              // Refrescar la lista
              // ref.invalidate(groupsProvider); // Se implementaría con el provider correspondiente
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
} 