import 'package:arcinus/core/auth/models/academy_specific_models.dart';
import 'package:arcinus/core/auth/models/academy_user_enums.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'academy_user_context.freezed.dart';
part 'academy_user_context.g.dart';

/// Contexto específico de un usuario en una academia particular.
/// Este modelo contiene toda la información relacionada con el rol 
/// y actividades del usuario dentro de una academia específica.
@freezed
class AcademyUserContext with _$AcademyUserContext {
  @JsonSerializable(
    explicitToJson: true,
    converters: [NullableTimestampConverter()]
  )
  const factory AcademyUserContext({
    /// ID del usuario (referencia al BaseUser)
    required String userId,
    
    /// ID de la academia
    required String academyId,
    
    /// Rol específico del usuario en esta academia
    required AppRole academyRole,
    
    /// Indica si el usuario está activo en esta academia
    @Default(true) bool isActive,
    
    /// Fecha cuando se unió a la academia
    DateTime? joinedAt,
    
    /// Fecha de última actividad en la academia
    DateTime? lastActive,
    
    /// Información específica de administradores (si aplica)
    /// Solo presente si academyRole es propietario o colaborador
    AcademyAdminData? adminData,
    
    /// Información específica de miembros (si aplica)
    /// Solo presente si academyRole es atleta o padre
    AcademyMemberData? memberData,
    
    /// Metadatos específicos del contexto
    @Default({}) Map<String, dynamic> contextMetadata,
    
    /// Fecha de creación del contexto
    DateTime? createdAt,
    
    /// Fecha de última actualización
    DateTime? updatedAt,
  }) = _AcademyUserContext;

  factory AcademyUserContext.fromJson(Map<String, dynamic> json) =>
      _$AcademyUserContextFromJson(json);
}

/// Factory methods para crear contextos específicos
extension AcademyUserContextFactory on AcademyUserContext {
  /// Crea un contexto para un propietario de academia
  static AcademyUserContext createOwnerContext({
    required String userId,
    required String academyId,
    DateTime? joinedAt,
    List<ManagerPermission>? customPermissions,
  }) {
    final defaultPermissions = [
      ManagerPermission.fullAccess,
      ManagerPermission.manageUsers,
      ManagerPermission.managePayments,
      ManagerPermission.managePermissions,
      ManagerPermission.editAcademyInfo,
      ManagerPermission.manageSchedule,
      ManagerPermission.manageTeams,
      ManagerPermission.viewStatistics,
      ManagerPermission.generateReports,
      ManagerPermission.exportData,
    ];

    return AcademyUserContext(
      userId: userId,
      academyId: academyId,
      academyRole: AppRole.propietario,
      joinedAt: joinedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
      adminData: AcademyAdminData(
        type: AdminType.owner,
        permissions: customPermissions ?? defaultPermissions,
        managedAcademyIds: [academyId],
        promotedAt: DateTime.now(),
      ),
    );
  }

  /// Crea un contexto para un colaborador/socio
  static AcademyUserContext createPartnerContext({
    required String userId,
    required String academyId,
    required List<ManagerPermission> permissions,
    required String promotedBy,
    DateTime? joinedAt,
  }) {
    return AcademyUserContext(
      userId: userId,
      academyId: academyId,
      academyRole: AppRole.colaborador,
      joinedAt: joinedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
      adminData: AcademyAdminData(
        type: AdminType.partner,
        permissions: permissions,
        managedAcademyIds: [academyId],
        promotedBy: promotedBy,
        promotedAt: DateTime.now(),
      ),
    );
  }

  /// Crea un contexto para un atleta
  static AcademyUserContext createAthleteContext({
    required String userId,
    required String academyId,
    AthleteInfo? athleteInfo,
    List<String>? parentIds,
    DateTime? joinedAt,
  }) {
    return AcademyUserContext(
      userId: userId,
      academyId: academyId,
      academyRole: AppRole.atleta,
      joinedAt: joinedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
      memberData: AcademyMemberData(
        type: MemberType.athlete,
        relatedMemberIds: parentIds ?? [],
        athleteInfo: athleteInfo,
      ),
    );
  }

  /// Crea un contexto para un padre/responsable
  static AcademyUserContext createParentContext({
    required String userId,
    required String academyId,
    required List<String> athleteIds,
    ParentInfo? parentInfo,
    DateTime? joinedAt,
  }) {
    return AcademyUserContext(
      userId: userId,
      academyId: academyId,
      academyRole: AppRole.padre,
      joinedAt: joinedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
      memberData: AcademyMemberData(
        type: MemberType.parent,
        relatedMemberIds: athleteIds,
        parentInfo: parentInfo,
      ),
    );
  }
}

