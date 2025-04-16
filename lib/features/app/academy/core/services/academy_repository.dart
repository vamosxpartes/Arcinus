import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/features/app/academy/core/models/academy_model.dart';
import 'package:arcinus/features/app/sports/core/models/sport_characteristics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final academyRepositoryProvider = Provider<AcademyRepository>((ref) {
  return AcademyRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

class AcademyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AcademyRepository(this._firestore, this._storage);

  // Colección de academias
  CollectionReference<Map<String, dynamic>> get _academiesCollection =>
      _firestore.collection('academies');

  // Crear una nueva academia
  Future<Academy> createAcademy({
    required String name,
    required String ownerId,
    required String sport,
    String? logo,
    String? academyFormattedAddress,
    double? academyLatitude,
    double? academyLongitude,
    String? academyGooglePlaceId,
    String? taxId,
    String? description,
    Map<String, dynamic>? sportConfig,
    String subscription = 'free', // Plan por defecto
  }) async {
    developer.log('DEBUG: Iniciando creación de academia: name=$name, ownerId=$ownerId, sport=$sport');
    
    try {
      final docRef = _academiesCollection.doc();
      developer.log('DEBUG: Generado ID para nueva academia: ${docRef.id}');
      
      // Si no se proporcionan configuraciones del deporte, generarlas y convertirlas a JSON
      final Map<String, dynamic> finalSportConfig;
      if (sportConfig != null) {
        finalSportConfig = sportConfig;
        developer.log('DEBUG: Usando configuración de deporte proporcionada');
      } else {
        finalSportConfig = SportCharacteristics.forSport(sport).toJson();
        developer.log('DEBUG: Generada configuración automática para deporte: $sport');
      }
      
      final academy = Academy(
        academyId: docRef.id,
        academyName: name,
        academyOwnerId: ownerId,
        academySport: sport,
        academyLogo: logo,
        academyFormattedAddress: academyFormattedAddress,
        academyLatitude: academyLatitude,
        academyLongitude: academyLongitude,
        academyGooglePlaceId: academyGooglePlaceId,
        academyTaxId: taxId,
        academyDescription: description,
        academySportConfig: SportCharacteristics.fromJson(finalSportConfig),
        academySubscription: subscription,
        createdAt: DateTime.now(),
      );
      
      // Para almacenar en Firestore, aseguramos que todo es serializable
      final json = academy.toJson();
      
      // Asegurar que sportConfig es un mapa y no un objeto SportCharacteristics
      // para evitar errores de serialización
      json['academySportConfig'] = finalSportConfig;
      
      developer.log('DEBUG: Preparando transacción para academia ${docRef.id}');
      
      // Verificar si el documento del usuario existe antes de la transacción
      final userRef = _firestore.collection('owners').doc(ownerId);
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        developer.log('ERROR: Documento de usuario no encontrado: $ownerId');
        throw Exception('Usuario con ID $ownerId no encontrado en Firestore');
      }
      
      developer.log('DEBUG: Documento de usuario encontrado, procediendo con la transacción');
      
      // Usamos una transacción para garantizar que ambas operaciones se completen o fallen juntas
      await _firestore.runTransaction((transaction) async {
        developer.log('DEBUG: Iniciando transacción para crear academia');
        
        // 1. Crear la academia
        developer.log('DEBUG: Guardando documento de academia en Firestore');
        transaction.set(docRef, json);
        
        // 2. Actualizar el array academyIds del usuario propietario
        developer.log('DEBUG: Actualizando academyIds del usuario $ownerId');
        transaction.update(userRef, {
          'academyIds': FieldValue.arrayUnion([docRef.id]),
        });
        
        developer.log('DEBUG: Transacción preparada correctamente');
      });
      
      developer.log('DEBUG: Academia creada exitosamente con ID: ${docRef.id}');
      return academy;
    } catch (e) {
      developer.log('ERROR: Error al crear academia: $e', error: e);
      rethrow;
    }
  }

  // Obtener academia por ID
  Future<Academy?> getAcademy(String academyId) async {
    developer.log('DEBUG: AcademyRepository.getAcademy - Buscando academia con ID: $academyId');
    
    try {
      final docSnap = await _academiesCollection.doc(academyId).get();
      
      if (!docSnap.exists) {
        developer.log('DEBUG: AcademyRepository.getAcademy - Academia no encontrada: $academyId');
        return null;
      }
      
      developer.log('DEBUG: AcademyRepository.getAcademy - Academia encontrada: $academyId');
      final data = docSnap.data()!;
      data['academyId'] = docSnap.id;
      
      // Generar sportConfig si no existe
      if (!data.containsKey('academySportConfig') && data.containsKey('academySport')) {
        developer.log('DEBUG: AcademyRepository.getAcademy - Generando sportConfig para academia $academyId');
        final sportConfig = SportCharacteristics.forSport(data['academySport'] as String);
        data['academySportConfig'] = sportConfig.toJson();
      }
      
      return Academy.fromJson(data);
    } catch (e) {
      developer.log('ERROR: AcademyRepository.getAcademy - Error al obtener academia: $e', error: e);
      rethrow;
    }
  }

  // Obtener academias por propietario
  Future<List<Academy>> getAcademiesByOwner(String ownerId) async {
    developer.log('DEBUG: AcademyRepository.getAcademiesByOwner - Buscando academias para propietario: $ownerId');
    
    try {
      final querySnap = await _academiesCollection
          .where('academyOwnerId', isEqualTo: ownerId)
          .get();
      
      developer.log('DEBUG: AcademyRepository.getAcademiesByOwner - Consulta ejecutada, documentos encontrados: ${querySnap.docs.length}');
      
      return querySnap.docs.map((doc) {
        final data = doc.data();
        data['academyId'] = doc.id;
        
        // Generar sportConfig si no existe
        if (!data.containsKey('academySportConfig') && data.containsKey('academySport')) {
          developer.log('DEBUG: AcademyRepository.getAcademiesByOwner - Generando sportConfig para academia ${doc.id}');
          final sportConfig = SportCharacteristics.forSport(data['academySport'] as String);
          data['academySportConfig'] = sportConfig.toJson();
        }
        
        return Academy.fromJson(data);
      }).toList();
    } catch (e) {
      developer.log('ERROR: AcademyRepository.getAcademiesByOwner - Error al obtener academias: $e', error: e);
      rethrow;
    }
  }

  // Método para obtener todas las academias
  Future<List<Academy>> getAllAcademies() async {
    developer.log('DEBUG: AcademyRepository.getAllAcademies - Obteniendo todas las academias');
    try {
      final querySnap = await _academiesCollection.get();
      developer.log('DEBUG: AcademyRepository.getAllAcademies - Documentos encontrados: ${querySnap.docs.length}');

      return querySnap.docs.map((doc) {
        final data = doc.data();
        data['academyId'] = doc.id;

        // Generar sportConfig si no existe
        if (!data.containsKey('academySportConfig') && data.containsKey('academySport')) {
          developer.log('DEBUG: AcademyRepository.getAllAcademies - Generando sportConfig para academia ${doc.id}');
          final sportConfig = SportCharacteristics.forSport(data['academySport'] as String);
          data['academySportConfig'] = sportConfig.toJson();
        }
        
        return Academy.fromJson(data);
      }).toList();
    } catch (e) {
      developer.log('ERROR: AcademyRepository.getAllAcademies - Error al obtener todas las academias: $e', error: e);
      rethrow;
    }
  }

  // Actualizar academia
  Future<void> updateAcademy(Academy academy) async {
    // Asegurarse de que haya características del deporte
    Academy academyToUpdate = academy;
    
    if (academyToUpdate.academySportConfig == null) {
      // Generar automáticamente las características del deporte si no están presentes
      final sportConfig = SportCharacteristics.forSport(academyToUpdate.academySport);
      academyToUpdate = academyToUpdate.copyWith(academySportConfig: sportConfig);
    }
    
    final json = academyToUpdate.toJson();
    await _academiesCollection.doc(academyToUpdate.academyId).update(json);
  }

  // Subir logo de academia
  Future<String> uploadAcademyLogo(String academyId, String filePath) async {
    try {
      // Crear una referencia específica para este archivo
      final ref = _storage.ref().child('academies').child(academyId).child('logo.jpg');
      
      // Validar que el archivo existe localmente
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('El archivo no existe: $filePath');
      }
      
      // Subir el archivo
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg', // Definimos el tipo de contenido
          customMetadata: {'academyId': academyId},
        ),
      );
      
      // Obtener la URL de descarga
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      // Actualizar el documento de la academia con la URL
      await _academiesCollection.doc(academyId).update({'academyLogo': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      developer.log('Error al subir logo de academia: $e');
      rethrow;
    }
  }

  // Eliminar academia
  Future<void> deleteAcademy(String academyId) async {
    developer.log('DEBUG: AcademyRepository.deleteAcademy - Eliminando academia: $academyId');
    
    try {
      await _academiesCollection.doc(academyId).delete();
      developer.log('DEBUG: AcademyRepository.deleteAcademy - Academia eliminada con éxito: $academyId');
    } catch (e) {
      developer.log('ERROR: AcademyRepository.deleteAcademy - Error al eliminar academia: $e', error: e);
      rethrow;
    }
  }
} 