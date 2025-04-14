import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de entrenadores
final coachesProvider = FutureProvider.family<List<User>, String>((ref, academyId) {
  final userService = ref.watch(userServiceProvider);
  // Asegúrate de que UserRole esté importado si es necesario.
  return userService.getUsersByRole(UserRole.coach, academyId: academyId);
}); 