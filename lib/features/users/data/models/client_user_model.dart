import 'package:arcinus/core/auth/roles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'client_user_model.freezed.dart';
part 'client_user_model.g.dart';

/// Estados posibles de pago para un usuario cliente
enum PaymentStatus {
  /// Cliente al día con sus pagos
  active,
  
  /// Cliente con pagos atrasados/pendientes
  overdue,
  
  /// Cliente inactivo (no está pagando actualmente)
  inactive
}

/// Extensión para facilitar la serialización/deserialización del enum PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  /// Convierte el enum a su representación en String (nombre del enum)
  String toJson() => name;

  /// Devuelve un nombre amigable para mostrar en la UI
  String get displayName {
    switch (this) {
      case PaymentStatus.active:
        return 'Activo';
      case PaymentStatus.overdue:
        return 'En mora';
      case PaymentStatus.inactive:
        return 'Inactivo';
    }
  }
  
  /// Devuelve un color asociado con el estado
  String get color {
    switch (this) {
      case PaymentStatus.active:
        return '#4CAF50'; // Verde
      case PaymentStatus.overdue:
        return '#FF9800'; // Naranja
      case PaymentStatus.inactive:
        return '#9E9E9E'; // Gris
    }
  }
}

/// Función de deserialización estática para json_serializable
PaymentStatus _paymentStatusFromJson(String json) {
  return PaymentStatus.values.firstWhere(
    (e) => e.name == json,
    orElse: () => PaymentStatus.inactive,
  );
}

/// Ciclos de facturación disponibles para planes de suscripción
enum BillingCycle {
  /// Facturación mensual
  monthly,
  
  /// Facturación trimestral
  quarterly,
  
  /// Facturación semestral
  biannual,
  
  /// Facturación anual
  annual
}

/// Extensión para facilitar la serialización/deserialización del enum BillingCycle
extension BillingCycleExtension on BillingCycle {
  /// Convierte el enum a su representación en String (nombre del enum)
  String toJson() => name;

  /// Devuelve un nombre amigable para mostrar en la UI
  String get displayName {
    switch (this) {
      case BillingCycle.monthly:
        return 'Mensual';
      case BillingCycle.quarterly:
        return 'Trimestral';
      case BillingCycle.biannual:
        return 'Semestral';
      case BillingCycle.annual:
        return 'Anual';
    }
  }

  /// Número de meses que cubre este ciclo
  int get months {
    switch (this) {
      case BillingCycle.monthly:
        return 1;
      case BillingCycle.quarterly:
        return 3;
      case BillingCycle.biannual:
        return 6;
      case BillingCycle.annual:
        return 12;
    }
  }

  /// Función de deserialización estática para json_serializable
  static BillingCycle fromJson(String json) {
    return BillingCycle.values.firstWhere(
      (e) => e.name == json,
      orElse: () => BillingCycle.monthly,
    );
  }
}

/// Modelo para representar un plan de suscripción
@freezed
class SubscriptionPlanModel with _$SubscriptionPlanModel {
  @JsonSerializable(explicitToJson: true)
  const factory SubscriptionPlanModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id,
    required String name,
    required double amount,
    required String currency,
    required BillingCycle billingCycle,
    @Default([]) List<String> benefits,
    @Default(true) bool isActive,
    @Default({}) Map<String, dynamic> metadata,
  }) = _SubscriptionPlanModel;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanModelFromJson(json);
}

/// Modelo de usuario cliente (atletas y padres) con información de pagos
@freezed
class ClientUserModel with _$ClientUserModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory ClientUserModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id,
    required String userId,
    required String academyId,
    required AppRole clientType, // ATHLETE o PARENT
    @JsonKey(fromJson: _paymentStatusFromJson)
    @Default(PaymentStatus.inactive) PaymentStatus paymentStatus,
    String? subscriptionPlanId,
    SubscriptionPlanModel? subscriptionPlan,
    DateTime? nextPaymentDate,
    int? remainingDays,
    @Default([]) List<String> linkedAccounts, // IDs de cuentas vinculadas (padre-atleta)
    DateTime? lastPaymentDate,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ClientUserModel;

  factory ClientUserModel.fromJson(Map<String, dynamic> json) =>
      _$ClientUserModelFromJson(json);
}

/// Extensión con propiedades computadas útiles
extension ClientUserExtension on ClientUserModel {
  /// Verifica si el usuario está activo (al día con pagos)
  bool get isActive => paymentStatus == PaymentStatus.active;
  
  /// Verifica si el usuario está en mora
  bool get isOverdue => paymentStatus == PaymentStatus.overdue;
  
  /// Verifica si el usuario es un atleta
  bool get isAthlete => clientType == AppRole.atleta;
  
  /// Verifica si el usuario es un padre/responsable
  bool get isParent => clientType == AppRole.padre;
} 