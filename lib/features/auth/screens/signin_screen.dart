import 'dart:developer' as developer;

import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
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
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Botón de retroceso en la esquina superior izquierda
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            
            // Contenido principal
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Logo
                    Image.asset(
                      isDarkMode ? 'assets/icons/Logo_white.png' : 'assets/icons/Logo_black.png',
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.sports, size: 100),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Texto de bienvenida
                    Text(
                      '¡Bienvenido de vuelta!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Subtítulo
                    Text(
                      'Inicia sesión para continuar gestionando tu academia',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withAlpha(180),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Mostrar error general si existe
                    if (_generalError != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.error),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _generalError!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo de email
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                hintText: 'ejemplo@correo.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                errorText: _emailError,
                                errorStyle: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              onChanged: (value) {
                                if (_emailError != null) {
                                  setState(() {
                                    _emailError = null;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu correo electrónico';
                                }
                                if (!value.contains('@')) {
                                  return 'Por favor ingresa un correo electrónico válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Campo de contraseña
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword 
                                        ? Icons.visibility_outlined 
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                errorText: _passwordError,
                                errorStyle: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              onChanged: (value) {
                                if (_passwordError != null) {
                                  setState(() {
                                    _passwordError = null;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Olvidé mi contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/forgot-password');
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botón de inicio de sesión
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 