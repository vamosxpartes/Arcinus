import 'package:arcinus/core/constants/app_assets.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/ui/widgets/auth_error_message.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Pantalla para iniciar sesión utilizando correo electrónico y contraseña.
///
/// Utiliza [ReactiveForm] para manejar el formulario y se integra con
/// los providers de autenticación de Riverpod.
class LoginScreen extends ConsumerStatefulWidget {
  /// Crea una instancia de [LoginScreen].
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  final _formGroup = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // Observar el estado de autenticación para mostrar errores
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      // AppBar opcional, se puede quitar si el diseño no lo requiere
      // appBar: AppBar(title: const Text('Iniciar sesión'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32), // Mayor padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Centrar horizontalmente
          children: [
            // Logo Arcinus
            Padding(
              padding: const EdgeInsets.only(bottom: 48), // Mayor espacio inferior
              child: Image.asset(
                AppAssets.logoBlack, // Usar el logo correcto desde AppAssets
                height: 120, // Ajustar tamaño según sea necesario
                // Considerar añadir color para visibilidad en tema oscuro si es necesario
                // color: theme.brightness == Brightness.dark ? Colors.white : null,
              ),
            ),

            Text(
              'Bienvenido a Arcinus',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia sesión para continuar',
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
               textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Formulario
            ReactiveForm(
              formGroup: _formGroup,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Estirar widgets internos
                children: [
                  // Email
                  ReactiveTextField<String>(
                    formControlName: 'email',
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(), // Estilo de borde
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validationMessages: {
                      'required':
                          (error) => 'El correo electrónico es obligatorio',
                      'email':
                          (error) =>
                              'Por favor ingresa un correo electrónico válido',
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
                       border: OutlineInputBorder(), // Estilo de borde
                    ),
                    validationMessages: {
                      'required': (error) => 'La contraseña es obligatoria',
                      'minLength':
                          (error) =>
                              'La contraseña debe tener al menos 6 caracteres',
                    },
                  ),
                  const SizedBox(height: 16), // Espacio antes del error

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

                  // Botón de iniciar sesión
                  SizedBox(
                    width: double.infinity,
                    height: 52, // Botón más alto
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: textTheme.titleMedium, // Texto más grande
                      ),
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                if (_formGroup.valid) {
                                  _login();
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
                              : const Text('INICIAR SESIÓN'),
                    ),
                  ),
                ],
              ),
            ),

            // Opción de Registrarse
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿No tienes una cuenta?', style: textTheme.bodyMedium),
                  SizedBox(
                    width: 100, // Ancho fijo para el botón
                    child: TextButton(
                      onPressed: () {
                        // Navegar a la pantalla de registro
                        context.push(AppRoutes.register);
                      },
                      child: const Text('Regístrate'),
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

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final values = _formGroup.value;
      final email = values['email']! as String;
      final password = values['password']! as String;

      await ref
          .read(authStateNotifierProvider.notifier)
          .signInWithEmailAndPassword(email, password);

      // No necesitamos manejar la navegación aquí;
      // se manejará en el router basado en el estado de autenticación
    } catch (e, s) {
      // El error ya se ha manejado en el notifier y se mostrará a través del estado
      AppLogger.logError(
        message: 'Error durante el login',
        error: e,
        stackTrace: s
      );
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
