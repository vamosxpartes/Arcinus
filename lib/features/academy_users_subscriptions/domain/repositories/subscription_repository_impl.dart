import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/subscription_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Provider para el repositorio de suscripciones
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SubscriptionRepositoryImpl(firestore: firestore);
});

/// Implementación del repositorio de suscripciones
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final FirebaseFirestore _firestore;
  static const String _className = 'SubscriptionRepositoryImpl';

  SubscriptionRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  // Referencia a la colección de planes de suscripción
  CollectionReference _getPlansCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('subscription_plans');
  }

  // Referencia a la colección de usuarios
  CollectionReference _getUsersCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('users');
  }
  
  // Referencia a la colección de suscripciones
  CollectionReference _getSubscriptionsCollection() {
    return _firestore.collection('subscriptions');
  }

  @override
  Future<Either<Failure, void>> createInitialSubscription(
    SubscriptionModel subscription,
  ) async {
    try {
      AppLogger.logInfo(
        'Creando suscripción inicial',
        className: _className,
        functionName: 'createInitialSubscription',
        params: {'academyId': subscription.academyId},
      );
      
      // Usamos directamente el modelo pasado, asumiendo que ya tiene los datos correctos
      final dataToAdd = subscription.toJson();

      await _getSubscriptionsCollection().add(dataToAdd);

      AppLogger.logInfo(
        'Suscripción inicial creada exitosamente',
        className: _className,
        functionName: 'createInitialSubscription',
        params: {'academyId': subscription.academyId},
      );
      
      return const Right(null);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado creando suscripción inicial',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createInitialSubscription',
        params: {'academyId': subscription.academyId},
      );
      return Left(
        Failure.unexpectedError(error: e),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionModel?>> getActiveSubscription(
    String academyId,
  ) async {
    try {
      AppLogger.logInfo(
        'Buscando suscripción activa',
        className: _className,
        functionName: 'getActiveSubscription',
        params: {'academyId': academyId},
      );
      
      final querySnapshot = await _getSubscriptionsCollection()
          .where('academyId', isEqualTo: academyId)
          .where('status', whereIn: ['active', 'trial']) // Permitir active o trial
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.now())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppLogger.logInfo(
          'No se encontró suscripción activa',
          className: _className,
          functionName: 'getActiveSubscription',
          params: {'academyId': academyId},
        );
        return const Right(null); // No encontrada o no activa/vigente
      }

      final doc = querySnapshot.docs.first;
      final subscriptionData = doc.data() as Map<String, dynamic>;
      
      // Crear el modelo desde JSON y añadir el ID del documento
      final subscription = SubscriptionModel.fromJson(subscriptionData).copyWith(id: doc.id);
      
      AppLogger.logInfo(
        'Suscripción activa encontrada',
        className: _className,
        functionName: 'getActiveSubscription',
        params: {
          'academyId': academyId,
          'subscriptionId': doc.id,
          'status': subscription.status,
        },
      );
      
      return Right(subscription);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado obteniendo suscripción activa',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getActiveSubscription',
        params: {'academyId': academyId},
      );
      return Left(
        Failure.unexpectedError(error: e),
      );
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlanModel>>> getSubscriptionPlans(
    String academyId, {
    bool activeOnly = false,
  }) async {
    try {
      AppLogger.logInfo(
        'Obteniendo planes de suscripción',
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId, 'activeOnly': activeOnly},
      );

      Query query = _getPlansCollection(academyId).orderBy('name');
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      final snapshot = await query.get();

      AppLogger.logInfo(
        'Consulta a Firestore para planes de suscripción devolvió ${snapshot.docs.length} documentos.',
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId, 'activeOnly': activeOnly, 'rawDocCount': snapshot.docs.length},
      );

      final plans = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionPlanModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      AppLogger.logInfo(
        'Planes de suscripción obtenidos: ${plans.length}',
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId, 'count': plans.length},
      );

      return Right(plans);
    } catch (e, stack) {
      AppLogger.logError(
        message: 'Error al obtener planes de suscripción',
        error: e,
        stackTrace: stack,
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId, 'activeOnly': activeOnly},
      );
      return Left(Failure.unexpectedError(error: e));
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

      final doc = await _getPlansCollection(academyId).doc(planId).get();
      
      if (!doc.exists) {
        return Left(const Failure.notFound(message: 'Plan no encontrado'));
      }

      final data = doc.data() as Map<String, dynamic>;
      final plan = SubscriptionPlanModel.fromJson({
        'id': doc.id,
        ...data,
      });

      return Right(plan);
    } catch (e, stack) {
      AppLogger.logError(
        message: 'Error al obtener plan de suscripción',
        error: e,
        stackTrace: stack,
        className: _className,
        functionName: 'getSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return Left(Failure.unexpectedError(error: e));
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

      final DateTime now = DateTime.now();
      // Asumimos que SubscriptionPlanModel tiene copyWith para estos campos
      // y que son DateTime en el modelo, convertidos a Timestamp por toJson.
      // Si plan.createdAt ya tiene un valor (por ejemplo, si se establece en la UI), se respeta.
      final planWithTimestamps = plan.copyWith(
        createdAt: plan.createdAt, // Establecer si es nulo, o mantener valor existente
        updatedAt: now                   // Siempre establecer/actualizar en creación
      );

      final data = planWithTimestamps.toJson();
      final docRef = await _getPlansCollection(academyId).add(data);
      
      // Devolver el plan con los timestamps y el ID asignado
      final newPlan = planWithTimestamps.copyWith(id: docRef.id);

      return Right(newPlan);
    } catch (e, stack) {
      AppLogger.logError(
        message: 'Error al crear plan de suscripción',
        error: e,
        stackTrace: stack,
        className: _className,
        functionName: 'createSubscriptionPlan',
        params: {'academyId': academyId},
      );
      return Left(Failure.unexpectedError(error: e));
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
        params: {'academyId': academyId, 'planId': planId},
      );

      final DateTime now = DateTime.now();
      final planToUpdate = plan.copyWith(updatedAt: now);

      final data = planToUpdate.toJson();
      
      // Eliminar el ID del JSON (no se actualiza en Firestore)
      data.remove('id');
      
      await _getPlansCollection(academyId).doc(planId).update(data);
      
      // Asegurar que el plan retornado tenga el ID correcto y el updatedAt actualizado
      final updatedPlan = planToUpdate.copyWith(id: planId);

      return Right(updatedPlan);
    } catch (e, stack) {
      AppLogger.logError(
        message: 'Error al actualizar plan de suscripción',
        error: e,
        stackTrace: stack,
        className: _className,
        functionName: 'updateSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubscriptionPlan(
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

      await _getPlansCollection(academyId).doc(planId).delete();

      return const Right(null);
    } catch (e, stack) {
      AppLogger.logError(
        message: 'Error al eliminar plan de suscripción',
        error: e,
        stackTrace: stack,
        className: _className,
        functionName: 'deleteSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> assignPlanToUser(
    String academyId,
    String userId,
    String planId,
    DateTime startDate,
  ) async {
    try {
      AppLogger.logInfo(
        'Asignando plan de suscripción a usuario',
        className: _className,
        functionName: 'assignPlanToUser',
        params: {
          'academyId': academyId,
          'userId': userId,
          'planId': planId,
          'startDate': startDate.toIso8601String(),
        },
      );

      // Obtener el plan para calcular la fecha de próximo pago
      final planResult = await getSubscriptionPlan(academyId, planId);
      
      return planResult.fold(
        (failure) => Left(failure),
        (plan) async {
          // Calcular fecha de próximo pago
          final durationInDays = plan.durationInDays;
          final nextPaymentDate = startDate.add(Duration(days: durationInDays));
          final remainingDays = nextPaymentDate.difference(DateTime.now()).inDays;
          
          // Datos a actualizar en el perfil de usuario
          final clientData = {
            'clientData': {
              'subscriptionPlanId': planId,
              'paymentStatus': 'active', // Marcar como activo al asignar plan
              'lastPaymentDate': Timestamp.fromDate(startDate),
              'nextPaymentDate': Timestamp.fromDate(nextPaymentDate),
              'remainingDays': remainingDays,
            }
          };
          
          // Actualizar el perfil de usuario
          await _getUsersCollection(academyId).doc(userId).update(clientData);
          
          return const Right(null);
        },
      );
    } catch (e, stack) {
      AppLogger.logError(
        message: 'Error al asignar plan de suscripción',
        error: e,
        stackTrace: stack,
        className: _className,
        functionName: 'assignPlanToUser',
        params: {'academyId': academyId, 'userId': userId, 'planId': planId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel?>> getUserPlan(
    String academyId,
    String userId,
  ) async {
    try {
      AppLogger.logInfo(
        'Obteniendo plan de suscripción de usuario',
        className: _className,
        functionName: 'getUserPlan',
        params: {'academyId': academyId, 'userId': userId},
      );

      // Obtener datos del usuario
      final userDoc = await _getUsersCollection(academyId).doc(userId).get();
      
      if (!userDoc.exists) {
        return Left(const Failure.notFound(message: 'Usuario no encontrado'));
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final clientData = userData['clientData'] as Map<String, dynamic>?;
      
      if (clientData == null || !clientData.containsKey('subscriptionPlanId')) {
        return const Right(null); // Usuario no tiene plan asignado
      }
      
      final planId = clientData['subscriptionPlanId'] as String;
      
      // Obtener el plan con el ID obtenido
      return getSubscriptionPlan(academyId, planId);
    } catch (e, stack) {
      AppLogger.logError(
        message: 'Error al obtener plan de usuario',
        error: e,
        stackTrace: stack,
        className: _className,
        functionName: 'getUserPlan',
        params: {'academyId': academyId, 'userId': userId},
      );
      return Left(Failure.unexpectedError(error: e));
    }
  }
} 