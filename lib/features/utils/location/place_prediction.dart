/// Representa una predicción de lugar obtenida de una API (ej. Google Places).
class PlacePrediction {
  /// Crea una instancia de [PlacePrediction].
  PlacePrediction({required this.description, required this.placeId});

  /// Crea una instancia de [PlacePrediction] a partir de un mapa JSON.
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
  
  /// La descripción textual de la predicción del lugar 
  /// (ej. nombre de calle, ciudad).
  final String description;
  /// El identificador único del lugar.
  final String placeId;
} 
