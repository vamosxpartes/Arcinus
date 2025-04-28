import 'package:arcinus/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Cargar variables de entorno ---
  // ignore: avoid_redundant_argument_values
  await dotenv.load(fileName: 'assets/config/env.config');

  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();

  // --- Inicializar Firebase ---
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: ArcinusApp()));
}
