import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that checks if an owner has at least one academy.
///
/// Returns `true` if one or more academies exist for the given ownerId,
/// `false` otherwise.
final ownerHasAcademiesProvider =
    StreamProvider.family<bool, String>((ref, ownerId) {
  if (ownerId.isEmpty) {
    return Stream.value(false); // No owner ID, no academies
  }
  final firestore = ref.watch(firestoreProvider);

  // Query for academies owned by the user, limiting to 1 result for efficiency
  final query = firestore
      .collection('academies')
      .where('ownerId', isEqualTo: ownerId)
      .limit(1);

  // Escuchar los snapshots de la query
  final snapshots = query.snapshots();

  // Mapear el snapshot a un booleano (si hay algún documento, tiene academias)
  return snapshots.map((querySnapshot) => querySnapshot.docs.isNotEmpty);
}); 