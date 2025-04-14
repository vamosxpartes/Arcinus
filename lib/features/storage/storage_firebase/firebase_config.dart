import 'package:arcinus/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';

/// Clase para gestionar la configuración de Firebase
class FirebaseConfig {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;
  
  /// Inicializa Firebase con las opciones correctas según el entorno
  static Future<void> initDevelopment() async {
    // Si ya está inicializado, no hacer nada
    if (_isInitialized) {
      _logger.i('Firebase ya estaba inicializado, omitiendo inicialización');
      return;
    }
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      _logger.i('Firebase inicializado correctamente');
    } catch (e) {
      _logger.e('Error al inicializar Firebase: $e');
      rethrow;
    }
  }
  
  /// Inicializa Firebase con las opciones para el entorno de producción
  static Future<void> initProduction() async {
    // Si ya está inicializado, no hacer nada
    if (_isInitialized) {
      _logger.i('Firebase ya estaba inicializado, omitiendo inicialización');
      return;
    }
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      _logger.i('Firebase inicializado en modo PRODUCCIÓN');
    } catch (e) {
      _logger.e('Error al inicializar Firebase: $e');
      rethrow;
    }
  }
} 