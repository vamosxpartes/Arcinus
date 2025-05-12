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
    // Delegamos al repositorio principal
    final mainRepository = ProviderContainer().read(subscriptionRepositoryProvider);
    return mainRepository.getSubscriptionPlans(academyId, activeOnly: activeOnly);
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> getSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    // Delegamos al repositorio principal
    final mainRepository = ProviderContainer().read(subscriptionRepositoryProvider);
    return mainRepository.getSubscriptionPlan(academyId, planId);
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> createSubscriptionPlan(
    String academyId,
    SubscriptionPlanModel plan,
  ) async {
    // Delegamos al repositorio principal
    final mainRepository = ProviderContainer().read(subscriptionRepositoryProvider);
    return mainRepository.createSubscriptionPlan(academyId, plan);
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel>> updateSubscriptionPlan(
    String academyId,
    String planId,
    SubscriptionPlanModel plan,
  ) async {
    // Delegamos al repositorio principal
    final mainRepository = ProviderContainer().read(subscriptionRepositoryProvider);
    return mainRepository.updateSubscriptionPlan(academyId, planId, plan);
  }

  @override
  Future<Either<Failure, void>> deleteSubscriptionPlan(
    String academyId,
    String planId,
  ) async {
    // Delegamos al repositorio principal
    final mainRepository = ProviderContainer().read(subscriptionRepositoryProvider);
    return mainRepository.deleteSubscriptionPlan(academyId, planId);
  }

  @override
  Future<Either<Failure, void>> assignPlanToUser(
    String academyId,
    String userId,
    String planId,
    DateTime startDate,
  ) async {
    // Delegamos al repositorio principal
    final mainRepository = ProviderContainer().read(subscriptionRepositoryProvider);
    return mainRepository.assignPlanToUser(academyId, userId, planId, startDate);
  }

  @override
  Future<Either<Failure, SubscriptionPlanModel?>> getUserPlan(
    String academyId,
    String userId,
  ) async {
    // Delegamos al repositorio principal
    final mainRepository = ProviderContainer().read(subscriptionRepositoryProvider);
    return mainRepository.getUserPlan(academyId, userId);
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
  // IMPORTANTE: Devolvemos la implementación del dominio, no esta clase
  // Para mantener compatibilidad, redirigimos a través del provider principal
  return ref.watch(subscriptionRepositoryProvider);
}
