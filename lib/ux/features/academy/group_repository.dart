import 'package:arcinus/shared/models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(FirebaseFirestore.instance);
});

class GroupRepository {
  final FirebaseFirestore _firestore;

  GroupRepository(this._firestore);

  // Referencia a la colección de academias
  CollectionReference<Map<String, dynamic>> _academiesCollection() =>
      _firestore.collection('academies');

  // Referencia a la colección de grupos dentro de una academia
  CollectionReference<Map<String, dynamic>> _groupsCollection(String academyId) =>
      _academiesCollection().doc(academyId).collection('groups');

  // Crear un nuevo grupo
  Future<Group> createGroup({
    required String academyId,
    required String name,
    String? description,
    String? coachId,
  }) async {
    final docRef = _groupsCollection(academyId).doc();
    
    final group = Group(
      id: docRef.id,
      academyId: academyId,
      name: name,
      description: description,
      coachId: coachId,
      createdAt: DateTime.now(),
    );
    
    final json = group.toJson();
    await docRef.set(json);
    
    // Actualizar la academia con la referencia al grupo
    await _academiesCollection().doc(academyId).update({
      'groupIds': FieldValue.arrayUnion([docRef.id]),
    });
    
    return group;
  }

  // Obtener un grupo por ID
  Future<Group?> getGroup(String academyId, String groupId) async {
    final docSnap = await _groupsCollection(academyId).doc(groupId).get();
    
    if (!docSnap.exists) {
      return null;
    }
    
    final data = docSnap.data()!;
    data['id'] = docSnap.id;
    return Group.fromJson(data);
  }

  // Obtener todos los grupos de una academia
  Future<List<Group>> getGroupsByAcademy(String academyId) async {
    final querySnap = await _groupsCollection(academyId).get();
    
    return querySnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Group.fromJson(data);
    }).toList();
  }

  // Obtener grupos por entrenador
  Future<List<Group>> getGroupsByCoach(String academyId, String coachId) async {
    final querySnap = await _groupsCollection(academyId)
        .where('coachId', isEqualTo: coachId)
        .get();
    
    return querySnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Group.fromJson(data);
    }).toList();
  }

  // Actualizar un grupo
  Future<void> updateGroup(Group group) async {
    final json = group.toJson();
    await _groupsCollection(group.academyId).doc(group.id).update(json);
  }

  // Asignar un atleta a un grupo
  Future<void> addAthleteToGroup(String academyId, String groupId, String athleteId) async {
    await _groupsCollection(academyId).doc(groupId).update({
      'athleteIds': FieldValue.arrayUnion([athleteId]),
    });
  }

  // Quitar un atleta de un grupo
  Future<void> removeAthleteFromGroup(String academyId, String groupId, String athleteId) async {
    await _groupsCollection(academyId).doc(groupId).update({
      'athleteIds': FieldValue.arrayRemove([athleteId]),
    });
  }

  // Eliminar un grupo
  Future<void> deleteGroup(String academyId, String groupId) async {
    // Primero eliminamos la referencia del grupo en la academia
    await _academiesCollection().doc(academyId).update({
      'groupIds': FieldValue.arrayRemove([groupId]),
    });
    
    // Luego eliminamos el grupo
    await _groupsCollection(academyId).doc(groupId).delete();
  }
} 