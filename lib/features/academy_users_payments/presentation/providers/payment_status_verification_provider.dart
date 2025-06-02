import 'package:arcinus/features/academy_users_payments/domain/services/payment_status_service.dart' as payment_service;
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:arcinus/features/academy_users/domain/repositories/academy_member_repository_impl.dart';
import 'package:arcinus/features/academy_users_payments/domain/repositories/academy_member_repository.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/core/providers/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/features/academy_users_subscriptions/presentation/providers/period_providers.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/repositories/period_repository.dart';

part 'payment_status_verification_provider.g.dart';

/// Provider para gestionar la verificación de estados de pago
///
/// Se ejecuta automáticamente al iniciar la aplicación, pero también
/// puede ejecutarse manualmente cuando sea necesario
@riverpod
class PaymentStatusVerification extends _$PaymentStatusVerification {
  @override
  Future<bool> build() async {
    return _verifyPaymentStatuses();
  }

  /// Inicia una verificación manual de estados de pago
  Future<bool> verifyNow() async {
    state = const AsyncValue.loading();
    return _verifyPaymentStatuses();
  }

  Future<bool> _verifyPaymentStatuses() async {
    try {
      AppLogger.logInfo(
        'Iniciando verificación de estados de pago',
        className: 'PaymentStatusVerification',
        functionName: '_verifyPaymentStatuses',
      );

      // Obtener instancias de repositorios necesarios
      final academyMemberRepo = ref.read(academyMemberRepositoryProvider);
      final academyRepo = ref.read(academyRepositoryProvider);
      final periodRepo = ref.read(periodRepositoryProvider);
      
      // Crear adaptadores para los repositorios
      final memberAdapter = _MemberAdapter(academyMemberRepo);
      final academyAdapter = _AcademyAdapter(academyRepo, ref);
      final periodAdapter = _PeriodAdapter(periodRepo);

      // Ejecutar verificación en todas las academias
      await payment_service.PaymentStatusService.verifyAllAcademies(
        memberAdapter,
        periodAdapter,
        academyAdapter,
      );

      AppLogger.logInfo(
        'Verificación de estados de pago completada',
        className: 'PaymentStatusVerification',
        functionName: '_verifyPaymentStatuses',
      );

      state = const AsyncValue.data(true);
      return true;
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al verificar estados de pago',
        error: e,
        stackTrace: s,
        className: 'PaymentStatusVerification',
        functionName: '_verifyPaymentStatuses',
      );
      state = AsyncValue.error(e, s);
      return false;
    }
  }
}

/// Adaptador para el repositorio de miembros de academia
class _MemberAdapter implements payment_service.ClientUserRepository {
  final AcademyMemberRepository _repo;
  
  _MemberAdapter(this._repo);
  
  @override
  Future<Either<Failure, List<AcademyMemberUserModel>>> getClientUsers(
    String academyId, {
    dynamic clientType,
    PaymentStatus? paymentStatus,
  }) {
    return _repo.getAcademyMembers(
      academyId,
      memberType: clientType as AppRole?,
      paymentStatus: paymentStatus,
    );
  }
  
  @override
  Future<Either<Failure, bool>> updateClientUserPaymentStatus(
    String academyId,
    String userId,
    PaymentStatus newStatus,
  ) {
    return _repo.updateAcademyMemberPaymentStatus(
      academyId,
      userId,
      newStatus,
    );
  }
}

/// Adaptador para el repositorio de períodos
class _PeriodAdapter implements payment_service.PeriodRepository {
  final PeriodRepository _repo;
  
  _PeriodAdapter(this._repo);
  
  @override
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAthleteActivePeriods(
    String academyId,
    String athleteId,
  ) {
    return _repo.getActivePeriods(academyId, athleteId);
  }
}

/// Adaptador para el repositorio de academias
class _AcademyAdapter implements payment_service.AcademyRepository {
  final Ref _ref;
  
  _AcademyAdapter(_, this._ref);
  
  @override
  Future<Either<Failure, List<payment_service.AcademyModel>>> getAcademies() async {
    try {
      // Como el AcademyRepository no tiene un método getAcademies,
      // creamos una implementación basada en los providers disponibles
      // Obtenemos todas las academias del usuario actual
      final firebaseAuth = _ref.read(firebaseAuthProvider);
      final currentUser = firebaseAuth.currentUser;
      
      if (currentUser == null) {
        return const Right([]);
      }
      
      // Obtenemos las academias del propietario actual
      final ownerId = currentUser.uid;
      final academiesStream = _ref.read(ownerAcademiesProvider(ownerId));
      
      final academies = academiesStream.when(
        data: (academyList) => academyList,
        error: (_, __) => <AcademyModel>[],
        loading: () => <AcademyModel>[],
      );
      
      // Convertir modelos de academia a la clase que espera el servicio
      return Right(
        academies.map((academy) => 
          payment_service.AcademyModel(id: academy.id!)
        ).toList()
      );
    } catch (e) {
      AppLogger.logError(
        message: 'Error al obtener academias',
        error: e,
        className: '_AcademyAdapter',
        functionName: 'getAcademies',
      );
      return Left(Failure.serverError(message: 'Error al obtener academias: $e'));
    }
  }
} 