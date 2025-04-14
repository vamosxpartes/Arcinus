import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de atletas
final athletesProvider = FutureProvider.family<List<User>, String>((ref, academyId) {
  final userService = ref.watch(userServiceProvider);
  // Asegúrate de que UserRole esté importado si es necesario, o usa el valor directamente.
  // Si UserRole viene de models/user.dart, ya está cubierto por la importación de User.
  return userService.getUsersByRole(UserRole.athlete, academyId: academyId);
}); 