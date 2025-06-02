import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/features/academy_sports/models/sport_characteristics.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'sport_model.freezed.dart';
part 'sport_model.g.dart';

/// Modelo para representar un deporte en Firestore
@freezed
class SportModel with _$SportModel {
  const factory SportModel({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    required String code,
    required String name,
    required String icon,
    required String displayName,
    @Default(true) bool isActive,
    required SportCharacteristics characteristics,
    @Default({}) Map<String, dynamic> metadata,
  }) = _SportModel;

  factory SportModel.fromJson(Map<String, dynamic> json) => 
      _$SportModelFromJson(json);
      
  /// Crear un SportModel desde SportCharacteristics
  factory SportModel.fromSportCode(String sportCode) {
    try {
      AppLogger.logInfo(
        'Creando SportModel desde código',
        className: 'SportModel',
        functionName: 'fromSportCode',
        params: {'sportCode': sportCode},
      );

      // Usar try-catch para manejar errores en la creación de características
      late SportCharacteristics characteristics;
      try {
        characteristics = SportCharacteristics.forSport(sportCode);
      } catch (e, stackTrace) {
        AppLogger.logError(
          message: 'Error creando SportCharacteristics, usando básico',
          error: e,
          stackTrace: stackTrace,
          className: 'SportModel',
          functionName: 'fromSportCode',
          params: {'sportCode': sportCode}
        );
        characteristics = SportCharacteristics.basic(sportCode);
      }
      
      AppLogger.logInfo(
        'SportCharacteristics creado exitosamente',
        className: 'SportModel',
        functionName: 'fromSportCode',
        params: {
          'sportCode': sportCode,
          'hasCharacteristics': true,
          'positionsCount': characteristics.positions.length,
        },
      );
      
      final sportModel = SportModel(
        code: sportCode,
        name: _getDisplayNameFromCode(sportCode),
        displayName: _getDisplayNameFromCode(sportCode),
        icon: _getIconFromCode(sportCode),
        characteristics: characteristics,
      );
      
      AppLogger.logInfo(
        'SportModel creado exitosamente',
        className: 'SportModel',
        functionName: 'fromSportCode',
        params: {
          'sportCode': sportCode,
          'name': sportModel.name,
          'icon': sportModel.icon,
        },
      );
      
      return sportModel;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error creando SportModel desde código',
        error: e,
        stackTrace: stackTrace,
        className: 'SportModel',
        functionName: 'fromSportCode',
        params: {'sportCode': sportCode},
      );
      
      // Crear un modelo básico como fallback
      return SportModel(
        code: sportCode,
        name: _getDisplayNameFromCode(sportCode),
        displayName: _getDisplayNameFromCode(sportCode),
        icon: _getIconFromCode(sportCode),
        characteristics: SportCharacteristics.basic(sportCode),
      );
    }
  }
  
  /// Método factory con validación adicional para JSON
  factory SportModel.fromJsonSafe(Map<String, dynamic> json) {
    try {
      AppLogger.logInfo(
        'Deserializando SportModel desde JSON',
        className: 'SportModel',
        functionName: 'fromJsonSafe',
        params: {
          'jsonKeys': json.keys.toList(),
          'hasCharacteristics': json.containsKey('characteristics'),
        },
      );

      // Validar campos requeridos
      final code = json['code']?.toString();
      if (code == null || code.isEmpty) {
        throw ArgumentError('Campo code es requerido');
      }

      // Validar y sanitizar SportCharacteristics
      SportCharacteristics? characteristics;
      if (json.containsKey('characteristics') && json['characteristics'] != null) {
        try {
          final characteristicsData = json['characteristics'];
          if (characteristicsData is Map<String, dynamic>) {
            characteristics = SportCharacteristics.fromJsonSafe(characteristicsData);
          } else {
            AppLogger.logWarning(
              'Campo characteristics no es un Map válido',
              className: 'SportModel',
              functionName: 'fromJsonSafe',
              params: {'characteristicsType': characteristicsData.runtimeType}
            );
            characteristics = SportCharacteristics.basic(code);
          }
        } catch (e) {
          AppLogger.logWarning(
            'Error deserializando characteristics, usando básico',
            error: e,
            className: 'SportModel',
            functionName: 'fromJsonSafe',
          );
          characteristics = SportCharacteristics.basic(code);
        }
      } else {
        characteristics = SportCharacteristics.basic(code);
      }

      return SportModel(
        code: code,
        name: json['name']?.toString() ?? _getDisplayNameFromCode(code),
        displayName: json['displayName']?.toString() ?? _getDisplayNameFromCode(code),
        icon: json['icon']?.toString() ?? _getIconFromCode(code),
        isActive: json['isActive'] as bool? ?? true,
        characteristics: characteristics,
        metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error deserializando SportModel, creando modelo básico',
        error: e,
        stackTrace: stackTrace,
        className: 'SportModel',
        functionName: 'fromJsonSafe',
        params: {'json': json}
      );
      
      // Crear modelo básico como fallback
      final code = json['code']?.toString() ?? 'unknown';
      return SportModel(
        code: code,
        name: _getDisplayNameFromCode(code),
        displayName: _getDisplayNameFromCode(code),
        icon: _getIconFromCode(code),
        characteristics: SportCharacteristics.basic(code),
      );
    }
  }
  
  /// Crea los modelos para todos los deportes soportados
  static List<SportModel> getAllSports() {
    try {
      AppLogger.logInfo(
        'Iniciando creación de todos los deportes',
        className: 'SportModel',
        functionName: 'getAllSports',
      );

      final sportCodes = [
        'basketball',
        'volleyball',
        'skating',
        'soccer',
        'futsal',
        'weightlifting',
      ];
      
      AppLogger.logInfo(
        'Códigos de deportes a procesar',
        className: 'SportModel',
        functionName: 'getAllSports',
        params: {
          'sportCodes': sportCodes,
          'count': sportCodes.length,
        },
      );

      final sports = <SportModel>[];
      
      for (int i = 0; i < sportCodes.length; i++) {
        final code = sportCodes[i];
        try {
          AppLogger.logInfo(
            'Procesando código de deporte',
            className: 'SportModel',
            functionName: 'getAllSports',
            params: {
              'code': code,
              'index': i,
              'progress': '${i + 1}/${sportCodes.length}',
            },
          );

          final sport = SportModel.fromSportCode(code);
          sports.add(sport);
          
          AppLogger.logInfo(
            'Deporte agregado exitosamente',
            className: 'SportModel',
            functionName: 'getAllSports',
            params: {
              'code': code,
              'name': sport.name,
              'completed': '${i + 1}/${sportCodes.length}',
            },
          );
        } catch (e, stackTrace) {
          AppLogger.logError(
            message: 'Error procesando código específico de deporte',
            error: e,
            stackTrace: stackTrace,
            className: 'SportModel',
            functionName: 'getAllSports',
            params: {
              'code': code,
              'index': i,
            },
          );
          rethrow;
        }
      }
      
      AppLogger.logInfo(
        'Todos los deportes creados exitosamente',
        className: 'SportModel',
        functionName: 'getAllSports',
        params: {
          'totalCreated': sports.length,
          'expectedCount': sportCodes.length,
        },
      );
      
      return sports;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error en getAllSports',
        error: e,
        stackTrace: stackTrace,
        className: 'SportModel',
        functionName: 'getAllSports',
      );
      rethrow;
    }
  }
}

/// Obtiene el nombre de visualización para un código de deporte
String _getDisplayNameFromCode(String code) {
  switch (code.toLowerCase()) {
    case 'basketball':
      return 'Baloncesto';
    case 'volleyball':
      return 'Voleibol';
    case 'skating':
      return 'Patinaje';
    case 'soccer':
      return 'Fútbol';
    case 'futsal':
      return 'Fútbol Sala';
    case 'weightlifting':
      return 'Levantamiento de Pesas';
    default:
      return code.substring(0, 1).toUpperCase() + code.substring(1);
  }
}

/// Obtiene el icono para un código de deporte
String _getIconFromCode(String code) {
  switch (code.toLowerCase()) {
    case 'basketball':
      return 'sports_basketball';
    case 'volleyball':
      return 'sports_volleyball';
    case 'skating':
      return 'ice_skating';
    case 'soccer':
      return 'sports_soccer';
    case 'futsal':
      return 'sports_soccer';
    case 'weightlifting':
      return 'fitness_center';
    default:
      return 'sports';
  }
} 