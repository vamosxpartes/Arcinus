import 'dart:async';
import 'package:arcinus/features/academy_sports/data/repositories/sports_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Clase utilitaria para inicializar la colección de deportes en Firestore
class SportsInitializer {
  /// Inicializa la colección de deportes en Firestore
  static Future<void> initializeSportsCollection() async {
    try {
      AppLogger.logInfo(
        'Iniciando inicialización de colección de deportes',
        className: 'SportsInitializer',
        functionName: 'initializeSportsCollection',
      );

      final sportsRepo = SportsRepository();
      
      AppLogger.logInfo(
        'SportsRepository creado, procediendo con inicialización',
        className: 'SportsInitializer',
        functionName: 'initializeSportsCollection',
      );

      await sportsRepo.initializeSportsCollection();
      
      AppLogger.logInfo(
        'Colección de deportes inicializada correctamente', 
        className: 'SportsInitializer', 
        functionName: 'initializeSportsCollection',
      );
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firebase al inicializar colección de deportes', 
        error: e,
        className: 'SportsInitializer', 
        functionName: 'initializeSportsCollection',
        params: {
          'code': e.code,
          'message': e.message,
          'plugin': e.plugin,
        },
      );
      // No re-lanzar para que no crashee la app
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error al inicializar colección de deportes', 
        error: e,
        stackTrace: stackTrace,
        className: 'SportsInitializer', 
        functionName: 'initializeSportsCollection',
      );
      // No re-lanzar para que no crashee la app
    }
  }
  
  /// Verifica si la colección de deportes ya existe
  static Future<bool> sportCollectionExists() async {
    try {
      AppLogger.logInfo(
        'Verificando si la colección de deportes existe',
        className: 'SportsInitializer',
        functionName: 'sportCollectionExists',
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('sports')
          .limit(1)
          .get();
      
      final exists = snapshot.docs.isNotEmpty;
      
      AppLogger.logInfo(
        'Verificación de colección completada',
        className: 'SportsInitializer',
        functionName: 'sportCollectionExists',
        params: {'exists': exists, 'docCount': snapshot.docs.length},
      );
      
      return exists;
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firebase al verificar colección de deportes', 
        error: e,
        className: 'SportsInitializer', 
        functionName: 'sportCollectionExists',
        params: {
          'code': e.code,
          'message': e.message,
        },
      );
      return false;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error al verificar colección de deportes', 
        error: e,
        stackTrace: stackTrace,
        className: 'SportsInitializer', 
        functionName: 'sportCollectionExists',
      );
      return false;
    }
  }
  
  /// Inicializa la colección si no existe
  static Future<void> initializeIfNeeded() async {
    try {
      AppLogger.logInfo(
        'Iniciando verificación e inicialización si es necesario',
        className: 'SportsInitializer',
        functionName: 'initializeIfNeeded',
      );

      final exists = await sportCollectionExists();
      
      if (!exists) {
        AppLogger.logInfo(
          'Colección de deportes no existe. Inicializando...',
          className: 'SportsInitializer',
          functionName: 'initializeIfNeeded',
        );
        await initializeSportsCollection();
      } else {
        AppLogger.logInfo(
          'Colección de deportes ya existe, omitiendo inicialización',
          className: 'SportsInitializer',
          functionName: 'initializeIfNeeded',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error durante initializeIfNeeded',
        error: e,
        stackTrace: stackTrace,
        className: 'SportsInitializer',
        functionName: 'initializeIfNeeded',
      );
    }
  }

  /// Reinicializa forzosamente la colección (útil para desarrollo)
  static Future<void> forceReinitialize() async {
    try {
      AppLogger.logInfo(
        'Iniciando reinicialización forzosa de deportes',
        className: 'SportsInitializer',
        functionName: 'forceReinitialize',
      );

      // Eliminar documentos existentes primero
      final collection = FirebaseFirestore.instance.collection('sports');
      final snapshot = await collection.get();
      
      AppLogger.logInfo(
        'Eliminando documentos existentes',
        className: 'SportsInitializer',
        functionName: 'forceReinitialize',
        params: {'docsToDelete': snapshot.docs.length},
      );

      // Eliminar documentos en lotes pequeños para evitar timeouts
      const batchSize = 10;
      for (int i = 0; i < snapshot.docs.length; i += batchSize) {
        final batch = FirebaseFirestore.instance.batch();
        final endIndex = (i + batchSize < snapshot.docs.length) ? i + batchSize : snapshot.docs.length;
        
        for (int j = i; j < endIndex; j++) {
          batch.delete(snapshot.docs[j].reference);
        }
        
        await batch.commit();
        
        AppLogger.logInfo(
          'Lote eliminado',
          className: 'SportsInitializer',
          functionName: 'forceReinitialize',
          params: {'deletedDocs': endIndex - i, 'totalProgress': '$endIndex/${snapshot.docs.length}'},
        );
      }

      // Inicializar de nuevo
      await initializeSportsCollection();
      
      AppLogger.logInfo(
        'Reinicialización forzosa completada',
        className: 'SportsInitializer',
        functionName: 'forceReinitialize',
      );
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'Error durante reinicialización forzosa',
        error: e,
        stackTrace: stackTrace,
        className: 'SportsInitializer',
        functionName: 'forceReinitialize',
      );
    }
  }
} 