import 'dart:developer' as developer;

import 'package:arcinus/core/constants/app_assets.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/ui/widgets/auth_error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Pantalla para registrar un nuevo usuario.
///
/// Utiliza [ReactiveForm] para manejar el formulario y se integra con
/// los providers de autenticación de Riverpod.
class RegisterScreen extends ConsumerStatefulWidget {
  /// Crea una instancia de [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _isLoading = false;
  final _formGroup = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
    'confirmPassword': FormControl<String>(
      validators: [Validators.required],
    ),
  }, validators: [
    Validators.mustMatch('password', 'confirmPassword'),
  ]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Observar el estado de autenticación para mostrar errores
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Arcinus
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Image.asset(
                AppAssets.logoBlack,
                height: 80,
              ),
            ),

            Text(
              'Crea tu cuenta',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Regístrate para comenzar a gestionar tu academia deportiva',
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Formulario
            ReactiveForm(
              formGroup: _formGroup,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email
                  ReactiveTextField<String>(
                    formControlName: 'email',
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validationMessages: {
                      'required': (error) => 'El correo electrónico es obligatorio',
                      'email': (error) => 'Por favor ingresa un correo electrónico válido',
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  ReactiveTextField<String>(
                    formControlName: 'password',
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validationMessages: {
                      'required': (error) => 'La contraseña es obligatoria',
                      'minLength': (error) => 'La contraseña debe tener al menos 6 caracteres',
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  ReactiveTextField<String>(
                    formControlName: 'confirmPassword',
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validationMessages: {
                      'required': (error) => 'Por favor confirma tu contraseña',
                      'passwordsNotMatch': (error) => 'Las contraseñas no coinciden',
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mostrar errores de auth si los hay
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: authState.hasError && !_isLoading
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AuthErrorMessage(authState: authState),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Botón de registro
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: textTheme.titleMedium,
                      ),
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                  if (_formGroup.valid) {
                                    _register();
                                  } else {
                                    _formGroup.markAllAsTouched();
                                  }
                                },
                      child:
                          _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('CREAR CUENTA'),
                    ),
                  ),
                ],
              ),
            ),

            // Opción de iniciar sesión
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿Ya tienes una cuenta?', style: textTheme.bodyMedium),
                  SizedBox(
                    width: 100, // Ancho fijo para el botón
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: const Text('Inicia sesión'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final values = _formGroup.value;
      final email = values['email']! as String;
      final password = values['password']! as String;

      await ref
          .read(authStateNotifierProvider.notifier)
          .createUserWithEmailAndPassword(email, password);

      // La navegación se manejará en el router basado en el estado de autenticación
    } catch (e) {
      // El error ya se ha manejado en el notifier y se mostrará a través del estado
      developer.log('Error durante el registro: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _formGroup.dispose();
    super.dispose();
  }
} 