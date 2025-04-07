import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ui/features/auth/screens/coach_form_screen.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de entrenadores
final coachesProvider = FutureProvider.family<List<User>, String>((ref, academyId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUsersByRole(UserRole.coach, academyId: academyId);
});

class CoachListScreen extends ConsumerStatefulWidget {
  const CoachListScreen({super.key});

  @override
  ConsumerState<CoachListScreen> createState() => _CoachListScreenState();
}

class _CoachListScreenState extends ConsumerState<CoachListScreen> {
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

  Future<void> _refreshCoaches() async {
    setState(() {
    });
    
    // Invalidar el provider para forzar una recarga
    ref.invalidate(coachesProvider);
    
    setState(() {
    });
  }

  Future<void> _addCoach() async {
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
        builder: (context) => CoachFormScreen(
          mode: CoachFormMode.create,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshCoaches();
    }
  }

  Future<void> _editCoach(User coach) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    if (!mounted) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoachFormScreen(
          mode: CoachFormMode.edit,
          userId: coach.id,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshCoaches();
    }
  }

  Future<void> _deleteCoach(User coach) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    // Pedir confirmación
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Entrenador'),
        content: Text('¿Estás seguro de eliminar a ${coach.name}? Esta acción no se puede deshacer.'),
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
        await userService.deleteCoach(coach.id, currentAcademy.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrenador eliminado correctamente')),
          );
          await _refreshCoaches();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar entrenador: $e')),
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
        appBar: AppBar(title: const Text('Entrenadores')),
        body: const Center(
          child: Text('No hay academia seleccionada'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCoaches,
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
                      hintText: 'Buscar entrenadores...',
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
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    onPressed: _addCoach,
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                    ),
                    tooltip: 'Agregar Entrenador',
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de entrenadores
          Expanded(
            child: _buildCoachList(currentAcademy.id),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachList(String academyId) {
    final coachesData = ref.watch(coachesProvider(academyId));
    
    return coachesData.when(
      data: (coaches) {
        // Filtrar entrenadores según búsqueda
        final filteredCoaches = _searchQuery.isEmpty
            ? coaches
            : coaches.where((coach) => 
                coach.name.toLowerCase().contains(_searchQuery)).toList();
        
        if (filteredCoaches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No hay entrenadores registrados'
                      : 'No se encontraron entrenadores con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (_searchQuery.isEmpty)
                  ElevatedButton.icon(
                    onPressed: _addCoach,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Entrenador'),
                  ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _refreshCoaches,
          child: ListView.builder(
            itemCount: filteredCoaches.length,
            itemBuilder: (context, index) {
              final coach = filteredCoaches[index];
              return _buildCoachItem(coach);
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
              onPressed: _refreshCoaches,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachItem(User coach) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: coach.profileImageUrl != null
              ? ClipOval(
                  child: Image.network(
                    coach.profileImageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.sports, color: Colors.white),
        ),
        title: Text(coach.name),
        subtitle: Text(coach.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editCoach(coach),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCoach(coach),
            ),
          ],
        ),
        onTap: () => _editCoach(coach),
      ),
    );
  }
} 