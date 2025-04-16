import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/coach/core/services/coach_providers.dart';
import 'package:arcinus/features/app/users/coach/screens/coach_form_screen.dart';
import 'package:arcinus/features/app/users/user/core/services/user_management_provider.dart';
import 'package:arcinus/features/theme/components/inputs/user_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoachTab extends ConsumerWidget {
  final TextEditingController searchController;

  const CoachTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagement = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    return Column(
      children: [
        // Barra de búsqueda con botón de agregar entrenador
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar entrenadores...',
          onSearch: (query) => userManagementNotifier.updateSearchQuery(query),
        ),
        
        const Divider(),
        
        // Lista de entrenadores
        Expanded(
          child: _buildCoachList(context, ref, userManagement.searchQuery),
        ),
      ],
    );
  }

  Widget _buildCoachList(BuildContext context, WidgetRef ref, String searchQuery) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    if (currentAcademy == null) {
      return const Center(
        child: Text('No hay academia seleccionada'),
      );
    }
    
    final coachesData = ref.watch(coachesProvider(currentAcademy.academyId));
    
    return coachesData.when(
      data: (coaches) {
        // Filtrar entrenadores según búsqueda
        final filteredCoaches = coaches.where((coach) => 
            coach.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        
        if (filteredCoaches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No hay entrenadores registrados'
                      : 'No se encontraron entrenadores con esa búsqueda',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: filteredCoaches.length,
          itemBuilder: (context, index) {
            final coach = filteredCoaches[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
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
                onTap: () => _editCoach(context, ref, coach.id, currentAcademy.academyId),
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

  void _editCoach(BuildContext context, WidgetRef ref, String coachId, String academyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoachFormScreen(
          mode: CoachFormMode.edit,
          userId: coachId,
          academyId: academyId,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refrescar datos
        ref.invalidate(coachesProvider(academyId));
      }
    });
  }
} 