import 'package:arcinus/config/firebase/analytics_service.dart';
import 'package:arcinus/config/firebase/firebase_config.dart';
import 'package:arcinus/config/local_storage/hive_config.dart';
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
