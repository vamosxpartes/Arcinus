import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/features/academy_sports/models/sport_characteristics.dart';

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
    final characteristics = SportCharacteristics.forSport(sportCode);
    
    return SportModel(
      code: sportCode,
      name: _getDisplayNameFromCode(sportCode),
      displayName: _getDisplayNameFromCode(sportCode),
      icon: _getIconFromCode(sportCode),
      characteristics: characteristics,
    );
  }
  
  /// Crea los modelos para todos los deportes soportados
  static List<SportModel> getAllSports() {
    return [
      'basketball',
      'volleyball',
      'skating',
      'soccer',
      'futsal',
    ].map((code) => SportModel.fromSportCode(code)).toList();
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
    default:
      return 'sports';
  }
} 