import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'owner_data_model.freezed.dart';
part 'owner_data_model.g.dart';

/// Modelo de datos del propietario para gestión por SuperAdmin
@freezed
class OwnerDataModel with _$OwnerDataModel {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory OwnerDataModel({
    /// ID único del propietario (Firebase Auth UID)
    @Default('') String id,
    
    /// Email del propietario
    required String email,
    
    /// Nombre para mostrar
    String? displayName,
    
    /// URL de la foto de perfil
    String? photoUrl,
    
    /// Número de teléfono
    String? phoneNumber,
    
    /// Indica si el perfil está completado
    @Default(false) bool profileCompleted,
    
    /// Indica si el usuario está activo
    @Default(true) bool isActive,
    
    /// Fecha de creación del usuario
    DateTime? createdAt,
    
    /// Fecha de última actualización
    DateTime? updatedAt,
    
    /// Fecha del último inicio de sesión
    DateTime? lastLoginAt,
    
    /// Metadatos adicionales
    @Default({}) Map<String, dynamic> metadata,
  }) = _OwnerDataModel;

  factory OwnerDataModel.fromJson(Map<String, dynamic> json) => 
      _$OwnerDataModelFromJson(json);
}

/// Información básica de la academia asociada al propietario
@freezed
class AcademyBasicInfoModel with _$AcademyBasicInfoModel {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory AcademyBasicInfoModel({
    /// ID de la academia
    @Default('') String id,
    
    /// Nombre de la academia
    required String name,
    
    /// URL del logo
    String? logoUrl,
    
    /// Código del deporte
    required String sportCode,
    
    /// Ubicación
    @Default('') String location,
    
    /// Dirección
    @Default('') String address,
    
    /// Teléfono de contacto
    @Default('') String phone,
    
    /// Email de contacto
    @Default('') String email,
    
    /// Número de miembros
    @Default(0) int membersCount,
    
    /// Fecha de creación
    DateTime? createdAt,
    
    /// Fecha de última actualización
    DateTime? updatedAt,
  }) = _AcademyBasicInfoModel;

  factory AcademyBasicInfoModel.fromJson(Map<String, dynamic> json) => 
      _$AcademyBasicInfoModelFromJson(json);
}

/// Métricas calculadas del propietario
@freezed
class OwnerMetricsModel with _$OwnerMetricsModel {
  const factory OwnerMetricsModel({
    /// Número total de academias del propietario
    @Default(0) int totalAcademies,
    
    /// Número total de usuarios en todas sus academias
    @Default(0) int totalUsers,
    
    /// Número de usuarios activos
    @Default(0) int activeUsers,
    
    /// Ingresos mensuales estimados
    @Default(0.0) double monthlyRevenue,
    
    /// Fecha de última actividad
    DateTime? lastActivityAt,
    
    /// Tasa de actividad (porcentaje)
    @Default(0.0) double activityRate,
  }) = _OwnerMetricsModel;
}

/// Enumeraciones para estados del propietario
enum OwnerStatusModel {
  active,      // Activo
  inactive,    // Inactivo
  suspended,   // Suspendido
  pending,     // Pendiente de aprobación
}

/// Estados de la academia
enum AcademyStatusModel {
  active,      // Activa
  inactive,    // Inactiva
  suspended,   // Suspendida
}

/// Extensiones útiles para OwnerDataModel
extension OwnerDataModelExtensions on OwnerDataModel {
  /// Obtiene el nombre completo o email como fallback
  String get displayNameOrEmail => displayName?.isNotEmpty == true ? displayName! : email;
  
  /// Separa firstName y lastName del displayName
  List<String> get nameComponents {
    if (displayName == null || displayName!.isEmpty) {
      return ['', ''];
    }
    
    final parts = displayName!.trim().split(' ');
    if (parts.length == 1) {
      return [parts[0], ''];
    }
    
    final firstName = parts[0];
    final lastName = parts.skip(1).join(' ');
    return [firstName, lastName];
  }
  
  /// Obtiene el firstName
  String get firstName => nameComponents[0];
  
  /// Obtiene el lastName
  String get lastName => nameComponents[1];
  
  /// Determina el estado basado en los campos disponibles
  OwnerStatusModel get status {
    if (!isActive) return OwnerStatusModel.inactive;
    if (!profileCompleted) return OwnerStatusModel.pending;
    return OwnerStatusModel.active;
  }
  
  /// Verifica si tiene información de contacto
  bool get hasContactInfo => phoneNumber?.isNotEmpty == true;
  
  /// Calcula los días desde la creación
  int? get daysSinceCreation {
    if (createdAt == null) return null;
    return DateTime.now().difference(createdAt!).inDays;
  }
  
  /// Calcula los días desde la última actividad
  int? get daysSinceLastLogin {
    if (lastLoginAt == null) return null;
    return DateTime.now().difference(lastLoginAt!).inDays;
  }
}

/// Extensiones para AcademyBasicInfoModel
extension AcademyBasicInfoModelExtensions on AcademyBasicInfoModel {
  /// Determina el estado de la academia
  AcademyStatusModel get status {
    // Por ahora, consideramos activa si tiene miembros
    return membersCount > 0 ? AcademyStatusModel.active : AcademyStatusModel.inactive;
  }
  
  /// Obtiene información de contacto disponible
  String get contactInfo {
    if (phone.isNotEmpty && email.isNotEmpty) {
      return '$phone • $email';
    } else if (phone.isNotEmpty) {
      return phone;
    } else if (email.isNotEmpty) {
      return email;
    }
    return 'Sin información de contacto';
  }
  
  /// Verifica si tiene información completa
  bool get hasCompleteInfo {
    return name.isNotEmpty && 
           location.isNotEmpty && 
           (phone.isNotEmpty || email.isNotEmpty);
  }
} 