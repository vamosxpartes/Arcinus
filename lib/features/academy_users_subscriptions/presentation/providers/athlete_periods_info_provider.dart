import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/period_providers.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/services/athlete_periods_helper.dart';
import 'package:arcinus/features/academy_users/presentation/providers/academy_member_provider.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Información completa de un atleta: datos básicos + información de períodos calculada
class AthleteCompleteInfo {
  final AcademyMemberUserModel clientUser;
  final AthletePeriodsInfo periodsInfo;
  
  const AthleteCompleteInfo({
    required this.clientUser,
    required this.periodsInfo,
  });
  
  // Propiedades derivadas para fácil acceso
  String get userId => clientUser.userId;
  String get academyId => clientUser.academyId;
  bool get isActive => periodsInfo.hasActivePlan;
  int get remainingDays => periodsInfo.totalRemainingDays;
  DateTime? get nextPaymentDate => periodsInfo.nextPaymentDate;
  DateTime? get lastPaymentDate => periodsInfo.lastPaymentDate;
  bool get hasActivePlan => periodsInfo.hasActivePlan;
  double get totalValue => periodsInfo.totalValue;
  String? get currentSubscriptionPlanId => AthletePeriodsHelper.getCurrentSubscriptionPlanId(periodsInfo.allPeriods);
  
  /// Determina el estado de pago actual basado en períodos
  String get calculatedPaymentStatus => AthletePeriodsHelper.determinePaymentStatusFromPeriods(periodsInfo.allPeriods);
}

/// Provider que combina información del cliente con períodos calculados
final athleteCompleteInfoProvider = FutureProvider.family<AthleteCompleteInfo, ({String academyId, String athleteId})>((ref, params) async {
  try {
    AppLogger.logInfo(
      'Obteniendo información completa del atleta',
      className: 'athleteCompleteInfoProvider',
      params: {
        'academyId': params.academyId,
        'athleteId': params.athleteId,
      },
    );
    
    // Obtener datos del cliente básicos
    final clientUser = await ref.read(academyMemberProvider(params.athleteId).future);
    
    if (clientUser == null) {
      throw Exception('Usuario cliente no encontrado');
    }
    
    // Obtener períodos activos del atleta
    final periods = await ref.read(athleteActivePeriodsProvider((
      academyId: params.academyId,
      athleteId: params.athleteId,
    )).future);
    
    // Calcular información de períodos
    final periodsInfo = AthletePeriodsHelper.calculatePeriodsInfo(periods);
    
    final result = AthleteCompleteInfo(
      clientUser: clientUser,
      periodsInfo: periodsInfo,
    );
    
    AppLogger.logInfo(
      'Información completa del atleta obtenida',
      className: 'athleteCompleteInfoProvider',
      params: {
        'athleteId': params.athleteId,
        'hasActivePlan': result.hasActivePlan,
        'remainingDays': result.remainingDays,
        'activePeriods': result.periodsInfo.activePeriodsCount,
        'totalValue': result.totalValue,
      },
    );
    
    return result;
    
  } catch (e) {
    AppLogger.logError(
      message: 'Error al obtener información completa del atleta',
      error: e,
      className: 'athleteCompleteInfoProvider',
    );
    rethrow;
  }
});

/// Provider optimizado para obtener solo los días restantes
final athleteRemainingDaysProvider = FutureProvider.family<int, ({String academyId, String athleteId})>((ref, params) async {
  final periods = await ref.read(athleteActivePeriodsProvider((
    academyId: params.academyId,
    athleteId: params.athleteId,
  )).future);
  
  return AthletePeriodsHelper.calculateRemainingDays(periods);
});

/// Provider optimizado para obtener solo la próxima fecha de pago
final athleteNextPaymentDateProvider = FutureProvider.family<DateTime?, ({String academyId, String athleteId})>((ref, params) async {
  final periods = await ref.read(athleteActivePeriodsProvider((
    academyId: params.academyId,
    athleteId: params.athleteId,
  )).future);
  
  return AthletePeriodsHelper.calculateNextPaymentDate(periods);
});

/// Provider optimizado para verificar si tiene plan activo
final athleteHasActivePlanProvider = FutureProvider.family<bool, ({String academyId, String athleteId})>((ref, params) async {
  final periods = await ref.read(athleteActivePeriodsProvider((
    academyId: params.academyId,
    athleteId: params.athleteId,
  )).future);
  
  return AthletePeriodsHelper.hasActivePlan(periods);
}); 