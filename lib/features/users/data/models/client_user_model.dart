import 'package:arcinus/core/auth/roles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

// Importar PaymentStatus modularizado
import 'package:arcinus/features/users/data/models/payment_status.dart';

part 'client_user_model.freezed.dart';
part 'client_user_model.g.dart';

/// Modelo de usuario cliente (atletas y padres) - información básica
/// NOTA: La información de suscripciones y pagos ahora se obtiene de los períodos (SubscriptionAssignmentModel)
@freezed
class ClientUserModel with _$ClientUserModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory ClientUserModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id,
    required String userId,
    required String academyId,
    required AppRole clientType, // ATHLETE o PARENT
    @JsonKey(fromJson: paymentStatusFromJson)
    @Default(PaymentStatus.inactive) PaymentStatus paymentStatus,
    @Default([]) List<String> linkedAccounts, // IDs de cuentas vinculadas (padre-atleta)
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