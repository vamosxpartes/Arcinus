import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/data/repositories/academy_users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'academy_users_providers.g.dart';

// Provider para todos los usuarios de una academia
@riverpod
Stream<List<AcademyUserModel>> academyUsers(Ref ref, String academyId) {
  final repository = ref.watch(academyUsersRepositoryProvider);
  return repository.getAcademyUsers(academyId);
}

// Provider para usuarios filtrados por rol
@riverpod
Stream<List<AcademyUserModel>> academyUsersByRole(
  Ref ref, 
  String academyId, 
  AppRole role,
) {
  final repository = ref.watch(academyUsersRepositoryProvider);
  
  // Asegurarnos de que estamos pasando el nombre del rol en minúsculas para coincidir con Firebase
  final roleName = role.name.toLowerCase();
  
  // Log para depuración
  print('PROVIDER DEBUG: Filtrando por rol "${roleName}" en academia $academyId');
  
  return repository.getUsersByRole(academyId, roleName);
}

// Provider para buscar un usuario específico
@riverpod
Future<AcademyUserModel?> academyUserDetails(
  Ref ref,
  String academyId,
  String userId,
) async {
  final repository = ref.watch(academyUsersRepositoryProvider);
  return repository.getUserById(academyId, userId);
}

// Provider de estado para el término de búsqueda
@riverpod
class SearchTermNotifier extends _$SearchTermNotifier {
  @override
  String build() {
    return '';
  }
  
  void updateSearchTerm(String term) {
    state = term;
  }
  
  void clearSearchTerm() {
    state = '';
  }
}

// Provider para resultados de búsqueda
@riverpod
Future<List<AcademyUserModel>> academyUsersSearch(
  Ref ref,
  String academyId,
) async {
  final searchTerm = ref.watch(searchTermNotifierProvider);
  
  // Si el término de búsqueda está vacío, devolver lista vacía
  if (searchTerm.isEmpty) {
    return [];
  }
  
  final repository = ref.watch(academyUsersRepositoryProvider);
  return repository.searchUsersByName(academyId, searchTerm);
} 