import 'package:arcinus/core/auth/roles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'manager_user_model.freezed.dart';
part 'manager_user_model.g.dart';

/// Estados posibles para un usuario manager
enum ManagerStatus {
  /// Manager activo (con permisos completos según su rol)
  active,
  
  /// Manager con acceso restringido temporalmente
  restricted,
  
  /// Manager inactivo (sin acceso)
  inactive
}

/// Extensión para facilitar la serialización/deserialización del enum ManagerStatus
extension ManagerStatusExtension on ManagerStatus {
  /// Convierte el enum a su representación en String (nombre del enum)
  String toJson() => name;

  /// Devuelve un nombre amigable para mostrar en la UI
  String get displayName {
    switch (this) {
      case ManagerStatus.active:
        return 'Activo';
      case ManagerStatus.restricted:
        return 'Restringido';
      case ManagerStatus.inactive:
        return 'Inactivo';
    }
  }
  
  /// Devuelve un color asociado con el estado
  String get color {
    switch (this) {
      case ManagerStatus.active:
        return '#4CAF50'; // Verde
      case ManagerStatus.restricted:
        return '#FF9800'; // Naranja
      case ManagerStatus.inactive:
        return '#9E9E9E'; // Gris
    }
  }

  /// Función de deserialización estática para json_serializable
  static ManagerStatus fromJson(String json) {
    return ManagerStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ManagerStatus.inactive,
    );
  }
}

/// Tipos de permisos que puede tener un manager
enum ManagerPermission {
  /// Permiso para gestionar usuarios (añadir, modificar, eliminar)
  manageUsers,
  
  /// Permiso para gestionar pagos (registrar, modificar, eliminar)
  managePayments,
  
  /// Permiso para gestionar suscripciones y planes
  manageSubscriptions,
  
  /// Permiso para ver estadísticas y reportes
  viewStats,
  
  /// Permiso para modificar configuración de academia
  editAcademy,
  
  /// Permiso para gestionar horarios y eventos
  manageSchedule,
  
  /// Permiso para acceder a todas las funcionalidades (solo propietarios)
  fullAccess
}

/// Extensión para facilitar la serialización/deserialización del enum ManagerPermission
extension ManagerPermissionExtension on ManagerPermission {
  /// Convierte el enum a su representación en String (nombre del enum)
  String toJson() => name;

  /// Devuelve un nombre amigable para mostrar en la UI
  String get displayName {
    switch (this) {
      case ManagerPermission.manageUsers:
        return 'Gestionar Usuarios';
      case ManagerPermission.managePayments:
        return 'Gestionar Pagos';
      case ManagerPermission.manageSubscriptions:
        return 'Gestionar Suscripciones';
      case ManagerPermission.viewStats:
        return 'Ver Estadísticas';
      case ManagerPermission.editAcademy:
        return 'Editar Academia';
      case ManagerPermission.manageSchedule:
        return 'Gestionar Horarios';
      case ManagerPermission.fullAccess:
        return 'Acceso Completo';
    }
  }

  /// Función de deserialización estática para json_serializable
  static ManagerPermission fromJson(String json) {
    return ManagerPermission.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ManagerPermission.manageUsers,
    );
  }
}

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