import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/groups/screen/group_list_screen.dart';
import 'package:arcinus/features/app/users/user/core/services/user_management_provider.dart';
import 'package:arcinus/features/theme/components/inputs/user_search_bar.dart';
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