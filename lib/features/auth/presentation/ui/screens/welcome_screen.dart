import 'package:arcinus/core/constants/app_assets.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/core/theme/ux/arcinus_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de bienvenida que permite al usuario elegir su rol inicial.
///
/// Esta pantalla se muestra después del splash cuando el usuario no está autenticado.
class WelcomeScreen extends ConsumerWidget {
  /// Crea una instancia de [WelcomeScreen].
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo y título
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.logoWhite,
                      height: size.height * 0.2,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bienvenido a Arcinus',
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'La plataforma integral para gestionar academias deportivas',
                      style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Texto explicativo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  '¿Cómo deseas comenzar?',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Botones de selección de rol
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Botón para propietarios
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ArcinusColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.push(AppRoutes.login),
                        child: const Text('SOY PROPIETARIO'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botón para miembros/invitados
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ArcinusColors.primaryBlue),
                          foregroundColor: ArcinusColors.primaryBlue,
                        ),
                        onPressed: () => context.push(AppRoutes.memberAccess),
                        child: const Text('SOY MIEMBRO'),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Texto de política de privacidad y términos
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(
                  'Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 