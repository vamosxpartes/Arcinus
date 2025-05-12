// import 'package:arcinus/core/error/exceptions.dart'; // Eliminado temporalmente
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_model.dart';
import 'package:arcinus/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/providers/firebase_providers.dart';

part 'subscription_repository_impl.g.dart';

/// Implementación de [SubscriptionRepository] usando Firestore.
/// NOTA: Esta implementación está deprecated y será reemplazada por la ubicada en domain/repositories/subscription_repository_impl.dart
/// Mantiene solo los métodos originales por compatibilidad
@Deprecated('Use la implementación ubicada en domain/repositories/subscription_repository_impl.dart')
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  static const String _className = 'SubscriptionRepositoryImpl';
  
  final FirebaseFirestore _firestore;
  late final CollectionReference _subscriptionsCollection;

  SubscriptionRepositoryImpl(this._firestore) {
    _subscriptionsCollection = _firestore.collection('subscriptions');
    AppLogger.logInfo(
      'Inicializado SubscriptionRepositoryImpl',
      className: _className,
      functionName: 'constructor',
    );
  }
  
  // Referencia a la colección de planes de suscripción
  CollectionReference _getPlansCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('subscription_plans');
  }

  // Referencia a la colección de usuarios
  CollectionReference _getUsersCollection(String academyId) {
    return _firestore.collection('academies').doc(academyId).collection('users');
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
      
      // Usamos directamente el modelo pasado, asumiendo que ya tiene los datos correctos.
      // Freezed se encarga de la serialización (sin el campo 'id').
      final dataToAdd = subscription.toJson();

      await _subscriptionsCollection.add(dataToAdd);

      AppLogger.logInfo(
        'Suscripción inicial creada exitosamente',
        className: _className,
        functionName: 'createInitialSubscription',
        params: {'academyId': subscription.academyId},
      );
      
      // No necesitamos devolver el modelo, solo indicar éxito.
      return const Right(null); // null representa void en este contexto
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firestore al crear suscripción inicial',
        error: e,
        className: _className,
        functionName: 'createInitialSubscription',
        params: {'code': e.code, 'message': e.message, 'academyId': subscription.academyId},
      );
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
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
        ServerFailure(message: 'Error inesperado creando suscripción: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionModel?>> getActiveSubscription(
    String academyId, // Cambio: Aceptar String academyId
  ) async {
    try {
      AppLogger.logInfo(
        'Buscando suscripción activa',
        className: _className,
        functionName: 'getActiveSubscription',
        params: {'academyId': academyId},
      );
      
      final querySnapshot = await _subscriptionsCollection
          .where('academyId', isEqualTo: academyId)
          // Usar el valor String directamente para la comparación
          .where('status', whereIn: [SubscriptionStatus.active.name, SubscriptionStatus.trial.name]) // Permitir active o trial
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
      final subscriptionData = doc.data()! as Map<String, dynamic>;
      
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
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener suscripción activa',
        error: e,
        className: _className,
        functionName: 'getActiveSubscription',
        params: {'academyId': academyId, 'code': e.code, 'message': e.message},
      );
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
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
        ServerFailure(message: 'Error inesperado obteniendo suscripción: $e'),
      );
    }
  }
  
  // Implementación de los métodos restantes delegando al repositorio principal
  
  @override
  Future<Either<Failure, List<SubscriptionPlanModel>>> getSubscriptionPlans(
    String academyId, {
    bool activeOnly = false,
  }) async {
    try {
      final plansCollection = _getPlansCollection(academyId);
      Query query = plansCollection;
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      
      final plans = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionPlanModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
      
      return Right(plans);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener planes de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getSubscriptionPlans',
        params: {'academyId': academyId},
      );
      return Left(ServerFailure(message: 'Error obteniendo planes: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> getSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    try {
      final docRef = _getPlansCollection(academyId).doc(planId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        return Left(ServerFailure(message: 'Plan no encontrado'));
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final plan = SubscriptionPlanModel.fromJson({
        ...data,
        'id': doc.id,
      });
      
      return Right(plan);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return Left(ServerFailure(message: 'Error obteniendo plan: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> createSubscriptionPlan(
    String academyId,
    SubscriptionPlanModel plan,
  ) async {
    try {
      final plansCollection = _getPlansCollection(academyId);
      final planData = plan.toJson();
      
      // Eliminar ID si existe
      planData.remove('id');
      
      final docRef = await plansCollection.add(planData);
      final createdPlan = plan.copyWith(id: docRef.id);
      
      return Right(createdPlan);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createSubscriptionPlan',
        params: {'academyId': academyId},
      );
      return Left(ServerFailure(message: 'Error creando plan: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> updateSubscriptionPlan(
    String academyId,
    String planId,
    SubscriptionPlanModel plan,
  ) async {
    try {
      final docRef = _getPlansCollection(academyId).doc(planId);
      final planData = plan.toJson();
      
      // Eliminar ID si existe
      planData.remove('id');
      
      await docRef.update(planData);
      final updatedPlan = plan.copyWith(id: planId);
      
      return Right(updatedPlan);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al actualizar plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return Left(ServerFailure(message: 'Error actualizando plan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    try {
      final docRef = _getPlansCollection(academyId).doc(planId);
      await docRef.delete();
      
      return const Right(null);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al eliminar plan de suscripción',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'deleteSubscriptionPlan',
        params: {'academyId': academyId, 'planId': planId},
      );
      return Left(ServerFailure(message: 'Error eliminando plan: $e'));
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
      // Obtener el plan
      final planResult = await getSubscriptionPlan(academyId, planId);
      
      return planResult.fold(
        (failure) => Left(failure),
        (plan) async {
          // Asignar el plan al usuario
          final userRef = _getUsersCollection(academyId).doc(userId);
          
          await userRef.update({
            'subscriptionPlanId': planId,
            'subscriptionStartDate': startDate,
            // Podríamos calcular la fecha de fin basada en el plan
          });
          
          return const Right(null);
        }
      );
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al asignar plan a usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'assignPlanToUser',
        params: {'academyId': academyId, 'userId': userId, 'planId': planId},
      );
      return Left(ServerFailure(message: 'Error asignando plan: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel?>> getUserPlan(
    String academyId,
    String userId,
  ) async {
    try {
      final userRef = _getUsersCollection(academyId).doc(userId);
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        return const Right(null); // Usuario no encontrado
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final planId = userData['subscriptionPlanId'] as String?;
      
      if (planId == null) {
        return const Right(null); // No tiene plan asignado
      }
      
      // Obtener el plan
      return getSubscriptionPlan(academyId, planId);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al obtener plan de usuario',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getUserPlan',
        params: {'academyId': academyId, 'userId': userId},
      );
      return Left(ServerFailure(message: 'Error obteniendo plan de usuario: $e'));
    }
  }
}

/// Provider para la implementación del repositorio de suscripciones.
@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) {
  AppLogger.logInfo(
    'Creando instancia de SubscriptionRepository',
    className: 'subscription_repository',
    functionName: 'subscriptionRepository',
  );
  
  // Crear una instancia directamente en lugar de usar otro provider
  final firestore = ref.watch(firestoreProvider);
  return SubscriptionRepositoryImpl(firestore);
}
