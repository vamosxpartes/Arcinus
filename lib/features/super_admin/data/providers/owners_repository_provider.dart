import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/providers/firebase_providers.dart';
import 'package:arcinus/features/super_admin/data/repositories/owners_management_repository.dart';

/// Provider para el repositorio de gestión de propietarios
final ownersManagementRepositoryProvider = Provider<OwnersManagementRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return OwnersManagementRepositoryImpl(firestore: firestore);
}); 