import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

/// Representa un pago realizado por un atleta en la academia
@freezed
class PaymentModel with _$PaymentModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory PaymentModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id, // ID del documento de pago en Firestore
    required String academyId,
    required String athleteId, // ID del usuario atleta
    
    /// Plan de suscripción relacionado con este pago
    String? subscriptionPlanId,
    
    /// Monto del pago (puede ser parcial o completo según el plan)
    required double amount, 
    
    /// Moneda (ej: MXN, USD)
    required String currency,
    
    /// Concepto del pago (ej: "Mensualidad Octubre")
    String? concept,
    
    /// Fecha en que se realizó el pago
    required DateTime paymentDate,
    
    /// Notas adicionales sobre el pago
    String? notes,
    
    /// ID del usuario que registró el pago
    required String registeredBy,
    
    /// Fecha de registro en el sistema
    required DateTime createdAt,
    
    /// URL a un comprobante (opcional)
    String? receiptUrl,
    
    /// Indica si es un pago parcial
    @Default(false) bool isPartialPayment,
    
    /// Monto total del plan (útil para pagos parciales)
    double? totalPlanAmount,
    
    /// Fecha de inicio del período que cubre este pago
    DateTime? periodStartDate,
    
    /// Fecha de fin del período que cubre este pago
    DateTime? periodEndDate,
    
    /// Para soft delete
    @Default(false) bool isDeleted,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
} 