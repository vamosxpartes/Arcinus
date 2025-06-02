import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/payments/domain/repositories/client_user_repository.dart';
import 'package:arcinus/features/users/data/models/payment_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'client_user_repository_impl.g.dart';

/// Proveedor del repositorio de usuarios cliente (atletas y padres)
@riverpod
ClientUserRepository clientUserRepository(Ref ref) {
  AppLogger.logInfo(
    'Creando instancia de ClientUserRepository',
    className: 'client_user_repository',
    functionName: 'clientUserRepository',
  );
  return ClientUserRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
}

/// Implementación del repositorio de usuarios cliente usando Firestore
class ClientUserRepositoryImpl implements ClientUserRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'ClientUserRepositoryImpl';
  
  ClientUserRepositoryImpl({
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
  Future<Either<Failure, ClientUserModel?>> getClientUser(
    String academyId,
    String userId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo usuario cliente',
        className: _className,
        functionName: 'getClientUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      final userDoc = await _getUsersCollection(academyId).doc(userId).get();
      
      if (!userDoc.exists) {
        AppLogger.logWarning(
          'Usuario no encontrado',
          className: _className,
          functionName: 'getClientUser',
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
          'Usuario no es cliente (atleta/padre)',
          className: _className,
          functionName: 'getClientUser',
          params: {'academyId': academyId, 'userId': userId, 'role': role.name},
        );
        return right(null);
      }
      
      // Obtener datos del cliente (información básica únicamente)
      final clientData = userData['clientData'] as Map<String, dynamic>? ?? {};
      
      // Construir el modelo de cliente (solo información básica)
      final clientUser = ClientUserModel(
        id: userDoc.id,
        userId: userDoc.id,
        academyId: academyId,
        clientType: role,
        paymentStatus: _parsePaymentStatus(clientData['paymentStatus'] as String?),
        linkedAccounts: _parseLinkedAccounts(clientData['linkedAccounts']),
        metadata: clientData['metadata'] as Map<String, dynamic>? ?? {},
      );
      
      AppLogger.logInfo(
        'Usuario cliente obtenido exitosamente',
        className: _className,
        functionName: 'getClientUser',
        params: {'academyId': academyId, 'userId': userId, 'clientType': role.name},
      );
      
      return right(clientUser);
      
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener usuario cliente',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getClientUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, List<ClientUserModel>>> getClientUsers(
    String academyId, {
    AppRole? clientType,
    PaymentStatus? paymentStatus,
  }) async {
    try {
      AppLogger.logInfo(
        'Obteniendo lista de usuarios cliente',
        className: _className,
        functionName: 'getClientUsers',
        params: {
          'academyId': academyId,
          'clientType': clientType?.name,
          'paymentStatus': paymentStatus?.name,
        },
      );
      
      Query<Map<String, dynamic>> query = _getUsersCollection(academyId);
      
      // Filtrar por tipo de cliente (atleta o padre)
      if (clientType != null) {
        query = query.where('role', isEqualTo: clientType.name);
      } else {
        // Si no se especifica, obtener solo atletas y padres
        query = query.where('role', whereIn: [AppRole.atleta.name, AppRole.padre.name]);
      }
      
      // Obtener los resultados
      final snapshot = await query.get();
      
      AppLogger.logInfo(
        'Registros obtenidos',
        className: _className,
        functionName: 'getClientUsers',
        params: {'academyId': academyId, 'count': snapshot.docs.length},
      );
      
      // Procesar los resultados
      final List<ClientUserModel> clientUsers = [];
      
      for (final doc in snapshot.docs) {
        final userData = doc.data();
        final clientData = userData['clientData'] as Map<String, dynamic>? ?? {};
        
        // Filtrar por estado de pago si se especifica
        final userPaymentStatus = _parsePaymentStatus(clientData['paymentStatus'] as String?);
        
        if (paymentStatus != null && userPaymentStatus != paymentStatus) {
          continue;
        }
        
        // Construir el modelo de cliente (solo información básica)
        final clientUser = ClientUserModel(
          id: doc.id,
          userId: doc.id,
          academyId: academyId,
          clientType: AppRole.fromString(userData['role'] as String?),
          paymentStatus: userPaymentStatus,
          linkedAccounts: _parseLinkedAccounts(clientData['linkedAccounts']),
          metadata: clientData['metadata'] as Map<String, dynamic>? ?? {},
        );
        
        clientUsers.add(clientUser);
      }
      
      AppLogger.logInfo(
        'Lista de usuarios cliente procesada',
        className: _className,
        functionName: 'getClientUsers',
        params: {'academyId': academyId, 'resultCount': clientUsers.length},
      );
      
      return right(clientUsers);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener lista de usuarios cliente',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getClientUsers',
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
      
      // Datos básicos del cliente (sin fechas específicas)
      Map<String, dynamic> clientData = {
        'paymentStatus': PaymentStatus.inactive.name, // Inactivo hasta primer pago
        'assignedAt': Timestamp.fromDate(DateTime.now()),
        'assignedPlanId': planId, // Plan asignado para referencia
        // NOTA: Las fechas específicas se manejan en los períodos
      };
      
      // Actualizar el documento del usuario
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': clientData,
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
  Future<Either<Failure, bool>> updateClientUserPaymentStatus(
    String academyId,
    String userId,
    PaymentStatus newStatus,
  ) async {
    try {
      AppLogger.logInfo(
        'Actualizando estado de pago de usuario cliente',
        className: _className,
        functionName: 'updateClientUserPaymentStatus',
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
      final clientData = userData['clientData'] as Map<String, dynamic>? ?? {};
      
      // Actualizar solo el campo de estado de pago
      final updatedClientData = {
        ...clientData,
        'paymentStatus': newStatus.name,
        'lastStatusUpdate': Timestamp.fromDate(DateTime.now()),
      };
      
      // Actualizar el documento
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': updatedClientData,
      });
      
      AppLogger.logInfo(
        'Estado de pago actualizado exitosamente',
        className: _className,
        functionName: 'updateClientUserPaymentStatus',
        params: {'academyId': academyId, 'userId': userId, 'newStatus': newStatus.name},
      );
      
      return right(true);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar estado de pago del usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateClientUserPaymentStatus',
        params: {'academyId': academyId, 'userId': userId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateClientUser(
    String academyId,
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      AppLogger.logInfo(
        'Actualizando datos del usuario cliente',
        className: _className,
        functionName: 'updateClientUser',
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
      final clientData = userData['clientData'] as Map<String, dynamic>? ?? {};
      
      // Mergear las actualizaciones con los datos existentes
      final updatedClientData = {
        ...clientData,
        ...updates,
        'lastModified': Timestamp.fromDate(DateTime.now()),
      };
      
      // Actualizar el documento
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': updatedClientData,
      });
      
      AppLogger.logInfo(
        'Datos del usuario cliente actualizados exitosamente',
        className: _className,
        functionName: 'updateClientUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      return right(true);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar datos del usuario cliente',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateClientUser',
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