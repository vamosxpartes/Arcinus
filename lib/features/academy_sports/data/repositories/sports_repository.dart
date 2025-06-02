import 'package:arcinus/features/academy_sports/data/models/sport_model.dart';
import 'package:arcinus/features/academy_sports/models/sport_characteristics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Repositorio para gestionar los deportes en Firestore
class SportsRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'sports';
  static const String _className = 'SportsRepository';

  SportsRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtiene la referencia a la colección de deportes
  CollectionReference<Map<String, dynamic>> get sportsCollection => 
      _firestore.collection(_collectionPath);

  /// Inicializa la colección de deportes con todos los deportes soportados
  Future<void> initializeSportsCollection() async {
    try {
      AppLogger.logInfo(
        'Iniciando inicialización de colección de deportes en Firestore',
        className: _className,
        functionName: 'initializeSportsCollection',
      );

      final sports = SportModel.getAllSports();
      
      AppLogger.logInfo(
        'Lista de deportes obtenida',
        className: _className,
        functionName: 'initializeSportsCollection',
        params: {
          'sportsCount': sports.length,
          'sportCodes': sports.map((s) => s.code).toList(),
        },
      );
      
      int successCount = 0;
      int errorCount = 0;
      
      // Crear deportes uno por uno en lugar de usar batch para mejor debugging
      for (int i = 0; i < sports.length; i++) {
        final sport = sports[i];
        try {
          AppLogger.logInfo(
            'Procesando deporte',
            className: _className,
            functionName: 'initializeSportsCollection',
            params: {
              'index': i,
              'sportCode': sport.code,
              'sportName': sport.name,
            },
          );

          final docRef = sportsCollection.doc(sport.code);
          
          // Convertir a JSON de forma segura
          Map<String, dynamic> sportJson;
          try {
            sportJson = sport.toJson();
            
            AppLogger.logInfo(
              'Deporte serializado a JSON exitosamente',
              className: _className,
              functionName: 'initializeSportsCollection',
              params: {
                'sportCode': sport.code,
                'jsonKeys': sportJson.keys.toList(),
                'hasCharacteristics': sportJson.containsKey('characteristics'),
              },
            );
          } catch (e, stackTrace) {
            AppLogger.logError(
              message: 'Error serializando deporte a JSON, usando datos básicos',
              error: e,
              stackTrace: stackTrace,
              className: _className,
              functionName: 'initializeSportsCollection',
              params: {'sportCode': sport.code},
            );
            
            // Crear JSON básico como fallback
            sportJson = {
              'code': sport.code,
              'name': sport.name,
              'displayName': sport.displayName,
              'icon': sport.icon,
              'isActive': sport.isActive,
              'characteristics': {
                'athleteStats': ['altura', 'peso'],
                'statUnits': {'altura': 'cm', 'peso': 'kg'},
                'athleteSpecializations': ['general'],
                'positions': ['Jugador'],
                'formations': {'básica': ['Jugador']},
                'defaultPlayersPerTeam': 1,
                'exerciseCategories': ['técnica', 'físico'],
                'predefinedExercises': ['calentamiento'],
                'equipmentNeeded': ['equipamiento_básico'],
                'matchRules': {'tiempo': 60},
                'scoreTypes': ['punto'],
                'foulTypes': {'falta': 'Infracción general'},
                'additionalParams': {},
              },
              'metadata': {},
            };
          }

          // Usar set individual en lugar de batch para mejor error handling
          await docRef.set(sportJson, SetOptions(merge: true));
          
          successCount++;
          AppLogger.logInfo(
            'Deporte guardado exitosamente',
            className: _className,
            functionName: 'initializeSportsCollection',
            params: {
              'sportCode': sport.code,
              'completed': '${i + 1}/${sports.length}',
              'successCount': successCount,
            },
          );
        } catch (e, stackTrace) {
          errorCount++;
          AppLogger.logError(
            message: 'Error procesando deporte específico',
            error: e,
            stackTrace: stackTrace,
            className: _className,
            functionName: 'initializeSportsCollection',
            params: {
              'sportCode': sport.code,
              'index': i,
              'errorCount': errorCount,
            },
          );
          // Continuar con el siguiente deporte en lugar de fallar completamente
          continue;
        }
      }
      
      AppLogger.logInfo(
        'Inicialización de deportes completada',
        className: _className,
        functionName: 'initializeSportsCollection',
        params: {
          'totalSports': sports.length,
          'successCount': successCount,
          'errorCount': errorCount,
          'successRate': '${((successCount / sports.length) * 100).toStringAsFixed(1)}%',
        },
      );
      
      if (errorCount > 0) {
        AppLogger.logWarning(
          'La inicialización se completó con algunos errores',
          className: _className,
          functionName: 'initializeSportsCollection',
          params: {
            'errorCount': errorCount,
            'successCount': successCount,
          },
        );
      }
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error durante inicialización de colección de deportes',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'initializeSportsCollection',
      );
      rethrow;
    }
  }

  /// Método alternativo usando batch (mantener como backup)
  Future<void> initializeSportsCollectionBatch() async {
    try {
      AppLogger.logInfo(
        'Iniciando inicialización de colección de deportes en Firestore (batch)',
        className: _className,
        functionName: 'initializeSportsCollectionBatch',
      );

      final batch = _firestore.batch();
      
      AppLogger.logInfo(
        'Batch creado, obteniendo lista de deportes',
        className: _className,
        functionName: 'initializeSportsCollectionBatch',
      );

      final sports = SportModel.getAllSports();
      
      AppLogger.logInfo(
        'Lista de deportes obtenida',
        className: _className,
        functionName: 'initializeSportsCollectionBatch',
        params: {
          'sportsCount': sports.length,
          'sportCodes': sports.map((s) => s.code).toList(),
        },
      );
      
      for (int i = 0; i < sports.length; i++) {
        final sport = sports[i];
        try {
          AppLogger.logInfo(
            'Procesando deporte',
            className: _className,
            functionName: 'initializeSportsCollectionBatch',
            params: {
              'index': i,
              'sportCode': sport.code,
              'sportName': sport.name,
            },
          );

          final docRef = sportsCollection.doc(sport.code);
          final sportJson = sport.toJson();
          
          AppLogger.logInfo(
            'Deporte serializado a JSON',
            className: _className,
            functionName: 'initializeSportsCollectionBatch',
            params: {
              'sportCode': sport.code,
              'jsonKeys': sportJson.keys.toList(),
            },
          );

          batch.set(docRef, sportJson, SetOptions(merge: true));
          
          AppLogger.logInfo(
            'Deporte agregado al batch',
            className: _className,
            functionName: 'initializeSportsCollectionBatch',
            params: {
              'sportCode': sport.code,
              'completed': '${i + 1}/${sports.length}',
            },
          );
        } catch (e, stackTrace) {
          AppLogger.logError(
            message: 'Error procesando deporte específico',
            error: e,
            stackTrace: stackTrace,
            className: _className,
            functionName: 'initializeSportsCollectionBatch',
            params: {
              'sportCode': sport.code,
              'index': i,
            },
          );
          rethrow;
        }
      }
      
      AppLogger.logInfo(
        'Todos los deportes procesados, ejecutando batch commit',
        className: _className,
        functionName: 'initializeSportsCollectionBatch',
        params: {'sportsCount': sports.length},
      );

      await batch.commit();
      
      AppLogger.logInfo(
        'Batch commit completado exitosamente',
        className: _className,
        functionName: 'initializeSportsCollectionBatch',
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error durante inicialización de colección de deportes (batch)',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'initializeSportsCollectionBatch',
      );
      rethrow;
    }
  }

  /// Obtiene todos los deportes
  Future<List<SportModel>> getAllSports() async {
    try {
      final snapshot = await sportsCollection.get();
      final sports = <SportModel>[];
      
      for (final doc in snapshot.docs) {
        try {
          final sport = SportModel.fromJsonSafe(doc.data()).copyWith(id: doc.id);
          sports.add(sport);
          
          AppLogger.logInfo(
            'Deporte deserializado exitosamente',
            className: _className,
            functionName: 'getAllSports',
            params: {'sportId': doc.id, 'sportCode': sport.code},
          );
        } catch (e, stackTrace) {
          AppLogger.logError(
            message: 'Error deserializando deporte individual',
            error: e,
            stackTrace: stackTrace,
            className: _className,
            functionName: 'getAllSports',
            params: {'docId': doc.id, 'docData': doc.data()},
          );
          // Continuar con el siguiente deporte en lugar de fallar completamente
        }
      }
      
      AppLogger.logInfo(
        'Todos los deportes obtenidos',
        className: _className,
        functionName: 'getAllSports',
        params: {'totalDeports': sports.length, 'totalDocs': snapshot.docs.length},
      );
      
      return sports;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error obteniendo deportes',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getAllSports',
      );
      return []; // Devolver lista vacía en lugar de fallar
    }
  }

  /// Obtiene un deporte por su código
  Future<SportModel?> getSportByCode(String sportCode) async {
    try {
      final docSnapshot = await sportsCollection.doc(sportCode).get();
      
      if (!docSnapshot.exists) {
        AppLogger.logInfo(
          'Deporte no encontrado en Firestore',
          className: _className,
          functionName: 'getSportByCode',
          params: {'sportCode': sportCode},
        );
        return null;
      }
      
      final data = docSnapshot.data();
      if (data == null) {
        AppLogger.logWarning(
          'Documento de deporte existe pero sin datos',
          className: _className,
          functionName: 'getSportByCode',
          params: {'sportCode': sportCode},
        );
        return null;
      }
      
      return SportModel.fromJsonSafe(data).copyWith(id: docSnapshot.id);
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error obteniendo deporte por código',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getSportByCode',
        params: {'sportCode': sportCode},
      );
      return null;
    }
  }

  /// Obtiene las características de un deporte por su código
  Future<SportCharacteristics?> getSportCharacteristics(String sportCode) async {
    try {
      final sport = await getSportByCode(sportCode);
      if (sport == null) {
        AppLogger.logInfo(
          'Deporte no encontrado para obtener características',
          className: _className,
          functionName: 'getSportCharacteristics',
          params: {'sportCode': sportCode},
        );
        return null;
      }
      
      return sport.characteristics;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error obteniendo características del deporte',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'getSportCharacteristics',
        params: {'sportCode': sportCode},
      );
      return null;
    }
  }

  /// Actualiza un deporte con validación mejorada
  Future<void> updateSport(SportModel sport) async {
    try {
      if (sport.id == null || sport.id!.isEmpty) {
        throw ArgumentError('El deporte debe tener un ID válido para actualizarlo');
      }
      
      AppLogger.logInfo(
        'Actualizando deporte',
        className: _className,
        functionName: 'updateSport',
        params: {'sportId': sport.id, 'sportCode': sport.code},
      );
      
      final json = sport.toJson();
      await sportsCollection.doc(sport.id).update(json);
      
      AppLogger.logInfo(
        'Deporte actualizado exitosamente',
        className: _className,
        functionName: 'updateSport',
        params: {'sportId': sport.id},
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error actualizando deporte',
        error: e,
        stackTrace: stackTrace,
        className: _className,
        functionName: 'updateSport',
        params: {'sportId': sport.id, 'sportCode': sport.code},
      );
      rethrow;
    }
  }
} 