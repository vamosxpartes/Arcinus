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
    required double amount, // Monto del pago
    required String currency, // Moneda (ej: MXN, USD)
    String? concept, // Concepto del pago (ej: "Mensualidad Octubre")
    required DateTime paymentDate, // Fecha en que se realizó el pago
    String? notes, // Notas adicionales sobre el pago
    required String registeredBy, // ID del usuario que registró el pago
    required DateTime createdAt, // Fecha de registro en el sistema
    String? receiptUrl, // URL a un comprobante (opcional)
    @Default(false) bool isDeleted, // Para soft delete
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
} 