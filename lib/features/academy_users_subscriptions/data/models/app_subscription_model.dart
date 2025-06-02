
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

// Importar BillingCycle desde la definición oficial
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_plan_model.dart';

// Importar PaymentStatus desde el módulo de usuarios  

part 'app_subscription_model.freezed.dart';
part 'app_subscription_model.g.dart';

/// Función de deserialización para BillingCycle
BillingCycle _billingCycleFromJson(String json) {
  return BillingCycle.values.firstWhere(
    (e) => e.name == json,
    orElse: () => BillingCycle.monthly,
  );
}

/// Enum para representar los tipos de planes de suscripción de la aplicación.
enum AppSubscriptionPlanType {
  free,
  basic, 
  pro,
  enterprise,
}

/// Enum para representar las características/funcionalidades disponibles
/// según el plan de suscripción.
enum AppFeature {
  videoAnalysis,
  advancedStats,
  multipleAcademies,
  apiAccess,
  customization,
}

/// Extensión para facilitar la serialización/deserialización del enum AppSubscriptionPlanType
extension AppSubscriptionPlanTypeExtension on AppSubscriptionPlanType {
  /// Convierte el enum a su representación en String (nombre del enum)
  String toJson() => name;

  /// Devuelve un nombre amigable para mostrar en la UI
  String get displayName {
    switch (this) {
      case AppSubscriptionPlanType.free:
        return 'Gratuito';
      case AppSubscriptionPlanType.basic:
        return 'Básico';
      case AppSubscriptionPlanType.pro:
        return 'Profesional';
      case AppSubscriptionPlanType.enterprise:
        return 'Empresarial';
    }
  }

  /// Función de deserialización estática para json_serializable
  static AppSubscriptionPlanType fromJson(String json) {
    return AppSubscriptionPlanType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => AppSubscriptionPlanType.free,
    );
  }
}

/// Extensión para facilitar la serialización/deserialización del enum AppFeature
extension AppFeatureExtension on AppFeature {
  /// Convierte el enum a su representación en String (nombre del enum)
  String toJson() => name;

  /// Devuelve un nombre amigable para mostrar en la UI
  String get displayName {
    switch (this) {
      case AppFeature.videoAnalysis:
        return 'Análisis de Video';
      case AppFeature.advancedStats:
        return 'Estadísticas Avanzadas';
      case AppFeature.multipleAcademies:
        return 'Múltiples Academias';
      case AppFeature.apiAccess:
        return 'Acceso a API';
      case AppFeature.customization:
        return 'Personalización';
    }
  }

  /// Función de deserialización estática para json_serializable
  static AppFeature fromJson(String json) {
    return AppFeature.values.firstWhere(
      (e) => e.name == json,
      orElse: () => AppFeature.values.first,
    );
  }
}

/// Modelo para representar un plan de suscripción de la aplicación.
@freezed
class AppSubscriptionPlanModel with _$AppSubscriptionPlanModel {
  @JsonSerializable(explicitToJson: true)
  const factory AppSubscriptionPlanModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id,
    required String name,
    @JsonKey(fromJson: AppSubscriptionPlanTypeExtension.fromJson)
    required AppSubscriptionPlanType planType,
    required double price,
    required String currency,
    @JsonKey(fromJson: _billingCycleFromJson)
    required BillingCycle billingCycle,
    @Default(1) int maxAcademies,
    @Default(10) int maxUsersPerAcademy,
    @Default([]) @JsonKey(fromJson: _featuresFromJson) List<AppFeature> features,
    @Default([]) List<String> benefits,
    @Default(true) bool isActive,
    @Default({}) Map<String, dynamic> metadata,
  }) = _AppSubscriptionPlanModel;

  factory AppSubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$AppSubscriptionPlanModelFromJson(json);
}

/// Modelo para representar una suscripción activa de un propietario.
@freezed
class AppSubscriptionModel with _$AppSubscriptionModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory AppSubscriptionModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id,
    required String ownerId,
    required String planId,
    AppSubscriptionPlanModel? plan,
    @Default("active") String status,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    @TimestampConverter() DateTime? lastPaymentDate,
    @TimestampConverter() DateTime? nextPaymentDate,
    @Default([]) List<String> academyIds,
    @Default(0) int currentAcademyCount,
    @Default(0) int totalUserCount,
    @Default({}) Map<String, dynamic> paymentHistory,
    @Default({}) Map<String, dynamic> metadata,
  }) = _AppSubscriptionModel;

  factory AppSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$AppSubscriptionModelFromJson(json);
}

/// Helper para convertir lista de strings a lista de AppFeature
List<AppFeature> _featuresFromJson(List<dynamic> json) {
  return json
      .map((feature) => AppFeatureExtension.fromJson(feature as String))
      .toList();
} 