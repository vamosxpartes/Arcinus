import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'academy_stats_model.freezed.dart';
part 'academy_stats_model.g.dart';

/// Modelo para almacenar estadísticas actuales de una academia
@freezed
class AcademyStatsModel with _$AcademyStatsModel {
  const factory AcademyStatsModel({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    required String academyId,
    required int totalMembers,
    double? monthlyRevenue,
    double? attendanceRate,
    int? totalTeams,
    int? totalStaff,
    double? retentionRate,
    double? growthRate,
    double? projectedAnnualRevenue,
    @NullableTimestampConverter() DateTime? lastUpdated,
    @Default({}) Map<String, dynamic> additionalData,
  }) = _AcademyStatsModel;

  /// Crea un AcademyStatsModel desde un Map de Firestore
  factory AcademyStatsModel.fromJson(Map<String, dynamic> json) => 
      _$AcademyStatsModelFromJson(json);
} 