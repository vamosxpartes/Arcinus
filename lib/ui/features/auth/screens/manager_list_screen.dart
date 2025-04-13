import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ui/features/auth/screens/manager_form_screen.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de gerentes
final managersProvider = FutureProvider.family<List<User>, String>((ref, academyId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUsersByRole(UserRole.manager, academyId: academyId);
});

class ManagerListScreen extends ConsumerStatefulWidget {
  const ManagerListScreen({super.key});

  @override
  ConsumerState<ManagerListScreen> createState() => _ManagerListScreenState();
}

class _ManagerListScreenState extends ConsumerState<ManagerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<void> _refreshManagers() async {
    setState(() {
    });
    
    // Invalidar el provider para forzar una recarga
    ref.invalidate(managersProvider);
    
    setState(() {
    });
  }

  Future<void> _addManager() async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay academia seleccionada')),
        );
      }
      return;
    }
    
    if (!mounted) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerFormScreen(
          mode: ManagerFormMode.create,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshManagers();
    }
  }

  Future<void> _editManager(User manager) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    if (!mounted) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerFormScreen(
          mode: ManagerFormMode.edit,
          userId: manager.id,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshManagers();
    }
  }

  Future<void> _deleteManager(User manager) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    // Pedir confirmación
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gerente'),
        content: Text('¿Estás seguro de eliminar a ${manager.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true) {
      try {
        final userService = ref.read(userServiceProvider);
        await userService.deleteUser(manager.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gerente eliminado correctamente')),
          );
          await _refreshManagers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar gerente: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    if (currentAcademy == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gerentes')),
        body: const Center(
          child: Text('No hay academia seleccionada'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshManagers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar gerentes...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      // ignore: avoid_redundant_argument_values
                      contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),                
              ],
            ),
          ),
          
          // Lista de gerentes
          Expanded(
            child: _buildManagerList(currentAcademy.id),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerList(String academyId) {
    final managersData = ref.watch(managersProvider(academyId));
    
    return managersData.when(
      data: (managers) {
        // Filtrar gerentes según búsqueda
        final filteredManagers = _searchQuery.isEmpty
            ? managers
            : managers.where((manager) => 
                manager.name.toLowerCase().contains(_searchQuery)).toList();
        
        if (filteredManagers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No hay gerentes registrados'
                      : 'No se encontraron gerentes con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (_searchQuery.isEmpty)
                  ElevatedButton.icon(
                    onPressed: _addManager,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Gerente'),
                  ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _refreshManagers,
          child: ListView.builder(
            itemCount: filteredManagers.length,
            itemBuilder: (context, index) {
              final manager = filteredManagers[index];
              return _buildManagerItem(manager);
            },
          ),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshManagers,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerItem(User manager) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editManager(manager),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteManager(manager),
            ),
          ],
        ),
        onTap: () => _editManager(manager),
      ),
    );
  }
} 