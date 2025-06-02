import 'package:arcinus/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academy_users/data/models/academy_user_model.dart';

class AcademyUsersRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'AcademyUsersRepository';

  AcademyUsersRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia a la colección de usuarios de una academia
  CollectionReference _usersCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('users');
  }

  // Método helper para convertir DocumentSnapshot a AcademyUserModel
  AcademyUserModel _fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      
      if (data == null) {
        AppLogger.logWarning(
          'Documento sin datos',
          className: _className,
          functionName: '_fromFirestore',
          params: {'docId': doc.id},
        );
        
        // Crear un modelo básico válido
        return AcademyUserModel(
          id: doc.id,
          firstName: 'Nombre no disponible',
          lastName: 'Apellido no disponible',
          createdBy: 'sistema',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      // Convertir Timestamps a DateTime antes de pasarlos al modelo
      final convertedData = Map<String, dynamic>.from(data);
      
      // Convertir campos de fecha de Timestamp a DateTime y luego a String ISO8601
      for (final dateField in ['birthDate', 'createdAt', 'updatedAt']) {
        if (convertedData[dateField] is Timestamp) {
          convertedData[dateField] = (convertedData[dateField] as Timestamp).toDate().toIso8601String();
        } else if (convertedData[dateField] is DateTime) { // Asegurarse de que si ya es DateTime, también se convierta
          convertedData[dateField] = (convertedData[dateField] as DateTime).toIso8601String();
        }
      }
      
      // Log datos para debugging
      AppLogger.logInfo(
        'Convirtiendo documento de Firestore a AcademyUserModel',
        className: _className,
        functionName: '_fromFirestore',
        params: {
          'docId': doc.id,
          'hasData': data.isNotEmpty,
          'dataKeys': data.keys.toList(),
          'birthDateType': convertedData['birthDate']?.runtimeType.toString(),
          'createdAtType': convertedData['createdAt']?.runtimeType.toString(),
          'updatedAtType': convertedData['updatedAt']?.runtimeType.toString(),
        },
      );
      
      // Usar el método fromJsonSafe que maneja mejor los errores
      return AcademyUserModel.fromJsonSafe(convertedData).copyWith(id: doc.id);
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error convirtiendo documento de Firestore',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: '_fromFirestore',
        params: {
          'docId': doc.id,
          'docData': doc.data(),
        },
      );
      
      // En lugar de fallar completamente, crear un modelo básico válido
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return AcademyUserModel(
        id: doc.id,
        firstName: data['firstName']?.toString() ?? 'Nombre no disponible',
        lastName: data['lastName']?.toString() ?? 'Apellido no disponible',
        createdBy: data['createdBy']?.toString() ?? 'sistema',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Método helper para convertir AcademyUserModel a Map para Firestore
  Map<String, dynamic> _toFirestore(AcademyUserModel user) {
    final json = user.toJson();
    // Convertir DateTime a Timestamp para Firestore
    if (user.birthDate != null) {
      json['birthDate'] = Timestamp.fromDate(user.birthDate!);
    }
    json['createdAt'] = Timestamp.fromDate(user.createdAt);
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  // Obtener todos los usuarios de una academia
  Stream<List<AcademyUserModel>> getAcademyUsers(String academyId) {
    return _usersCollection(academyId)
        .orderBy('lastName')
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => _fromFirestore(doc))
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
              .map((doc) => _fromFirestore(doc))
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
        return _fromFirestore(docSnapshot);
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
  Future<String?> createUser(String academyId, AcademyUserModel user) async {
    try {
      final docRef = await _usersCollection(academyId).add(_toFirestore(user));
      
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
  Future<bool> updateUser(String academyId, String userId, AcademyUserModel user) async {
    try {
      await _usersCollection(academyId).doc(userId).update(_toFirestore(user));
      
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

  // Buscar usuarios por nombre
  Stream<List<AcademyUserModel>> searchUsersByName(String academyId, String searchTerm) {
    return _usersCollection(academyId)
        .where('firstName', isGreaterThanOrEqualTo: searchTerm)
        .where('firstName', isLessThan: '${searchTerm}z')
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs
              .map((doc) => _fromFirestore(doc))
              .toList();
          
          AppLogger.logInfo(
            'Búsqueda completada: ${users.length} usuarios encontrados',
            className: _className,
            functionName: 'searchUsersByName',
            params: {'academyId': academyId, 'searchTerm': searchTerm},
          );
          
          return users;
        });
  }

  // Obtener estadísticas de usuarios
  Future<Map<String, int>> getUserStats(String academyId) async {
    try {
      final snapshot = await _usersCollection(academyId).get();
      final users = snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
      
      final stats = <String, int>{
        'total': users.length,
        'atletas': users.where((u) => u.isAthlete).length,
        'padres': users.where((u) => u.isParent).length,
        'con_info_medica': users.where((u) => u.hasMedicalInfo).length,
        'con_contacto_emergencia': users.where((u) => u.hasEmergencyContact).length,
      };
      
      AppLogger.logInfo(
        'Estadísticas de usuarios obtenidas',
        className: _className,
        functionName: 'getUserStats',
        params: {'academyId': academyId, 'stats': stats},
      );
      
      return stats;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener estadísticas de usuarios',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getUserStats',
        params: {'academyId': academyId},
      );
      return {};
    }
  }
}

// Provider para el repositorio de usuarios de academias
final academyUsersRepositoryProvider = Provider<AcademyUsersRepository>((ref) {
  return AcademyUsersRepository();
}); 