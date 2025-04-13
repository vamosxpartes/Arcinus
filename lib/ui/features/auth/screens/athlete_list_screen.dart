import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ui/features/auth/screens/athlete_form_screen.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de atletas
final athletesProvider = FutureProvider.family<List<User>, String>((ref, academyId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getUsersByRole(UserRole.athlete, academyId: academyId);
});

class AthleteListScreen extends ConsumerStatefulWidget {
  const AthleteListScreen({super.key});

  @override
  ConsumerState<AthleteListScreen> createState() => _AthleteListScreenState();
}

class _AthleteListScreenState extends ConsumerState<AthleteListScreen> {
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

  Future<void> _refreshAthletes() async {
    setState(() {
    });
    
    // Invalidar el provider para forzar una recarga
    ref.invalidate(athletesProvider);
    
    setState(() {
    });
  }

  Future<void> _addAthlete() async {
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
        builder: (context) => AthleteFormScreen(
          mode: AthleteFormMode.create,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshAthletes();
    }
  }

  Future<void> _editAthlete(User athlete) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    if (!mounted) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AthleteFormScreen(
          mode: AthleteFormMode.edit,
          userId: athlete.id,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshAthletes();
    }
  }

  Future<void> _deleteAthlete(User athlete) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    // Pedir confirmación
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Atleta'),
        content: Text('¿Estás seguro de eliminar a ${athlete.name}? Esta acción no se puede deshacer.'),
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
        await userService.deleteAthlete(athlete.id, currentAcademy.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Atleta eliminado correctamente')),
          );
          await _refreshAthletes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar atleta: $e')),
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
        appBar: AppBar(title: const Text('Atletas')),
        body: const Center(
          child: Text('No hay academia seleccionada'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atletas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAthletes,
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
                      hintText: 'Buscar atletas...',
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
          
          // Lista de atletas
          Expanded(
            child: _buildAthleteList(currentAcademy.id),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteList(String academyId) {
    final athletesData = ref.watch(athletesProvider(academyId));
    
    return athletesData.when(
      data: (athletes) {
        // Filtrar atletas según búsqueda
        final filteredAthletes = _searchQuery.isEmpty
            ? athletes
            : athletes.where((athlete) => 
                athlete.name.toLowerCase().contains(_searchQuery)).toList();
        
        if (filteredAthletes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No hay atletas registrados'
                      : 'No se encontraron atletas con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (_searchQuery.isEmpty)
                  ElevatedButton.icon(
                    onPressed: _addAthlete,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Atleta'),
                  ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _refreshAthletes,
          child: ListView.builder(
            itemCount: filteredAthletes.length,
            itemBuilder: (context, index) {
              final athlete = filteredAthletes[index];
              return _buildAthleteItem(athlete);
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
              onPressed: _refreshAthletes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleteItem(User athlete) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: athlete.profileImageUrl != null
              ? ClipOval(
                  child: Image.network(
                    athlete.profileImageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : Text(athlete.name.isNotEmpty ? athlete.name[0].toUpperCase() : '?'),
        ),
        title: Text(athlete.name),
        subtitle: Text(athlete.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editAthlete(athlete),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAthlete(athlete),
            ),
          ],
        ),
        onTap: () => _editAthlete(athlete),
      ),
    );
  }
} 