import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/auth/domain/repositories/base_user_repository.dart';
import 'package:arcinus/core/auth/domain/repositories/academy_user_context_repository.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Caso de uso para gestión de administradores de academia.
/// Centraliza toda la lógica de negocio relacionada con la administración
/// de propietarios y colaboradores en academias específicas.
class ManageAcademyAdminsUseCase {
  final BaseUserRepository _baseUserRepository;
  final AcademyUserContextRepository _contextRepository;

  const ManageAcademyAdminsUseCase(
    this._baseUserRepository,
    this._contextRepository,
  );

  // === Promoción de usuarios a administrador ===

  /// Promueve un usuario existente a propietario de una academia
  Future<Either<Failure, void>> promoteToOwner({
    required String userId,
    required String academyId,
    List<ManagerPermission>? customPermissions,
    String? promotedBy,
  }) async {
    // 1. Verificar que el usuario existe
    final userResult = await _baseUserRepository.getUserById(userId);
    if (userResult.isLeft()) return userResult.map((_) => {});
    
    final user = userResult.getRight().toNullable();
    if (user == null) {
      return left(const Failure.notFound(message: 'Usuario no encontrado'));
    }

    // 2. Verificar que no existe ya en la academia
    final existsResult = await _contextRepository.userExistsInAcademy(userId, academyId);
    if (existsResult.isLeft()) return existsResult.map((_) => {});
    
    if (existsResult.getRight().toNullable() == true) {
      return left(const Failure.validationError(
        message: 'El usuario ya existe en esta academia'
      ));
    }

    // 3. Actualizar rol global si es necesario
    if (user.globalRole == AppRole.desconocido) {
      final roleResult = await _baseUserRepository.updateGlobalRole(userId, AppRole.propietario);
      if (roleResult.isLeft()) return roleResult;
    }

    // 4. Crear contexto de propietario
    final context = AcademyUserContextFactory.createOwnerContext(
      userId: userId,
      academyId: academyId,
      customPermissions: customPermissions,
    );

    // 5. Guardar contexto
    final createResult = await _contextRepository.createUserContext(context);
    if (createResult.isLeft()) return createResult;

    // 6. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: userId,
      academyId: academyId,
      action: 'PROMOTED_TO_OWNER',
      details: 'Usuario promovido a propietario de la academia',
      metadata: {
        'promotedBy': promotedBy,
        'permissions': customPermissions?.map((p) => p.name).toList(),
      },
    );

