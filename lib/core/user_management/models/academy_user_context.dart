import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/user_management/models/enums.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';
import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'academy_user_context.freezed.dart';
part 'academy_user_context.g.dart';

/// Contexto específico de un usuario en una academia.
/// Define el rol, permisos y datos específicos del usuario dentro de esa academia.
@freezed
class AcademyUserContext with _$AcademyUserContext {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory AcademyUserContext({
    /// ID único del contexto (combinación userId_academyId)
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    
    /// ID del usuario (referencia al BaseUser)
    required String userId,
    
    /// ID de la academia
    required String academyId,
    
    /// Rol específico del usuario en esta academia
    required AppRole academyRole,
    
    /// Indica si el usuario está activo en esta academia
    @Default(true) bool isActive,
    
    /// Fecha en que el usuario se unió a la academia
    @TimestampConverter() DateTime? joinedAt,
    
    /// Fecha de última actividad del usuario en la academia
    @TimestampConverter() DateTime? lastActive,
    
    /// Información específica de administradores (propietarios y colaboradores)
    AcademyAdminData? adminData,
    
    /// Información específica de miembros (atletas y padres)
    AcademyMemberData? memberData,
    
    /// Metadatos adicionales específicos de la implementación
    @Default({}) Map<String, dynamic> metadata,
  }) = _AcademyUserContext;

  factory AcademyUserContext.fromJson(Map<String, dynamic> json) =>
      _$AcademyUserContextFromJson(json);
}

/// Información específica para administradores de academia
@freezed
class AcademyAdminData with _$AcademyAdminData {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory AcademyAdminData({
    /// Tipo de administrador (propietario o socio)
    required AdminType type,
    
    /// Lista de permisos específicos del administrador
    @Default([]) List<ManagerPermission> permissions,
    
    /// Lista de IDs de academias que gestiona (útil para propietarios con múltiples academias)
    @Default([]) List<String> managedAcademyIds,
    
    /// Estado actual del administrador
    @Default(ManagerStatus.active) ManagerStatus status,
    
    /// Fecha de último inicio de sesión como administrador
    @TimestampConverter() DateTime? lastLoginDate,
    
    /// Metadatos específicos de administración
    @Default({}) Map<String, dynamic> adminMetadata,
  }) = _AcademyAdminData;

  factory AcademyAdminData.fromJson(Map<String, dynamic> json) =>
      _$AcademyAdminDataFromJson(json);
}

/// Información específica para miembros de academia (atletas y padres)
@freezed
class AcademyMemberData with _$AcademyMemberData {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory AcademyMemberData({
    /// Tipo de miembro (atleta o padre)
    required MemberType type,
    
    /// Lista de IDs de miembros relacionados (ej: padre-atleta)
    @Default([]) List<String> relatedMemberIds,
    
    /// Estado actual de pago del miembro
    @Default(PaymentStatus.inactive) PaymentStatus paymentStatus,
    
    /// Información específica de atletas
    AthleteInfo? athleteInfo,
    
    /// Información específica de padres
    ParentInfo? parentInfo,
    
    /// Metadatos específicos de membresía
    @Default({}) Map<String, dynamic> memberMetadata,
  }) = _AcademyMemberData;

  factory AcademyMemberData.fromJson(Map<String, dynamic> json) =>
      _$AcademyMemberDataFromJson(json);
}

/// Información específica de atletas
@freezed
class AthleteInfo with _$AthleteInfo {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory AthleteInfo({
    /// Fecha de nacimiento del atleta
    @TimestampConverter() DateTime? birthDate,
    
    /// Número de teléfono del atleta
    String? phoneNumber,
    
    // Información física
    /// Altura en centímetros
    double? heightCm,
    
    /// Peso en kilogramos
    double? weightKg,
    
    // Información deportiva
    /// Posición de juego
    String? position,
    
    /// Especialización deportiva
    String? specialization,
    
    /// Años de experiencia
    int? experienceYears,
    
    // Información médica
    /// Alergias conocidas
    String? allergies,
    
    /// Condiciones médicas
    String? medicalConditions,
    
    /// Nombre del contacto de emergencia
    String? emergencyContactName,
    
    /// Teléfono del contacto de emergencia
    String? emergencyContactPhone,
    
    /// Métricas deportivas (rendimiento, estadísticas, etc.)
    @Default({}) Map<String, dynamic> metrics,
    
    /// IDs de equipos a los que pertenece el atleta
    @Default([]) List<String> teamIds,
    
    /// URL de la imagen de perfil del atleta
    String? profileImageUrl,
  }) = _AthleteInfo;

