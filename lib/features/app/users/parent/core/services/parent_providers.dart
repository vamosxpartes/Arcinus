import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para la lista de padres
final parentsProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final currentAcademy = ref.watch(currentAcademyProvider);
  if (currentAcademy == null) {
    throw Exception('No hay academia seleccionada');
  }

  final userService = ref.read(userServiceProvider);
  return userService.getUsersByRole(UserRole.parent, academyId: currentAcademy.id);
}); 