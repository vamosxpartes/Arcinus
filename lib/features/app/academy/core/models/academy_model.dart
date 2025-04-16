import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../sports/core/models/sport_characteristics.dart';

part 'academy_model.freezed.dart';
part 'academy_model.g.dart';

// Funciones de conversión DateTime/String globales
DateTime dateTimeFromString(String dateString) => DateTime.parse(dateString);
String dateTimeToString(DateTime dateTime) => dateTime.toIso8601String();

@freezed
class Academy with _$Academy {
  const factory Academy({
    required String       academyId,
    required String       academyName,
    required String       academyOwnerId,
    required String       academySport,
    required String       academySubscription,
    @JsonKey(
      fromJson: dateTimeFromString,
      toJson: dateTimeToString,
    )
    required DateTime     createdAt,
    String?               academyLogo,
    String?               academyFormattedAddress,
    double?               academyLatitude,
    double?               academyLongitude,
    String?               academyGooglePlaceId,
    String?               academyTaxId,
    String?               academyDescription,
    SportCharacteristics? academySportConfig,
    List<String>?         academyGroupIds,
    List<String>?         academyCoachIds,
    List<String>?         academyAthleteIds,
    Map<String, dynamic>? academySettings,
     String? academyLocation,
  }) = _Academy;

  const Academy._();

  factory Academy.fromJson(Map<String, dynamic> json) => _$AcademyFromJson(json);
} 