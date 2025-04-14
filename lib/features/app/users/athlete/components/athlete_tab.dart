import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/athlete/core/services/athlete_providers.dart';
import 'package:arcinus/features/app/users/athlete/screens/athlete_form_screen.dart';
import 'package:arcinus/features/app/users/user/core/services/user_management_provider.dart';
import 'package:arcinus/features/theme/components/inputs/user_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AthleteTab extends ConsumerWidget {
  final TextEditingController searchController;

  const AthleteTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagement = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    return Column(
      children: [
        // Barra de búsqueda con botón de agregar atleta
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar atletas...',
          onSearch: (query) => userManagementNotifier.updateSearchQuery(query),
        ),
        
        const Divider(),
        
        // Lista de atletas
        Expanded(
          child: _buildAthleteList(context, ref, userManagement.searchQuery),
        ),
      ],
    );
  }

  Widget _buildAthleteList(BuildContext context, WidgetRef ref, String searchQuery) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    if (currentAcademy == null) {
      return const Center(
        child: Text('No hay academia seleccionada'),
      );
    }
    
    final athletesData = ref.watch(athletesProvider(currentAcademy.id));
    
    return athletesData.when(
      data: (athletes) {
        // Filtrar atletas según búsqueda
        final filteredAthletes = athletes.where((athlete) => 
            athlete.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        
        if (filteredAthletes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No hay atletas registrados'
                      : 'No se encontraron atletas con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: filteredAthletes.length,
          itemBuilder: (context, index) {
            final athlete = filteredAthletes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: athlete.profileImageUrl != null
                      ? ClipOval(
                          child: Image.network(
                            athlete.profileImageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.fitness_center, color: Colors.white),
                ),
                title: Text(athlete.name),
                subtitle: Text(athlete.email),
                onTap: () => _editAthlete(context, ref, athlete.id, currentAcademy.id),
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

  void _editAthlete(BuildContext context, WidgetRef ref, String athleteId, String academyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AthleteFormScreen(
          mode: AthleteFormMode.edit,
          userId: athleteId,
          academyId: academyId,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refrescar datos
        ref.invalidate(athletesProvider(academyId));
      }
    });
  }
} 