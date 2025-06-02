import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:arcinus/features/academy_users_payments/payment_status.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz para el repositorio de miembros de academia
/// MIGRACIÓN: Los campos de suscripción específicos se manejan ahora por separado con períodos
/// Los planes de suscripción se gestionan en un repositorio separado
abstract class AcademyMemberRepository {
  /// Obtiene un miembro de academia por su ID
  /// Retorna null si el usuario no existe o no es un miembro (atleta/padre)
  Future<Either<Failure, AcademyMemberUserModel?>> getAcademyMember(
    String academyId,
    String userId,
  );
  
  /// Obtiene todos los miembros de academia de una academia, con filtros opcionales
  Future<Either<Failure, List<AcademyMemberUserModel>>> getAcademyMembers(
    String academyId, {
    AppRole? memberType,
    PaymentStatus? paymentStatus,
  });
  
  /// Actualiza los datos generales de un miembro de academia (metadatos, cuentas vinculadas, etc.)
  /// MIGRACIÓN: Ya no maneja fechas ni información específica de suscripción
  Future<Either<Failure, bool>> updateAcademyMember(
    String academyId,
    String userId,
    Map<String, dynamic> updates,
  );
  
  /// Asigna un plan de suscripción básico a un usuario
  /// MIGRACIÓN: Solo asigna referencia básica, los períodos se manejan por separado
  Future<Either<Failure, bool>> assignSubscriptionPlan(
    String academyId,
    String userId,
    String planId, {
    DateTime? startDate,
  });
  
  /// Actualiza específicamente el estado de pago de un usuario
  Future<Either<Failure, bool>> updateAcademyMemberPaymentStatus(
    String academyId,
    String userId,
    PaymentStatus newStatus,
  );

  /// Obtiene todos los planes de suscripción disponibles
  /// NOTA: Este método se mantendrá temporalmente para compatibilidad
  /// En el futuro se migrará a un repositorio específico de planes
  Future<Either<Failure, List<SubscriptionPlanModel>>> getSubscriptionPlans(
    String academyId, {
    bool activeOnly = true,
  });
}
