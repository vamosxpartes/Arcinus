import 'package:arcinus/core/auth/data/models/user_model.dart';
import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Helper para crear un UserModel seguro a partir de datos que podrían contener campos nulos
UserModel? createSafeUserModel(Map<String, dynamic>? data, String userId) {
  if (data == null) return null;
  
  try {
    // Validar campos requeridos primero
    if (!data.containsKey('email') || data['email'] == null) {
      AppLogger.logWarning(
        'Campo email faltante o null en UserModel, usando email por defecto',
        className: 'userProfileProvider',
        functionName: 'createSafeUserModel',
        params: {'userId': userId, 'data': data}
      );
      data['email'] = 'usuario_$userId@temporal.com';
    }

    // Sanitizar campos string que podrían ser null
    final sanitizedData = Map<String, dynamic>.from(data);
    
    // Asegurar que email es string
    sanitizedData['email'] = sanitizedData['email']?.toString() ?? 'usuario_$userId@temporal.com';
    
    // Asegurar que displayName es string o null (no otro tipo)
    final displayName = sanitizedData['displayName'];
    if (displayName != null && displayName is! String) {
      sanitizedData['displayName'] = displayName.toString();
    }
    
    // Asegurar que photoUrl es string o null
    final photoUrl = sanitizedData['photoUrl'];
    if (photoUrl != null && photoUrl is! String) {
      sanitizedData['photoUrl'] = photoUrl.toString();
    }
    
    // Manejar fechas de creación
    if (!sanitizedData.containsKey('createdAt') || sanitizedData['createdAt'] == null) {
      sanitizedData['createdAt'] = DateTime.now();
    }
    
    AppLogger.logInfo(
      'Datos sanitizados para UserModel',
      className: 'userProfileProvider',
      functionName: 'createSafeUserModel',
      params: {
        'userId': userId,
        'sanitizedKeys': sanitizedData.keys.toList(),
        'emailType': sanitizedData['email'].runtimeType.toString(),
        'displayNameType': sanitizedData['displayName']?.runtimeType.toString(),
      }
    );
    
    return UserModel.fromJson(sanitizedData);
  } catch (e, s) {
    // Intentar crear un modelo básico
    try {
      AppLogger.logWarning(
        'Error al parsear UserModel, creando modelo básico',
        error: e,
        className: 'userProfileProvider',
        functionName: 'createSafeUserModel',
        params: {
          'userId': userId,
          'originalError': e.toString(),
        }
      );
      
      // Crear manualmente un modelo con la información mínima
      return UserModel(
        id: userId,
        email: _extractSafeString(data, 'email') ?? 'unknown@email.com',
        displayName: _extractSafeString(data, 'displayName') ?? _extractSafeString(data, 'name'),
        photoUrl: _extractSafeString(data, 'photoUrl'),
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
        functionName: 'createSafeUserModel',
        params: {'userId': userId}
      );
      return null;
    }
  }
}

/// Helper para extraer strings de forma segura
String? _extractSafeString(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString().isEmpty ? null : value.toString();
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
          displayName: 'Usuario temporal',
        );
      }
    } else {
      return null; // Documento no existe
    }
  });
}); 