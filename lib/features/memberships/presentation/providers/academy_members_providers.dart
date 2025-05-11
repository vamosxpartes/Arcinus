import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para buscar miembros específicos por pestaña con filtros 
final membersScreenSearchProvider = FutureProvider.family<List<AcademyUserModel>, ({String academyId, String searchTerm, AppRole? role})>(
  (ref, params) async {
    final repository = ref.watch(academyUsersRepositoryProvider);
    // Si getAcademyUsers devuelve un Stream, tomamos el primer evento para que sea un Future.
    final List<AcademyUserModel> allUsers = await repository.getAcademyUsers(params.academyId).first;
    
    List<AcademyUserModel> filteredUsers = allUsers;

    if (params.role != null) {
      filteredUsers = filteredUsers.where((user) => user.role == params.role!.name).toList();
    }

    if (params.searchTerm.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        final searchTermLower = params.searchTerm.toLowerCase();
        return user.fullName.toLowerCase().contains(searchTermLower);
      }).toList();
    }
    return filteredUsers;
  }
); 