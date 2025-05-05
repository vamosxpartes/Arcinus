import 'package:arcinus/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

// Instancia de Logger a nivel de módulo
final _logger = Logger();

void main() async {
  _logger.d('main: Execution started');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    _logger.d('main: WidgetsBinding initialized');

    // --- Cargar variables de entorno ---
    await dotenv.load(fileName: 'assets/config/env.config');
    _logger.d('main: DotEnv loaded');

    // Inicializar Hive para almacenamiento local
    await Hive.initFlutter();
    _logger.d('main: Hive initialized');

    // --- Inicializar Firebase ---
    await Firebase.initializeApp();
    _logger.d('main: Firebase initialized');

    _logger.d('main: Running ProviderScope...');
    runApp(const ProviderScope(child: ArcinusApp()));
    _logger.d('main: runApp finished (or backgrounded)');
  } catch (e, stackTrace) {
    _logger.e('main: CRITICAL ERROR during initialization', error: e, stackTrace: stackTrace);
    // Optionally, display a fallback error UI if possible
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Error crítico al iniciar: $e")))));
  }
}
