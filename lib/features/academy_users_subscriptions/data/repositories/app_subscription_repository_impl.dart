import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/app_subscription_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_subscription_repository_impl.g.dart';

/// Implementación de [AppSubscriptionRepository] usando Firestore.
class AppSubscriptionRepositoryImpl implements AppSubscriptionRepository {
  final FirebaseFirestore _firestore;
  final AcademyRepository _academyRepository;
  
  late final CollectionReference _plansCollection;
  late final CollectionReference _subscriptionsCollection;

  AppSubscriptionRepositoryImpl(this._firestore, this._academyRepository) {
    _plansCollection = _firestore.collection('plans');
    _subscriptionsCollection = _firestore.collection('subscriptions');
  }

  @override
  Future<Either<Failure, List<AppSubscriptionPlanModel>>> getAvailablePlans({
    bool activeOnly = true,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _plansCollection as Query<Map<String, dynamic>>;
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      
      final plans = snapshot.docs.map((doc) {
        final data = doc.data();
        return AppSubscriptionPlanModel.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
      
      return right(plans);
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, AppSubscriptionPlanModel>> getPlan(String planId) async {
    try {
      final docSnapshot = await _plansCollection.doc(planId).get();
      
      if (!docSnapshot.exists) {
        return left(const Failure.notFound(message: 'Plan no encontrado'));
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      final plan = AppSubscriptionPlanModel.fromJson({
        ...data,
        'id': docSnapshot.id,
      });
      
      return right(plan);
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, AppSubscriptionModel?>> getOwnerSubscription(String ownerId) async {
    try {
      // Buscar suscripción por ownerId y que esté activa
      final querySnapshot = await _subscriptionsCollection
          .where('ownerId', isEqualTo: ownerId)
          .where('status', isEqualTo: 'active')
          .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return right(null); // No hay suscripción activa
      }
      
      final doc = querySnapshot.docs.first;
      final subscriptionData = doc.data() as Map<String, dynamic>;
      
      // Obtener el plan asociado
      final planId = subscriptionData['planId'] as String;
      final planResult = await getPlan(planId);
      
      return planResult.fold(
        (failure) => left(failure),
        (plan) {
          final subscription = AppSubscriptionModel.fromJson({
            ...subscriptionData,
            'id': doc.id,
          }).copyWith(plan: plan);
          
          return right(subscription);
        },
      );
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, AppSubscriptionModel>> createSubscription(
    String ownerId, 
    String planId,
    DateTime startDate,
  ) async {
    try {
      // Primero verificar que el plan existe
      final planResult = await getPlan(planId);
      
      return planResult.fold(
        (failure) => left(failure),
        (plan) async {
          // Calcular fecha de fin según el ciclo de facturación
          final endDate = _calculateEndDate(startDate, plan.billingCycle);
          
          // Crear nueva suscripción
          final subscriptionData = {
            'ownerId': ownerId,
            'planId': planId,
            'status': 'active',
            'startDate': startDate,
            'endDate': endDate,
            'lastPaymentDate': startDate,
            'nextPaymentDate': endDate,
            'academyIds': <String>[],
            'currentAcademyCount': 0,
            'totalUserCount': 0,
            'paymentHistory': {},
            'metadata': {},
          };
          
          final docRef = await _subscriptionsCollection.add(subscriptionData);
          
          // Crear modelo con plan incluido
          final subscription = AppSubscriptionModel.fromJson({
            ...subscriptionData,
            'id': docRef.id,
          }).copyWith(plan: plan);
          
          return right(subscription);
        },
      );
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, AppSubscriptionModel>> updateSubscription(
    String subscriptionId, 
    Map<String, dynamic> data,
  ) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).update(data);
      
      // Obtener la suscripción actualizada
      final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
      
      if (!docSnapshot.exists) {
        return left(const Failure.notFound(message: 'Suscripción no encontrada'));
      }
      
      final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
      
      // Obtener el plan asociado
      final planId = subscriptionData['planId'] as String;
      final planResult = await getPlan(planId);
      
      return planResult.fold(
        (failure) => left(failure),
        (plan) {
          final subscription = AppSubscriptionModel.fromJson({
            ...subscriptionData,
            'id': docSnapshot.id,
          }).copyWith(plan: plan);
          
          return right(subscription);
        },
      );
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, AppSubscriptionModel>> changePlan(
    String subscriptionId, 
    String newPlanId,
  ) async {
    try {
      // Obtener el nuevo plan
      final planResult = await getPlan(newPlanId);
      
      return planResult.fold(
        (failure) => left(failure),
        (plan) async {
          // Actualizar la suscripción con el nuevo plan
          await _subscriptionsCollection.doc(subscriptionId).update({
            'planId': newPlanId,
            // Podríamos recalcular fechas aquí si es necesario
          });
          
          // Obtener la suscripción actualizada
          final docSnapshot = await _subscriptionsCollection.doc(subscriptionId).get();
          
          if (!docSnapshot.exists) {
            return left(const Failure.notFound(message: 'Suscripción no encontrada'));
          }
          
          final subscriptionData = docSnapshot.data() as Map<String, dynamic>;
          
          // Crear modelo actualizado
          final subscription = AppSubscriptionModel.fromJson({
            ...subscriptionData,
            'id': docSnapshot.id,
          }).copyWith(plan: plan);
          
          return right(subscription);
        },
      );
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, bool>> canCreateMoreAcademies(String ownerId) async {
    try {
      // Obtener la suscripción del propietario
      final subscriptionResult = await getOwnerSubscription(ownerId);
      
      return subscriptionResult.fold(
        (failure) => left(failure),
        (subscription) {
          if (subscription == null) {
            return right(false); // Sin suscripción activa, no puede crear academias
          }
          
          final plan = subscription.plan;
          if (plan == null) {
            return right(false); // Sin plan definido, no puede crear academias
          }
          
          // Verificar si puede crear más academias
          return right(subscription.currentAcademyCount < plan.maxAcademies);
        },
      );
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> linkAcademyToSubscription(
    String subscriptionId, 
    String academyId,
  ) async {
    try {
      // Actualizar la suscripción añadiendo la academia a la lista
      await _subscriptionsCollection.doc(subscriptionId).update({
        'academyIds': FieldValue.arrayUnion([academyId]),
        'currentAcademyCount': FieldValue.increment(1),
      });
      
      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> unlinkAcademyFromSubscription(
    String subscriptionId, 
    String academyId,
  ) async {
    try {
      // Actualizar la suscripción eliminando la academia de la lista
      await _subscriptionsCollection.doc(subscriptionId).update({
        'academyIds': FieldValue.arrayRemove([academyId]),
        'currentAcademyCount': FieldValue.increment(-1),
      });
      
      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, bool>> canAddMoreUsers(
    String academyId, 
    int count,
  ) async {
    try {
      // Obtener la academia para saber quién es el propietario
      final academyResult = await _academyRepository.getAcademyById(academyId);
      
      return academyResult.fold(
        (failure) => left(failure),
        (academy) async {
          final ownerId = academy.ownerId;
          final subscriptionResult = await getOwnerSubscription(ownerId);
          
          return subscriptionResult.fold(
            (failure) => left(failure),
            (subscription) {
              if (subscription == null) {
                return right(false); // Sin suscripción activa, no puede añadir usuarios
              }
              
              final plan = subscription.plan;
              if (plan == null) {
                return right(false); // Sin plan definido, no puede añadir usuarios
              }
              
              // Verificar si puede añadir más usuarios
              final currentUsers = subscription.totalUserCount;
              return right(currentUsers + count <= plan.maxUsersPerAcademy);
            },
          );
        },
      );
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, bool>> isFeatureAvailable(
    String academyId, 
    AppFeature feature,
  ) async {
    try {
      // Obtener la academia para saber quién es el propietario
      final academyResult = await _academyRepository.getAcademyById(academyId);
      
      return academyResult.fold(
        (failure) => left(failure),
        (academy) async {
          final ownerId = academy.ownerId;
          final subscriptionResult = await getOwnerSubscription(ownerId);
          
          return subscriptionResult.fold(
            (failure) => left(failure),
            (subscription) {
              if (subscription == null) {
                return right(false); // Sin suscripción activa, no tiene características
              }
              
              final plan = subscription.plan;
              if (plan == null) {
                return right(false); // Sin plan definido, no tiene características
              }
              
              // Verificar si la característica está disponible
              return right(plan.features.contains(feature));
            },
          );
        },
      );
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, AppSubscriptionPlanModel>> createPlan(
    AppSubscriptionPlanModel plan,
  ) async {
    try {
      final planData = plan.toJson();
      
      final docRef = await _plansCollection.add(planData);
      
      final createdPlan = plan.copyWith(id: docRef.id);
      
      return right(createdPlan);
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, AppSubscriptionPlanModel>> updatePlan(
    String planId,
    AppSubscriptionPlanModel plan,
  ) async {
    try {
      final planData = plan.toJson();
      
      await _plansCollection.doc(planId).update(planData);
      
      final updatedPlan = plan.copyWith(id: planId);
      
      return right(updatedPlan);
    } on FirebaseException catch (e) {
      return left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return left(Failure.unexpectedError(error: e));
    }
  }
  
  // Método auxiliar para calcular la fecha de fin según el ciclo de facturación
  DateTime _calculateEndDate(DateTime startDate, BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return startDate.add(const Duration(days: 30));
      case BillingCycle.quarterly:
        return startDate.add(const Duration(days: 90));
      case BillingCycle.biannual:
        return startDate.add(const Duration(days: 180));
      case BillingCycle.annual:
        return startDate.add(const Duration(days: 365));
      // ignore: unreachable_switch_default
      default:
        return startDate.add(const Duration(days: 30)); // Por defecto mensual
    }
  }
}

/// Provider para la implementación del repositorio de suscripciones de la aplicación.
@riverpod
AppSubscriptionRepository appSubscriptionRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  final academyRepository = ref.watch(academyRepositoryProvider);
  return AppSubscriptionRepositoryImpl(firestore, academyRepository);
} 