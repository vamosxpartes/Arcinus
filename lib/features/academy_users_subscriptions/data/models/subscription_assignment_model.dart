import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

part 'subscription_assignment_model.freezed.dart';
part 'subscription_assignment_model.g.dart';

/// Estados de una asignación de suscripción
enum SubscriptionAssignmentStatus {
  /// Asignación activa
  active,
  
  /// Asignación pausada
  paused,
  
  /// Asignación expirada
  expired,
  
  /// Asignación cancelada
  cancelled
}

/// Extensión para facilitar el trabajo con estados de asignación
extension SubscriptionAssignmentStatusExtension on SubscriptionAssignmentStatus {
  /// Convierte el enum a su representación en String
  String toJson() => name;
  
  /// Nombre para mostrar al usuario
  String get displayName {
    switch (this) {
      case SubscriptionAssignmentStatus.active:
        return 'Activa';
      case SubscriptionAssignmentStatus.paused:
        return 'Pausada';
      case SubscriptionAssignmentStatus.expired:
        return 'Expirada';
      case SubscriptionAssignmentStatus.cancelled:
        return 'Cancelada';
    }
  }
  
  /// Color asociado al estado
  String get color {
    switch (this) {
      case SubscriptionAssignmentStatus.active:
        return '#4CAF50'; // Verde
      case SubscriptionAssignmentStatus.paused:
        return '#FF9800'; // Naranja
      case SubscriptionAssignmentStatus.expired:
        return '#F44336'; // Rojo
      case SubscriptionAssignmentStatus.cancelled:
        return '#9E9E9E'; // Gris
    }
  }
}

/// Función de deserialización estática para json_serializable
SubscriptionAssignmentStatus _subscriptionAssignmentStatusFromJson(String json) {
  return SubscriptionAssignmentStatus.values.firstWhere(
    (e) => e.name == json,
    orElse: () => SubscriptionAssignmentStatus.active,
  );
}

/// Modelo que representa la asignación de un plan de suscripción a un atleta
/// con fechas separadas para pago, inicio y fin del servicio
@freezed
class SubscriptionAssignmentModel with _$SubscriptionAssignmentModel {
  @JsonSerializable(explicitToJson: true, converters: [TimestampConverter()])
  const factory SubscriptionAssignmentModel({
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? id, // ID del documento en Firestore
    
    /// ID de la academia
    required String academyId,
    
    /// ID del atleta
    required String athleteId,
    
    /// ID del plan de suscripción
    required String subscriptionPlanId,
    
    /// ID del pago relacionado (si existe)
    String? paymentId,
    
    /// Fecha en que se realizó el pago
    required DateTime paymentDate,
    
    /// Fecha en que comienza el servicio/período
    required DateTime startDate,
    
    /// Fecha en que termina el servicio/período
    required DateTime endDate,
    
    /// Estado de la asignación
    @JsonKey(fromJson: _subscriptionAssignmentStatusFromJson)
    @Default(SubscriptionAssignmentStatus.active)
    SubscriptionAssignmentStatus status,
    
    /// Monto pagado para esta asignación
    required double amountPaid,
    
    /// Moneda del pago
    required String currency,
    
    /// Indica si fue un pago parcial
    @Default(false) bool isPartialPayment,
    
    /// Monto total del plan (útil para pagos parciales)
    double? totalPlanAmount,
    
    /// Notas adicionales sobre la asignación
    String? notes,
    
    /// ID del usuario que creó la asignación
    required String createdBy,
    
    /// Fecha de creación del registro
    required DateTime createdAt,
    
    /// Fecha de última actualización
    DateTime? updatedAt,
    
    /// Para soft delete
    @Default(false) bool isDeleted,
  }) = _SubscriptionAssignmentModel;

  factory SubscriptionAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionAssignmentModelFromJson(json);
}

/// Extensión con propiedades computadas útiles
extension SubscriptionAssignmentExtension on SubscriptionAssignmentModel {
  /// Calcula los días restantes hasta el vencimiento
  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }
  
  /// Verifica si la asignación está activa
  bool get isActive => status == SubscriptionAssignmentStatus.active;
  
  /// Verifica si la asignación ha expirado
  bool get isExpired {
    return status == SubscriptionAssignmentStatus.expired || 
           DateTime.now().isAfter(endDate);
  }
  
  /// Verifica si la asignación está próxima a vencer (dentro de 7 días)
  bool get isNearExpiry {
    if (isExpired) return false;
    return daysRemaining <= 7;
  }
  
  /// Calcula la duración total del período en días
  int get totalDurationDays {
    return endDate.difference(startDate).inDays;
  }
  
  /// Calcula el porcentaje de tiempo transcurrido
  double get progressPercentage {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 100.0;
    
    final totalDuration = endDate.difference(startDate).inDays;
    final elapsed = now.difference(startDate).inDays;
    
    return (elapsed / totalDuration * 100).clamp(0.0, 100.0);
  }
  
  /// Verifica si el pago fue realizado antes de la fecha de inicio
  bool get isPrepaid => paymentDate.isBefore(startDate);
  
  /// Verifica si el pago fue realizado después de la fecha de fin
  bool get isPostpaid => paymentDate.isAfter(endDate);
  
  /// Formatea el período para mostrar
  String get formattedPeriod {
    final startFormatted = '${startDate.day}/${startDate.month}/${startDate.year}';
    final endFormatted = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$startFormatted - $endFormatted';
  }
} 