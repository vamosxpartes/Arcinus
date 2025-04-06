import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/academy/academy_repository.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para la academia actual seleccionada
final currentAcademyProvider = StateProvider<Academy?>((ref) => null);

// Provider para la lista de academias del usuario actual
final userAcademiesProvider = FutureProvider<List<Academy>>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    return [];
  }
  
  final academyRepository = ref.watch(academyRepositoryProvider);
  return await academyRepository.getAcademiesByOwner(user.id);
});

// Provider para verificar si el usuario tiene que crear su primera academia
final needsAcademyCreationProvider = FutureProvider<bool>((ref) async {
  final userAsync = ref.watch(authStateProvider);
  
  print('DEBUG: Estado de autenticación en needsAcademyCreationProvider: ${userAsync.toString().substring(0, 50)}...');
  
  // Si no hay usuario o está cargando, no necesita crear academia
  if (userAsync is! AsyncData || userAsync.value == null) {
    print('DEBUG: No hay usuario autenticado o está cargando');
    return false;
  }
  
  final user = userAsync.value!;
  print('DEBUG: Usuario en needsAcademyCreationProvider: ${user.email}, rol: ${user.role}');
  
  // Solo los propietarios necesitan crear academia
  if (user.role != UserRole.owner) {
    print('DEBUG: El usuario no es propietario, no necesita crear academia');
    return false;
  }
  
  try {
    // Verificar si ya tiene academias
    print('DEBUG: Verificando academias del propietario: ${user.id}');
    final academyRepository = ref.read(academyRepositoryProvider);
    final academies = await academyRepository.getAcademiesByOwner(user.id);
    print('DEBUG: Propietario tiene ${academies.length} academias');
    
    return academies.isEmpty;
  } catch (e) {
    print('DEBUG: Error al verificar academias: $e');
    rethrow;
  }
});

// Provider para operaciones de academias
// Ahora definido en academy_controller.dart
// final academyControllerProvider = Provider((ref) {
//   final academyRepository = ref.watch(academyRepositoryProvider);
//   return AcademyController(ref, academyRepository);
// });

// La clase AcademyController ahora está en academy_controller.dart 