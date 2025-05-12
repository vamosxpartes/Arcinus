import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/memberships/domain/entities/academy_member.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositorio para gestionar los miembros de academias
class AcademyMembersRepository {
  final FirebaseFirestore _firestore;
  
  AcademyMembersRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Obtiene la referencia a la colección de miembros de una academia
  CollectionReference<Map<String, dynamic>> membersCollection(String academyId) => 
      _firestore.collection('academies/$academyId/members');
  
  /// Obtiene todos los miembros de una academia
  Future<List<AcademyMember>> getAcademyMembers(String academyId) async {
    final snapshot = await membersCollection(academyId).get();
    return snapshot.docs.map((doc) {
      return AcademyMember.fromJson(doc.data()).copyWith(id: doc.id);
    }).toList();
  }
  
  /// Obtiene un miembro por su ID
  Future<AcademyMember?> getMemberById(String academyId, String memberId) async {
    final docSnapshot = await membersCollection(academyId).doc(memberId).get();
    
    if (!docSnapshot.exists) return null;
    
    return AcademyMember.fromJson(docSnapshot.data()!)
        .copyWith(id: docSnapshot.id);
  }
  
  /// Obtiene todos los atletas de una academia
  Future<List<AcademyMember>> getAthletes(String academyId) async {
    final snapshot = await membersCollection(academyId)
        .where('role', isEqualTo: AppRole.atleta.name)
        .get();
        
    return snapshot.docs.map((doc) {
      return AcademyMember.fromJson(doc.data()).copyWith(id: doc.id);
    }).toList();
  }
  
  /// Busca atletas por nombre
  Future<List<AcademyMember>> searchAthletesByName(
    String academyId, 
    String query,
  ) async {
    // Convertir a minúsculas para búsqueda no sensible a mayúsculas
    final lowerQuery = query.toLowerCase();
    
    // Firestore no soporta búsquedas de texto completo, pero podemos filtrar por startsWith
    final snapshot = await membersCollection(academyId)
        .where('role', isEqualTo: AppRole.atleta.name)
        .where('name_lowercase', isGreaterThanOrEqualTo: lowerQuery)
        .where('name_lowercase', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
        .get();
        
    return snapshot.docs.map((doc) {
      return AcademyMember.fromJson(doc.data()).copyWith(id: doc.id);
    }).toList();
  }
  
  /// Añade un nuevo miembro a la academia
  Future<String> addMember(String academyId, AcademyMember member) async {
    // Preparar datos con lowercase para facilitar búsquedas
    final data = member.toJson();
    data['name_lowercase'] = member.name.toLowerCase();
    
    // Añadir fechas
    final now = DateTime.now();
    data['createdAt'] = Timestamp.fromDate(now);
    data['updatedAt'] = Timestamp.fromDate(now);
    
    // Guardar en Firestore
    final docRef = await membersCollection(academyId).add(data);
    
    // Actualizar contador de miembros en la academia
    await _updateMemberCount(academyId, 1);
    
    return docRef.id;
  }
  
  /// Actualiza un miembro existente
  Future<void> updateMember(
    String academyId, 
    String memberId, 
    AcademyMember member,
  ) async {
    // Preparar datos con lowercase para facilitar búsquedas
    final data = member.toJson();
    data['name_lowercase'] = member.name.toLowerCase();
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    
    await membersCollection(academyId).doc(memberId).update(data);
  }
  
  /// Elimina un miembro
  Future<void> deleteMember(String academyId, String memberId) async {
    await membersCollection(academyId).doc(memberId).delete();
    
    // Actualizar contador de miembros en la academia
    await _updateMemberCount(academyId, -1);
  }
  
  /// Obtiene los atletas relacionados con un padre/tutor
  Future<List<AcademyMember>> getRelatedAthletes(
    String academyId, 
    String parentMemberId,
  ) async {
    final parent = await getMemberById(academyId, parentMemberId);
    
    if (parent == null || !parent.isParent) {
      return [];
    }
    
    final athleteIds = parent.relatedMemberIds;
    if (athleteIds.isEmpty) return [];
    
    // Obtener los atletas relacionados
    final snapshot = await membersCollection(academyId)
        .where(FieldPath.documentId, whereIn: athleteIds)
        .get();
        
    return snapshot.docs.map((doc) {
      return AcademyMember.fromJson(doc.data()).copyWith(id: doc.id);
    }).toList();
  }
  
  /// Vincula un atleta con un padre/tutor
  Future<void> linkAthleteToParent(
    String academyId, 
    String athleteMemberId, 
    String parentMemberId,
  ) async {
    final batch = _firestore.batch();
    
    // Añadir athleteId a la lista de relatedMemberIds del padre
    final parentRef = membersCollection(academyId).doc(parentMemberId);
    batch.update(parentRef, {
      'relatedMemberIds': FieldValue.arrayUnion([athleteMemberId]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    
    // Añadir parentId a la lista de relatedMemberIds del atleta
    final athleteRef = membersCollection(academyId).doc(athleteMemberId);
    batch.update(athleteRef, {
      'relatedMemberIds': FieldValue.arrayUnion([parentMemberId]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    
    await batch.commit();
  }
  
  /// Actualiza el contador de miembros en la academia
  Future<void> _updateMemberCount(String academyId, int delta) async {
    await _firestore.collection('academies').doc(academyId).update({
      'membersCount': FieldValue.increment(delta),
    });
  }
} 