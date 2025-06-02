import 'package:arcinus/core/auth/models/models.dart';
import 'package:arcinus/core/auth/domain/repositories/base_user_repository.dart';
import 'package:arcinus/core/auth/domain/repositories/academy_user_context_repository.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Caso de uso para gestión de miembros de academia.
/// Centraliza toda la lógica de negocio relacionada con atletas y padres.
class ManageAcademyMembersUseCase {
  final BaseUserRepository _baseUserRepository;
  final AcademyUserContextRepository _contextRepository;

  const ManageAcademyMembersUseCase(
    this._baseUserRepository,
    this._contextRepository,
  );

  // === Gestión de atletas ===

  /// Añade un nuevo atleta a la academia
  Future<Either<Failure, void>> addAthlete({
    required String userId,
    required String academyId,
    required String addedBy,
    AthleteInfo? athleteInfo,
    List<String>? parentIds,
  }) async {
    // 1. Verificar permisos
    final canAddResult = await _contextRepository.userHasPermission(
      addedBy,
      academyId,
      ManagerPermission.manageUsers,
    );
    
    if (canAddResult.isLeft()) return canAddResult.map((_) => {});
    if (canAddResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para añadir usuarios'
      ));
    }

    // 2. Verificar que el usuario existe
    final userResult = await _baseUserRepository.getUserById(userId);
    if (userResult.isLeft()) return userResult.map((_) => {});
    
    final user = userResult.getRight().toNullable();
    if (user == null) {
      return left(const Failure.notFound(message: 'Usuario no encontrado'));
    }

    // 3. Verificar que no existe ya en la academia
    final existsResult = await _contextRepository.userExistsInAcademy(userId, academyId);
    if (existsResult.isLeft()) return existsResult.map((_) => {});
    
    if (existsResult.getRight().toNullable() == true) {
      return left(const Failure.validationError(
        message: 'El usuario ya existe en esta academia'
      ));
    }

    // 4. Actualizar rol global si es necesario
    if (user.globalRole == AppRole.desconocido) {
      final roleResult = await _baseUserRepository.updateGlobalRole(userId, AppRole.atleta);
      if (roleResult.isLeft()) return roleResult;
    }

    // 5. Crear contexto de atleta
    final context = AcademyUserContextFactory.createAthleteContext(
      userId: userId,
      academyId: academyId,
      athleteInfo: athleteInfo,
      parentIds: parentIds,
    );

    // 6. Guardar contexto
    final createResult = await _contextRepository.createUserContext(context);
    if (createResult.isLeft()) return createResult;

    // 7. Vincular con padres si se especificaron
    if (parentIds != null && parentIds.isNotEmpty) {
      for (final parentId in parentIds) {
        await _linkParentToAthleteInternal(parentId, userId, academyId);
      }
    }

    // 8. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: userId,
      academyId: academyId,
      action: 'ATHLETE_ADDED',
      details: 'Atleta añadido a la academia',
      metadata: {
        'addedBy': addedBy,
        'parentIds': parentIds,
        'hasAthleteInfo': athleteInfo != null,
      },
    );

    return right(null);
  }

  /// Actualiza información de un atleta
  Future<Either<Failure, void>> updateAthleteInfo({
    required String athleteId,
    required String academyId,
    required String updatedBy,
    required AthleteInfo newInfo,
  }) async {
    // 1. Verificar permisos
    final canUpdateResult = await _contextRepository.userHasPermission(
      updatedBy,
      academyId,
      ManagerPermission.manageUsers,
    );
    
    if (canUpdateResult.isLeft()) return canUpdateResult.map((_) => {});
    if (canUpdateResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para actualizar información de atletas'
      ));
    }

    // 2. Obtener contexto actual
    final contextResult = await _contextRepository.getUserContext(athleteId, academyId);
    if (contextResult.isLeft()) return contextResult.map((_) => {});
    
    final context = contextResult.getRight().toNullable();
    if (context == null) {
      return left(const Failure.notFound(message: 'Atleta no encontrado en la academia'));
    }

    // 3. Verificar que es un atleta
    if (!context.isAthlete) {
      return left(const Failure.validationError(
        message: 'El usuario no es un atleta'
      ));
    }

    // 4. Crear contexto actualizado
    final updatedContext = context.copyWith(
      memberData: context.memberData?.copyWith(
        athleteInfo: newInfo,
      ),
      updatedAt: DateTime.now(),
    );

    // 5. Guardar cambios
    final updateResult = await _contextRepository.updateUserContext(updatedContext);
    if (updateResult.isLeft()) return updateResult;

    // 6. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: athleteId,
      academyId: academyId,
      action: 'ATHLETE_INFO_UPDATED',
      details: 'Información de atleta actualizada',
      metadata: {
        'updatedBy': updatedBy,
        'fields': _getUpdatedFields(context.athleteInfo, newInfo),
      },
    );

    return right(null);
  }

  // === Gestión de padres ===

  /// Añade un padre/responsable a la academia
  Future<Either<Failure, void>> addParent({
    required String userId,
    required String academyId,
    required String addedBy,
    required List<String> athleteIds,
    ParentInfo? parentInfo,
  }) async {
    // 1. Verificar permisos
    final canAddResult = await _contextRepository.userHasPermission(
      addedBy,
      academyId,
      ManagerPermission.manageUsers,
    );
    
    if (canAddResult.isLeft()) return canAddResult.map((_) => {});
    if (canAddResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para añadir usuarios'
      ));
    }

    // 2. Validar que se especificaron atletas
    if (athleteIds.isEmpty) {
      return left(const Failure.validationError(
        message: 'Debe especificar al menos un atleta para el padre'
      ));
    }

    // 3. Verificar que el usuario existe
    final userResult = await _baseUserRepository.getUserById(userId);
    if (userResult.isLeft()) return userResult.map((_) => {});
    
    final user = userResult.getRight().toNullable();
    if (user == null) {
      return left(const Failure.notFound(message: 'Usuario no encontrado'));
    }

    // 4. Verificar que todos los atletas existen en la academia
    for (final athleteId in athleteIds) {
      final athleteExists = await _contextRepository.userExistsInAcademy(athleteId, academyId);
      if (athleteExists.isLeft()) return athleteExists.map((_) => {});
      
      if (athleteExists.getRight().toNullable() != true) {
        return left(const Failure.validationError(
          message: 'Uno o más atletas especificados no existen en la academia'
        ));
      }
    }

    // 5. Verificar que no existe ya en la academia
    final existsResult = await _contextRepository.userExistsInAcademy(userId, academyId);
    if (existsResult.isLeft()) return existsResult.map((_) => {});
    
    if (existsResult.getRight().toNullable() == true) {
      return left(const Failure.validationError(
        message: 'El usuario ya existe en esta academia'
      ));
    }

    // 6. Actualizar rol global si es necesario
    if (user.globalRole == AppRole.desconocido) {
      final roleResult = await _baseUserRepository.updateGlobalRole(userId, AppRole.padre);
      if (roleResult.isLeft()) return roleResult;
    }

    // 7. Crear contexto de padre
    final context = AcademyUserContextFactory.createParentContext(
      userId: userId,
      academyId: academyId,
      athleteIds: athleteIds,
      parentInfo: parentInfo,
    );

    // 8. Guardar contexto
    final createResult = await _contextRepository.createUserContext(context);
    if (createResult.isLeft()) return createResult;

    // 9. Actualizar relaciones padre-atleta
    for (final athleteId in athleteIds) {
      await _linkParentToAthleteInternal(userId, athleteId, academyId);
    }

    // 10. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: userId,
      academyId: academyId,
      action: 'PARENT_ADDED',
      details: 'Padre añadido a la academia',
      metadata: {
        'addedBy': addedBy,
        'athleteIds': athleteIds,
        'hasParentInfo': parentInfo != null,
      },
    );

    return right(null);
  }

  /// Actualiza información de un padre
  Future<Either<Failure, void>> updateParentInfo({
    required String parentId,
    required String academyId,
    required String updatedBy,
    required ParentInfo newInfo,
  }) async {
    // 1. Verificar permisos
    final canUpdateResult = await _contextRepository.userHasPermission(
      updatedBy,
      academyId,
      ManagerPermission.manageUsers,
    );
    
    if (canUpdateResult.isLeft()) return canUpdateResult.map((_) => {});
    if (canUpdateResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para actualizar información de padres'
      ));
    }

    // 2. Obtener contexto actual
    final contextResult = await _contextRepository.getUserContext(parentId, academyId);
    if (contextResult.isLeft()) return contextResult.map((_) => {});
    
    final context = contextResult.getRight().toNullable();
    if (context == null) {
      return left(const Failure.notFound(message: 'Padre no encontrado en la academia'));
    }

    // 3. Verificar que es un padre
    if (!context.isParent) {
      return left(const Failure.validationError(
        message: 'El usuario no es un padre'
      ));
    }

    // 4. Crear contexto actualizado
    final updatedContext = context.copyWith(
      memberData: context.memberData?.copyWith(
        parentInfo: newInfo,
      ),
      updatedAt: DateTime.now(),
    );

    // 5. Guardar cambios
    final updateResult = await _contextRepository.updateUserContext(updatedContext);
    if (updateResult.isLeft()) return updateResult;

    // 6. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: parentId,
      academyId: academyId,
      action: 'PARENT_INFO_UPDATED',
      details: 'Información de padre actualizada',
      metadata: {
        'updatedBy': updatedBy,
        'fields': _getUpdatedParentFields(context.parentInfo, newInfo),
      },
    );

    return right(null);
  }

  // === Gestión de relaciones padre-atleta ===

  /// Vincula un padre con un atleta
  Future<Either<Failure, void>> linkParentToAthlete({
    required String parentId,
    required String athleteId,
    required String academyId,
    required String linkedBy,
  }) async {
    // 1. Verificar permisos
    final canLinkResult = await _contextRepository.userHasPermission(
      linkedBy,
      academyId,
      ManagerPermission.manageUsers,
    );
    
    if (canLinkResult.isLeft()) return canLinkResult.map((_) => {});
    if (canLinkResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para gestionar relaciones padre-atleta'
      ));
    }

    // 2. Verificar que ambos usuarios existen en la academia
    final parentExistsResult = await _contextRepository.userExistsInAcademy(parentId, academyId);
    if (parentExistsResult.isLeft()) return parentExistsResult.map((_) => {});
    
    final athleteExistsResult = await _contextRepository.userExistsInAcademy(athleteId, academyId);
    if (athleteExistsResult.isLeft()) return athleteExistsResult.map((_) => {});

    if (parentExistsResult.getRight().toNullable() != true ||
        athleteExistsResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'Uno o ambos usuarios no existen en la academia'
      ));
    }

    // 3. Realizar vinculación
    final linkResult = await _contextRepository.linkParentToAthlete(parentId, athleteId, academyId);
    if (linkResult.isLeft()) return linkResult;

    // 4. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: parentId,
      academyId: academyId,
      action: 'PARENT_ATHLETE_LINKED',
      details: 'Padre vinculado con atleta',
      metadata: {
        'linkedBy': linkedBy,
        'athleteId': athleteId,
      },
    );

    return right(null);
  }

  /// Desvincula un padre de un atleta
  Future<Either<Failure, void>> unlinkParentFromAthlete({
    required String parentId,
    required String athleteId,
    required String academyId,
    required String unlinkedBy,
  }) async {
    // 1. Verificar permisos
    final canUnlinkResult = await _contextRepository.userHasPermission(
      unlinkedBy,
      academyId,
      ManagerPermission.manageUsers,
    );
    
    if (canUnlinkResult.isLeft()) return canUnlinkResult.map((_) => {});
    if (canUnlinkResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para gestionar relaciones padre-atleta'
      ));
    }

    // 2. Realizar desvinculación
    final unlinkResult = await _contextRepository.unlinkParentFromAthlete(parentId, athleteId, academyId);
    if (unlinkResult.isLeft()) return unlinkResult;

    // 3. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: parentId,
      academyId: academyId,
      action: 'PARENT_ATHLETE_UNLINKED',
      details: 'Padre desvinculado de atleta',
      metadata: {
        'unlinkedBy': unlinkedBy,
        'athleteId': athleteId,
      },
    );

    return right(null);
  }

  // === Gestión de pagos ===

  /// Actualiza el estado de pago de un miembro
  Future<Either<Failure, void>> updatePaymentStatus({
    required String memberId,
    required String academyId,
    required String updatedBy,
    required PaymentStatus status,
    DateTime? lastPaymentDate,
    double? lastPaymentAmount,
    DateTime? nextPaymentDue,
  }) async {
    // 1. Verificar permisos
    final canUpdateResult = await _contextRepository.userHasPermission(
      updatedBy,
      academyId,
      ManagerPermission.managePayments,
    );
    
    if (canUpdateResult.isLeft()) return canUpdateResult.map((_) => {});
    if (canUpdateResult.getRight().toNullable() != true) {
      return left(const Failure.validationError(
        message: 'No tiene permisos para gestionar pagos'
      ));
    }

    // 2. Actualizar estado de pago
    final updateResult = await _contextRepository.updateMemberPaymentStatus(
      memberId,
      academyId,
      status,
      lastPaymentDate: lastPaymentDate,
      lastPaymentAmount: lastPaymentAmount,
      nextPaymentDue: nextPaymentDue,
    );
    if (updateResult.isLeft()) return updateResult;

    // 3. Registrar auditoría
    await _contextRepository.logContextAudit(
      userId: memberId,
      academyId: academyId,
      action: 'PAYMENT_STATUS_UPDATED',
      details: 'Estado de pago actualizado',
      metadata: {
        'updatedBy': updatedBy,
        'newStatus': status.name,
        'lastPaymentAmount': lastPaymentAmount,
        'nextPaymentDue': nextPaymentDue?.toIso8601String(),
      },
    );

    return right(null);
  }

  // === Consultas ===

  /// Obtiene todos los miembros de una academia
  Future<Either<Failure, List<AcademyUserContext>>> getAcademyMembers({
    required String academyId,
    MemberType? typeFilter,
    PaymentStatus? paymentStatusFilter,
  }) async {
    return await _contextRepository.getAcademyMembers(
      academyId,
      typeFilter: typeFilter,
      paymentStatusFilter: paymentStatusFilter,
    );
  }

  /// Obtiene atletas asociados a un padre
  Future<Either<Failure, List<AcademyUserContext>>> getParentAthletes({
    required String parentId,
    required String academyId,
  }) async {
    return await _contextRepository.getParentAthletes(parentId, academyId);
  }

  /// Obtiene padres asociados a un atleta
  Future<Either<Failure, List<AcademyUserContext>>> getAthleteParents({
    required String athleteId,
    required String academyId,
  }) async {
    return await _contextRepository.getAthleteParents(athleteId, academyId);
  }

  /// Obtiene miembros con problemas de pago
  Future<Either<Failure, List<AcademyUserContext>>> getMembersWithPaymentIssues({
    required String academyId,
  }) async {
    return await _contextRepository.getMembersWithPaymentIssues(academyId);
  }

  // === Métodos auxiliares privados ===

  Future<void> _linkParentToAthleteInternal(String parentId, String athleteId, String academyId) async {
    await _contextRepository.linkParentToAthlete(parentId, athleteId, academyId);
  }

  List<String> _getUpdatedFields(AthleteInfo? oldInfo, AthleteInfo newInfo) {
    final fields = <String>[];
    if (oldInfo?.birthDate != newInfo.birthDate) fields.add('birthDate');
    if (oldInfo?.heightCm != newInfo.heightCm) fields.add('height');
    if (oldInfo?.weightKg != newInfo.weightKg) fields.add('weight');
    if (oldInfo?.position != newInfo.position) fields.add('position');
    if (oldInfo?.allergies != newInfo.allergies) fields.add('allergies');
    return fields;
  }

  List<String> _getUpdatedParentFields(ParentInfo? oldInfo, ParentInfo newInfo) {
    final fields = <String>[];
    if (oldInfo?.phoneNumber != newInfo.phoneNumber) fields.add('phoneNumber');
    if (oldInfo?.address != newInfo.address) fields.add('address');
    if (oldInfo?.occupation != newInfo.occupation) fields.add('occupation');
    return fields;
  }
} 