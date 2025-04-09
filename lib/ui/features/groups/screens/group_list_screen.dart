import 'package:arcinus/shared/models/group.dart';
import 'package:arcinus/shared/theme/app_theme.dart';
import 'package:arcinus/ui/features/groups/screens/group_form_screen.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/groups/services/group_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de grupos
final groupsProvider = FutureProvider.family<List<Group>, String>((ref, academyId) {
  final groupService = ref.watch(groupServiceProvider);
  return groupService.getGroupsByAcademy(academyId);
});

class GroupListScreen extends ConsumerStatefulWidget {
  const GroupListScreen({super.key});

  @override
  ConsumerState<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends ConsumerState<GroupListScreen> {
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

  Future<void> _refreshGroups() async {
    setState(() {
    });
    
    // Invalidar el provider para forzar una recarga
    ref.invalidate(groupsProvider);
    
    setState(() {
    });
  }

  Future<void> _addGroup() async {
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
        builder: (context) => GroupFormScreen(
          mode: GroupFormMode.create,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshGroups();
    }
  }

  Future<void> _editGroup(Group group) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    if (!mounted) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupFormScreen(
          mode: GroupFormMode.edit,
          groupId: group.id,
          academyId: currentAcademy.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _refreshGroups();
    }
  }


  Future<void> _viewGroupDetails(Group group) async {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) return;
    
    // Aquí podríamos navegar a una pantalla de detalles del grupo
    // que muestre información más completa, incluyendo la lista de atletas,
    // el entrenador asignado, etc.
    
    // Por ahora simplemente navegamos a la pantalla de edición
    await _editGroup(group);
  }

  @override
  Widget build(BuildContext context) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    if (currentAcademy == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grupos')),
        body: const Center(
          child: Text('No hay academia seleccionada'),
        ),
      );
    }
    
    return Scaffold(
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
                      hintText: 'Buscar grupos...',
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
                    onPressed: _addGroup,
                    icon: const Icon(
                      Icons.group_add,
                      color: Colors.white,
                    ),
                    tooltip: 'Crear Grupo',
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de grupos
          Expanded(
            child: _buildGroupList(currentAcademy.id),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(String academyId) {
    final groupsData = ref.watch(groupsProvider(academyId));
    
    return groupsData.when(
      data: (groups) {
        // Filtrar grupos según búsqueda
        final filteredGroups = _searchQuery.isEmpty
            ? groups
            : groups.where((group) => 
                group.name.toLowerCase().contains(_searchQuery)).toList();
        
        if (filteredGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.groups, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No hay grupos creados'
                      : 'No se encontraron grupos con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),              
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _refreshGroups,
          child: ListView.builder(
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final group = filteredGroups[index];
              return _buildGroupItem(group);
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
              onPressed: _refreshGroups,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItem(Group group) {
    final hasCoach = group.coachId != null;
    final hasAthletes = group.athleteIds.isNotEmpty;
    final athletesCount = group.athleteIds.length;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _viewGroupDetails(group),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Imagen circular
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.mediumGray,
                    child: Icon(
                      Icons.group,
                      size: 30,
                      color: hasCoach ? AppTheme.embers : AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Información del grupo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: AppTheme.h3Size,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.magnoliaWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.description ?? 'description',
                          style: const TextStyle(
                            fontSize: AppTheme.bodySize,
                            color: AppTheme.lightGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasAthletes
                              ? '$athletesCount miembros'
                              : 'Sin miembros',
                          style: const TextStyle(
                            fontSize: AppTheme.h3Size,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.magnoliaWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Barra de fotografías (simulada con círculos)
            if (hasAthletes)
              Container(
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Mostramos hasta 5 atletas
                    ...List.generate(athletesCount > 5 ? 5 : athletesCount, (index) => 
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.darkGray,
                        ),
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.person, color: AppTheme.lightGray),
                      )
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 