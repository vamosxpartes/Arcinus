import 'package:arcinus/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcademyUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String? phoneNumber;
  final double? heightCm;
  final double? weightKg;
  final String? profileImageUrl;
  final String? allergies;
  final String? medicalConditions;
  final Map<String, dynamic>? emergencyContact;
  final String? position;
  final String? role;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AcademyUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.phoneNumber,
    this.heightCm,
    this.weightKg,
    this.profileImageUrl,
    this.allergies,
    this.medicalConditions,
    this.emergencyContact,
    this.position,
    this.role,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AcademyUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AcademyUserModel(
      id: doc.id,
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      birthDate: data['birthDate'] != null ? (data['birthDate'] as Timestamp).toDate() : null,
      phoneNumber: data['phoneNumber']?.toString(),
      heightCm: data['heightCm'] != null ? (data['heightCm'] as num).toDouble() : null,
      weightKg: data['weightKg'] != null ? (data['weightKg'] as num).toDouble() : null,
      profileImageUrl: data['profileImageUrl']?.toString(),
      allergies: data['allergies']?.toString(),
      medicalConditions: data['medicalConditions']?.toString(),
      emergencyContact: data['emergencyContact'] as Map<String, dynamic>?,
      position: data['position']?.toString(),
      role: data['role']?.toString(),
      createdBy: data['createdBy']?.toString() ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'phoneNumber': phoneNumber,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'profileImageUrl': profileImageUrl,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'emergencyContact': emergencyContact,
      'position': position,
      'role': role,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  String get fullName => '$firstName $lastName';
}

class AcademyUsersRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'AcademyUsersRepository';

  AcademyUsersRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia a la colección de usuarios de una academia
  CollectionReference _usersCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('users');
  }

  // Obtener todos los usuarios de una academia
  Stream<List<AcademyUserModel>> getAcademyUsers(String academyId) {
    return _usersCollection(academyId)
        .orderBy('lastName')
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => AcademyUserModel.fromFirestore(doc))
              .toList();
          
          AppLogger.logInfo(
            'Obtenidos ${users.length} usuarios de la academia',
            className: _className,
            functionName: 'getAcademyUsers',
            params: {'academyId': academyId},
          );
          
          return users;
        });
  }

  // Obtener usuarios filtrados por rol
  Stream<List<AcademyUserModel>> getUsersByRole(String academyId, String role) {
    AppLogger.logInfo(
      'Buscando usuarios con rol $role',
      className: _className,
      functionName: 'getUsersByRole',
      params: {'academyId': academyId, 'role': role},
    );

    return _usersCollection(academyId)
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => AcademyUserModel.fromFirestore(doc))
              .toList();
          
          // Log detallado de la consulta
          AppLogger.logInfo(
            'Query getUsersByRole - documentos: ${snapshot.docs.length}',
            className: _className,
            functionName: 'getUsersByRole',
            params: {'academyId': academyId, 'role': role},
          );
          
          // Log de cada documento encontrado para análisis
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            AppLogger.logInfo(
              'Documento encontrado: ${doc.id}',
              className: _className,
              functionName: 'getUsersByRole',
              params: {
                'academyId': academyId, 
                'role': role,
                'docData': {'id': doc.id, 'role': data['role'], 'firstName': data['firstName'], 'lastName': data['lastName']}
              },
            );
          }
          
          AppLogger.logInfo(
            'Obtenidos ${users.length} usuarios con rol $role',
            className: _className,
            functionName: 'getUsersByRole',
            params: {'academyId': academyId, 'role': role},
          );
          
          return users;
        });
  }

  // Obtener un usuario específico
  Future<AcademyUserModel?> getUserById(String academyId, String userId) async {
    try {
      final docSnapshot = await _usersCollection(academyId).doc(userId).get();
      
      if (docSnapshot.exists) {
        return AcademyUserModel.fromFirestore(docSnapshot);
      }
      
      return null;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener usuario por ID',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getUserById',
        params: {'academyId': academyId, 'userId': userId},
      );
      return null;
    }
  }

  // Crear un nuevo usuario
  Future<String?> createUser(String academyId, Map<String, dynamic> userData) async {
    try {
      final docRef = await _usersCollection(academyId).add(userData);
      
      AppLogger.logInfo(
        'Usuario creado con éxito',
        className: _className,
        functionName: 'createUser',
        params: {'academyId': academyId, 'userId': docRef.id},
      );
      
      return docRef.id;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createUser',
        params: {'academyId': academyId},
      );
      return null;
    }
  }

  // Actualizar un usuario existente
  Future<bool> updateUser(String academyId, String userId, Map<String, dynamic> updatedData) async {
    try {
      // Asegurar que el campo updatedAt siempre se actualice
      updatedData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _usersCollection(academyId).doc(userId).update(updatedData);
      
      AppLogger.logInfo(
        'Usuario actualizado con éxito',
        className: _className,
        functionName: 'updateUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      return true;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      return false;
    }
  }

  // Eliminar un usuario
  Future<bool> deleteUser(String academyId, String userId) async {
    try {
      await _usersCollection(academyId).doc(userId).delete();
      
      AppLogger.logInfo(
        'Usuario eliminado con éxito',
        className: _className,
        functionName: 'deleteUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      return true;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al eliminar usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'deleteUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      return false;
    }
  }

  // Buscar usuarios por nombre o apellido
  Future<List<AcademyUserModel>> searchUsersByName(String academyId, String searchTerm) async {
    try {
      // Normalizar término de búsqueda (convertir a minúsculas)
      final normalizedTerm = searchTerm.toLowerCase();
      
      AppLogger.logInfo(
        'Iniciando búsqueda por nombre con término: "$normalizedTerm"',
        className: _className,
        functionName: 'searchUsersByName',
        params: {'academyId': academyId, 'searchTerm': searchTerm},
      );
      
      // Log de la consulta actual para usuarios
      final allUsers = await _usersCollection(academyId).get();
      AppLogger.logInfo(
        'Total usuarios en colección: ${allUsers.docs.length}',
        className: _className,
        functionName: 'searchUsersByName',
        params: {'academyId': academyId},
      );
      
      for (var doc in allUsers.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final firstName = (data['firstName'] ?? '').toString().toLowerCase();
        final lastName = (data['lastName'] ?? '').toString().toLowerCase();
        
        AppLogger.logInfo(
          'Usuario en DB: ${doc.id}',
          className: _className,
          functionName: 'searchUsersByName',
          params: {
            'firstName': firstName,
            'lastName': lastName,
            'matchesFirstName': firstName.contains(normalizedTerm),
            'matchesLastName': lastName.contains(normalizedTerm),
          },
        );
      }
      
      // Modificamos el enfoque de búsqueda para ser más flexible
      final results = allUsers.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final firstName = (data['firstName'] ?? '').toString().toLowerCase();
            final lastName = (data['lastName'] ?? '').toString().toLowerCase();
            return firstName.contains(normalizedTerm) || lastName.contains(normalizedTerm);
          })
          .map((doc) => AcademyUserModel.fromFirestore(doc))
          .toList();
      
      AppLogger.logInfo(
        'Búsqueda completada, encontrados ${results.length} usuarios',
        className: _className,
        functionName: 'searchUsersByName',
        params: {'academyId': academyId, 'searchTerm': searchTerm},
      );
      
      return results;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al buscar usuarios por nombre',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'searchUsersByName',
        params: {'academyId': academyId, 'searchTerm': searchTerm},
      );
      return [];
    }
  }
}

// Provider para el repositorio de usuarios de academias
final academyUsersRepositoryProvider = Provider<AcademyUsersRepository>((ref) {
  return AcademyUsersRepository();
}); 