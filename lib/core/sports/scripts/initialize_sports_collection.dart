import 'package:arcinus/core/sports/data/repositories/sports_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Clase utilitaria para inicializar la colección de deportes en Firestore
class SportsInitializer {
  /// Inicializa la colección de deportes en Firestore
  static Future<void> initializeSportsCollection() async {
    try {
      final sportsRepo = SportsRepository();
      await sportsRepo.initializeSportsCollection();
      AppLogger.logInfo('Colección de deportes inicializada correctamente', 
          className: 'SportsInitializer', 
          functionName: 'initializeSportsCollection');
    } catch (e) {
      AppLogger.logError(
          message: 'Error al inicializar colección de deportes', 
          error: e,
          className: 'SportsInitializer', 
          functionName: 'initializeSportsCollection');
    }
  }
  
  /// Verifica si la colección de deportes ya existe
  static Future<bool> sportCollectionExists() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('sports').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      AppLogger.logError(
          message: 'Error al verificar colección de deportes', 
          error: e,
          className: 'SportsInitializer', 
          functionName: 'sportCollectionExists');
      return false;
    }
  }
  
  /// Inicializa la colección si no existe
  static Future<void> initializeIfNeeded() async {
    final exists = await sportCollectionExists();
    if (!exists) {
      AppLogger.logInfo('Colección de deportes no existe. Inicializando...',
          className: 'SportsInitializer',
          functionName: 'initializeIfNeeded');
      await initializeSportsCollection();
    } else {
      AppLogger.logInfo('Colección de deportes ya existe',
          className: 'SportsInitializer',
          functionName: 'initializeIfNeeded');
    }
  }
} 