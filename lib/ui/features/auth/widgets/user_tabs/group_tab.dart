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
        ),
        
        const Divider(),
        
        // Lista de grupos
        const Expanded(
          child: GroupListScreen(),
        ),
      ],
    );
  }

} 