import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/app_subscription_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/app_subscription_repository.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/repositories/app_subscription_repository_impl.dart';

/// Notifier para la gestión de planes globales con Firestore
class GlobalPlansNotifier extends StateNotifier<AsyncValue<List<AppSubscriptionPlanModel>>> {
  final AppSubscriptionRepository _repository;
  List<AppSubscriptionPlanModel> _allPlans = [];

  GlobalPlansNotifier(this._repository) : super(const AsyncValue.loading());

  /// Cargar todos los planes desde Firestore
  Future<void> loadPlans() async {
    state = const AsyncValue.loading();
    
    try {
      AppLogger.logInfo(
        'Iniciando carga de planes desde Firestore',
        className: 'GlobalPlansNotifier',
        functionName: 'loadPlans',
      );

      final result = await _repository.getAvailablePlans(activeOnly: false);
      
      result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error al cargar planes: ${failure.message}',
            className: 'GlobalPlansNotifier',
            functionName: 'loadPlans',
          );
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (plans) {
          // Validar que todos los planes tengan ID válidos
          final plansWithValidIds = <AppSubscriptionPlanModel>[];
          final plansWithInvalidIds = <AppSubscriptionPlanModel>[];
          
          for (final plan in plans) {
            if (plan.id == null || plan.id!.isEmpty) {
              plansWithInvalidIds.add(plan);
              AppLogger.logWarning(
                'Plan encontrado sin ID válido: ${plan.name}',
                className: 'GlobalPlansNotifier',
                functionName: 'loadPlans',
                params: {'planName': plan.name, 'planType': plan.planType.name},
              );
            } else {
              plansWithValidIds.add(plan);
            }
          }
          
          if (plansWithInvalidIds.isNotEmpty) {
            AppLogger.logWarning(
              'Se encontraron ${plansWithInvalidIds.length} planes sin ID válido',
              className: 'GlobalPlansNotifier',
              functionName: 'loadPlans',
              params: {
                'totalPlans': plans.length,
                'validPlans': plansWithValidIds.length,
                'invalidPlans': plansWithInvalidIds.length,
              },
            );
          }
          
          _allPlans = plansWithValidIds; // Solo guardar planes con ID válidos
          state = AsyncValue.data(plansWithValidIds); // Solo mostrar planes válidos
          
          AppLogger.logInfo(
            'Planes cargados exitosamente desde Firestore: ${plansWithValidIds.length} válidos de ${plans.length} totales',
            className: 'GlobalPlansNotifier',
            functionName: 'loadPlans',
            params: {
              'totalPlanes': plans.length,
              'planesValidos': plansWithValidIds.length,
              'planesInvalidos': plansWithInvalidIds.length,
            },
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al cargar planes: $e',
        error: e,
        stackTrace: stackTrace,
        className: 'GlobalPlansNotifier',
        functionName: 'loadPlans',
      );
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }

  /// Filtrar planes según criterios
  void filterPlans({
    String? searchQuery,
    AppSubscriptionPlanType? planType,
    BillingCycle? billingCycle,
    bool? isActive,
  }) {
    List<AppSubscriptionPlanModel> filtered = List.from(_allPlans);

    // Filtrar por búsqueda de texto
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((plan) {
        return plan.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               plan.planType.displayName.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar por tipo de plan
    if (planType != null) {
      filtered = filtered.where((plan) => plan.planType == planType).toList();
    }

    // Filtrar por ciclo de facturación
    if (billingCycle != null) {
      filtered = filtered.where((plan) => plan.billingCycle == billingCycle).toList();
    }

    // Filtrar por estado activo
    if (isActive != null) {
      filtered = filtered.where((plan) => plan.isActive == isActive).toList();
    }

    state = AsyncValue.data(filtered);

    AppLogger.logInfo(
      'Planes filtrados: ${filtered.length} de ${_allPlans.length}',
      className: 'GlobalPlansNotifier',
      functionName: 'filterPlans',
      params: {
        'filteredCount': filtered.length,
        'totalCount': _allPlans.length,
        'searchQuery': searchQuery,
        'planType': planType?.name,
        'billingCycle': billingCycle?.name,
        'isActive': isActive,
      },
    );
  }

  /// Crear un nuevo plan en Firestore
  Future<bool> createPlan(AppSubscriptionPlanModel plan) async {
    try {
      AppLogger.logInfo(
        'Iniciando creación de plan en Firestore: ${plan.name}',
        className: 'GlobalPlansNotifier',
        functionName: 'createPlan',
        params: {'planName': plan.name, 'planType': plan.planType.name},
      );

      final result = await _repository.createPlan(plan);
      
      return result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error al crear plan: ${failure.message}',
            className: 'GlobalPlansNotifier',
            functionName: 'createPlan',
            params: {'planName': plan.name},
          );
          return false;
        },
        (createdPlan) {
          _allPlans.add(createdPlan);
          state = AsyncValue.data(List.from(_allPlans));
          
          AppLogger.logInfo(
            'Plan creado exitosamente en Firestore: ${createdPlan.name}',
            className: 'GlobalPlansNotifier',
            functionName: 'createPlan',
            params: {'planId': createdPlan.id, 'planName': createdPlan.name},
          );
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al crear plan: $e',
        error: e,
        stackTrace: stackTrace,
        className: 'GlobalPlansNotifier',
        functionName: 'createPlan',
        params: {'planName': plan.name},
      );
      return false;
    }
  }

  /// Actualizar un plan existente en Firestore
  Future<bool> updatePlan(String planId, AppSubscriptionPlanModel plan) async {
    try {
      AppLogger.logInfo(
        'Iniciando actualización de plan en Firestore: ${plan.name}',
        className: 'GlobalPlansNotifier',
        functionName: 'updatePlan',
        params: {'planId': planId, 'planName': plan.name},
      );

      final result = await _repository.updatePlan(planId, plan);
      
      return result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error al actualizar plan: ${failure.message}',
            className: 'GlobalPlansNotifier',
            functionName: 'updatePlan',
            params: {'planId': planId, 'planName': plan.name},
          );
          return false;
        },
        (updatedPlan) {
          final index = _allPlans.indexWhere((p) => p.id == planId);
          if (index != -1) {
            _allPlans[index] = updatedPlan;
            state = AsyncValue.data(List.from(_allPlans));
          }
          
          AppLogger.logInfo(
            'Plan actualizado exitosamente en Firestore: ${updatedPlan.name}',
            className: 'GlobalPlansNotifier',
            functionName: 'updatePlan',
            params: {'planId': updatedPlan.id, 'planName': updatedPlan.name},
          );
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al actualizar plan: $e',
        error: e,
        stackTrace: stackTrace,
        className: 'GlobalPlansNotifier',
        functionName: 'updatePlan',
        params: {'planId': planId},
      );
      return false;
    }
  }

  /// Alternar el estado activo de un plan en Firestore
  Future<bool> togglePlanStatus(String planId) async {
    try {
      final index = _allPlans.indexWhere((plan) => plan.id == planId);
      if (index == -1) {
        AppLogger.logWarning(
          'Plan no encontrado para cambiar estado: $planId',
          className: 'GlobalPlansNotifier',
          functionName: 'togglePlanStatus',
        );
        return false;
      }

      final currentPlan = _allPlans[index];
      final updatedPlan = currentPlan.copyWith(isActive: !currentPlan.isActive);

      AppLogger.logInfo(
        'Cambiando estado del plan: ${currentPlan.name} - ${currentPlan.isActive} → ${updatedPlan.isActive}',
        className: 'GlobalPlansNotifier',
        functionName: 'togglePlanStatus',
        params: {
          'planId': planId,
          'planName': currentPlan.name,
          'currentStatus': currentPlan.isActive,
          'newStatus': updatedPlan.isActive,
        },
      );

      final result = await _repository.updatePlan(planId, updatedPlan);
      
      return result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error al cambiar estado del plan: ${failure.message}',
            className: 'GlobalPlansNotifier',
            functionName: 'togglePlanStatus',
            params: {'planId': planId},
          );
          return false;
        },
        (plan) {
          _allPlans[index] = plan;
          state = AsyncValue.data(List.from(_allPlans));
          
          AppLogger.logInfo(
            'Estado del plan cambiado exitosamente: ${plan.name}',
            className: 'GlobalPlansNotifier',
            functionName: 'togglePlanStatus',
            params: {'planId': plan.id, 'newStatus': plan.isActive},
          );
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al cambiar estado del plan: $e',
        error: e,
        stackTrace: stackTrace,
        className: 'GlobalPlansNotifier',
        functionName: 'togglePlanStatus',
        params: {'planId': planId},
      );
      return false;
    }
  }

  /// Eliminar un plan de Firestore
  Future<bool> deletePlan(String planId) async {
    try {
      final planToDelete = _allPlans.firstWhere(
        (plan) => plan.id == planId,
        orElse: () => throw Exception('Plan no encontrado'),
      );

      AppLogger.logInfo(
        'Iniciando eliminación de plan: ${planToDelete.name}',
        className: 'GlobalPlansNotifier',
        functionName: 'deletePlan',
        params: {'planId': planId, 'planName': planToDelete.name},
      );

      // Desactivar el plan en lugar de eliminarlo físicamente
      final deactivatedPlan = planToDelete.copyWith(isActive: false);
      final result = await _repository.updatePlan(planId, deactivatedPlan);
      
      return result.fold(
        (failure) {
          AppLogger.logError(
            message: 'Error al desactivar plan: ${failure.message}',
            className: 'GlobalPlansNotifier',
            functionName: 'deletePlan',
            params: {'planId': planId},
          );
          return false;
        },
        (updatedPlan) {
          final index = _allPlans.indexWhere((plan) => plan.id == planId);
          if (index != -1) {
            _allPlans[index] = updatedPlan;
            state = AsyncValue.data(List.from(_allPlans));
          }
          
          AppLogger.logInfo(
            'Plan desactivado exitosamente: ${updatedPlan.name}',
            className: 'GlobalPlansNotifier',
            functionName: 'deletePlan',
            params: {'planId': updatedPlan.id, 'planName': updatedPlan.name},
          );
          return true;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error inesperado al eliminar plan: $e',
        error: e,
        stackTrace: stackTrace,
        className: 'GlobalPlansNotifier',
        functionName: 'deletePlan',
        params: {'planId': planId},
      );
      return false;
    }
  }

  /// Recargar los planes desde Firestore
  Future<void> refresh() async {
    await loadPlans();
  }
}

/// Provider principal para la gestión de planes globales con Firestore
final globalPlansProvider = StateNotifierProvider<GlobalPlansNotifier, AsyncValue<List<AppSubscriptionPlanModel>>>((ref) {
  final repository = ref.watch(appSubscriptionRepositoryProvider);
  return GlobalPlansNotifier(repository);
}); 