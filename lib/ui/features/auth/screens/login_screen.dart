import 'dart:developer' as developer;

import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // Variables para control de errores
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  
  // Resetear todos los errores
  void _resetErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
  }

  Future<void> _signIn() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) return;
    
    // Resetear errores previos
    _resetErrors();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authStateProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;
      // La navegación se maneja en ArcinusApp con base en el estado de autenticación
    } catch (e) {
      if (!mounted) return;
      
      // Manejar diferentes tipos de errores de autenticación
      String errorMessage = e.toString().toLowerCase();
      String finalEmailError = ''; // Usar variables locales temporales
      String finalPasswordError = '';
      String finalGeneralError = '';
      
      // Errores específicos para email
      if (errorMessage.contains('user-not-found') || 
          errorMessage.contains('usuario no encontrado')) {
        finalEmailError = 'Correo electrónico no registrado.';
      } 
      // Errores específicos para contraseña
      else if (errorMessage.contains('wrong-password') || 
               errorMessage.contains('contraseña incorrecta')) {
        finalPasswordError = 'Contraseña incorrecta.';
      }
      // Caso específico para credenciales inválidas (email o contraseña incorrectos)
      else if (errorMessage.contains('invalid-credential') || // Detectar por código Firebase
               errorMessage.contains('credenciales inválidas')) { // Detectar por nuestro mensaje
        finalGeneralError = 'El correo electrónico o la contraseña son incorrectos.';
      }
      // Cuenta deshabilitada
      else if (errorMessage.contains('user-disabled') ||
               errorMessage.contains('usuario deshabilitado')) {
        finalGeneralError = 'Esta cuenta ha sido deshabilitada. Contacta con soporte si crees que es un error.';
      }
      // Demasiados intentos
      else if (errorMessage.contains('too-many-requests') ||
               errorMessage.contains('demasiados intentos')) {
        finalGeneralError = 'Demasiados intentos. Por seguridad, espera un momento y vuelve a intentarlo.';
      }
      // Errores de red
      else if (errorMessage.contains('network-request-failed') ||
               errorMessage.contains('error de red')) {
        finalGeneralError = 'Error de conexión. Revisa tu conexión a internet.';
      }
      // Error general para otros casos
      else {
        // Evitar mostrar el error técnico directamente al usuario
        finalGeneralError = 'Ocurrió un error inesperado al iniciar sesión. Por favor, inténtalo de nuevo.';
        // Loguear el error real para depuración
        developer.log('Error de inicio de sesión no manejado específicamente: $e');
      }
      
      // Actualizar el estado con los errores finales
      setState(() {
        _emailError = finalEmailError.isNotEmpty ? finalEmailError : null;
        _passwordError = finalPasswordError.isNotEmpty ? finalPasswordError : null;
        _generalError = finalGeneralError.isNotEmpty ? finalGeneralError : null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  constraints: BoxConstraints(minHeight: screenHeight - 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Logo
                      Image.asset(
                        isDarkMode ? 'assets/icons/Logo_white.png' : 'assets/icons/Logo_black.png',
                        height: 120,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.sports, size: 120),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Títulos
                      Text(
                        'Bienvenido',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Entrena, compite y alcanza tus objetivos deportivos con Arcinus',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color?.withAlpha(180),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Botón de inicio de sesión
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signin');
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Botón de registro
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: theme.colorScheme.primary),
                          ),
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 