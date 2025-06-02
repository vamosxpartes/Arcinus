import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_serializer.dart'; // Necesario para serializar Timestamp

// Importar o definir el TimestampConverter
// import 'package:arcinus/core/utils/timestamp_converter.dart'; 

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// Enum para representar el estado de la suscripción.
enum SubscriptionStatus {
  active,
  inactive,
  trial,
  expired,
  cancelled,
  unknown, // Para manejar casos inesperados
}

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id, // Document ID from Firestore
    required String academyId,
    required String status, // Ej: 'active', 'inactive', 'trial', 'expired'
    @TimestampSerializer() required Timestamp endDate,
    // Opcional/Futuro: planId, startDate, etc.
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}

