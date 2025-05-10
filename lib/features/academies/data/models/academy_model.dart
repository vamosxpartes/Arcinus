import 'package:arcinus/features/subscriptions/data/models/app_subscription_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy_model.freezed.dart';
part 'academy_model.g.dart';

/// Modelo de academia deportiva
@freezed
class AcademyModel with _$AcademyModel {
  const factory AcademyModel({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id, // ID se maneja externamente
    required String ownerId,
    required String name,
    required String sportCode,
    @Default('') String location,
    @Default('') String description,
    @Default('') String logoUrl,
    @Default('') String address,
    @Default('') String phone,
    @Default('') String email,
    @Default(0) int membersCount,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
    // Referencias a la suscripción del propietario
    String? ownerSubscriptionId,
    // Lista de características heredadas del plan del propietario
    @Default([]) @JsonKey(ignore: true) List<AppFeature> inheritedFeatures,
    @Default({}) Map<String, dynamic> metadata,
  }) = _AcademyModel;

  /// Crea un AcademyModel desde un Map de Firestore
  factory AcademyModel.fromJson(Map<String, dynamic> json) => _$AcademyModelFromJson(json);

  // Nota: El ID del documento (docId) no se incluye directamente en fromJson/toJson.
  // Se recomienda manejarlo en la capa de repositorio/datasource al obtener/guardar datos.
  // Ejemplo:
  // final academy = AcademyModel.fromJson(snapshot.data()!).copyWith(id: snapshot.id);
}
