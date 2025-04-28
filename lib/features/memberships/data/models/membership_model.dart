import 'package:arcinus/core/auth/roles.dart'; // Importar AppRole
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart'; // Asumiendo existe

part 'membership_model.freezed.dart';
part 'membership_model.g.dart';

/// Representa la membresía de un usuario a una academia específica,
/// incluyendo su rol y permisos dentro de ella.
@freezed
class MembershipModel with _$MembershipModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory MembershipModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id, // ID del documento de membresía en Firestore
    required String userId,
    required String academyId,
    // Usar el enum AppRole directamente, json_serializable lo manejará con @JsonEnum
    required AppRole role, 
    // Lista de permisos específicos (strings), útil para Colaboradores
    @Default([]) List<String> permissions, 
    // Fecha en que se añadió/creó la membresía
    required DateTime addedAt, 
  }) = _MembershipModel;

  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      _$MembershipModelFromJson(json);
}

// Helpers para serialización/deserialización de AppRole
AppRole _roleFromJson(dynamic json) => AppRole.fromString(json as String?);
String _roleToJson(AppRole role) => role.name;
