import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/features/academy_users_payments/domain/repositories/academy_member_repository.dart';
import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'academy_member_repository_impl.g.dart';

/// Proveedor del repositorio de miembros de academia (atletas y padres)
@riverpod
AcademyMemberRepository academyMemberRepository(Ref ref) {
  AppLogger.logInfo(
    'Creando instancia de AcademyMemberRepository',
    className: 'academy_member_repository',
    functionName: 'academyMemberRepository',
  );
  return AcademyMemberRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
}

/// Implementación del repositorio de miembros de academia usando Firestore
class AcademyMemberRepositoryImpl implements AcademyMemberRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'AcademyMemberRepositoryImpl';
  
  AcademyMemberRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;
  
  /// Obtiene la referencia de la colección de usuarios para una academia
  CollectionReference<Map<String, dynamic>> _getUsersCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('users');
  }

  /// Obtiene la referencia de la colección de planes de suscripción para una academia
  CollectionReference<Map<String, dynamic>> _getSubscriptionPlansCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('subscription_plans');
  }

  @override
  Future<Either<Failure, AcademyMemberUserModel?>> getAcademyMember(
    String academyId,
    String userId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo miembro de academia',
        className: _className,
        functionName: 'getAcademyMember',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      final userDoc = await _getUsersCollection(academyId).doc(userId).get();
      
      if (!userDoc.exists) {
        AppLogger.logWarning(
          'Usuario no encontrado',
          className: _className,
          functionName: 'getAcademyMember',
          params: {'academyId': academyId, 'userId': userId},
        );
        return right(null);
      }
      
      final userData = userDoc.data()!;
      final String? roleString = userData['role'] as String?;
      final AppRole role = AppRole.fromString(roleString);
      
      // Solo procesar si es atleta o padre
      if (role != AppRole.atleta && role != AppRole.padre) {
        AppLogger.logInfo(
          'Usuario no es miembro (atleta/padre)',
          className: _className,
          functionName: 'getAcademyMember',
          params: {'academyId': academyId, 'userId': userId, 'role': role.name},
        );
        return right(null);
      }
      
      // Obtener datos del miembro (información básica únicamente)
      final memberData = userData['clientData'] as Map<String, dynamic>? ?? {};
      
      // Construir el modelo de miembro (solo información básica)
      final academyMember = AcademyMemberUserModel(
        id: userDoc.id,
        userId: userDoc.id,
        academyId: academyId,
        clientType: role,
        paymentStatus: _parsePaymentStatus(memberData['paymentStatus'] as String?),
        linkedAccounts: _parseLinkedAccounts(memberData['linkedAccounts']),
        metadata: memberData['metadata'] as Map<String, dynamic>? ?? {},
      );
      
      AppLogger.logInfo(
        'Miembro de academia obtenido exitosamente',
        className: _className,
        functionName: 'getAcademyMember',
        params: {'academyId': academyId, 'userId': userId, 'memberType': role.name},
      );
      
      return right(academyMember);
      
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener miembro de academia',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getAcademyMember',
        params: {'academyId': academyId, 'userId': userId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, List<AcademyMemberUserModel>>> getAcademyMembers(
    String academyId, {
    AppRole? memberType,
    PaymentStatus? paymentStatus,
  }) async {
    try {
      AppLogger.logInfo(
        'Obteniendo lista de miembros de academia',
        className: _className,
        functionName: 'getAcademyMembers',
        params: {
          'academyId': academyId,
          'memberType': memberType?.name,
          'paymentStatus': paymentStatus?.name,
        },
      );
      
      Query<Map<String, dynamic>> query = _getUsersCollection(academyId);
      
      // Filtrar por tipo de miembro (atleta o padre)
      if (memberType != null) {
        query = query.where('role', isEqualTo: memberType.name);
      } else {
        // Si no se especifica, obtener solo atletas y padres
        query = query.where('role', whereIn: [AppRole.atleta.name, AppRole.padre.name]);
      }
      
      // Obtener los resultados
      final snapshot = await query.get();
      
      AppLogger.logInfo(
        'Registros obtenidos',
        className: _className,
        functionName: 'getAcademyMembers',
        params: {'academyId': academyId, 'count': snapshot.docs.length},
      );
      
      // Procesar los resultados
      final List<AcademyMemberUserModel> academyMembers = [];
      
      for (final doc in snapshot.docs) {
        final userData = doc.data();
        final memberData = userData['clientData'] as Map<String, dynamic>? ?? {};
        
        // Filtrar por estado de pago si se especifica
        final userPaymentStatus = _parsePaymentStatus(memberData['paymentStatus'] as String?);
        
        if (paymentStatus != null && userPaymentStatus != paymentStatus) {
          continue;
        }
        
        // Construir el modelo de miembro (solo información básica)
        final academyMember = AcademyMemberUserModel(
          id: doc.id,
          userId: doc.id,
          academyId: academyId,
          clientType: AppRole.fromString(userData['role'] as String?),
          paymentStatus: userPaymentStatus,
          linkedAccounts: _parseLinkedAccounts(memberData['linkedAccounts']),
          metadata: memberData['metadata'] as Map<String, dynamic>? ?? {},
        );
        
        academyMembers.add(academyMember);
      }
      
      AppLogger.logInfo(
        'Lista de miembros de academia procesada',
        className: _className,
        functionName: 'getAcademyMembers',
        params: {'academyId': academyId, 'resultCount': academyMembers.length},
      );
      
      return right(academyMembers);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener lista de miembros de academia',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getAcademyMembers',
        params: {'academyId': academyId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlanModel>>> getSubscriptionPlans(
    String academyId, {
    bool activeOnly = true,
  }) async {
    try {
      AppLogger.logInfo(
        'Obteniendo planes de suscripción',
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId, 'activeOnly': activeOnly},
      );
      
      Query<Map<String, dynamic>> query = _getSubscriptionPlansCollection(academyId);
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      
      final plans = snapshot.docs.map((doc) {
        final data = doc.data();
        return SubscriptionPlanModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
      
      AppLogger.logInfo(
        'Planes de suscripción obtenidos exitosamente',
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId, 'count': plans.length},
      );
      
      return right(plans);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener planes de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, bool>> assignSubscriptionPlan(
    String academyId,
    String userId,
    String planId, {
    DateTime? startDate,
  }) async {
    try {
      AppLogger.logInfo(
        'Asignando plan de suscripción básico a usuario',
        className: _className,
        functionName: 'assignSubscriptionPlan',
        params: {
          'academyId': academyId,
          'userId': userId,
          'planId': planId,
          'startDate': startDate?.toIso8601String(),
        },
      );

      // Validar que el plan existe
      final planDoc = await _getSubscriptionPlansCollection(academyId).doc(planId).get();
      
      if (!planDoc.exists) {
        return left(const Failure.notFound(message: 'Plan de suscripción no encontrado'));
      }
      
      // Datos básicos del miembro (sin fechas específicas)
      Map<String, dynamic> memberData = {
        'paymentStatus': PaymentStatus.inactive.name, // Inactivo hasta primer pago
        'assignedAt': Timestamp.fromDate(DateTime.now()),
        'assignedPlanId': planId, // Plan asignado para referencia
        // NOTA: Las fechas específicas se manejan en los períodos
      };
      
      // Actualizar el documento del usuario
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': memberData,
      });
      
      AppLogger.logInfo(
        'Plan básico asignado exitosamente',
        className: _className,
        functionName: 'assignSubscriptionPlan',
        params: {'academyId': academyId, 'userId': userId, 'planId': planId},
      );
      
      return right(true);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al asignar plan básico a usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'assignSubscriptionPlan',
        params: {'academyId': academyId, 'userId': userId, 'planId': planId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAcademyMemberPaymentStatus(
    String academyId,
    String userId,
    PaymentStatus newStatus,
  ) async {
    try {
      AppLogger.logInfo(
        'Actualizando estado de pago de usuario miembro',
        className: _className,
        functionName: 'updateAcademyMemberPaymentStatus',
        params: {
          'academyId': academyId, 
          'userId': userId, 
          'newStatus': newStatus.name
        },
      );
      
      // Obtener el documento actual para actualizar solo el estado de pago
      final userDoc = await _getUsersCollection(academyId).doc(userId).get();
      
      if (!userDoc.exists) {
        return left(const Failure.notFound(message: 'Usuario no encontrado'));
      }
      
      final userData = userDoc.data()!;
      final memberData = userData['clientData'] as Map<String, dynamic>? ?? {};
      
      // Actualizar solo el campo de estado de pago
      final updatedMemberData = {
        ...memberData,
        'paymentStatus': newStatus.name,
        'lastStatusUpdate': Timestamp.fromDate(DateTime.now()),
      };
      
      // Actualizar el documento
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': updatedMemberData,
      });
      
      AppLogger.logInfo(
        'Estado de pago actualizado exitosamente',
        className: _className,
        functionName: 'updateAcademyMemberPaymentStatus',
        params: {'academyId': academyId, 'userId': userId, 'newStatus': newStatus.name},
      );
      
      return right(true);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar estado de pago del usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateAcademyMemberPaymentStatus',
        params: {'academyId': academyId, 'userId': userId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAcademyMember(
    String academyId,
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      AppLogger.logInfo(
        'Actualizando datos del usuario miembro',
        className: _className,
        functionName: 'updateAcademyMember',
        params: {
          'academyId': academyId,
          'userId': userId,
          'updates': updates.keys.toList(),
        },
      );
      
      final userDoc = await _getUsersCollection(academyId).doc(userId).get();
      
      if (!userDoc.exists) {
        return left(const Failure.notFound(message: 'Usuario no encontrado'));
      }
      
      final userData = userDoc.data()!;
      final memberData = userData['clientData'] as Map<String, dynamic>? ?? {};
      
      // Mergear las actualizaciones con los datos existentes
      final updatedMemberData = {
        ...memberData,
        ...updates,
        'lastModified': Timestamp.fromDate(DateTime.now()),
      };
      
      // Actualizar el documento
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': updatedMemberData,
      });
      
      AppLogger.logInfo(
        'Datos del usuario miembro actualizados exitosamente',
        className: _className,
        functionName: 'updateAcademyMember',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      return right(true);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar datos del usuario miembro',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateAcademyMember',
        params: {'academyId': academyId, 'userId': userId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  // Método auxiliar para parsear el estado de pago
  PaymentStatus _parsePaymentStatus(String? status) {
    if (status == null) return PaymentStatus.inactive;
    
    switch (status) {
      case 'active':
        return PaymentStatus.active;
      case 'overdue':
        return PaymentStatus.overdue;
      default:
        return PaymentStatus.inactive;
    }
  }

  // Método auxiliar para parsear las cuentas vinculadas
  List<String> _parseLinkedAccounts(dynamic linkedAccounts) {
    if (linkedAccounts == null) {
      return [];
    }
    
    if (linkedAccounts is List) {
      return linkedAccounts.map((item) => item.toString()).toList();
    }
    
    return [];
  }
} 