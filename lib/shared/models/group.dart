import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

// Funciones de conversión DateTime/String globales
DateTime dateTimeFromString(String dateString) => DateTime.parse(dateString);
String dateTimeToString(DateTime dateTime) => dateTime.toIso8601String();

@freezed
class Group with _$Group {
  const factory Group({
    required String id,
    required String academyId,
    required String name,
    String? description,
    String? coachId,
    List<String>? athleteIds,
    Map<String, dynamic>? settings,
    @JsonKey(
      fromJson: dateTimeFromString,
      toJson: dateTimeToString,
    )
    required DateTime createdAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
} 