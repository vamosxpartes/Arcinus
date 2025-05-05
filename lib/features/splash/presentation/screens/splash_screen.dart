import 'package:arcinus/features/theme/ui/widgets/adaptive_logo.dart';
import 'package:arcinus/features/theme/ux/arcinus_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

// Instancia de Logger
final _logger = Logger();

/// Pantalla de splash que se muestra durante la inicialización de la app.
class SplashScreen extends ConsumerWidget {
  /// Crea una instancia de [SplashScreen].
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.d('AppRouter.Splash - SplashScreen: Build started');
    final widget = const Scaffold(
      backgroundColor: ArcinusColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo adaptativo al tema
            AdaptiveLogo(size: 150),
            SizedBox(height: 24),
            Text(
              'Arcinus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ArcinusColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
    _logger.d('AppRouter.Splash - SplashScreen: Build finished');
    return widget;
  }
}
