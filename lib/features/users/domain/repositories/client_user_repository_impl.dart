import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/payments/domain/repositories/client_user_repository.dart';
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

/// Implementación del repositorio de usuarios cliente
class ClientUserRepositoryImpl implements ClientUserRepository {
  static const String _className = 'ClientUserRepositoryImpl';
  final FirebaseFirestore _firestore;
  
  ClientUserRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore {
    AppLogger.logInfo(
      'Inicializado ClientUserRepositoryImpl',
      className: _className,
      functionName: 'constructor',
    );
  }
  
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
        return left(const Failure.notFound(message: 'Usuario no encontrado'));
      }
      
      final userData = userDoc.data()!;
      
      // Verificar si el usuario es un atleta o padre
      final role = AppRole.fromString(userData['role'] as String?);
      if (role != AppRole.atleta && role != AppRole.padre) {
        AppLogger.logWarning(
          'Usuario no es un cliente (atleta o padre)',
          className: _className,
          functionName: 'getClientUser',
          params: {'academyId': academyId, 'userId': userId, 'role': role.name},
        );
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
        AppLogger.logInfo(
          'Obteniendo plan de suscripción',
          className: _className,
          functionName: 'getClientUser',
          params: {'academyId': academyId, 'subscriptionPlanId': subscriptionPlanId},
        );
        
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
        isEstimatedDays: clientData['isEstimatedDays'] as bool? ?? false,
        linkedAccounts: _parseLinkedAccounts(clientData['linkedAccounts']),
        lastPaymentDate: clientData['lastPaymentDate'] != null
          ? (clientData['lastPaymentDate'] as Timestamp).toDate()
          : null,
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
          isEstimatedDays: clientData['isEstimatedDays'] as bool? ?? false,
          linkedAccounts: _parseLinkedAccounts(clientData['linkedAccounts']),
          lastPaymentDate: clientData['lastPaymentDate'] != null
            ? (clientData['lastPaymentDate'] as Timestamp).toDate()
            : null,
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
  Future<Either<Failure, SubscriptionPlanModel>> getSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo plan de suscripción por ID',
        className: _className,
        functionName: 'getSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      
      final planDoc = await _getSubscriptionPlansCollection(academyId).doc(planId).get();
      
      if (!planDoc.exists) {
        AppLogger.logWarning(
          'Plan de suscripción no encontrado',
          className: _className,
          functionName: 'getSubscriptionPlan',
          params: {'academyId': academyId, 'planId': planId},
        );
        return left(const Failure.notFound(message: 'Plan de suscripción no encontrado'));
      }
      
      final data = planDoc.data()!;
      final plan = SubscriptionPlanModel.fromJson({
        'id': planDoc.id,
        ...data,
      });
      
      AppLogger.logInfo(
        'Plan de suscripción obtenido exitosamente',
        className: _className,
        functionName: 'getSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId, 'planName': plan.name},
      );
      
      return right(plan);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> createSubscriptionPlan(
    String academyId,
    SubscriptionPlanModel plan,
  ) async {
    try {
      AppLogger.logInfo(
        'Creando plan de suscripción',
        className: _className,
        functionName: 'createSubscriptionPlan',
        params: {'academyId': academyId, 'planName': plan.name},
      );
      
      final planData = plan.toJson();
      
      final docRef = await _getSubscriptionPlansCollection(academyId).add(planData);
      
      final createdPlan = plan.copyWith(id: docRef.id);
      
      AppLogger.logInfo(
        'Plan de suscripción creado exitosamente',
        className: _className,
        functionName: 'createSubscriptionPlan',
        params: {'academyId': academyId, 'planId': docRef.id, 'planName': plan.name},
      );
      
      return right(createdPlan);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createSubscriptionPlan',
        params: {'academyId': academyId, 'planName': plan.name},
      );
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
      AppLogger.logInfo(
        'Actualizando plan de suscripción',
        className: _className,
        functionName: 'updateSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId, 'planName': plan.name},
      );
      
      final planData = plan.toJson();
      
      await _getSubscriptionPlansCollection(academyId).doc(planId).update(planData);
      
      AppLogger.logInfo(
        'Plan de suscripción actualizado exitosamente',
        className: _className,
        functionName: 'updateSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      
      return right(plan.copyWith(id: planId));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    try {
      AppLogger.logInfo(
        'Eliminando plan de suscripción',
        className: _className,
        functionName: 'deleteSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      
      await _getSubscriptionPlansCollection(academyId).doc(planId).delete();
      
      AppLogger.logInfo(
        'Plan de suscripción eliminado exitosamente',
        className: _className,
        functionName: 'deleteSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      
      return right(unit);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al eliminar plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'deleteSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
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
      AppLogger.logInfo(
        'Actualizando datos de usuario cliente',
        className: _className,
        functionName: 'updateClientUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      // Actualizar el campo clientData como un mapa, no como un array
      await _getUsersCollection(academyId).doc(userId).update({
        'clientData': clientData,
      });
      
      AppLogger.logInfo(
        'Usuario cliente actualizado, obteniendo datos actualizados',
        className: _className,
        functionName: 'updateClientUser',
        params: {'academyId': academyId, 'userId': userId},
      );
      
      // Obtener el usuario actualizado
      final result = await getClientUser(academyId, userId);
      
      result.fold(
        (failure) => AppLogger.logWarning(
          'Error al obtener datos actualizados del usuario',
          className: _className,
          functionName: 'updateClientUser',
          params: {'academyId': academyId, 'userId': userId, 'error': failure.message},
        ),
        (user) => AppLogger.logInfo(
          'Usuario cliente actualizado exitosamente',
          className: _className,
          functionName: 'updateClientUser',
          params: {'academyId': academyId, 'userId': userId},
        ),
      );
      
      return result;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar usuario cliente',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateClientUser',
        params: {'academyId': academyId, 'userId': userId},
      );
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
      AppLogger.logInfo(
        'Asignando plan de suscripción a usuario',
        className: _className,
        functionName: 'assignSubscriptionPlan',
        params: {
          'academyId': academyId,
          'userId': userId,
          'planId': planId,
          'startDate': startDate?.toIso8601String(),
        },
      );
      
      // Obtener el plan
      final planResult = await getSubscriptionPlan(academyId, planId);
      
      return planResult.fold(
        (failure) {
          AppLogger.logWarning(
            'Plan de suscripción no encontrado para asignar',
            className: _className,
            functionName: 'assignSubscriptionPlan',
            params: {
              'academyId': academyId,
              'userId': userId,
              'planId': planId,
              'error': failure.message,
            },
          );
          return left(failure);
        },
        (plan) async {
          // Al asignar un plan sin fecha de inicio, NO calculamos fechas específicas
          // Todas las fechas se calcularán únicamente cuando se registre el primer pago
          
          Map<String, dynamic> clientData;
          
          if (startDate != null) {
            // Caso legacy: se proporciona fecha de inicio específica
            final planDurationDays = _getPlanDurationInDays(plan.billingCycle);
            clientData = {
              'subscriptionPlanId': planId,
              'planStartDate': Timestamp.fromDate(startDate),
              'remainingDays': planDurationDays,
              'paymentStatus': PaymentStatus.inactive.name,
              'assignedAt': Timestamp.fromDate(DateTime.now()),
              'isEstimatedDays': true,
            };
                     } else {
             // Nuevo comportamiento: plan asignado sin fecha de inicio
             // Las fechas se establecerán al registrar el primer pago
             clientData = {
               'subscriptionPlanId': planId,
               'paymentStatus': PaymentStatus.inactive.name, // Inactivo hasta primer pago
               'assignedAt': Timestamp.fromDate(DateTime.now()),
               'isPendingFirstPayment': true, // Flag para indicar que espera primer pago
               // NO asignamos planStartDate, remainingDays, ni nextPaymentDate
               // Se asignarán al registrar el primer pago
             };
           }
          
          AppLogger.logInfo(
            'Actualizando datos de usuario con plan de suscripción',
            className: _className,
            functionName: 'assignSubscriptionPlan',
            params: {
              'academyId': academyId,
              'userId': userId,
              'planId': planId,
              'startDateProvided': startDate != null,
              'note': startDate != null 
                ? 'Plan asignado con fecha de inicio específica'
                : 'Plan asignado sin fecha - se establecerá al registrar primer pago',
            },
          );
          
          // Actualizar el usuario
          final updateResult = await updateClientUser(academyId, userId, clientData);
          
          updateResult.fold(
            (failure) => AppLogger.logWarning(
              'Error al asignar plan al usuario',
              className: _className,
              functionName: 'assignSubscriptionPlan',
              params: {
                'academyId': academyId,
                'userId': userId,
                'planId': planId,
                'error': failure.message,
              },
            ),
            (user) => AppLogger.logInfo(
              'Plan de suscripción asignado exitosamente',
              className: _className,
              functionName: 'assignSubscriptionPlan',
              params: {
                'academyId': academyId,
                'userId': userId,
                'planId': planId,
                'planName': plan.name,
              },
            ),
          );
          
          return updateResult;
        },
      );
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al asignar plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'assignSubscriptionPlan',
        params: {'academyId': academyId, 'userId': userId, 'planId': planId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }
  
  // Método auxiliar para calcular la duración del plan en días
  int _getPlanDurationInDays(BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return 30; // Aproximación para un mes
      case BillingCycle.quarterly:
        return 90; // 3 meses aproximado
      case BillingCycle.biannual:
        return 180; // 6 meses aproximado
      case BillingCycle.annual:
        return 365; // 1 año aproximado
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

  Future<Either<Failure, String>> createClientUser(String academyId, Map<String, dynamic> userData) async {
    try {
      AppLogger.logInfo(
        'Creando usuario cliente',
        className: _className,
        functionName: 'createClientUser',
        params: {'academyId': academyId},
      );
      
      // Asegurar que el clientData incluya un estado de pago inactivo
      if (userData.containsKey('clientData')) {
        final clientData = userData['clientData'] as Map<String, dynamic>;
        // Si no se especifica un estado, establecer como inactivo
        if (!clientData.containsKey('paymentStatus')) {
          clientData['paymentStatus'] = PaymentStatus.inactive.name;
        }
        userData['clientData'] = clientData;
      } else {
        // Si no tiene clientData, crearlo con estado inactivo
        userData['clientData'] = {
          'paymentStatus': PaymentStatus.inactive.name,
        };
      }
      
      final docRef = await _getUsersCollection(academyId).add(userData);
      
      AppLogger.logInfo(
        'Usuario cliente creado exitosamente',
        className: _className,
        functionName: 'createClientUser',
        params: {'academyId': academyId, 'userId': docRef.id},
      );
      
      return right(docRef.id);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear usuario cliente',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createClientUser',
        params: {'academyId': academyId},
      );
      return left(Failure.unexpectedError(error: e));
    }
  }
} 