import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/subscription_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que obtiene todos los planes de suscripción de una academia
final subscriptionPlansProvider = FutureProvider.family<List<SubscriptionPlanModel>, String>(
  (ref, academyId) async {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final result = await repository.getSubscriptionPlans(academyId);
    
    return result.fold(
      (failure) {
        // Si hay un error, lanzamos una excepción para que el proveedor entre en estado de error
        throw failure;
      },
      (plans) => plans,
    );
  }
);

/// Provider que obtiene planes de suscripción activos
final activeSubscriptionPlansProvider = FutureProvider.family<List<SubscriptionPlanModel>, String>(
  (ref, academyId) async {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final result = await repository.getSubscriptionPlans(academyId, activeOnly: true);
    
    return result.fold(
      (failure) => throw failure,
      (plans) => plans,
    );
  }
);

/// Provider que obtiene un plan específico por su ID
final subscriptionPlanProvider = FutureProvider.family<SubscriptionPlanModel?, ({String academyId, String planId})>(
  (ref, params) async {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final result = await repository.getSubscriptionPlan(params.academyId, params.planId);
    
    return result.fold(
      (failure) => null, // En caso de error, devolvemos null
      (plan) => plan,
    );
  }
);

/// Provider que obtiene el plan asignado a un usuario específico
final userSubscriptionPlanProvider = FutureProvider.family<SubscriptionPlanModel?, ({String academyId, String userId})>(
  (ref, params) async {
    final repository = ref.watch(subscriptionRepositoryProvider);
    final result = await repository.getUserPlan(params.academyId, params.userId);
    
    return result.fold(
      (failure) => null, // En caso de error, devolvemos null
      (plan) => plan,
    );
  }
); 