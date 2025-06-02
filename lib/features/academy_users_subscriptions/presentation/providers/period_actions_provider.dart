import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/period_repository.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/repositories/period_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/period_providers.dart';

/// Estados posibles para las acciones de períodos
class PeriodActionState {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;

  const PeriodActionState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  const PeriodActionState.initial() : this();
  const PeriodActionState.loading() : this(isLoading: true);
  const PeriodActionState.success(String message) : this(successMessage: message);
  const PeriodActionState.error(String message) : this(errorMessage: message);

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
}

/// Provider del repositorio de períodos
final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  return PeriodRepositoryImpl(FirebaseFirestore.instance);
});

/// Notifier para gestionar las acciones de períodos
class PeriodActionsNotifier extends StateNotifier<PeriodActionState> {
  final Ref _ref;

  PeriodActionsNotifier(this._ref) : super(const PeriodActionState.initial());

  /// Pausa un período activo
  Future<void> pausePeriod(String academyId, SubscriptionAssignmentModel period) async {
    if (period.status != SubscriptionAssignmentStatus.active) {
      state = const PeriodActionState.error('Solo se pueden pausar períodos activos');
      return;
    }

    state = const PeriodActionState.loading();

    try {
      AppLogger.logInfo(
        'Pausando período',
        className: 'PeriodActionsNotifier',
        functionName: 'pausePeriod',
        params: {
          'periodId': period.id,
          'athleteId': period.athleteId,
        },
      );

      final repository = _ref.read(periodRepositoryProvider);
      final result = await repository.updatePeriodStatus(
        academyId,
        period.id!,
        SubscriptionAssignmentStatus.paused,
      );

      result.fold(
        (failure) {
          final errorMessage = _getErrorMessage(failure);
          AppLogger.logError(
            message: 'Error al pausar período',
            error: errorMessage,
            className: 'PeriodActionsNotifier',
            functionName: 'pausePeriod',
          );
          state = PeriodActionState.error(errorMessage);
        },
        (updatedPeriod) {
          AppLogger.logInfo(
            'Período pausado exitosamente',
            className: 'PeriodActionsNotifier',
            functionName: 'pausePeriod',
            params: {'periodId': updatedPeriod.id},
          );
          state = const PeriodActionState.success('Período pausado exitosamente');
          
          // Invalidar providers relacionados
          _invalidateRelatedProviders(academyId, period.athleteId);
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error inesperado al pausar período',
        error: e,
        className: 'PeriodActionsNotifier',
        functionName: 'pausePeriod',
      );
      state = PeriodActionState.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Cancela un período futuro
  Future<void> cancelPeriod(String academyId, SubscriptionAssignmentModel period) async {
    final now = DateTime.now();
    
    if (period.startDate.isBefore(now)) {
      state = const PeriodActionState.error('No se pueden cancelar períodos que ya han iniciado');
      return;
    }

    state = const PeriodActionState.loading();

    try {
      AppLogger.logInfo(
        'Cancelando período futuro',
        className: 'PeriodActionsNotifier',
        functionName: 'cancelPeriod',
        params: {
          'periodId': period.id,
          'athleteId': period.athleteId,
        },
      );

      final repository = _ref.read(periodRepositoryProvider);
      final result = await repository.updatePeriodStatus(
        academyId,
        period.id!,
        SubscriptionAssignmentStatus.cancelled,
      );

      result.fold(
        (failure) {
          final errorMessage = _getErrorMessage(failure);
          AppLogger.logError(
            message: 'Error al cancelar período',
            error: errorMessage,
            className: 'PeriodActionsNotifier',
            functionName: 'cancelPeriod',
          );
          state = PeriodActionState.error(errorMessage);
        },
        (updatedPeriod) {
          AppLogger.logInfo(
            'Período cancelado exitosamente',
            className: 'PeriodActionsNotifier',
            functionName: 'cancelPeriod',
            params: {'periodId': updatedPeriod.id},
          );
          state = const PeriodActionState.success('Período cancelado exitosamente');
          
          // Invalidar providers relacionados
          _invalidateRelatedProviders(academyId, period.athleteId);
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error inesperado al cancelar período',
        error: e,
        className: 'PeriodActionsNotifier',
        functionName: 'cancelPeriod',
      );
      state = PeriodActionState.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Reactiva un período pausado
  Future<void> reactivatePeriod(String academyId, SubscriptionAssignmentModel period) async {
    if (period.status != SubscriptionAssignmentStatus.paused) {
      state = const PeriodActionState.error('Solo se pueden reactivar períodos pausados');
      return;
    }

    state = const PeriodActionState.loading();

    try {
      AppLogger.logInfo(
        'Reactivando período pausado',
        className: 'PeriodActionsNotifier',
        functionName: 'reactivatePeriod',
        params: {
          'periodId': period.id,
          'athleteId': period.athleteId,
        },
      );

      final repository = _ref.read(periodRepositoryProvider);
      final result = await repository.updatePeriodStatus(
        academyId,
        period.id!,
        SubscriptionAssignmentStatus.active,
      );

      result.fold(
        (failure) {
          final errorMessage = _getErrorMessage(failure);
          AppLogger.logError(
            message: 'Error al reactivar período',
            error: errorMessage,
            className: 'PeriodActionsNotifier',
            functionName: 'reactivatePeriod',
          );
          state = PeriodActionState.error(errorMessage);
        },
        (updatedPeriod) {
          AppLogger.logInfo(
            'Período reactivado exitosamente',
            className: 'PeriodActionsNotifier',
            functionName: 'reactivatePeriod',
            params: {'periodId': updatedPeriod.id},
          );
          state = const PeriodActionState.success('Período reactivado exitosamente');
          
          // Invalidar providers relacionados
          _invalidateRelatedProviders(academyId, period.athleteId);
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error inesperado al reactivar período',
        error: e,
        className: 'PeriodActionsNotifier',
        functionName: 'reactivatePeriod',
      );
      state = PeriodActionState.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Edita las fechas de un período
  Future<void> editPeriodDates(
    String academyId,
    SubscriptionAssignmentModel period,
    DateTime newStartDate,
    DateTime newEndDate, {
    String? notes,
  }) async {
    if (newStartDate.isAfter(newEndDate)) {
      state = const PeriodActionState.error('La fecha de inicio debe ser anterior a la fecha de fin');
      return;
    }

    final now = DateTime.now();
    if (period.status == SubscriptionAssignmentStatus.active && newStartDate.isAfter(now)) {
      state = const PeriodActionState.error('No se puede cambiar la fecha de inicio de un período activo a una fecha futura');
      return;
    }

    state = const PeriodActionState.loading();

    try {
      AppLogger.logInfo(
        'Editando fechas del período',
        className: 'PeriodActionsNotifier',
        functionName: 'editPeriodDates',
        params: {
          'periodId': period.id,
          'newStartDate': newStartDate.toString(),
          'newEndDate': newEndDate.toString(),
        },
      );

      final updatedPeriod = period.copyWith(
        startDate: newStartDate,
        endDate: newEndDate,
        notes: notes ?? period.notes,
        updatedAt: DateTime.now(),
      );

      final repository = _ref.read(periodRepositoryProvider);
      final result = await repository.updatePeriod(
        academyId,
        period.id!,
        updatedPeriod,
      );

      result.fold(
        (failure) {
          final errorMessage = _getErrorMessage(failure);
          AppLogger.logError(
            message: 'Error al editar período',
            error: errorMessage,
            className: 'PeriodActionsNotifier',
            functionName: 'editPeriodDates',
          );
          state = PeriodActionState.error(errorMessage);
        },
        (updatedPeriod) {
          AppLogger.logInfo(
            'Período editado exitosamente',
            className: 'PeriodActionsNotifier',
            functionName: 'editPeriodDates',
            params: {'periodId': updatedPeriod.id},
          );
          state = const PeriodActionState.success('Período editado exitosamente');
          
          // Invalidar providers relacionados
          _invalidateRelatedProviders(academyId, period.athleteId);
        },
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error inesperado al editar período',
        error: e,
        className: 'PeriodActionsNotifier',
        functionName: 'editPeriodDates',
      );
      state = PeriodActionState.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Obtiene el mensaje de error apropiado para mostrar al usuario
  String _getErrorMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    } else if (failure is ServerFailure) {
      return 'Error del servidor. Inténtalo de nuevo más tarde.';
    } else {
      return 'Ha ocurrido un error inesperado.';
    }
  }

  /// Invalida los providers relacionados después de una acción exitosa
  void _invalidateRelatedProviders(String academyId, String athleteId) {
    // Invalidar el provider de períodos activos del atleta
    _ref.invalidate(athleteActivePeriodsProvider((
      academyId: academyId,
      athleteId: athleteId,
    )));
  }

  /// Resetea el estado a inicial
  void resetState() {
    state = const PeriodActionState.initial();
  }
}

/// Provider del StateNotifier para las acciones de períodos
final periodActionsProvider = StateNotifierProvider<PeriodActionsNotifier, PeriodActionState>((ref) {
  return PeriodActionsNotifier(ref);
}); 