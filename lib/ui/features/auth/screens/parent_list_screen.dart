import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ui/features/auth/screens/parent_form_screen.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para la lista de padres
final parentsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final currentAcademy = ref.watch(currentAcademyProvider);
  if (currentAcademy == null) {
    throw Exception('No hay academia seleccionada');
  }
  
  final userService = ref.read(userServiceProvider);
  return userService.getUsersByRole(UserRole.parent, academyId: currentAcademy.id);
});

class ParentListScreen extends ConsumerWidget {
  final String? searchQuery;
  final VoidCallback onRefresh;

  const ParentListScreen({
    super.key,
    this.searchQuery,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentsAsync = ref.watch(parentsProvider);
    
    return parentsAsync.when(
      data: (parents) {
        // Filtrar la lista si hay una consulta de búsqueda
        final filteredParents = searchQuery != null && searchQuery!.isNotEmpty
            ? parents.where((parent) =>
                parent.name.toLowerCase().contains(searchQuery!.toLowerCase()) ||
                parent.email.toLowerCase().contains(searchQuery!.toLowerCase()))
              .toList()
            : parents;
        
        if (filteredParents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people_alt_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  parents.isEmpty
                      ? 'No hay padres registrados'
                      : 'No se encontraron padres con "$searchQuery"',
                  textAlign: TextAlign.center,
                ),                
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(parentsProvider);
            onRefresh();
          },
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar padres:\n${e.toString()}',
              textAlign: TextAlign.center,
            ),
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
  
  Widget _buildParentCard(BuildContext context, WidgetRef ref, User parent) {
    // Verificar si el usuario actual puede editar este padre
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final currentAcademy = ref.watch(currentAcademyProvider);
    final canEdit = currentUser != null && currentAcademy != null &&
        (currentUser.role == UserRole.owner || 
         currentUser.role == UserRole.manager || 
         currentUser.role == UserRole.superAdmin);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre y acciones
            Row(
              children: [
                // Icono de usuario
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                // Información del padre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parent.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        parent.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Menú de opciones
                if (canEdit)
                  PopupMenuButton<String>(
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
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToEditParent(BuildContext context, WidgetRef ref, User parent) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentFormScreen(
          mode: ParentFormMode.edit,
          userId: parent.id,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true) {
      ref.invalidate(parentsProvider);
      onRefresh();
    }
  }
  
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
  
  Future<void> _deleteParent(BuildContext context, WidgetRef ref, User parent) async {
    try {
      final currentAcademy = ref.read(currentAcademyProvider);
      if (currentAcademy == null) return;
      
      final userService = ref.read(userServiceProvider);
      await userService.deleteParent(parent.id, currentAcademy.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Padre/Madre eliminado correctamente')),
        );
        ref.invalidate(parentsProvider);
        onRefresh();
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