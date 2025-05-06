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
    String? description,
    String? logoUrl,
    String? address,
    String? phone,
    String? email,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
    required String location,
  }) = _AcademyModel;

  /// Crea un AcademyModel desde un Map de Firestore
  factory AcademyModel.fromJson(Map<String, dynamic> json) => _$AcademyModelFromJson(json);

  // Nota: El ID del documento (docId) no se incluye directamente en fromJson/toJson.
  // Se recomienda manejarlo en la capa de repositorio/datasource al obtener/guardar datos.
  // Ejemplo:
  // final academy = AcademyModel.fromJson(snapshot.data()!).copyWith(id: snapshot.id);
}
