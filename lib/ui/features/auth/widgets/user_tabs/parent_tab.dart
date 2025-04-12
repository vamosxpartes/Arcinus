import 'package:arcinus/ui/features/auth/screens/parent_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/parent_list_screen.dart';
import 'package:arcinus/ui/features/auth/widgets/shared/user_search_bar.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/user_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParentTab extends ConsumerWidget {
  final TextEditingController searchController;

  const ParentTab({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userManagement = ref.watch(userManagementProvider);
    final userManagementNotifier = ref.read(userManagementProvider.notifier);

    return Column(
      children: [
        // Barra de búsqueda con botón de agregar padre
        UserSearchBar(
          controller: searchController,
          hintText: 'Buscar padres...',
          onSearch: (query) => userManagementNotifier.updateSearchQuery(query),
          onAddPressed: () => _addParent(context, ref),
          addButtonTooltip: 'Agregar Responsable',
        ),
        
        const Divider(),
        
        // Lista de padres
        Expanded(
          child: ParentListScreen(
            searchQuery: userManagement.searchQuery,
            onRefresh: () => searchController.clear(),
          ),
        ),
      ],
    );
  }

  void _addParent(BuildContext context, WidgetRef ref) {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay academia seleccionada')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentFormScreen(
          mode: ParentFormMode.create,
          academyId: currentAcademy.id,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refrescar datos
        ref.invalidate(parentsProvider);
      }
    });
  }
} 