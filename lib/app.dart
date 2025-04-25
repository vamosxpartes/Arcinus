import 'package:arcinus/features/theme/ux/app_theme.dart';
import 'package:arcinus/features/utils/screens/screen_under_development.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO(User): Definir un mejor estado inicial o lógica para esto.
/// Provider para controlar cuando se ha cargado el splash
final splashCompletedProvider = StateProvider<bool>((ref) => false);

// TODO(User): Evaluar si este provider es realmente necesario globalmente.
/// Provider para controlar si se muestra el diálogo de confirmación para salir
final confirmExitProvider = StateProvider<bool>((ref) => true);

/// Widget raíz de la aplicación Arcinus.
class ArcinusApp extends ConsumerWidget {
  /// Crea la instancia principal de la aplicación.
  const ArcinusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return MaterialApp(
      title: 'Arcinus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme, // Considera si necesitas un tema oscuro diferente
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      // TODO(User): Implementar navegación con GoRouter u otro.
      home: const UnderDevelopmentScreen(title: 'Arcinus'), 
      // routes: ..., 
      // onGenerateRoute: ..., 
      // onUnknownRoute: ..., 
    );
  }
}
