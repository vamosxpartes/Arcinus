import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'payment_config_model.freezed.dart';
part 'payment_config_model.g.dart';

/// Enum que define el modo de facturación para los pagos
enum BillingMode {
  /// Pago por adelantado (antes del periodo)
  advance,
  
  /// Pago durante el periodo (mes actual)
  current,
  
  /// Pago después del periodo (mes vencido)
  arrears
}

/// Extensión para funcionalidades adicionales de BillingMode
extension BillingModeExtension on BillingMode {
  /// Convierte el enum a string para almacenar en Firestore
  String toJson() => name;
  
  /// Nombre para mostrar al usuario
  String get displayName {
    switch (this) {
      case BillingMode.advance:
        return 'Por adelantado';
      case BillingMode.current:
        return 'Mes en curso';
      case BillingMode.arrears:
        return 'Mes vencido';
    }
  }
}

/// Función para deserializar BillingMode desde JSON
BillingMode _billingModeFromJson(String json) {
  return BillingMode.values.firstWhere(
    (e) => e.name == json,
    orElse: () => BillingMode.current,
  );
}

/// Modelo para la configuración de pagos de una academia
@freezed
class PaymentConfigModel with _$PaymentConfigModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory PaymentConfigModel({
    @JsonKey(includeFromJson: true, includeToJson: false)
    String? id,
    required String academyId,
    
    /// Modo de facturación (adelantado, actual, vencido)
    @JsonKey(fromJson: _billingModeFromJson)
    @Default(BillingMode.current) BillingMode billingMode,
    
    /// Permite pagos parciales (abonos)
    @Default(false) bool allowPartialPayments,
    
    /// Días de gracia después de la fecha de vencimiento
    @Default(0) int gracePeriodDays,
    
    /// Aplica descuento por pronto pago
    @Default(false) bool earlyPaymentDiscount,
    
    /// Porcentaje de descuento por pronto pago
    @Default(0.0) double earlyPaymentDiscountPercent,
    
    /// Días antes para considerar como pronto pago
    @Default(0) int earlyPaymentDays,
    
    /// Aplica recargo por pago tardío
    @Default(false) bool lateFeeEnabled,
    
    /// Porcentaje de recargo por pago tardío
    @Default(0.0) double lateFeePercent,
    
    /// Permite renovación automática de planes
    @Default(false) bool autoRenewal,
    
    /// Días de anticipación para notificar vencimiento
    @Default(3) int expirationNotificationDays,
    
    /// Fecha de creación
    required DateTime createdAt,
    
    /// Fecha de última actualización
    DateTime? updatedAt,
  }) = _PaymentConfigModel;

  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentConfigModelFromJson(json);
      
  /// Constructor para crear una configuración predeterminada
  factory PaymentConfigModel.defaultConfig({
    required String academyId,
  }) {
    return PaymentConfigModel(
      academyId: academyId,
      createdAt: DateTime.now(),
    );
  }
} 