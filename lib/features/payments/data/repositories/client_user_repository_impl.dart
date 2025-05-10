import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/payments/data/models/client_user_model.dart';
import 'package:arcinus/features/payments/domain/repositories/client_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_user_repository_impl.g.dart';

/// Proveedor del repositorio de usuarios cliente (atletas y padres)
@riverpod
ClientUserRepository clientUserRepository(Ref ref) {
  return ClientUserRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
}

/// Implementación del repositorio de usuarios cliente
class ClientUserRepositoryImpl implements ClientUserRepository {
  final FirebaseFirestore _firestore;
  
  ClientUserRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;
  
  // Referencia a la subcolección de usuarios de una academia
  CollectionReference<Map<String, dynamic>> _getUsersCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('users');
  }

  // Referencia a la subcolección de planes de suscripción de una academia
  CollectionReference<Map<String, dynamic>> _getSubscriptionPlansCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('subscription_plans');
  }

  @override
  Future<Either<Failure, ClientUserModel>> getClientUser(String academyId, String userId) async {
    try {
      final userDoc = await _getUsersCollection(academyId).doc(userId).get();
      
      if (!userDoc.exists) {
        return left(const Failure.notFound(message: 'Usuario no encontrado'));
      }
      
      final userData = userDoc.data()!;
      
      // Verificar si el usuario es un atleta o padre
      final role = AppRole.fromString(userData['role'] as String?);
      if (role != AppRole.atleta && role != AppRole.padre) {
        return left(const Failure.validationError(
          message: 'El usuario no es un cliente (atleta o padre)'
        ));
      }
      
      // Obtener los datos de cliente del usuario
      final clientData = userData['clientData'] as Map<String, dynamic>? ?? {};
      
      // Obtener el plan de suscripción si existe
      SubscriptionPlanModel? subscriptionPlan;
      final subscriptionPlanId = clientData['subscriptionPlanId'] as String?;
      
      if (subscriptionPlanId != null) {
        final planDoc = await _getSubscriptionPlansCollection(academyId)
            .doc(subscriptionPlanId).get();
        
        if (planDoc.exists) {
          final planData = planDoc.data()!;
          subscriptionPlan = SubscriptionPlanModel.fromJson({
            'id': planDoc.id,
            ...planData,
          });
        }
      }
      
      // Construir el modelo de cliente
      final clientUser = ClientUserModel(
        id: userDoc.id,
        userId: userDoc.id,
        academyId: academyId,
        clientType: role,
        paymentStatus: _parsePaymentStatus(clientData['paymentStatus'] as String?),
        subscriptionPlanId: subscriptionPlanId,
        subscriptionPlan: subscriptionPlan,
        nextPaymentDate: clientData['nextPaymentDate'] != null
          ? (clientData['nextPaymentDate'] as Timestamp).toDate()
          : null,
        remainingDays: clientData['remainingDays'] as int?,
        linkedAccounts: _parseLinkedAccounts(clientData['linkedAccounts']),
        lastPaymentDate: clientData['lastPaymentDate'] != null
          ? (clientData['lastPaymentDate'] as Timestamp).toDate()
          : null,
        metadata: clientData['metadata'] as Map<String, dynamic>? ?? {},
      );
      
      return right(clientUser);
    } catch (e) {
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
        
        // Obtener el plan de suscripción si existe
        SubscriptionPlanModel? subscriptionPlan;
        final subscriptionPlanId = clientData['subscriptionPlanId'] as String?;
        
        if (subscriptionPlanId != null) {
          final planDoc = await _getSubscriptionPlansCollection(academyId)
              .doc(subscriptionPlanId).get();
          
          if (planDoc.exists) {
            final planData = planDoc.data()!;
            subscriptionPlan = SubscriptionPlanModel.fromJson({
              'id': planDoc.id,
              ...planData,
            });
          }
        }
        
        // Construir el modelo de cliente
        final clientUser = ClientUserModel(
          id: doc.id,
          userId: doc.id,
          academyId: academyId,
          clientType: AppRole.fromString(userData['role'] as String?),
          paymentStatus: userPaymentStatus,
          subscriptionPlanId: subscriptionPlanId,
          subscriptionPlan: subscriptionPlan,
          nextPaymentDate: clientData['nextPaymentDate'] != null
            ? (clientData['nextPaymentDate'] as Timestamp).toDate()
            : null,
          remainingDays: clientData['remainingDays'] as int?,
          linkedAccounts: _parseLinkedAccounts(clientData['linkedAccounts']),
          lastPaymentDate: clientData['lastPaymentDate'] != null
            ? (clientData['lastPaymentDate'] as Timestamp).toDate()
            : null,
          metadata: clientData['metadata'] as Map<String, dynamic>? ?? {},
        );
        
        clientUsers.add(clientUser);
      }
      
      return right(clientUsers);
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlanModel>>> getSubscriptionPlans(
    String academyId, {
    bool activeOnly = true,
  }) async {
    try {
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
      
      return right(plans);
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> getSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    try {
      final planDoc = await _getSubscriptionPlansCollection(academyId).doc(planId).get();
      
      if (!planDoc.exists) {
        return left(const Failure.notFound(message: 'Plan de suscripción no encontrado'));
      }
      
      final data = planDoc.data()!;
      final plan = SubscriptionPlanModel.fromJson({
        'id': planDoc.id,
        ...data,
      });
      
      return right(plan);
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> createSubscriptionPlan(
    String academyId,
    SubscriptionPlanModel plan,
  ) async {
    try {
      final planData = plan.toJson();
      
      final docRef = await _getSubscriptionPlansCollection(academyId).add(planData);
      
      final createdPlan = plan.copyWith(id: docRef.id);
      
      return right(createdPlan);
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> updateSubscriptionPlan(
    String academyId,
    String planId,
    SubscriptionPlanModel plan,
  ) async {
    try {
      final planData = plan.toJson();
      
      await _getSubscriptionPlansCollection(academyId).doc(planId).update(planData);
      
      return right(plan.copyWith(id: planId));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    try {
      await _getSubscriptionPlansCollection(academyId).doc(planId).delete();
      
      return right(unit);
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, ClientUserModel>> updateClientUser(
    String academyId,
    String userId,
    Map<String, dynamic> clientData,
  ) async {
    try {
      // Actualizar solo el campo clientData
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': FieldValue.arrayUnion([clientData]),
      });
      
      // Obtener el usuario actualizado
      final result = await getClientUser(academyId, userId);
      
      return result;
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, ClientUserModel>> assignSubscriptionPlan(
    String academyId,
    String userId,
    String planId,
    DateTime? startDate,
  ) async {
    try {
      // Obtener el plan
      final planResult = await getSubscriptionPlan(academyId, planId);
      
      return planResult.fold(
        (failure) => left(failure),
        (plan) async {
          // Calcular la próxima fecha de pago
          final effectiveStartDate = startDate ?? DateTime.now();
          final nextPaymentDate = _calculateNextPaymentDate(effectiveStartDate, plan.billingCycle);
          
          // Calcular días restantes
          final remainingDays = _calculateRemainingDays(effectiveStartDate, nextPaymentDate);
          
          // Actualizar el usuario
          final clientData = {
            'subscriptionPlanId': planId,
            'nextPaymentDate': Timestamp.fromDate(nextPaymentDate),
            'remainingDays': remainingDays,
            'paymentStatus': PaymentStatus.active.name,
            'assignedAt': Timestamp.fromDate(DateTime.now()),
          };
          
          // Actualizar el usuario
          final updateResult = await updateClientUser(academyId, userId, clientData);
          
          return updateResult;
        },
      );
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }
  
  // Método auxiliar para calcular la próxima fecha de pago
  DateTime _calculateNextPaymentDate(DateTime startDate, BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case BillingCycle.quarterly:
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case BillingCycle.biannual:
        return DateTime(startDate.year, startDate.month + 6, startDate.day);
      case BillingCycle.annual:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
    }
  }
  
  // Método auxiliar para calcular los días restantes
  int _calculateRemainingDays(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
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