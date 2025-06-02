import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/academy_users/data/models/manager/academy_manager_permission.dart';
import 'package:arcinus/features/academy_users/data/models/manager/academy_manager_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'academy_manager_model.freezed.dart';
part 'academy_manager_model.g.dart';

/// Modelo de usuario manager (propietarios y colaboradores)
@freezed
class ManagerUserModel with _$ManagerUserModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory ManagerUserModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id,
    required String userId,
    required String academyId,
    required AppRole managerType, // PROPIETARIO o COLABORADOR
    @Default(ManagerStatus.active) ManagerStatus status,
    @Default([]) List<ManagerPermission> permissions,
    @Default([]) List<String> managedAcademyIds, // Academias que gestiona (relevante para propietarios con múltiples academias)
    DateTime? lastLoginDate,
    @Default(0) int academyCount, // Número de academias para propietarios
    @Default(0) int managedUsersCount, // Número de usuarios que gestiona
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ManagerUserModel;

  factory ManagerUserModel.fromJson(Map<String, dynamic> json) =>
      _$ManagerUserModelFromJson(json);
}

/// Extensión con propiedades computadas útiles
extension ManagerUserExtension on ManagerUserModel {
  /// Verifica si el usuario está activo
  bool get isActive => status == ManagerStatus.active;
  
  /// Verifica si el usuario tiene acceso restringido
  bool get isRestricted => status == ManagerStatus.restricted;
  
  /// Verifica si el usuario es propietario
  bool get isOwner => managerType == AppRole.propietario;
  
  /// Verifica si el usuario es colaborador
  bool get isCollaborator => managerType == AppRole.colaborador;
  
  /// Verifica si el usuario tiene un permiso específico
  bool hasPermission(ManagerPermission permission) {
    return permissions.contains(permission) || permissions.contains(ManagerPermission.fullAccess);
  }
  
  /// Verifica si el usuario es propietario de una academia específica
  bool isOwnerOf(String academyId) {
    return isOwner && managedAcademyIds.contains(academyId);
  }
} 