import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/timestamp_converter.dart';

/// Pruebas unitarias para los convertidores de Timestamp en la aplicación.
/// 
/// Estas pruebas verifican que:
/// - TimestampConverter convierta correctamente entre DateTime y Timestamp de Firestore
/// - NullableTimestampConverter maneje adecuadamente valores nulos
/// 
/// Mejores prácticas implementadas:
/// - Uso del patrón AAA (Arrange-Act-Assert) para estructurar cada prueba
/// - Normalización de fechas para evitar problemas de precisión
/// - Prueba de todos los casos límite (valores nulos y no nulos)
/// - Pruebas independientes y enfocadas para cada función

void main() {
  group('TimestampConverter', () {
    final converter = TimestampConverter();
    final now = DateTime.now();
    // Eliminamos los microsegundos para evitar problemas de precisión
    final normalizedDate = DateTime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch,
    );
    
    test('fromJson convierte Timestamp a DateTime correctamente', () {
      // Arrange
      final timestamp = Timestamp.fromDate(normalizedDate);
      
      // Act
      final result = converter.fromJson(timestamp);
      
      // Assert
      expect(result, normalizedDate);
    });
    
    test('toJson convierte DateTime a Timestamp correctamente', () {
      // Arrange
      final expectedTimestamp = Timestamp.fromDate(normalizedDate);
      
      // Act
      final result = converter.toJson(normalizedDate);
      
      // Assert
      expect(result.seconds, expectedTimestamp.seconds);
      expect(result.nanoseconds, expectedTimestamp.nanoseconds);
    });
  });
  
  group('NullableTimestampConverter', () {
    final converter = NullableTimestampConverter();
    final now = DateTime.now();
    final normalizedDate = DateTime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch,
    );
    
    test('fromJson maneja Timestamp no nulo correctamente', () {
      // Arrange
      final timestamp = Timestamp.fromDate(normalizedDate);
      
      // Act
      final result = converter.fromJson(timestamp);
      
      // Assert
      expect(result, normalizedDate);
    });
    
    test('fromJson maneja Timestamp nulo correctamente', () {
      // Act
      final result = converter.fromJson(null);
      
      // Assert
      expect(result, isNull);
    });
    
    test('toJson maneja DateTime no nulo correctamente', () {
      // Arrange
      final expectedTimestamp = Timestamp.fromDate(normalizedDate);
      
      // Act
      final result = converter.toJson(normalizedDate);
      
      // Assert
      expect(result?.seconds, expectedTimestamp.seconds);
      expect(result?.nanoseconds, expectedTimestamp.nanoseconds);
    });
    
    test('toJson maneja DateTime nulo correctamente', () {
      // Act
      final result = converter.toJson(null);
      
      // Assert
      expect(result, isNull);
    });
  });
} 