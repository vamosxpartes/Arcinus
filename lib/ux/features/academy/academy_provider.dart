import 'dart:developer' as developer;

import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/academy/academy_repository.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para la academia actual seleccionada
final currentAcademyProvider = StateProvider<Academy?>((ref) => null);

// Proveedor para cargar automáticamente la academia del propietario
final autoLoadAcademyProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (previous, next) async {
    developer.log('DEBUG: autoLoadAcademyProvider - Estado de autenticación cambiado');
    
    if (next.hasValue && next.value != null) {
      final user = next.value!;
      developer.log('DEBUG: autoLoadAcademyProvider - Usuario autenticado: ${user.id}, Rol: ${user.role}');
      
      // Si es propietario, establecer automáticamente su academia
      if (user.role == UserRole.owner) {
        if (user.academyIds.isNotEmpty) {
          developer.log('DEBUG: autoLoadAcademyProvider - Propietario con academias: ${user.academyIds}');
          final academyRepo = ref.read(academyRepositoryProvider);
          
          try {
            final academy = await academyRepo.getAcademy(user.academyIds.first);
            if (academy != null) {
              developer.log('DEBUG: autoLoadAcademyProvider - Academia cargada: ${academy.id} - ${academy.name}');
              // Actualiza la academia seleccionada
              ref.read(currentAcademyProvider.notifier).state = academy;
            } else {
              developer.log('ERROR: autoLoadAcademyProvider - No se encontró la academia ${user.academyIds.first} a pesar de estar en el usuario');
            }
          } catch (e) {
            developer.log('ERROR: autoLoadAcademyProvider - Error al cargar la academia: $e');
          }
        } else {
          developer.log('DEBUG: autoLoadAcademyProvider - Propietario sin academias');
          // Asegurarnos de que currentAcademyProvider sea null si no hay academias
          ref.read(currentAcademyProvider.notifier).state = null;
        }
      }
    } else {
      // Si el usuario no está autenticado, limpiar la academia actual
      ref.read(currentAcademyProvider.notifier).state = null;
      developer.log('DEBUG: autoLoadAcademyProvider - Usuario no autenticado, limpiando academia');
    }
  });
  
  // También escuchar cambios en userAcademiesProvider para mantener sincronizada la academia actual
  ref.listen(userAcademiesProvider, (previous, next) {
    if (next.hasValue) {
      final academies = next.value!;
      final currentUser = ref.read(authStateProvider).valueOrNull;
      
      if (currentUser?.role == UserRole.owner && academies.isNotEmpty) {
        // Verificar si ya hay una academia seleccionada
        final currentAcademy = ref.read(currentAcademyProvider);
        
        if (currentAcademy == null) {
          developer.log('DEBUG: autoLoadAcademyProvider - Seleccionando primera academia de la lista: ${academies.first.id}');
          ref.read(currentAcademyProvider.notifier).state = academies.first;
        }
      }
    }
  });
  
  return;
});

// Provider para obtener el ID de la academia actual
final currentAcademyIdProvider = Provider<String?>((ref) {
  // Asegurarse de que el auto-cargador de academia esté activo
  ref.watch(autoLoadAcademyProvider);
  
  final currentAcademy = ref.watch(currentAcademyProvider);
  return currentAcademy?.id;
});

// Provider para la lista de academias del usuario actual
final userAcademiesProvider = FutureProvider<List<Academy>>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) {
    return [];
  }
  
  final academyRepository = ref.watch(academyRepositoryProvider);
  final academies = await academyRepository.getAcademiesByOwner(user.id);
  
  developer.log('DEBUG: userAcademiesProvider - Academias cargadas: ${academies.length}');
  return academies;
});

// Provider para verificar si el usuario tiene que crear su primera academia
final needsAcademyCreationProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null || user.role != UserRole.owner) {
    return false;
  }
  
  final academies = await ref.watch(userAcademiesProvider.future);
  return academies.isEmpty;
});

// Provider para operaciones de academias
// Ahora definido en academy_controller.dart
// final academyControllerProvider = Provider((ref) {
//   final academyRepository = ref.watch(academyRepositoryProvider);
//   return AcademyController(ref, academyRepository);
// });

// La clase AcademyController ahora está en academy_controller.dart 