import 'package:arcinus/core/auth/domain/repositories/base_user_repository.dart';
import 'package:arcinus/core/auth/domain/repositories/academy_user_context_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// === Providers de repositorios centralizados ===
// Estos providers deben ser implementados con las versiones reales
// cuando se tengan las implementaciones de Firestore

/// Provider para el repositorio base de usuarios
final baseUserRepositoryProvider = Provider<BaseUserRepository>((ref) {
  throw UnimplementedError('BaseUserRepository implementation needed');
});

/// Provider para el repositorio de contextos de academia
final academyUserContextRepositoryProvider = Provider<AcademyUserContextRepository>((ref) {
  throw UnimplementedError('AcademyUserContextRepository implementation needed');
}); 