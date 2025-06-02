import 'package:arcinus/core/auth/models/academy_user_enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'academy_specific_models.freezed.dart';
part 'academy_specific_models.g.dart';

/// Información específica de administradores de academia
@freezed
class AcademyAdminData with _$AcademyAdminData {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory AcademyAdminData({
    /// Tipo de administrador (propietario o socio)
    required AdminType type,
    
    /// Lista de permisos específicos del administrador
    @Default([]) List<ManagerPermission> permissions,
    
    /// Lista de IDs de academias que puede gestionar
    @Default([]) List<String> managedAcademyIds,
    
    /// Estado actual del manager
    @Default(ManagerStatus.active) ManagerStatus status,
    
    /// Fecha de último acceso
    DateTime? lastLoginDate,
    
    /// Fecha cuando fue promovido a administrador
    DateTime? promotedAt,
    
    /// ID del usuario que lo promovió
    String? promotedBy,
    
    /// Metadatos específicos de administración
    @Default({}) Map<String, dynamic> adminMetadata,
  }) = _AcademyAdminData;

  factory AcademyAdminData.fromJson(Map<String, dynamic> json) =>
      _$AcademyAdminDataFromJson(json);
}

/// Información específica de miembros de academia
@freezed
class AcademyMemberData with _$AcademyMemberData {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory AcademyMemberData({
    /// Tipo de miembro (atleta o padre)
    required MemberType type,
    
    /// IDs de miembros relacionados (padre-atleta)
    @Default([]) List<String> relatedMemberIds,
    
    /// Estado de pago del miembro
    @Default(PaymentStatus.upToDate) PaymentStatus paymentStatus,
    
    /// Fecha de último pago
    DateTime? lastPaymentDate,
    
    /// Monto del último pago
    double? lastPaymentAmount,
    
    /// Fecha de vencimiento del próximo pago
    DateTime? nextPaymentDue,
    
    /// Datos específicos de atletas (si aplica)
    AthleteInfo? athleteInfo,
    
    /// Datos específicos de padres (si aplica)
    ParentInfo? parentInfo,
    
    /// Metadatos específicos del miembro
    @Default({}) Map<String, dynamic> memberMetadata,
  }) = _AcademyMemberData;

  factory AcademyMemberData.fromJson(Map<String, dynamic> json) =>
      _$AcademyMemberDataFromJson(json);
}

/// Información específica de atletas
@freezed
class AthleteInfo with _$AthleteInfo {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory AthleteInfo({
    /// Fecha de nacimiento del atleta
    DateTime? birthDate,
    
    /// Número de teléfono del atleta
    String? phoneNumber,
    
    // === Información física ===
    /// Altura en centímetros
    double? heightCm,
    
    /// Peso en kilogramos
    double? weightKg,
    
    /// Tipo de sangre
    String? bloodType,
    
    // === Información deportiva ===
    /// Posición o especialización deportiva
    String? position,
    
    /// Deporte principal
    String? primarySport,
    
    /// Deportes secundarios
    @Default([]) List<String> secondarySports,
    
    /// Años de experiencia
    int? experienceYears,
    
    /// Nivel de habilidad (principiante, intermedio, avanzado)
    String? skillLevel,
    
    // === Información médica ===
    /// Alergias conocidas
    String? allergies,
    
    /// Condiciones médicas
    String? medicalConditions,
    
    /// Medicamentos actuales
    String? currentMedications,
    
    /// Lesiones previas
    String? previousInjuries,
    
    /// Contacto de emergencia principal
    EmergencyContact? primaryEmergencyContact,
    
    /// Contacto de emergencia secundario
    EmergencyContact? secondaryEmergencyContact,
    
    // === Información académica ===
    /// Colegio o institución educativa
    String? school,
    
    /// Grado o nivel académico
    String? grade,
    
    // === Métricas deportivas ===
    /// Métricas específicas del deporte
    @Default({}) Map<String, dynamic> sportsMetrics,
    
    /// Historial de rendimiento
    @Default([]) List<Map<String, dynamic>> performanceHistory,
    
    // === Equipos y grupos ===
    /// IDs de equipos a los que pertenece
    @Default([]) List<String> teamIds,
    
    /// IDs de grupos de entrenamiento
    @Default([]) List<String> trainingGroupIds,
    
    // === Configuraciones adicionales ===
    /// Objetivos deportivos
    @Default([]) List<String> goals,
    
    /// Notas adicionales
    String? notes,
    
    /// Metadatos específicos del atleta
    @Default({}) Map<String, dynamic> athleteMetadata,
  }) = _AthleteInfo;

  factory AthleteInfo.fromJson(Map<String, dynamic> json) =>
      _$AthleteInfoFromJson(json);
}

