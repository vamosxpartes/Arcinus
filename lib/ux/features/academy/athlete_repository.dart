import 'package:arcinus/shared/models/athlete_profile.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final athleteRepositoryProvider = Provider<AthleteRepository>((ref) {
  return AthleteRepository(FirebaseFirestore.instance);
});

class AthleteRepository {
  final FirebaseFirestore _firestore;

  AthleteRepository(this._firestore);

  // Referencia a la colección de usuarios
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // Referencia a la colección de academias
  CollectionReference<Map<String, dynamic>> get _academiesCollection =>
      _firestore.collection('academies');

  // Crear perfil de atleta
  Future<AthleteProfile> createAthleteProfile({
    required String userId,
    required String academyId,
    DateTime? birthDate,
    double? height,
    double? weight,
    List<String>? groupIds,
    List<String>? parentIds,
    Map<String, dynamic>? medicalInfo,
    Map<String, dynamic>? emergencyContacts,
    Map<String, dynamic>? additionalInfo,
    String? position,
    List<String>? specializations,
    Map<String, dynamic>? sportStats,
  }) async {
    // Crear el perfil del atleta
    final athleteProfile = AthleteProfile(
      userId: userId,
      academyId: academyId,
      birthDate: birthDate,
      height: height,
      weight: weight,
      groupIds: groupIds,
      parentIds: parentIds,
      medicalInfo: medicalInfo,
      emergencyContacts: emergencyContacts,
      additionalInfo: additionalInfo,
      position: position,
      specializations: specializations,
      sportStats: sportStats,
      createdAt: DateTime.now(),
    );

    // Guardar el perfil en la colección del usuario
    await _usersCollection
        .doc(userId)
        .collection('athlete_profile')
        .doc(academyId)
        .set(athleteProfile.toJson());

    // Actualizar la academia con la referencia al atleta
    await _academiesCollection.doc(academyId).update({
      'athleteIds': FieldValue.arrayUnion(<String>[userId]),
    });

    return athleteProfile;
  }

  // Obtener perfil de atleta
  Future<AthleteProfile?> getAthleteProfile(String userId, String academyId) async {
    final docSnap = await _usersCollection
        .doc(userId)
        .collection('athlete_profile')
        .doc(academyId)
        .get();

    if (!docSnap.exists) {
      return null;
    }

    return AthleteProfile.fromJson(docSnap.data()!);
  }

  // Actualizar perfil de atleta
  Future<void> updateAthleteProfile(AthleteProfile profile) async {
    await _usersCollection
        .doc(profile.userId)
        .collection('athlete_profile')
        .doc(profile.academyId)
        .update(profile.toJson());
  }

  // Obtener todos los atletas de una academia
  Future<List<User>> getAthletesByAcademy(String academyId) async {
    final academySnap = await _academiesCollection.doc(academyId).get();
    
    if (!academySnap.exists || !academySnap.data()!.containsKey('athleteIds')) {
      return [];
    }
    
    final dynamic athleteIdsRaw = academySnap.data()!['athleteIds'] ?? [];
    final athleteIds = List<String>.from(athleteIdsRaw is Iterable ? athleteIdsRaw : []);
    
    if (athleteIds.isEmpty) {
      return [];
    }
    
    // Consultar usuarios que sean atletas
    final querySnap = await _usersCollection
        .where(FieldPath.documentId, whereIn: athleteIds)
        .where('role', isEqualTo: UserRole.athlete.name)
        .get();
    
    return querySnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return User.fromJson(data);
    }).toList();
  }

  // Obtener atletas por grupo
  Future<List<User>> getAthletesByGroup(String academyId, String groupId) async {
    final groupSnap = await _academiesCollection
        .doc(academyId)
        .collection('groups')
        .doc(groupId)
        .get();
    
    if (!groupSnap.exists || !groupSnap.data()!.containsKey('athleteIds')) {
      return [];
    }
    
    final dynamic athleteIdsRaw = groupSnap.data()!['athleteIds'] ?? [];
    final athleteIds = List<String>.from(athleteIdsRaw is Iterable ? athleteIdsRaw : []);
    
    if (athleteIds.isEmpty) {
      return [];
    }
    
    // Consultar usuarios que sean atletas
    final querySnap = await _usersCollection
        .where(FieldPath.documentId, whereIn: athleteIds)
        .where('role', isEqualTo: UserRole.athlete.name)
        .get();
    
    return querySnap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return User.fromJson(data);
    }).toList();
  }

  // Eliminar atleta de una academia
  Future<void> removeAthleteFromAcademy(String userId, String academyId) async {
    // Eliminar la referencia del atleta en la academia
    await _academiesCollection.doc(academyId).update({
      'athleteIds': FieldValue.arrayRemove(<String>[userId]),
    });
    
    // Eliminar el perfil de atleta
    await _usersCollection
        .doc(userId)
        .collection('athlete_profile')
        .doc(academyId)
        .delete();
    
    // Eliminar el atleta de todos los grupos de la academia
    final groupsSnap = await _academiesCollection
        .doc(academyId)
        .collection('groups')
        .get();
    
    final batch = _firestore.batch();
    
    for (final groupDoc in groupsSnap.docs) {
      if (groupDoc.data().containsKey('athleteIds') && 
          (groupDoc.data()['athleteIds'] as List<dynamic>?)?.contains(userId) == true) {
        batch.update(
          groupDoc.reference, 
          {'athleteIds': FieldValue.arrayRemove(<String>[userId])},
        );
      }
    }
    
    await batch.commit();
  }
} 