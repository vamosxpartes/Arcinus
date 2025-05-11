import 'package:arcinus/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/sports/scripts/initialize_sports_collection.dart';
import 'firebase_options.dart';

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

    // --- Inicializar Firebase ---
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    AppLogger.logInfo('main: Firebase initialized');

    // Verificar e inicializar la colección de deportes si es necesario
    await SportsInitializer.initializeIfNeeded();

    AppLogger.logInfo('main: Running ProviderScope...');
    runApp(const ProviderScope(child: ArcinusApp()));
    AppLogger.logInfo('main: runApp finished (or backgrounded)');
  } catch (e, stackTrace) {
    AppLogger.logError(
      message: 'main: CRITICAL ERROR during initialization',
      error: e,
      stackTrace: stackTrace
    );
    // Optionally, display a fallback error UI if possible
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Error crítico al iniciar: $e")))));
  }
}
