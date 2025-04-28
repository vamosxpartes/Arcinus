import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Serializador para convertir entre [Timestamp] de Firestore y JSON.
/// Maneja el caso estándar donde Firestore devuelve un objeto Timestamp
/// y también intenta manejar representaciones alternativas como Map o int (milliseconds).
class TimestampSerializer implements JsonConverter<Timestamp, Object> {
  const TimestampSerializer();

  @override
  Timestamp fromJson(Object json) {
    if (json is Timestamp) {
      return json;
    }
    // Firestore a veces puede devolver Timestamps anidados como Map
    if (json is Map<String, dynamic> &&
        json.containsKey('_seconds') &&
        json.containsKey('_nanoseconds')) {
      return Timestamp(json['_seconds'] as int, json['_nanoseconds'] as int);
    }
    // Manejo de milisegundos desde epoch (menos común con Firestore directo)
     if (json is int) {
       return Timestamp.fromMillisecondsSinceEpoch(json);
     }
     // Manejo de String (ISO 8601), aunque menos ideal
     if (json is String) {
       final dt = DateTime.tryParse(json);
       if (dt != null) {
         return Timestamp.fromDate(dt);
       }
     }
    // Lanzar error si el tipo no es manejable
    throw FormatException(
        'Tipo JSON inesperado para Timestamp: ${json.runtimeType}');
  }

  /// Firestore maneja la serialización de Timestamp directamente al escribir.
  @override
  Object toJson(Timestamp object) => object;
}

/// Serializador opcional para Timestamps que pueden ser nulos.
/// Útil si un campo Timestamp no siempre está presente.
class NullableTimestampSerializer implements JsonConverter<Timestamp?, Object?> {
  const NullableTimestampSerializer();

  @override
  Timestamp? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    // Reutiliza la lógica del serializador no nulo
    return const TimestampSerializer().fromJson(json);
  }

  @override
  Object? toJson(Timestamp? object) => object; // Firestore maneja nulls y Timestamps
} 