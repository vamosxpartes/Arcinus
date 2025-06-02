import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:arcinus/features/academy_users_subscriptions/domain/services/athlete_periods_helper.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';
import 'package:fpdart/fpdart.dart';

// Abstracciones de los repositorios necesarios
abstract class ClientUserRepository {
  Future<Either<Failure, List<AcademyMemberUserModel>>> getClientUsers(
    String academyId, {
    dynamic clientType,
    PaymentStatus? paymentStatus,
  });
  
  Future<Either<Failure, bool>> updateClientUserPaymentStatus(
    String academyId,
    String userId,
    PaymentStatus newStatus,
  );
}

// Abstracción para el repositorio de períodos
abstract class PeriodRepository {
  Future<Either<Failure, List<SubscriptionAssignmentModel>>> getAthleteActivePeriods(
    String academyId,
    String athleteId,
  );
}

// Define una clase básica de academia para el servicio
class AcademyModel {
  final String? id;
  AcademyModel({this.id});
}

abstract class AcademyRepository {
  Future<Either<Failure, List<AcademyModel>>> getAcademies();
}

/// Servicio para gestionar y verificar el estado de pago de los usuarios
class PaymentStatusService {
  static const String _className = 'PaymentStatusService';
  final ClientUserRepository _clientUserRepository;
  final PeriodRepository _periodRepository;
  
  PaymentStatusService(
    this._clientUserRepository,
    this._periodRepository,
  );
  
  /// Verifica y actualiza los estados de pago de todos los usuarios de una academia
  Future<void> verifyPaymentStatuses(String academyId) async {
    AppLogger.logInfo(
      'Verificando estados de pago de usuarios',
      className: _className,
      functionName: 'verifyPaymentStatuses',
      params: {'academyId': academyId},
    );
    
    final today = DateTime.now();
    
    // Obtener todos los usuarios clientes
    final clientUsersResult = await _clientUserRepository.getClientUsers(academyId);
    
    clientUsersResult.fold(
      (failure) => AppLogger.logError(
        message: 'Error al obtener usuarios para verificación de pagos', 
        error: failure,
        className: _className,
        functionName: 'verifyPaymentStatuses'
      ),
      (clientUsers) async {
        AppLogger.logInfo(
          'Procesando ${clientUsers.length} usuarios para verificación de pagos',
          className: _className,
          functionName: 'verifyPaymentStatuses',
        );
        
        for (final user in clientUsers) {
          // Obtener períodos activos del atleta para calcular información de pago
          final periodsResult = await _periodRepository.getAthleteActivePeriods(
            academyId,
            user.userId,
          );
          
          await periodsResult.fold(
            (failure) async {
              AppLogger.logError(
                message: 'Error al obtener períodos del atleta ${user.userId}',
                error: failure,
                className: _className,
                functionName: 'verifyPaymentStatuses',
              );
              // Si no se pueden obtener períodos, marcar como inactivo si no lo está ya
              if (user.paymentStatus != PaymentStatus.inactive) {
                await _updateUserPaymentStatus(user, PaymentStatus.inactive);
              }
            },
            (periods) async {
              // Usar AthletePeriodsHelper para calcular información de pago
              final nextPaymentDate = AthletePeriodsHelper.calculateNextPaymentDate(periods);
              
              // Caso 1: Sin fecha de próximo pago - marcar como inactivo
              if (nextPaymentDate == null) {
                if (user.paymentStatus != PaymentStatus.inactive) {
                  await _updateUserPaymentStatus(user, PaymentStatus.inactive);
                }
                return;
              }
              
              // Caso 2: Próximo pago vencido - marcar en mora
              if (nextPaymentDate.isBefore(today)) {
                if (user.paymentStatus != PaymentStatus.overdue) {
                  await _updateUserPaymentStatus(user, PaymentStatus.overdue);
                }
                return;
              }
              
              // Caso 3: Próximo pago futuro pero estado incorrecto - corregir a activo
              if (user.paymentStatus != PaymentStatus.active) {
                await _updateUserPaymentStatus(user, PaymentStatus.active);
              }
            },
          );
        }
      }
    );
  }
  
  /// Actualiza el estado de pago de un usuario específico
  Future<void> _updateUserPaymentStatus(AcademyMemberUserModel user, PaymentStatus newStatus) async {
    AppLogger.logInfo(
      'Actualizando estado de pago de usuario ${user.id} a ${newStatus.name}',
      className: _className,
      functionName: '_updateUserPaymentStatus',
      params: {
        'userId': user.id,
        'oldStatus': user.paymentStatus.name,
        'newStatus': newStatus.name,
      },
    );
    
    final result = await _clientUserRepository.updateClientUserPaymentStatus(
      user.academyId, 
      user.userId, 
      newStatus
    );
    
    result.fold(
      (failure) => AppLogger.logError(
        message: 'Error al actualizar estado de pago del usuario',
        error: failure,
        className: _className,
        functionName: '_updateUserPaymentStatus',
        params: {'userId': user.id, 'academyId': user.academyId},
      ),
      (_) => AppLogger.logInfo(
        'Estado de pago actualizado correctamente',
        className: _className,
        functionName: '_updateUserPaymentStatus',
        params: {'userId': user.id, 'newStatus': newStatus.name},
      )
    );
  }
  
  /// Método para ejecutar la verificación en todas las academias
  static Future<void> verifyAllAcademies(
    ClientUserRepository clientUserRepository,
    PeriodRepository periodRepository,
    AcademyRepository academyRepository
  ) async {
    AppLogger.logInfo(
      'Iniciando verificación de estados de pago en todas las academias',
      className: _className,
      functionName: 'verifyAllAcademies',
    );
    
    final service = PaymentStatusService(clientUserRepository, periodRepository);
    
    // Obtener todas las academias activas
    final academiesResult = await academyRepository.getAcademies();
    
    academiesResult.fold(
      (failure) => AppLogger.logError(
        message: 'Error al obtener academias para verificación',
        error: failure,
        className: _className,
        functionName: 'verifyAllAcademies',
      ),
      (academies) async {
        for (final academy in academies) {
          if (academy.id != null) {
            await service.verifyPaymentStatuses(academy.id!);
          }
        }
        
        AppLogger.logInfo(
          'Verificación de pagos completada para todas las academias',
          className: _className,
          functionName: 'verifyAllAcademies',
        );
      }
    );
  }
} 