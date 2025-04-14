import 'package:arcinus/features/storage/hive/hive_config.dart';
import 'package:arcinus/features/storage/storage_firebase/analytics_service.dart';
import 'package:arcinus/features/storage/storage_firebase/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();
  await HiveConfig.init();
  
  // Inicializar Firebase
  await FirebaseConfig.initDevelopment();
  
  // Inicializar Analytics
  final analyticsService = AnalyticsService();
  analyticsService.init();
  
  runApp(
    const ProviderScope(
      child: ArcinusApp(),
    ),
  );
}
