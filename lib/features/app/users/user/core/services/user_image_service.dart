import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Servicio para gestionar las imágenes de perfil de usuarios
/// 
/// Proporciona métodos para subir, descargar y gestionar imágenes de perfil
/// en Firebase Storage y localmente
class UserImageService {
  final FirebaseStorage _storage;
  
  UserImageService({FirebaseStorage? storage}) 
      : _storage = storage ?? FirebaseStorage.instance;
  
  /// Preparar una imagen de perfil localmente (sin subir a Firebase)
  ///
  /// Este método sólo guarda la imagen localmente y devuelve la ruta
  /// para ser utilizada al guardar el formulario completo
  ///
  /// [imagePath] es la ruta local de la imagen
  /// 
  /// Retorna la ruta local donde se guardó permanentemente la imagen
  Future<String> prepareProfileImage({
    required String imagePath,
  }) async {
    try {
      developer.log(
        'Preparando imagen de perfil localmente - Ruta: $imagePath',
        name: 'UserImageService',
      );
      
      // Guardar la imagen localmente en una ubicación permanente
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${const Uuid().v4()}.jpg';
      final String permanentPath = path.join(appDir.path, 'profile_images', fileName);
      
      // Crear directorio si no existe
      final Directory profileImagesDir = Directory(path.dirname(permanentPath));
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }
      
      // Copiar archivo a ubicación permanente
      final File savedFile = await File(imagePath).copy(permanentPath);
      
      developer.log(
        'Imagen preparada localmente con éxito en: ${savedFile.path}',
        name: 'UserImageService',
      );
      
      return savedFile.path;
    } catch (e) {
      developer.log(
        'Error al preparar imagen de perfil: $e',
        name: 'UserImageService',
        error: e,
      );
      rethrow;
    }
  }
  
  /// Sube una imagen de perfil a Firebase Storage
  ///
  /// [imagePath] es la ruta local de la imagen a subir
  /// [userId] es el ID del usuario asociado a la imagen (opcional)
  /// [academyId] es el ID de la academia (opcional)
  /// 
  /// Retorna la URL de descarga de la imagen subida
  Future<String> uploadProfileImage({
    required String imagePath,
    String? userId,
    String? academyId,
  }) async {
    try {
      // Usar una estructura más organizada para el almacenamiento
      final String fileName = userId != null 
        ? 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : 'pending_profile_${const Uuid().v4()}.jpg';
      
      // Organizar por academia si está disponible
      final String storagePath = userId != null 
        ? academyId != null
          ? 'profile_images/academies/$academyId/users/$userId/$fileName'
          : 'profile_images/users/$userId/$fileName'
        : 'profile_images/pending/$fileName';
        
      final Reference storageRef = _storage.ref().child(storagePath);
      
      developer.log(
        'Subiendo imagen de perfil a Storage - Ruta: $imagePath\nRuta Storage: $storagePath',
        name: 'UserImageService',
      );
      
      // Configurar metadata
      final SettableMetadata metadata = SettableMetadata(
        customMetadata: {
          if (userId != null) 'userId': userId,
          if (academyId != null) 'academyId': academyId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Subir archivo con metadata
      final UploadTask uploadTask = storageRef.putFile(File(imagePath), metadata);
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Obtener URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      developer.log(
        'Imagen subida exitosamente - URL: $downloadUrl',
        name: 'UserImageService',
      );
      
      // Guardar la imagen localmente
      await saveImageLocally(imageUrl: downloadUrl, localImagePath: imagePath);
      
      return downloadUrl;
    } catch (e) {
      developer.log(
        'Error al subir imagen de perfil: $e',
        name: 'UserImageService',
        error: e,
      );
      rethrow;
    }
  }
  
  /// Guarda una imagen en el almacenamiento local del dispositivo
  ///
  /// [imageUrl] es la URL remota de la imagen (para referencia)
  /// [localImagePath] es la ruta de la imagen local que se guardará permanentemente
  Future<String> saveImageLocally({
    required String imageUrl,
    required String localImagePath,
  }) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(localImagePath);
      final String permanentPath = path.join(appDir.path, 'profile_images', fileName);
      
      developer.log(
        'Guardando imagen localmente - URL: $imageUrl - Ruta: $permanentPath',
        name: 'UserImageService',
      );
      
      // Crear directorio si no existe
      final Directory profileImagesDir = Directory(path.dirname(permanentPath));
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }
      
      // Copiar archivo a ubicación permanente
      final File savedFile = await File(localImagePath).copy(permanentPath);
      
      developer.log(
        'Imagen guardada localmente con éxito en: ${savedFile.path}',
        name: 'UserImageService',
      );
      
      return savedFile.path;
    } catch (e) {
      developer.log(
        'Error al guardar imagen localmente: $e',
        name: 'UserImageService',
        error: e,
      );
      rethrow;
    }
  }
  
  /// Obtiene una imagen desde Firebase Storage o desde el almacenamiento local
  ///
  /// [imageUrl] es la URL de la imagen en Firebase Storage
  /// 
  /// Primero intenta encontrar la imagen localmente, y si no está disponible
  /// la descarga desde Firebase Storage y la guarda localmente
  Future<File?> getProfileImage(String imageUrl) async {
    try {
      // Extraer el nombre del archivo de la URL
      final Uri uri = Uri.parse(imageUrl);
      final String fileName = path.basename(uri.path);
      
      developer.log(
        'Buscando imagen de perfil - URL: $imageUrl - Archivo: $fileName',
        name: 'UserImageService',
      );
      
      // Buscar en almacenamiento local
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String localPath = path.join(appDir.path, 'profile_images', fileName);
      final File localFile = File(localPath);
      
      // Verificar si existe localmente
      if (await localFile.exists()) {
        developer.log(
          'Imagen encontrada localmente: $localPath',
          name: 'UserImageService',
        );
        return localFile;
      }
      
      // Si no existe localmente, descargar desde Storage
      developer.log(
        'Imagen no encontrada localmente, descargando desde Storage',
        name: 'UserImageService',
      );
      
      // Descargar desde Storage
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = path.join(tempDir.path, fileName);
      final File tempFile = File(tempPath);
      
      await _storage.refFromURL(imageUrl).writeToFile(tempFile);
      
      // Guardar permanentemente
      final String savedPath = await saveImageLocally(
        imageUrl: imageUrl,
        localImagePath: tempPath,
      );
      
      return File(savedPath);
    } catch (e) {
      developer.log(
        'Error al obtener imagen de perfil: $e',
        name: 'UserImageService',
        error: e,
      );
      return null;
    }
  }
  
  /// Elimina una imagen de perfil de Firebase Storage y localmente
  ///
  /// [imageUrl] es la URL de la imagen en Firebase Storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      developer.log(
        'Eliminando imagen de perfil - URL: $imageUrl',
        name: 'UserImageService',
      );
      
      // Eliminar de Storage
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      
      // Eliminar localmente
      final Uri uri = Uri.parse(imageUrl);
      final String fileName = path.basename(uri.path);
      
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String localPath = path.join(appDir.path, 'profile_images', fileName);
      final File localFile = File(localPath);
      
      if (await localFile.exists()) {
        await localFile.delete();
      }
      
      developer.log(
        'Imagen eliminada con éxito',
        name: 'UserImageService',
      );
    } catch (e) {
      developer.log(
        'Error al eliminar imagen de perfil: $e',
        name: 'UserImageService',
        error: e,
      );
      // No lanzamos excepción para evitar que un error en la eliminación
      // bloquee el proceso principal
    }
  }
}

/// Provider para el servicio de imágenes de usuario
final userImageServiceProvider = Provider<UserImageService>((ref) {
  return UserImageService();
}); 