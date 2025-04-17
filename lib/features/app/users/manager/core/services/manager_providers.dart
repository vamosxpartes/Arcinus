import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para obtener la lista de gerentes (incluyendo pendientes)
final managersProvider = FutureProvider.family<List<dynamic>, String>((ref, academyId) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getUsersByRoleWithPending(UserRole.manager, academyId: academyId);
}); 