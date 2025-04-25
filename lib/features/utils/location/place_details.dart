/// Representa los detalles de un lugar específico,
///  incluyendo dirección y coordenadas.
class PlaceDetails {
  /// Crea una instancia de [PlaceDetails].
  PlaceDetails({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.placeId,
  });

  /// La dirección formateada completa del lugar.
  final String formattedAddress;
  /// La latitud geográfica del lugar.
  final double latitude;
  /// La longitud geográfica del lugar.
  final double longitude;
  /// El identificador único del lugar.
  final String placeId;
} 