/// Extensiones útiles para AcademyUserContext
extension AcademyUserContextExtensions on AcademyUserContext {
  /// Verifica si el usuario es administrador en esta academia
  bool get isAdmin => academyRole == AppRole.propietario || 
                     academyRole == AppRole.colaborador;
  
  /// Verifica si el usuario es miembro en esta academia
  bool get isMember => academyRole == AppRole.atleta || 
                      academyRole == AppRole.padre;
  
  /// Verifica si es propietario de la academia
  bool get isOwner => academyRole == AppRole.propietario;
  
  /// Verifica si es colaborador/socio
  bool get isPartner => academyRole == AppRole.colaborador;
  
  /// Verifica si es atleta
  bool get isAthlete => academyRole == AppRole.atleta;
  
  /// Verifica si es padre/responsable
  bool get isParent => academyRole == AppRole.padre;
  
  /// Obtiene los permisos específicos (solo para administradores)
  List<ManagerPermission> get permissions => 
      adminData?.permissions ?? [];
  
  /// Verifica si tiene un permiso específico
  bool hasPermission(ManagerPermission permission) => 
      permissions.contains(permission) || 
      permissions.contains(ManagerPermission.fullAccess);
  
  /// Verifica si puede gestionar usuarios
  bool get canManageUsers => hasPermission(ManagerPermission.manageUsers);
  
  /// Verifica si puede gestionar pagos
  bool get canManagePayments => hasPermission(ManagerPermission.managePayments);
  
  /// Verifica si puede editar información de la academia
  bool get canEditAcademyInfo => hasPermission(ManagerPermission.editAcademyInfo);
  
  /// Verifica si puede gestionar equipos
  bool get canManageTeams => hasPermission(ManagerPermission.manageTeams);
  
  /// Verifica si puede ver estadísticas
  bool get canViewStatistics => hasPermission(ManagerPermission.viewStatistics);
  
  /// Obtiene el estado de pago (solo para miembros)
  PaymentStatus? get paymentStatus => memberData?.paymentStatus;
  
  /// Verifica si está al día con los pagos
  bool get isPaymentUpToDate => memberData?.isPaymentUpToDate ?? true;
  
  /// Obtiene información de atleta (si aplica)
  AthleteInfo? get athleteInfo => memberData?.athleteInfo;
  
  /// Obtiene información de padre (si aplica)
  ParentInfo? get parentInfo => memberData?.parentInfo;
  
  /// Obtiene IDs de miembros relacionados
  List<String> get relatedMemberIds => memberData?.relatedMemberIds ?? [];
  
  /// Días activo en la academia
  int get daysInAcademy {
    if (joinedAt == null) return 0;
    return DateTime.now().difference(joinedAt!).inDays;
  }
  
  /// Verifica si es un usuario nuevo (menos de 30 días)
  bool get isNewUser => daysInAcademy < 30;
  
  /// Crea una copia con timestamp actualizado
  AcademyUserContext withUpdatedTimestamp() => copyWith(
    updatedAt: DateTime.now(),
    lastActive: DateTime.now(),
  );
  
  /// Crea una copia con nuevo estado de actividad
  AcademyUserContext withActiveStatus(bool active) => copyWith(
    isActive: active,
    updatedAt: DateTime.now(),
  );
  
  /// Crea una copia con nuevos permisos (solo para administradores)
  AcademyUserContext withUpdatedPermissions(List<ManagerPermission> newPermissions) {
    if (adminData == null) return this;
    
    return copyWith(
      adminData: adminData!.copyWith(permissions: newPermissions),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Crea una copia con nuevo estado de pago (solo para miembros)
  AcademyUserContext withUpdatedPaymentStatus(
    PaymentStatus status, {
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
    DateTime? nextPaymentDue,
  }) {
    if (memberData == null) return this;
    
    return copyWith(
      memberData: memberData!.copyWith(
        paymentStatus: status,
        lastPaymentDate: lastPaymentDate ?? memberData!.lastPaymentDate,
        lastPaymentAmount: lastPaymentAmount ?? memberData!.lastPaymentAmount,
        nextPaymentDue: nextPaymentDue ?? memberData!.nextPaymentDue,
      ),
      updatedAt: DateTime.now(),
    );
  }
} 