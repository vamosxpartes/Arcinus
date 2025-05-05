import 'package:arcinus/core/models/user_model.dart';
import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

// Instancia de Logger
final _logger = Logger();

/// Provider that provides a stream of the user's profile data.
///
/// Listens to the user's document in Firestore based on their UID.
final userProfileProvider = 
    StreamProvider.family<UserModel?, String>((ref, userId) {
  if (userId.isEmpty) {
    return Stream.value(null); // No user ID, no profile
  }
  final firestore = ref.watch(firestoreProvider);
  final docRef = firestore.collection('users').doc(userId);

  // Escuchar los cambios en el documento
  final snapshots = docRef.snapshots();

  // Mapear los snapshots a UserModel
  return snapshots.map((docSnapshot) {
    if (docSnapshot.exists && docSnapshot.data() != null) {
      try {
        return UserModel.fromJson(docSnapshot.data()!);
      } catch (e, s) {
        _logger.e('Error parsing UserModel for $userId', error: e, stackTrace: s);
        // Podrías devolver null o lanzar un error específico
        return null; 
      }
    } else {
      return null; // Documento no existe
    }
  });
}); 