  factory AthleteInfo.fromJson(Map<String, dynamic> json) =>
      _$AthleteInfoFromJson(json);
}

/// Información específica de padres/responsables
@freezed
class ParentInfo with _$ParentInfo {
  @JsonSerializable(explicitToJson: true)
  const factory ParentInfo({
    /// Número de teléfono del padre
    String? phoneNumber,
    
    /// Dirección del padre
    String? address,
    
    /// Ocupación del padre
    String? occupation,
    
    // Información de contacto de emergencia
    /// Nombre del contacto de emergencia alternativo
    String? emergencyContactName,
    
    /// Teléfono del contacto de emergencia alternativo
    String? emergencyContactPhone,
    
    /// Relación del contacto de emergencia con el padre
    String? emergencyContactRelation,
    
    /// Lista de IDs de atletas que están a cargo de este padre
    @Default([]) List<String> athleteIds,
    
    /// Información adicional del padre
    @Default({}) Map<String, dynamic> additionalInfo,
  }) = _ParentInfo;

  factory ParentInfo.fromJson(Map<String, dynamic> json) =>
      _$ParentInfoFromJson(json);
}

/// Extensiones de utilidad para AcademyUserContext
extension AcademyUserContextExtension on AcademyUserContext {
  /// Verifica si el usuario es administrador en esta academia
  bool get isAdmin => academyRole == AppRole.propietario || academyRole == AppRole.colaborador;
  
  /// Verifica si el usuario es propietario de esta academia
  bool get isOwner => academyRole == AppRole.propietario;
  
  /// Verifica si el usuario es colaborador en esta academia
  bool get isCollaborator => academyRole == AppRole.colaborador;
  
  /// Verifica si el usuario es miembro (atleta o padre) en esta academia
  bool get isMember => academyRole == AppRole.atleta || academyRole == AppRole.padre;
  
  /// Verifica si el usuario es atleta en esta academia
  bool get isAthlete => academyRole == AppRole.atleta;
  
  /// Verifica si el usuario es padre en esta academia
  bool get isParent => academyRole == AppRole.padre;
  
  /// Verifica si el administrador tiene un permiso específico
  bool hasPermission(ManagerPermission permission) {
    if (!isAdmin || adminData == null) return false;
    return adminData!.permissions.hasPermission(permission);
  }
  
  /// Verifica si el administrador tiene acceso completo
  bool get hasFullAccess {
    if (!isAdmin || adminData == null) return false;
    return adminData!.permissions.hasFullAccess || isOwner;
  }
  
  /// Verifica si el administrador está activo
  bool get isAdminActive {
    if (!isAdmin || adminData == null) return false;
    return adminData!.status.canAccess;
  }
  
  /// Verifica si el miembro está al día con los pagos
  bool get isPaymentActive {
    if (!isMember || memberData == null) return false;
    return memberData!.paymentStatus == PaymentStatus.active;
  }
  
  /// Obtiene la edad del atleta si está disponible
  int? get athleteAge {
    if (!isAthlete || memberData?.athleteInfo?.birthDate == null) return null;
    final birthDate = memberData!.athleteInfo!.birthDate!;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  /// Obtiene el nombre completo desde AthleteInfo si está disponible
  String? get athleteFullName {
    if (!isAthlete || memberData?.athleteInfo == null) return null;
    // Aquí podrías obtener el nombre desde BaseUser o AthleteInfo dependiendo de tu implementación
    return null; // Se implementaría según la estructura específica
  }
} 