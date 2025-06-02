import 'package:arcinus/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academy_sports/scripts/initialize_sports_collection.dart';
import 'package:arcinus/core/auth/presentation/providers/registration_form_provider.dart';
import 'package:arcinus/features/academy_users_payments/presentation/providers/payment_status_verification_provider.dart';
import 'firebase_options.dart';


// Firebase AppCheck imports (condicional)
import 'package:flutter/foundation.dart'; // Para kDebugMode

void configureFirebaseLogging() {
  // Configurar Firebase para silenciar warnings conocidos que no afectan funcionalidad
  // Estos warnings aparecen cuando App Check no está configurado pero no son críticos
  AppLogger.logInfo(
    'Configurando logging de Firebase',
    className: 'Main',
    functionName: 'configureFirebaseLogging',
  );
}

void main() async {
  AppLogger.logInfo('main: Execution started');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.logInfo('main: WidgetsBinding initialized');

    // --- Cargar variables de entorno ---
    await dotenv.load(fileName: 'assets/config/env.config');
    AppLogger.logInfo('main: DotEnv loaded');

    // Inicializar Hive para almacenamiento local
    await Hive.initFlutter();
    AppLogger.logInfo('main: Hive initialized');
    
    // Registrar adaptadores de Hive
    await _registerHiveAdapters();

    // --- Inicializar Firebase ---
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    AppLogger.logInfo('main: Firebase initialized');
    
    // --- Configurar Firebase AppCheck (opcional) ---
    await _configureFirebaseAppCheck();

    // Verificar e inicializar la colección de deportes si es necesario
    await SportsInitializer.initializeIfNeeded();
    
    // Crear contenedor de ProviderScope para inicializar Hive boxes
    final container = ProviderContainer();
    await initRegistrationBox(container);
    AppLogger.logInfo('main: Registration box initialized');
    
    // Iniciar la verificación automática de estados de pago
    AppLogger.logInfo('main: Starting payment status verification');
    container.read(paymentStatusVerificationProvider);

    AppLogger.logInfo('main: Running ProviderScope...');
    runApp(
      ProviderScope(
        child: const ArcinusApp(),
      ),
    );
  } catch (e, s) {
    AppLogger.logError(
      message: 'Error fatal durante la inicialización',
      error: e,
      stackTrace: s,
    );
    
    // App de emergencia para mostrar el error
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red[50],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[700],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al inicializar la aplicación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Error: $e',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Configura Firebase AppCheck para prevenir errores en desarrollo
/// Esta función es opcional y no impedirá que la app funcione si falla
Future<void> _configureFirebaseAppCheck() async {
  try {
    // Intentar importar y configurar AppCheck de manera condicional
    if (kDebugMode) {
      // En desarrollo, simplemente registramos que no configuramos AppCheck
      AppLogger.logInfo('main: Saltando configuración de Firebase AppCheck en desarrollo');
    } else {
      // En producción, intentar configurar AppCheck si está disponible
      AppLogger.logInfo('main: Intentando configurar Firebase AppCheck para producción');
      // TODO: Configurar AppCheck cuando sea necesario en producción
    }
  } catch (e) {
    AppLogger.logWarning(
      'Advertencia: No se pudo configurar Firebase AppCheck: $e',
      error: e,
    );
    // AppCheck no es crítico para el funcionamiento básico de la app
    // La app puede continuar sin él, aunque con menor seguridad
  }
}

/// Registra todos los adaptadores de Hive necesarios
Future<void> _registerHiveAdapters() async {
  try {
    // Verificar si el adaptador ya está registrado para evitar duplicados
    if (!Hive.isAdapterRegistered(0)) {
      // Registrar adaptador de SportCharacteristics
      // Nota: Esto requerirá generar el código con build_runner
      // Hive.registerAdapter(SportCharacteristicsAdapter());
      AppLogger.logInfo('main: Adaptadores de Hive registrados (placeholder)');
    }
    
    // TODO: Agregar otros adaptadores aquí cuando se implementen
    // Por ejemplo: UserModel, AcademyModel, etc.
    
  } catch (e) {
    AppLogger.logWarning(
      'Advertencia: No se pudieron registrar algunos adaptadores de Hive: $e',
      error: e,
    );
    // No es crítico, la app puede continuar sin almacenamiento en caché
  }
}
