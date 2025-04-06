import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/shared/models/academy.dart';
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
    String? location,
    String? taxId,
    String? description,
    Map<String, dynamic>? sportCharacteristics,
    String subscription = 'free', // Plan por defecto
  }) async {
    final docRef = _academiesCollection.doc();
    
    final academy = Academy(
      id: docRef.id,
      name: name,
      ownerId: ownerId,
      sport: sport,
      logo: logo,
      location: location,
      taxId: taxId,
      description: description,
      sportCharacteristics: sportCharacteristics,
      subscription: subscription,
      createdAt: DateTime.now(),
    );
    
    final json = academy.toJson();
    
    // Usamos una transacción para garantizar que ambas operaciones se completen o fallen juntas
    await _firestore.runTransaction((transaction) async {
      // 1. Crear la academia
      transaction.set(docRef, json);
      
      // 2. Actualizar el array academyIds del usuario propietario
      final userRef = _firestore.collection('users').doc(ownerId);
      transaction.update(userRef, {
        'academyIds': FieldValue.arrayUnion([docRef.id]),
      });
    });
    
    return academy;
  }

  // Obtener academia por ID
  Future<Academy?> getAcademy(String academyId) async {
    final docSnap = await _academiesCollection.doc(academyId).get();
    
    if (!docSnap.exists) {
      return null;
    }
    
    final data = docSnap.data()!;
    data['id'] = docSnap.id;
    return Academy.fromJson(data);
  }

  // Obtener academias por propietario
  Future<List<Academy>> getAcademiesByOwner(String ownerId) async {
    final querySnap = await _academiesCollection
        .where('ownerId', isEqualTo: ownerId)
        .get();
    
    return querySnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Academy.fromJson(data);
    }).toList();
  }

  // Actualizar academia
  Future<void> updateAcademy(Academy academy) async {
    final json = academy.toJson();
    await _academiesCollection.doc(academy.id).update(json);
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
      await _academiesCollection.doc(academyId).update({'logo': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      developer.log('Error al subir logo de academia: $e');
      rethrow;
    }
  }

  // Eliminar academia
  Future<void> deleteAcademy(String academyId) async {
    await _academiesCollection.doc(academyId).delete();
  }
} 