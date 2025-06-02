import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/users/data/models/client_user_model.dart';
import 'package:arcinus/features/users/data/models/payment_status.dart';
import 'package:arcinus/features/subscriptions/data/models/subscription_plan_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz para el repositorio de usuarios cliente
/// MIGRACIÓN: Los campos de suscripción específicos se manejan ahora por separado con períodos
/// Los planes de suscripción se gestionan en un repositorio separado
abstract class ClientUserRepository {
  /// Obtiene un usuario cliente por su ID
  /// Retorna null si el usuario no existe o no es un cliente (atleta/padre)
  Future<Either<Failure, ClientUserModel?>> getClientUser(
    String academyId,
    String userId,
  );
  
  /// Obtiene todos los usuarios cliente de una academia, con filtros opcionales
  Future<Either<Failure, List<ClientUserModel>>> getClientUsers(
    String academyId, {
    AppRole? clientType,
    PaymentStatus? paymentStatus,
  });
  
  /// Actualiza los datos generales de un usuario cliente (metadatos, cuentas vinculadas, etc.)
  /// MIGRACIÓN: Ya no maneja fechas ni información específica de suscripción
  Future<Either<Failure, bool>> updateClientUser(
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
  Future<Either<Failure, bool>> updateClientUserPaymentStatus(
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
