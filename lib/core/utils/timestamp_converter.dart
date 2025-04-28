import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Convertidor para manejar la serialización entre DateTime y Timestamp de Firestore
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  /// Constructor
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Convierte entre [DateTime?] nullable de Dart y [Timestamp?] de Firestore.
class NullableTimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
} 