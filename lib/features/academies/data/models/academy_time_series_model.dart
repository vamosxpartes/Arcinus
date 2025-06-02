import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'academy_time_series_model.freezed.dart';
part 'academy_time_series_model.g.dart';

/// Modelo para almacenar datos de series temporales (datos históricos)
@freezed
class AcademyTimeSeriesModel with _$AcademyTimeSeriesModel {
  const factory AcademyTimeSeriesModel({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    required String academyId,
    required int year,
    required int month,
    required String label, // "Ene 2023", etc.
    required Map<String, double> metrics, // {"members": 42, "revenue": 3500.0, "attendance": 78.5}
    @TimestampConverter() required DateTime timestamp,
    @Default({}) Map<String, dynamic> additionalData,
  }) = _AcademyTimeSeriesModel;

  /// Crea un AcademyTimeSeriesModel desde un Map de Firestore
  factory AcademyTimeSeriesModel.fromJson(Map<String, dynamic> json) => 
      _$AcademyTimeSeriesModelFromJson(json);
} 