    return right(null);
  }

  /// Promueve un usuario a colaborador/socio de una academia
  Future<Either<Failure, void>> promoteToPartner({
    required String userId,
    required String academyId,
    required List<ManagerPermission> permissions,
    required String promotedBy,
  }) async {
    // 1. Validar permisos
    if (permissions.isEmpty) {
      return left(const Failure.validationError(
        message: 'Debe especificar al menos un permiso para el colaborador'
      ));
    }

    // Verificar que no incluya permisos exclusivos de propietario
    final ownerOnlyPermissions = [
      ManagerPermission.fullAccess,
      ManagerPermission.managePermissions,
    ];
    
    final hasOwnerPermissions = permissions.any((p) => ownerOnlyPermissions.contains(p));
    if (hasOwnerPermissions) {
      return left(const Failure.validationError(
        message: 'Los colaboradores no pueden tener permisos exclusivos de propietario'
      ));
    }

    // 2. Verificar que el usuario existe
    final userResult = await _baseUserRepository.getUserById(userId);
    if (userResult.isLeft()) return userResult.map((_) => {});
    
    final user = userResult.getRight().toNullable();
    if (user == null) {
      return left(const Failure.notFound(message: 'Usuario no encontrado'));
    }

    // 3. Verificar que quien promueve tiene permisos
    final canPromoteResult = await _contextRepository.userHasPermission(
      promotedBy,
      academyId,
      ManagerPermission.managePermissions,
    );
    
    if (canPromoteResult.isLeft()) return canPromoteResult.map((_) => {});
    if (canPromoteResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para promover usuarios'
      ));
    }

    // 4. Verificar que no existe ya en la academia
    final existsResult = await _contextRepository.userExistsInAcademy(userId, academyId);
    if (existsResult.isLeft()) return existsResult.map((_) => {});
    
    if (existsResult.getRight().toNullable() == true) {
      return left(const Failure.validationError(
        message: 'El usuario ya existe en esta academia'
      ));
    }

    // 5. Actualizar rol global si es necesario
    if (user.globalRole == AppRole.desconocido) {
      final roleResult = await _baseUserRepository.updateGlobalRole(userId, AppRole.colaborador);
      if (roleResult.isLeft()) return roleResult;
    }

    // 6. Crear contexto de colaborador
    final context = AcademyUserContextFactory.createPartnerContext(
      userId: userId,
      academyId: academyId,
      permissions: permissions,
      promotedBy: promotedBy,
    );

    // 7. Guardar contexto
    final createResult = await _contextRepository.createUserContext(context);
    if (createResult.isLeft()) return createResult;

    // 8. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: userId,
      academyId: academyId,
      action: 'PROMOTED_TO_PARTNER',
      details: 'Usuario promovido a colaborador de la academia',
      metadata: {
        'promotedBy': promotedBy,
        'permissions': permissions.map((p) => p.name).toList(),
      },
    );

    return right(null);
  }

  // === Gestión de permisos ===

  /// Actualiza los permisos de un colaborador
  Future<Either<Failure, void>> updatePartnerPermissions({
    required String partnerId,
    required String academyId,
    required List<ManagerPermission> newPermissions,
    required String updatedBy,
  }) async {
    // 1. Verificar que quien actualiza tiene permisos
    final canUpdateResult = await _contextRepository.userHasPermission(
      updatedBy,
      academyId,
      ManagerPermission.managePermissions,
    );
    
    if (canUpdateResult.isLeft()) return canUpdateResult.map((_) => {});
    if (canUpdateResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para modificar permisos de otros usuarios'
      ));
    }

    // 2. Obtener contexto actual del colaborador
    final contextResult = await _contextRepository.getUserContext(partnerId, academyId);
    if (contextResult.isLeft()) return contextResult.map((_) => {});
    
    final context = contextResult.getRight().toNullable();
    if (context == null) {
      return left(const Failure.notFound(message: 'Usuario no encontrado en la academia'));
    }

    // 3. Verificar que es un colaborador
    if (!context.isPartner) {
      return left(const Failure.validationError(
        message: 'Solo se pueden modificar permisos de colaboradores'
      ));
    }

    // 4. Validar nuevos permisos
    final ownerOnlyPermissions = [
      ManagerPermission.fullAccess,
      ManagerPermission.managePermissions,
    ];
    
    final hasOwnerPermissions = newPermissions.any((p) => ownerOnlyPermissions.contains(p));
    if (hasOwnerPermissions) {
      return left(const Failure.validationError(
        message: 'Los colaboradores no pueden tener permisos exclusivos de propietario'
      ));
    }

    // 5. Actualizar permisos
    final updateResult = await _contextRepository.updateAdminPermissions(
      partnerId,
      academyId,
      newPermissions,
    );
    if (updateResult.isLeft()) return updateResult;

    // 6. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: partnerId,
      academyId: academyId,
      action: 'PERMISSIONS_UPDATED',
      details: 'Permisos de colaborador actualizados',
      metadata: {
        'updatedBy': updatedBy,
        'oldPermissions': context.permissions.map((p) => p.name).toList(),
        'newPermissions': newPermissions.map((p) => p.name).toList(),
      },
    );

    return right(null);
  }

  // === Gestión de estado de administradores ===

  /// Suspende un administrador (solo para propietarios)
  Future<Either<Failure, void>> suspendAdmin({
    required String adminId,
    required String academyId,
    required String suspendedBy,
    String? reason,
  }) async {
    // 1. Verificar permisos del que suspende
    final canSuspendResult = await _contextRepository.userHasPermission(
      suspendedBy,
      academyId,
      ManagerPermission.managePermissions,
    );
    
    if (canSuspendResult.isLeft()) return canSuspendResult.map((_) => {});
    if (canSuspendResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para suspender administradores'
      ));
    }

    // 2. Verificar que no se trate de suspender al propietario
    final contextResult = await _contextRepository.getUserContext(adminId, academyId);
    if (contextResult.isLeft()) return contextResult.map((_) => {});
    
    final context = contextResult.getRight().toNullable();
    if (context == null) {
      return left(const Failure.notFound(message: 'Administrador no encontrado'));
    }

    if (context.isOwner) {
      return left(const Failure.validationError(
        message: 'No se puede suspender al propietario de la academia'
      ));
    }

    // 3. Actualizar estado
    final updateResult = await _contextRepository.updateAdminStatus(
      adminId,
      academyId,
      ManagerStatus.suspended,
    );
    if (updateResult.isLeft()) return updateResult;

    // 4. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: adminId,
      academyId: academyId,
      action: 'ADMIN_SUSPENDED',
      details: reason ?? 'Administrador suspendido',
      metadata: {
        'suspendedBy': suspendedBy,
        'reason': reason,
      },
    );

    return right(null);
  }

  /// Reactiva un administrador suspendido
  Future<Either<Failure, void>> reactivateAdmin({
    required String adminId,
    required String academyId,
    required String reactivatedBy,
  }) async {
    // 1. Verificar permisos
    final canReactivateResult = await _contextRepository.userHasPermission(
      reactivatedBy,
      academyId,
      ManagerPermission.managePermissions,
    );
    
    if (canReactivateResult.isLeft()) return canReactivateResult.map((_) => {});
    if (canReactivateResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para reactivar administradores'
      ));
    }

    // 2. Actualizar estado
    final updateResult = await _contextRepository.updateAdminStatus(
      adminId,
      academyId,
      ManagerStatus.active,
    );
    if (updateResult.isLeft()) return updateResult;

    // 3. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: adminId,
      academyId: academyId,
      action: 'ADMIN_REACTIVATED',
      details: 'Administrador reactivado',
      metadata: {
        'reactivatedBy': reactivatedBy,
      },
    );

    return right(null);
  }

  // === Remover administradores ===

  /// Remueve un colaborador de la academia
  Future<Either<Failure, void>> removePartner({
    required String partnerId,
    required String academyId,
    required String removedBy,
    String? reason,
  }) async {
    // 1. Verificar permisos
    final canRemoveResult = await _contextRepository.userHasPermission(
      removedBy,
      academyId,
      ManagerPermission.managePermissions,
    );
    
    if (canRemoveResult.isLeft()) return canRemoveResult.map((_) => {});
    if (canRemoveResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para remover administradores'
      ));
    }

    // 2. Verificar que es un colaborador
    final contextResult = await _contextRepository.getUserContext(partnerId, academyId);
    if (contextResult.isLeft()) return contextResult.map((_) => {});
    
    final context = contextResult.getRight().toNullable();
    if (context == null) {
      return left(const Failure.notFound(message: 'Usuario no encontrado en la academia'));
    }

    if (!context.isPartner) {
      return left(const Failure.validationError(
        message: 'Solo se pueden remover colaboradores, no propietarios'
      ));
    }

    // 3. Registrar auditoría antes de remover
    await _contextRepository.logContextAudit(
      userId: partnerId,
      academyId: academyId,
      action: 'PARTNER_REMOVED',
      details: reason ?? 'Colaborador removido de la academia',
      metadata: {
        'removedBy': removedBy,
        'reason': reason,
        'permissions': context.permissions.map((p) => p.name).toList(),
      },
    );

    // 4. Remover de la academia
    final removeResult = await _contextRepository.removeUserFromAcademy(partnerId, academyId);
    if (removeResult.isLeft()) return removeResult;

    return right(null);
  }

  // === Consultas ===

  /// Obtiene todos los administradores de una academia
  Future<Either<Failure, List<AcademyUserContext>>> getAcademyAdmins({
    required String academyId,
    AdminType? typeFilter,
    ManagerStatus? statusFilter,
  }) async {
    return await _contextRepository.getAcademyAdmins(
      academyId,
      typeFilter: typeFilter,
      statusFilter: statusFilter,
    );
  }

  /// Verifica si un usuario puede realizar una acción específica
  Future<Either<Failure, bool>> canUserPerformAction({
    required String userId,
    required String academyId,
    required ManagerPermission permission,
  }) async {
    return await _contextRepository.userHasPermission(userId, academyId, permission);
  }
} 