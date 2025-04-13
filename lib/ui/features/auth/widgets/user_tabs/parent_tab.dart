import 'package:arcinus/ui/features/auth/screens/parent_list_screen.dart';
import 'package:arcinus/ui/features/auth/widgets/shared/user_search_bar.dart';
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
} 