/// Información específica de padres o responsables
@freezed
class ParentInfo with _$ParentInfo {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory ParentInfo({
    /// Número de teléfono principal
    String? phoneNumber,
    
    /// Número de teléfono secundario
    String? secondaryPhoneNumber,
    
    /// Dirección de residencia
    String? address,
    
    /// Ciudad
    String? city,
    
    /// Código postal
    String? zipCode,
    
    /// Ocupación profesional
    String? occupation,
    
    /// Empresa donde trabaja
    String? workplace,
    
    /// Número de teléfono del trabajo
    String? workPhoneNumber,
    
    // === Información de contacto de emergencia ===
    /// Contacto de emergencia (diferente al padre)
    EmergencyContact? emergencyContact,
    
    // === Relación con atletas ===
    /// IDs de atletas bajo su responsabilidad
    @Default([]) List<String> athleteIds,
    
    /// Tipo de relación con cada atleta
    @Default({}) Map<String, String> relationshipTypes, // athleteId -> relationship
    
    // === Información adicional ===
    /// Autorizado para recoger atletas
    @Default(true) bool authorizedPickup,
    
    /// Autorizado para decisiones médicas
    @Default(true) bool authorizedMedicalDecisions,
    
    /// Notas importantes
    String? notes,
    
    /// Metadatos específicos del padre
    @Default({}) Map<String, dynamic> parentMetadata,
  }) = _ParentInfo;

  factory ParentInfo.fromJson(Map<String, dynamic> json) =>
      _$ParentInfoFromJson(json);
}

/// Información de contacto de emergencia
@freezed
class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    /// Nombre completo del contacto
    required String name,
    
    /// Número de teléfono principal
    required String phoneNumber,
    
    /// Número de teléfono secundario
    String? secondaryPhoneNumber,
    
    /// Relación con el atleta/usuario
    required String relationship,
    
    /// Email del contacto
    String? email,
    
    /// Dirección del contacto
    String? address,
    
    /// Notas adicionales
    String? notes,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}

/// Extensiones para AcademyAdminData
extension AcademyAdminDataExtensions on AcademyAdminData {
  /// Verifica si es propietario
  bool get isOwner => type.isOwner;
  
  /// Verifica si es socio
  bool get isPartner => type.isPartner;
  
  /// Verifica si puede operar
  bool get canOperate => status.canOperate;
  
  /// Verifica si tiene acceso completo
  bool get hasFullAccess => permissions.contains(ManagerPermission.fullAccess);
  
  /// Verifica si puede gestionar usuarios
  bool get canManageUsers => permissions.contains(ManagerPermission.manageUsers);
  
  /// Verifica si puede gestionar pagos
  bool get canManagePayments => permissions.contains(ManagerPermission.managePayments);
}

/// Extensiones para AcademyMemberData
extension AcademyMemberDataExtensions on AcademyMemberData {
  /// Verifica si es atleta
  bool get isAthlete => type.isAthlete;
  
  /// Verifica si es padre
  bool get isParent => type.isParent;
  
  /// Verifica si está al día con los pagos
  bool get isPaymentUpToDate => paymentStatus.isUpToDate;
  
  /// Verifica si tiene problemas de pago
  bool get hasPaymentIssues => paymentStatus.hasPaymentIssues;
  
  /// Días hasta el próximo vencimiento
  int? get daysUntilNextPayment {
    if (nextPaymentDue == null) return null;
    return nextPaymentDue!.difference(DateTime.now()).inDays;
  }
}

/// Extensiones para AthleteInfo
extension AthleteInfoExtensions on AthleteInfo {
  /// Calcula la edad del atleta
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
  
  /// Verifica si es menor de edad
  bool get isMinor => age != null && age! < 18;
  
  /// Verifica si tiene información médica completa
  bool get hasMedicalInfo => 
      allergies != null || 
      medicalConditions != null || 
      primaryEmergencyContact != null;
  
  /// Obtiene el contacto de emergencia principal
  EmergencyContact? get primaryContact => primaryEmergencyContact;
}

/// Extensiones para ParentInfo
extension ParentInfoExtensions on ParentInfo {
  /// Verifica si puede autorizar decisiones médicas
  bool get canAuthorizeMedical => authorizedMedicalDecisions;
  
  /// Verifica si puede recoger atletas
  bool get canPickupAthletes => authorizedPickup;
  
  /// Número de atletas bajo su responsabilidad
  int get numberOfAthletes => athleteIds.length;
  
  /// Verifica si tiene información de contacto completa
  bool get hasCompleteContactInfo => 
      phoneNumber != null && address != null;
} 