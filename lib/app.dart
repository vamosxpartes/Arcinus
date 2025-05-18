import 'package:arcinus/core/localization/app_localizations.dart';
import 'package:arcinus/core/navigation/app_router.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Configura el tema, la localización y el enrutador principal.
class ArcinusApp extends ConsumerWidget {
  /// Crea la instancia principal de la aplicación.
  const ArcinusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.logInfo('ArcinusApp: Build started');
    try {
      // Obtenemos el router desde el provider
      AppLogger.logInfo('ArcinusApp: Watching routerProvider...');
      final router = ref.watch(routerProvider);
      AppLogger.logInfo('ArcinusApp: routerProvider obtained');
      
      final appWidget = MaterialApp.router(
        title: 'Arcinus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme, 
        // Considera si necesitas un tema oscuro diferente
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''), // Español
          // Locale('en', ''), // Puedes descomentar si añades inglés
        ],
        // Configuración de GoRouter
        routerConfig: router,
      );
      AppLogger.logInfo('ArcinusApp: Build finished successfully');
      return appWidget;
    } catch (e, stackTrace) {
      AppLogger.logError(
        message: 'ArcinusApp: CRITICAL ERROR during build',
        error: e,
        stackTrace: stackTrace
      );
      // Fallback UI
      return MaterialApp(home: Scaffold(body: Center(child: Text("Error en ArcinusApp build: $e"))));
    }
  }
}
