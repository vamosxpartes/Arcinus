import 'package:arcinus/core/auth/roles.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

// Importar PaymentStatus modularizado
import 'package:arcinus/features/academy_users_payments/payment_status.dart';

part 'academy_member_model.freezed.dart';
part 'academy_member_model.g.dart';

/// Modelo de usuario cliente (atletas y padres) - información básica
/// NOTA: La información de suscripciones y pagos ahora se obtiene de los períodos (SubscriptionAssignmentModel)
@freezed
class AcademyMemberUserModel with _$AcademyMemberUserModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory AcademyMemberUserModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id,
    required String userId,
    required String academyId,
    required AppRole clientType, // ATHLETE o PARENT
    @JsonKey(fromJson: paymentStatusFromJson)
    @Default(PaymentStatus.inactive) PaymentStatus paymentStatus,
    @Default([]) List<String> linkedAccounts, // IDs de cuentas vinculadas (padre-atleta)
    @Default({}) Map<String, dynamic> metadata,
  }) = _AcademyMemberUserModel;

  factory AcademyMemberUserModel.fromJson(Map<String, dynamic> json) =>
      _$AcademyMemberUserModelFromJson(json);
}

/// Extensión con propiedades computadas útiles
extension ClientUserExtension on AcademyMemberUserModel {
  /// Verifica si el usuario está activo (al día con pagos)
  bool get isActive => paymentStatus == PaymentStatus.active;
  
  /// Verifica si el usuario está en mora
  bool get isOverdue => paymentStatus == PaymentStatus.overdue;
  
  /// Verifica si el usuario es un atleta
  bool get isAthlete => clientType == AppRole.atleta;
  
  /// Verifica si el usuario es un padre/responsable
  bool get isParent => clientType == AppRole.padre;
} 