import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/super_admin/data/models/owner_data_model.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';

/// Repositorio para la gestión de propietarios en el SuperAdmin
abstract class OwnersManagementRepository {
  /// Obtiene todos los propietarios del sistema
  Future<Either<Failure, List<OwnerDataModel>>> getAllOwners();
  
  /// Obtiene un propietario específico por ID
  Future<Either<Failure, OwnerDataModel?>> getOwnerById(String ownerId);
  
  /// Obtiene las academias de un propietario
  Future<Either<Failure, List<AcademyBasicInfoModel>>> getOwnerAcademies(String ownerId);
  
  /// Obtiene las métricas de un propietario
  Future<Either<Failure, OwnerMetricsModel>> getOwnerMetrics(String ownerId);
  
  /// Actualiza el estado de un propietario
  Future<Either<Failure, void>> updateOwnerStatus(String ownerId, bool isActive);
  
  /// Actualiza la información del propietario
  Future<Either<Failure, void>> updateOwnerInfo(String ownerId, Map<String, dynamic> updates);
}

/// Implementación del repositorio usando Firestore
class OwnersManagementRepositoryImpl implements OwnersManagementRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'OwnersManagementRepositoryImpl';

  OwnersManagementRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Colección de usuarios
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  /// Colección de academias
  CollectionReference get _academiesCollection => _firestore.collection('academies');

  @override
  Future<Either<Failure, List<OwnerDataModel>>> getAllOwners() async {
    try {
      AppLogger.logInfo(
        'Obteniendo todos los propietarios del sistema',
        className: _className,
        functionName: 'getAllOwners',
      );

      // Consultar usuarios con rol 'propietario' usando el campo correcto 'role'
      final querySnapshot = await _usersCollection
          .where('role', isEqualTo: 'propietario')
          .get();

      final owners = <OwnerDataModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) {
            AppLogger.logWarning(
              'Documento sin datos - saltando',
              className: _className,
              functionName: 'getAllOwners',
              params: {'docId': doc.id},
            );
            continue;
          }

          AppLogger.logInfo(
            'Procesando documento de propietario',
            className: _className,
            functionName: 'getAllOwners',
            params: {
              'docId': doc.id,
              'dataKeys': data.keys.toList(),
              'hasEmail': data.containsKey('email'),
              'emailValue': data['email']?.toString(),
              'hasRole': data.containsKey('role'),
              'roleValue': data['role']?.toString(),
            },
          );

          // Convertir Timestamps a DateTime
          final sanitizedData = _sanitizeTimestamps(data);
          
          // Intentar crear el modelo con validación adicional
          final owner = _createOwnerModelSafely(sanitizedData, doc.id);
          if (owner != null) {
            owners.add(owner);

            AppLogger.logInfo(
              'Propietario procesado correctamente',
              className: _className,
              functionName: 'getAllOwners',
              params: {
                'ownerId': doc.id,
                'email': owner.email,
                'status': owner.status.toString(),
              },
            );
          }
        } catch (e, stackTrace) {
          AppLogger.logError(
            message: 'Error procesando propietario',
            error: e,
            stackTrace: stackTrace,
            className: _className,
            functionName: 'getAllOwners',
            params: {'docId': doc.id},
          );
          // Continuar con el siguiente propietario
        }
      }

      AppLogger.logInfo(
        'Propietarios obtenidos exitosamente',
        className: _className,
        functionName: 'getAllOwners',
        params: {'totalOwners': owners.length},
      );

      return Right(owners);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener propietarios',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getAllOwners',
      );
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al obtener propietarios',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getAllOwners',
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, OwnerDataModel?>> getOwnerById(String ownerId) async {
    try {
      AppLogger.logInfo(
        'Obteniendo propietario por ID',
        className: _className,
        functionName: 'getOwnerById',
        params: {'ownerId': ownerId},
      );

      final docSnapshot = await _usersCollection.doc(ownerId).get();

      if (!docSnapshot.exists) {
        AppLogger.logWarning(
          'Propietario no encontrado',
          className: _className,
          functionName: 'getOwnerById',
          params: {'ownerId': ownerId},
        );
        return const Right(null);
      }

      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        return const Right(null);
      }

      // Convertir Timestamps a DateTime
      final sanitizedData = _sanitizeTimestamps(data);
      
      // Usar método seguro para crear el modelo
      final owner = _createOwnerModelSafely(sanitizedData, docSnapshot.id);
      if (owner == null) {
        AppLogger.logError(
          message: 'No se pudo crear modelo de propietario con datos válidos',
          className: _className,
          functionName: 'getOwnerById',
          params: {'ownerId': ownerId},
        );
        return const Right(null);
      }

      AppLogger.logInfo(
        'Propietario obtenido correctamente',
        className: _className,
        functionName: 'getOwnerById',
        params: {
          'ownerId': ownerId,
          'email': owner.email,
        },
      );

      return Right(owner);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener propietario',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getOwnerById',
        params: {'ownerId': ownerId},
      );
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al obtener propietario',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getOwnerById',
        params: {'ownerId': ownerId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, List<AcademyBasicInfoModel>>> getOwnerAcademies(String ownerId) async {
    try {
      AppLogger.logInfo(
        'Obteniendo academias del propietario',
        className: _className,
        functionName: 'getOwnerAcademies',
        params: {'ownerId': ownerId},
      );

      final querySnapshot = await _academiesCollection
          .where('ownerId', isEqualTo: ownerId)
          .get();

      final academies = <AcademyBasicInfoModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          // Obtener el número de miembros de la academia
          final membersCount = await _getAcademyMembersCount(doc.id);

          // Convertir AcademyModel a AcademyBasicInfoModel
          final academyData = _sanitizeTimestamps(data);
          
          final academy = AcademyBasicInfoModel(
            id: doc.id,
            name: academyData['name']?.toString() ?? 'Sin nombre',
            logoUrl: academyData['logoUrl']?.toString(),
            sportCode: academyData['sportCode']?.toString() ?? '',
            location: academyData['location']?.toString() ?? '',
            address: academyData['address']?.toString() ?? '',
            phone: academyData['phone']?.toString() ?? '',
            email: academyData['email']?.toString() ?? '',
            membersCount: membersCount,
            createdAt: academyData['createdAt'] as DateTime?,
            updatedAt: academyData['updatedAt'] as DateTime?,
          );

          academies.add(academy);
        } catch (e, stackTrace) {
          AppLogger.logError(
            message: 'Error procesando academia',
            error: e,
            stackTrace: stackTrace,
            className: _className,
            functionName: 'getOwnerAcademies',
            params: {'academyId': doc.id},
          );
        }
      }

      AppLogger.logInfo(
        'Academias obtenidas exitosamente',
        className: _className,
        functionName: 'getOwnerAcademies',
        params: {
          'ownerId': ownerId,
          'totalAcademies': academies.length,
        },
      );

      return Right(academies);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener academias',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getOwnerAcademies',
        params: {'ownerId': ownerId},
      );
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al obtener academias',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getOwnerAcademies',
        params: {'ownerId': ownerId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, OwnerMetricsModel>> getOwnerMetrics(String ownerId) async {
    try {
      AppLogger.logInfo(
        'Calculando métricas del propietario',
        className: _className,
        functionName: 'getOwnerMetrics',
        params: {'ownerId': ownerId},
      );

      // Obtener academias del propietario
      final academiesResult = await getOwnerAcademies(ownerId);
      
      return academiesResult.fold(
        (failure) => Left(failure),
        (academies) async {
          int totalUsers = 0;
          int activeUsers = 0;
          DateTime? lastActivityAt;

          // Calcular métricas agregadas de todas las academias
          for (final academy in academies) {
            final academyUsers = await _getAcademyUsersCount(academy.id);
            totalUsers += academyUsers['total'] ?? 0;
            activeUsers += academyUsers['active'] ?? 0;

            // Actualizar última actividad (usar createdAt de academia como proxy)
            if (academy.updatedAt != null) {
              if (lastActivityAt == null || academy.updatedAt!.isAfter(lastActivityAt)) {
                lastActivityAt = academy.updatedAt;
              }
            }
          }

          // Calcular tasa de actividad
          final activityRate = totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0.0;

          // Simular ingresos mensuales (esto se debería calcular desde datos de suscripciones reales)
          final monthlyRevenue = academies.length * 1500.0; // Estimación básica

          final metrics = OwnerMetricsModel(
            totalAcademies: academies.length,
            totalUsers: totalUsers,
            activeUsers: activeUsers,
            monthlyRevenue: monthlyRevenue,
            lastActivityAt: lastActivityAt,
            activityRate: activityRate,
          );

          AppLogger.logInfo(
            'Métricas calculadas exitosamente',
            className: _className,
            functionName: 'getOwnerMetrics',
            params: {
              'ownerId': ownerId,
              'totalAcademies': metrics.totalAcademies,
              'totalUsers': metrics.totalUsers,
              'monthlyRevenue': metrics.monthlyRevenue,
            },
          );

          return Right(metrics);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error calculando métricas del propietario',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getOwnerMetrics',
        params: {'ownerId': ownerId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> updateOwnerStatus(String ownerId, bool isActive) async {
    try {
      AppLogger.logInfo(
        'Actualizando estado del propietario',
        className: _className,
        functionName: 'updateOwnerStatus',
        params: {
          'ownerId': ownerId,
          'isActive': isActive,
        },
      );

      await _usersCollection.doc(ownerId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.logInfo(
        'Estado del propietario actualizado exitosamente',
        className: _className,
        functionName: 'updateOwnerStatus',
        params: {
          'ownerId': ownerId,
          'newStatus': isActive ? 'active' : 'inactive',
        },
      );

      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error de Firestore al actualizar estado',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'updateOwnerStatus',
        params: {'ownerId': ownerId},
      );
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al actualizar estado',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'updateOwnerStatus',
        params: {'ownerId': ownerId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> updateOwnerInfo(String ownerId, Map<String, dynamic> updates) async {
    try {
      AppLogger.logInfo(
        'Actualizando información del propietario',
        className: _className,
        functionName: 'updateOwnerInfo',
        params: {
          'ownerId': ownerId,
          'updates': updates.keys.toList(),
        },
      );

      // Añadir timestamp de actualización
      final updateData = Map<String, dynamic>.from(updates);
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(ownerId).update(updateData);

      AppLogger.logInfo(
        'Información del propietario actualizada exitosamente',
        className: _className,
        functionName: 'updateOwnerInfo',
        params: {'ownerId': ownerId},
      );

      return const Right(null);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error de Firestore al actualizar información',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'updateOwnerInfo',
        params: {'ownerId': ownerId},
      );
      return Left(ServerFailure(message: e.message ?? 'Error de Firestore [${e.code}]'));
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al actualizar información',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'updateOwnerInfo',
        params: {'ownerId': ownerId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  /// Método auxiliar para sanitizar Timestamps de Firestore
  Map<String, dynamic> _sanitizeTimestamps(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    
    for (final key in ['createdAt', 'updatedAt', 'lastLoginAt']) {
      if (sanitized[key] is Timestamp) {
        sanitized[key] = (sanitized[key] as Timestamp).toDate();
      }
    }
    
    return sanitized;
  }

  /// Obtiene el número de miembros de una academia
  Future<int> _getAcademyMembersCount(String academyId) async {
    try {
      final snapshot = await _firestore
          .collection('academies')
          .doc(academyId)
          .collection('users')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      AppLogger.logWarning(
        'Error obteniendo conteo de miembros de academia',
        className: _className,
        functionName: '_getAcademyMembersCount',
        params: {'academyId': academyId},
        error: e,
      );
      return 0;
    }
  }

  /// Obtiene el conteo de usuarios de una academia (total y activos)
  Future<Map<String, int>> _getAcademyUsersCount(String academyId) async {
    try {
      final snapshot = await _firestore
          .collection('academies')
          .doc(academyId)
          .collection('users')
          .get();
      
      int total = snapshot.docs.length;
      int active = 0;

      // Contar usuarios activos (simplificación - basado en si tienen updatedAt reciente)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final updatedAt = data['updatedAt'];
        
        if (updatedAt is Timestamp) {
          final date = updatedAt.toDate();
          if (date.isAfter(thirtyDaysAgo)) {
            active++;
          }
        }
      }
      
      return {
        'total': total,
        'active': active,
      };
    } catch (e) {
      AppLogger.logWarning(
        'Error obteniendo conteo de usuarios de academia',
        className: _className,
        functionName: '_getAcademyUsersCount',
        params: {'academyId': academyId},
        error: e,
      );
      return {'total': 0, 'active': 0};
    }
  }

  /// Método auxiliar para crear un modelo de OwnerDataModel con validación adicional
  OwnerDataModel? _createOwnerModelSafely(Map<String, dynamic> data, String id) {
    try {
      AppLogger.logInfo(
        'Iniciando creación de modelo de propietario',
        className: _className,
        functionName: '_createOwnerModelSafely',
        params: {
          'docId': id,
          'originalDataKeys': data.keys.toList(),
          'email': data['email']?.toString(),
          'emailType': data['email']?.runtimeType.toString(),
        },
      );

      // Validar y limpiar los datos antes del procesamiento
      final validatedData = _validateAndSanitizeOwnerData(data);
      if (validatedData == null) {
        AppLogger.logError(
          message: 'Datos del propietario no válidos después de la validación',
          className: _className,
          functionName: '_createOwnerModelSafely',
          params: {'docId': id},
        );
        return null;
      }

      AppLogger.logInfo(
        'Datos validados correctamente, creando modelo',
        className: _className,
        functionName: '_createOwnerModelSafely',
        params: {
          'docId': id,
          'validatedDataKeys': validatedData.keys.toList(),
          'email': validatedData['email']?.toString(),
          'emailType': validatedData['email']?.runtimeType.toString(),
          'id': validatedData['id']?.toString(),
          'displayName': validatedData['displayName']?.toString(),
          'profileCompleted': validatedData['profileCompleted'],
          'isActive': validatedData['isActive'],
        },
      );

      // Crear el modelo usando los datos validados
      final owner = OwnerDataModel.fromJson(validatedData).copyWith(id: id);

      AppLogger.logInfo(
        'Propietario procesado correctamente',
        className: _className,
        functionName: '_createOwnerModelSafely',
        params: {
          'ownerId': id,
          'email': owner.email,
          'displayName': owner.displayName,
          'status': owner.status.toString(),
        },
      );

      return owner;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error creando modelo de propietario',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: '_createOwnerModelSafely',
        params: {
          'docId': id,
          'errorType': e.runtimeType.toString(),
          'errorMessage': e.toString(),
          'dataKeys': data.keys.toList(),
          'email': data['email']?.toString(),
        },
      );
      return null;
    }
  }

  /// Valida y sanitiza los datos del propietario antes del procesamiento
  Map<String, dynamic>? _validateAndSanitizeOwnerData(Map<String, dynamic> data) {
    try {
      final sanitized = Map<String, dynamic>.from(data);

      AppLogger.logInfo(
        'Iniciando validación y sanitización de datos',
        className: _className,
        functionName: '_validateAndSanitizeOwnerData',
        params: {
          'originalKeys': data.keys.toList(),
          'email': data['email']?.toString(),
          'emailType': data['email']?.runtimeType.toString(),
        },
      );

      // Validar campo email (requerido)
      if (!sanitized.containsKey('email') || 
          sanitized['email'] == null || 
          sanitized['email'].toString().trim().isEmpty) {
        AppLogger.logError(
          message: 'Campo email faltante o inválido',
          className: _className,
          functionName: '_validateAndSanitizeOwnerData',
          params: {
            'email': sanitized['email']?.toString(),
            'hasEmailKey': sanitized.containsKey('email'),
            'emailIsNull': sanitized['email'] == null,
          },
        );
        return null;
      }

      // Sanitizar email - asegurar que no sea null después de sanitizar
      final emailValue = sanitized['email'].toString().trim().toLowerCase();
      if (emailValue.isEmpty) {
        AppLogger.logError(
          message: 'Email vacío después de sanitización',
          className: _className,
          functionName: '_validateAndSanitizeOwnerData',
          params: {'originalEmail': sanitized['email']?.toString()},
        );
        return null;
      }
      sanitized['email'] = emailValue;

      // Sanitizar displayName
      if (sanitized.containsKey('displayName') && sanitized['displayName'] != null) {
        sanitized['displayName'] = sanitized['displayName'].toString().trim();
        // Si displayName está vacío después del trim, ponerlo como null
        if (sanitized['displayName'].toString().isEmpty) {
          sanitized['displayName'] = null;
        }
      }

      // Sanitizar phoneNumber
      if (sanitized.containsKey('phoneNumber') && sanitized['phoneNumber'] != null) {
        sanitized['phoneNumber'] = sanitized['phoneNumber'].toString().trim();
        // Si phoneNumber está vacío después del trim, ponerlo como null
        if (sanitized['phoneNumber'].toString().isEmpty) {
          sanitized['phoneNumber'] = null;
        }
      }

      // Sanitizar photoUrl
      if (sanitized.containsKey('photoUrl') && sanitized['photoUrl'] != null) {
        sanitized['photoUrl'] = sanitized['photoUrl'].toString().trim();
        // Si photoUrl está vacío después del trim, ponerlo como null
        if (sanitized['photoUrl'].toString().isEmpty) {
          sanitized['photoUrl'] = null;
        }
      }

      // Validar y sanitizar campos booleanos
      sanitized['profileCompleted'] = _sanitizeBoolean(sanitized['profileCompleted'], false);
      sanitized['isActive'] = _sanitizeBoolean(sanitized['isActive'], true);

      // Sanitizar timestamps
      sanitized['createdAt'] = _sanitizeTimestamp(sanitized['createdAt']);
      sanitized['updatedAt'] = _sanitizeTimestamp(sanitized['updatedAt']);
      sanitized['lastLoginAt'] = _sanitizeTimestamp(sanitized['lastLoginAt']);

      // Sanitizar metadata
      if (!sanitized.containsKey('metadata') || sanitized['metadata'] == null) {
        sanitized['metadata'] = <String, dynamic>{};
      } else if (sanitized['metadata'] is! Map) {
        sanitized['metadata'] = <String, dynamic>{};
      }

      // Remover el campo 'id' si existe para evitar conflictos
      sanitized.remove('id');

      AppLogger.logInfo(
        'Datos del propietario validados y sanitizados exitosamente',
        className: _className,
        functionName: '_validateAndSanitizeOwnerData',
        params: {
          'email': sanitized['email'],
          'hasDisplayName': sanitized['displayName'] != null,
          'profileCompleted': sanitized['profileCompleted'],
          'isActive': sanitized['isActive'],
          'finalKeys': sanitized.keys.toList(),
        },
      );

      return sanitized;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error validando y sanitizando datos del propietario',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: '_validateAndSanitizeOwnerData',
        params: {
          'originalEmail': data['email']?.toString(),
          'originalKeys': data.keys.toList(),
        },
      );
      return null;
    }
  }

  /// Sanitiza un valor booleano con valor por defecto
  bool _sanitizeBoolean(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Sanitiza un timestamp individual
  DateTime? _sanitizeTimestamp(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      if (value is String) {
        return DateTime.tryParse(value);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      
      AppLogger.logWarning(
        'Tipo de timestamp no reconocido',
        className: _className,
        functionName: '_sanitizeTimestamp',
        params: {
          'valueType': value.runtimeType.toString(),
          'value': value.toString(),
        },
      );
      return null;
    } catch (e) {
      AppLogger.logWarning(
        'Error sanitizando timestamp',
        className: _className,
        functionName: '_sanitizeTimestamp',
        params: {
          'value': value.toString(),
          'error': e.toString(),
        },
      );
      return null;
    }
  }
} 