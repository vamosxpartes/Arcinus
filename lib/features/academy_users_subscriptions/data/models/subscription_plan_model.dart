import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'subscription_plan_model.freezed.dart';
part 'subscription_plan_model.g.dart';

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

/// Extensión para facilitar el trabajo con ciclos de facturación
extension BillingCycleExtension on BillingCycle {
  /// Convierte el enum a su representación en String (nombre del enum)
  String toJson() => name;
  
  /// Nombre para mostrar al usuario
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
  
  /// Obtiene la duración en días según el ciclo
  int get durationInDays {
    switch (this) {
      case BillingCycle.monthly:
        return 30;
      case BillingCycle.quarterly:
        return 90;
      case BillingCycle.biannual:
        return 180;
      case BillingCycle.annual:
        return 365;
    }
  }
}

/// Función de deserialización estática para json_serializable
BillingCycle _billingCycleFromJson(String json) {
  return BillingCycle.values.firstWhere(
    (e) => e.name == json,
    orElse: () => BillingCycle.monthly,
  );
}

/// Modelo que representa un plan de suscripción en una academia
@freezed
class SubscriptionPlanModel with _$SubscriptionPlanModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory SubscriptionPlanModel({
    @JsonKey(includeFromJson: true, includeToJson: false)
    String? id,
    required String name,
    required double amount,
    required String currency,
    @JsonKey(fromJson: _billingCycleFromJson)
    @Default(BillingCycle.monthly) BillingCycle billingCycle,
    String? description,
    @Default([]) List<String> benefits,
    @Default(true) bool isActive,
    @Default(0) int extraDays, // Días adicionales a la duración estándar del ciclo
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SubscriptionPlanModel;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanModelFromJson(json);
      
  /// Crea un modelo básico con valores predeterminados
  factory SubscriptionPlanModel.basic({
    required String name,
    required double amount,
    required String currency,
    BillingCycle billingCycle = BillingCycle.monthly,
  }) {
    return SubscriptionPlanModel(
      name: name,
      amount: amount,
      currency: currency,
      billingCycle: billingCycle,
      createdAt: DateTime.now(),
    );
  }
}

/// Extensión con propiedades computadas útiles
extension SubscriptionPlanExtension on SubscriptionPlanModel {
  /// Calcula la duración total del plan en días
  int get durationInDays => billingCycle.durationInDays + extraDays;
  
  /// Calcula el precio mensual equivalente para comparativas
  double get monthlyEquivalent {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.quarterly:
        return amount / 3;
      case BillingCycle.biannual:
        return amount / 6;
      case BillingCycle.annual:
        return amount / 12;
    }
  }
  
  /// Calcula un descuento aproximado respecto al plan mensual
  String get discountDisplay {
    if (billingCycle == BillingCycle.monthly) return '';
    
    final double monthlyPrice = amount / billingCycle.durationInDays * 30;
    final double discount = 100 - (monthlyEquivalent / monthlyPrice * 100);
    
    if (discount <= 0) return '';
    return '${discount.toStringAsFixed(0)}% menos que mensual';
  }
  
  /// Formatea el precio para mostrar
  String get formattedPrice {
    return '$amount $currency / ${billingCycle.displayName}';
  }
} 