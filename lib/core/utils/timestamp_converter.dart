import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Convertidor para manejar la serialización entre DateTime y Timestamp de Firestore
class TimestampConverter implements JsonConverter<DateTime, Object> {
  /// Constructor
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    try {
      // Manejar null explícitamente
      if (json is Timestamp) {
        return json.toDate();
      }
      
      // Si es un Map (formato serializado de Timestamp)
      if (json is Map<String, dynamic> &&
          json.containsKey('_seconds') &&
          json.containsKey('_nanoseconds')) {
        return Timestamp(json['_seconds'] as int, json['_nanoseconds'] as int).toDate();
      }
      
      // Si es milisegundos desde epoch
      if (json is int) {
        return DateTime.fromMillisecondsSinceEpoch(json);
      }
      
      // Si es un String (formato ISO 8601)
      if (json is String) {
        final dateTime = DateTime.tryParse(json);
        if (dateTime != null) {
          return dateTime;
        }
        // Si el string no es válido, registrar y usar fecha actual
        AppLogger.logError(
          message: 'TimestampConverter: String inválido para fecha',
          error: 'String recibido: $json',
          className: 'TimestampConverter',
          functionName: 'fromJson'
        );
        return DateTime.now();
      }
      
      // Caso especial: Si recibimos un objeto que no podemos convertir,
      // registrar error y usar fecha actual en lugar de fallar
      AppLogger.logError(
        message: 'TimestampConverter: Tipo no soportado, usando fecha actual',
        error: 'Tipo: ${json.runtimeType}, Valor: $json',
        className: 'TimestampConverter',
        functionName: 'fromJson'
      );
      return DateTime.now();
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error en TimestampConverter.fromJson',
        error: e,
        stackTrace: stackTrace,
        className: 'TimestampConverter',
        functionName: 'fromJson',
        params: {
          'json_type': json.runtimeType.toString(),
          'json_value': json.toString(),
        }
      );
      // En lugar de lanzar excepción, devolver fecha actual
      return DateTime.now();
    }
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Convierte entre [DateTime?] nullable de Dart y [Timestamp?] de Firestore.
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    // Manejar null explícitamente
    if (json == null) {
      return null;
    }
    
    try {
      // Usar el convertidor no-nullable para la conversión real
      return const TimestampConverter().fromJson(json);
    } catch (e, stackTrace) {
      // Si hay error en la conversión, registrar y devolver null
      AppLogger.logError(
        message: 'Error en NullableTimestampConverter.fromJson',
        error: e,
        stackTrace: stackTrace,
        className: 'NullableTimestampConverter',
        functionName: 'fromJson',
        params: {
          'json_type': json.runtimeType.toString(),
          'json_value': json.toString(),
        }
      );
      return null;
    }
  }

  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}

/// Convertidor seguro que siempre devuelve un DateTime válido
class SafeTimestampConverter implements JsonConverter<DateTime, Object?> {
  const SafeTimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) {
      return DateTime.now(); // Valor por defecto
    }
    
    try {
      return const TimestampConverter().fromJson(json);
    } catch (e, stackTrace) {
      // Si hay error, devolver fecha actual como fallback
      AppLogger.logError(
        message: 'Error en SafeTimestampConverter.fromJson',
        error: e,
        stackTrace: stackTrace,
        className: 'SafeTimestampConverter',
        functionName: 'fromJson',
        params: {
          'json_type': json.runtimeType.toString(),
          'json_value': json.toString(),
        }
      );
      return DateTime.now();
    }
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
} 