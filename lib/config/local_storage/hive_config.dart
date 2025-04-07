import 'package:arcinus/shared/models/hive/user_hive_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// Clase para gestionar la configuración de Hive
class HiveConfig {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;
  
  /// Nombres de cajas (boxes) para almacenar diferentes tipos de datos
  static const String userBox = 'users';
  static const String academyBox = 'academies';
  static const String athleteBox = 'athletes';
  static const String coachBox = 'coaches';
  static const String managerBox = 'managers';
  static const String groupBox = 'groups';
  static const String sessionBox = 'sessions';
  static const String trainingBox = 'trainings';
  static const String operationsQueueBox = 'operations_queue';
  
  /// Inicializa Hive y registra los adaptadores
  static Future<void> init() async {
    if (_isInitialized) {
      _logger.i('Hive ya está inicializado, omitiendo inicialización');
      return;
    }
    
    try {
      // Hive ya debe estar inicializado en main.dart con Hive.initFlutter()
      
      // Registrar adaptadores
      Hive.registerAdapter(UserHiveModelAdapter());
      
      // Abrir las cajas (boxes) principales
      await _openBoxes();
      
      _isInitialized = true;
      _logger.i('Hive inicializado correctamente');
    } catch (e) {
      _logger.e('Error al inicializar Hive: $e');
      rethrow;
    }
  }
  
  /// Abre las cajas (boxes) principales
  static Future<void> _openBoxes() async {
    try {
      await Hive.openBox(userBox);
      await Hive.openBox(academyBox);
      await Hive.openBox(athleteBox);
      await Hive.openBox(coachBox);
      await Hive.openBox(managerBox);
      await Hive.openBox(groupBox);
      await Hive.openBox(sessionBox);
      await Hive.openBox(trainingBox);
      await Hive.openBox(operationsQueueBox);
      
      _logger.i('Cajas de Hive abiertas correctamente');
    } catch (e) {
      _logger.e('Error al abrir cajas de Hive: $e');
      rethrow;
    }
  }
  
  /// Limpia todos los datos almacenados localmente
  static Future<void> clearAllData() async {
    try {
      await Hive.box(userBox).clear();
      await Hive.box(academyBox).clear();
      await Hive.box(athleteBox).clear();
      await Hive.box(coachBox).clear();
      await Hive.box(managerBox).clear();
      await Hive.box(groupBox).clear();
      await Hive.box(sessionBox).clear();
      await Hive.box(trainingBox).clear();
      await Hive.box(operationsQueueBox).clear();
      
      _logger.i('Datos locales limpiados correctamente');
    } catch (e) {
      _logger.e('Error al limpiar datos locales: $e');
      rethrow;
    }
  }
  
  /// Cierra todas las cajas abiertas
  static Future<void> closeBoxes() async {
    try {
      await Hive.close();
      _logger.i('Cajas de Hive cerradas correctamente');
    } catch (e) {
      _logger.e('Error al cerrar cajas de Hive: $e');
      rethrow;
    }
  }
} 