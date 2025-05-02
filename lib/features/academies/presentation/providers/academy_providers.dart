import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:arcinus/features/academies/data/repositories/academy_repository_impl.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'academy_providers.g.dart';

/// Provider que expone la implementación del [AcademyRepository].
///
/// Utiliza el provider de Firestore para obtener la instancia necesaria.
@riverpod
AcademyRepository academyRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return AcademyRepositoryImpl(firestore);
}

// Aquí se podrían añadir otros providers relacionados con academias,
// como un provider para obtener la lista de academias del usuario, etc. 