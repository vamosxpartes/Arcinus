import 'dart:developer' as developer;

import 'package:arcinus/features/app/groups/core/models/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupServiceProvider = Provider<GroupService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return GroupService(firestore: firestore);
});

class GroupService {
  final FirebaseFirestore firestore;

  GroupService({required this.firestore});

  CollectionReference<Map<String, dynamic>> _groupsCollection(String academyId) {
    return firestore.collection('academies').doc(academyId).collection('groups');
  }

  // Método para obtener un grupo específico por ID
  Future<Group> getGroup(String groupId) async {
    // Buscar el grupo en todas las academias
    final academiesSnapshot = await firestore.collection('academies').get();
    for (final academy in academiesSnapshot.docs) {
      try {
        final groupDoc = await firestore
            .collection('academies')
            .doc(academy.id)
            .collection('groups')
            .doc(groupId)
            .get();
        
        if (groupDoc.exists) {
          final data = groupDoc.data()!;
          data['id'] = groupDoc.id;
          data['academyId'] = academy.id;
          
          // Convertir timestamps de Firestore a strings ISO8601
          if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
            data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }
          
          return Group.fromJson(data);
        }
      } catch (e) {
        developer.log('Error buscando grupo en academia ${academy.id}: $e');
      }
    }
    
    throw Exception('Grupo no encontrado con ID: $groupId');
  }

  Future<List<Group>> getGroupsByAcademy(String academyId) async {
    final snapshot = await _groupsCollection(academyId).get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Convertir timestamps de Firestore a strings ISO8601
          if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
            data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }
          
          return Group.fromJson(data);
        })
        .toList();
  }

  Future<Group?> getGroupById(String groupId, String academyId) async {
    final doc = await _groupsCollection(academyId).doc(groupId).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    
    // Convertir timestamps de Firestore a strings ISO8601
    if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    
    return Group.fromJson(data);
  }

  Future<List<Group>> getGroupsByCoach(String coachId, String academyId) async {
    final snapshot = await _groupsCollection(academyId)
        .where('coachId', isEqualTo: coachId)
        .get();
    
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Convertir timestamps de Firestore a strings ISO8601
          if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
            data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }
          
          return Group.fromJson(data);
        })
        .toList();
  }

  Future<List<Group>> getGroupsByAthlete(String athleteId, String academyId) async {
    final snapshot = await _groupsCollection(academyId)
        .where('athleteIds', arrayContains: athleteId)
        .get();
    
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          
          // Convertir timestamps de Firestore a strings ISO8601
          if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
            data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }
          
          return Group.fromJson(data);
        })
        .toList();
  }

  Future<Group> createGroup({
    required String name,
    required String academyId,
    String? description,
    String? coachId,
    List<String>? athleteIds,
    int? capacity,
    bool isPublic = true,
    Map<String, dynamic>? formationData,
  }) async {
    final now = DateTime.now();
    final data = {
      'name': name,
      'academyId': academyId,
      'description': description,
      'coachId': coachId,
      'athleteIds': athleteIds ?? [],
      'capacity': capacity,
      'isPublic': isPublic,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    
    if (formationData != null) {
      data['formationData'] = formationData;
    }

    final docRef = await _groupsCollection(academyId).add(data);
    
    // También podríamos actualizar referencias en la academia y en coach/atletas
    // Ejemplos:
    // - Actualizar la lista de grupos en la academia
    // - Actualizar la lista de grupos asignados al entrenador
    // - Actualizar la lista de grupos asignados a cada atleta
    
    return Group.fromJson({...data, 'id': docRef.id});
  }

  Future<void> updateGroup(
    String groupId,
    Map<String, dynamic> data,
  ) async {
    // Buscar el grupo en todas las academias
    final academiesSnapshot = await firestore.collection('academies').get();
    bool found = false;
    
    for (final academy in academiesSnapshot.docs) {
      try {
        final groupDoc = await firestore
            .collection('academies')
            .doc(academy.id)
            .collection('groups')
            .doc(groupId)
            .get();
        
        if (groupDoc.exists) {
          // Añadir timestamp de actualización
          data['updatedAt'] = DateTime.now().toIso8601String();
          
          // Actualizar el grupo
          await firestore
              .collection('academies')
              .doc(academy.id)
              .collection('groups')
              .doc(groupId)
              .update(data);
          
          found = true;
          break;
        }
      } catch (e) {
        developer.log('Error actualizando grupo en academia ${academy.id}: $e');
      }
    }
    
    if (!found) {
      throw Exception('Grupo no encontrado con ID: $groupId');
    }
  }

  Future<void> deleteGroup(String groupId, String academyId) async {
    // Primero obtenemos el grupo para poder limpiar referencias
    final group = await getGroupById(groupId, academyId);
    if (group == null) {
      throw Exception('Grupo no encontrado');
    }
    
    // Aquí podríamos limpiar referencias:
    // - Quitar referencia del grupo en la academia
    // - Quitar referencia del grupo en el entrenador
    // - Quitar referencia del grupo en los atletas
    
    // Finalmente eliminamos el grupo
    await _groupsCollection(academyId).doc(groupId).delete();
  }

  Future<void> addAthleteToGroup(String athleteId, String groupId, String academyId) async {
    await _groupsCollection(academyId).doc(groupId).update({
      'athleteIds': FieldValue.arrayUnion([athleteId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    // También podríamos actualizar la referencia en el atleta
  }

  Future<void> removeAthleteFromGroup(String athleteId, String groupId, String academyId) async {
    await _groupsCollection(academyId).doc(groupId).update({
      'athleteIds': FieldValue.arrayRemove([athleteId]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    // También podríamos actualizar la referencia en el atleta
  }

  Future<void> assignCoachToGroup(String coachId, String groupId, String academyId) async {
    // Primero obtenemos el grupo para ver si ya tiene un entrenador
    final group = await getGroupById(groupId, academyId);
    if (group == null) {
      throw Exception('Grupo no encontrado');
    }
    
    // Si hay un entrenador previo, podríamos actualizar sus referencias
    
    // Actualizar el grupo con el nuevo entrenador
    await _groupsCollection(academyId).doc(groupId).update({
      'coachId': coachId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    // También podríamos actualizar la referencia en el entrenador
  }

  Future<void> removeCoachFromGroup(String groupId, String academyId) async {
    // Similar a assignCoachToGroup pero estableciendo coachId a null
    await _groupsCollection(academyId).doc(groupId).update({
      'coachId': null,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
} 