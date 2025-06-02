import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/subscriptions/domain/repositories/period_repository.dart';
import 'package:arcinus/features/subscriptions/data/repositories/period_repository_impl.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_assignment_model.dart';

/// Provider para el repositorio de períodos
final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  return PeriodRepositoryImpl(FirebaseFirestore.instance);
});

/// Provider para obtener los períodos activos de un atleta
final athleteActivePeriodsProvider = FutureProvider.family<List<SubscriptionAssignmentModel>, ({String academyId, String athleteId})>((ref, params) async {
  final repository = ref.read(periodRepositoryProvider);
  final result = await repository.getActivePeriods(params.academyId, params.athleteId);
  
  return result.fold(
    (failure) => throw Exception('Error al cargar períodos: ${failure.message}'),
    (periods) => periods,
  );
});

/// Provider para obtener el período actual de un atleta
final athleteCurrentPeriodProvider = FutureProvider.family<SubscriptionAssignmentModel?, ({String academyId, String athleteId})>((ref, params) async {
  final repository = ref.read(periodRepositoryProvider);
  final result = await repository.getCurrentPeriod(params.academyId, params.athleteId);
  
  return result.fold(
    (failure) => throw Exception('Error al cargar período actual: ${failure.message}'),
    (period) => period,
  );
});

/// Provider para obtener todos los períodos de un atleta
final athletePeriodsProvider = FutureProvider.family<List<SubscriptionAssignmentModel>, ({String academyId, String athleteId, SubscriptionAssignmentStatus? status})>((ref, params) async {
  final repository = ref.read(periodRepositoryProvider);
  final result = await repository.getAthletesPeriods(
    params.academyId, 
    params.athleteId,
    status: params.status,
  );
  
  return result.fold(
    (failure) => throw Exception('Error al cargar períodos: ${failure.message}'),
    (periods) => periods,
  );
}); 