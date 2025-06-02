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
PaymentStatus paymentStatusFromJson(String json) {
  return PaymentStatus.values.firstWhere(
    (e) => e.name == json,
    orElse: () => PaymentStatus.inactive,
  );
} 