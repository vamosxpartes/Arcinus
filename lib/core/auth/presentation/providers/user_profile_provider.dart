import 'package:arcinus/core/models/user_model.dart';
import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Helper para crear un UserModel seguro a partir de datos que podrían contener campos nulos
UserModel? createSafeUserModel(Map<String, dynamic>? data, String userId) {
  if (data == null) return null;
  
  try {
    return UserModel.fromJson(data);
  } catch (e, s) {
    // Intentar crear un modelo básico
    try {
      AppLogger.logWarning(
        'Error al parsear UserModel, creando modelo básico',
        error: e,
        className: 'userProfileProvider',
        functionName: 'createSafeUserModel'
      );
      
      // Crear manualmente un modelo con la información mínima
      return UserModel(
        id: userId,
        email: data['email'] as String? ?? 'unknown@email.com',
        name: data['displayName'] as String? ?? data['name'] as String?,
        profilePictureUrl: data['photoUrl'] as String?,
        createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is DateTime 
              ? data['createdAt'] as DateTime 
              : DateTime.now())
          : DateTime.now(),
      );
    } catch (e2) {
      AppLogger.logError(
        message: 'Error creando modelo básico',
        error: e2,
        stackTrace: s,
        className: 'userProfileProvider',
        functionName: 'createSafeUserModel'
      );
      return null;
    }
  }
}

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
        final data = docSnapshot.data()!;
        
        // Si hay un campo profileCompleted, considerarlo correctamente
        final profileCompleted = data['profileCompleted'];
        if (profileCompleted == true) {
          AppLogger.logInfo(
            'Perfil detectado como completado en Firestore',
            className: 'userProfileProvider',
            functionName: 'mapSnapshot'
          );
        }
        
        // Intentar usar una deserialización segura
        final userModel = createSafeUserModel(data, userId);
        if (userModel != null) {
          return userModel;
        }
        
        // Si falla, intentar deserialización normal
        return UserModel.fromJson(data);
      } catch (e, s) {
        AppLogger.logError(
          message: 'Error parsing UserModel for $userId',
          error: e,
          stackTrace: s
        );
        
        // Crear un userModel vacío pero válido para evitar bloqueos de navegación
        return UserModel(
          id: userId,
          email: 'error@parsing.model',
          name: 'Usuario temporal',
        );
      }
    } else {
      return null; // Documento no existe
    }
  });
}); 