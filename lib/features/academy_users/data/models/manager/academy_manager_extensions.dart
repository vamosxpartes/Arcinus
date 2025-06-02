import 'package:arcinus/features/academy_users/data/models/manager/academy_manager_permission.dart';
import 'package:arcinus/features/academy_users/data/models/manager/academy_manager_status.dart';

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