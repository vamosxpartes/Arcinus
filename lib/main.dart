import 'dart:developer' as developer;
import 'package:arcinus/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  developer.log('main: Execution started', name: 'AppLifecycle');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('main: WidgetsBinding initialized', name: 'AppLifecycle');

    // --- Cargar variables de entorno ---
    await dotenv.load(fileName: 'assets/config/env.config');
    developer.log('main: DotEnv loaded', name: 'AppLifecycle');

    // Inicializar Hive para almacenamiento local
    await Hive.initFlutter();
    developer.log('main: Hive initialized', name: 'AppLifecycle');

    // --- Inicializar Firebase ---
    await Firebase.initializeApp();
    developer.log('main: Firebase initialized', name: 'AppLifecycle');

    developer.log('main: Running ProviderScope...', name: 'AppLifecycle');
    runApp(const ProviderScope(child: ArcinusApp()));
    developer.log('main: runApp finished (or backgrounded)', name: 'AppLifecycle'); // Might not show if runApp blocks
  } catch (e, stackTrace) {
    developer.log('main: CRITICAL ERROR during initialization', error: e, stackTrace: stackTrace, name: 'AppLifecycle.Error');
    // Optionally, display a fallback error UI if possible
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Error crítico al iniciar: $e")))));
  }
}
