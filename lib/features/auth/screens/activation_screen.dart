import 'dart:developer' as developer;

import 'package:arcinus/features/auth/core/providers/pre_registration_providers.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ActivationScreen extends HookConsumerWidget {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeController = useTextEditingController();
    final isVerifying = useState(false);
    final isCompleting = useState(false);
    final preRegisteredUser = useState<dynamic>(null);
    
    // Formulario para la contraseña
    final passwordForm = useMemoized(() => FormGroup({
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
          Validators.pattern(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$'),
        ],
      ),
      'confirmPassword': FormControl<String>(validators: [Validators.required]),
    }, validators: [
      Validators.mustMatch('password', 'confirmPassword'),
    ]));
    
    // Verificar código de activación
    Future<void> verifyCode() async {
      final code = codeController.text.trim();
      if (code.isEmpty) return;
      
      isVerifying.value = true;
      
      try {
        final result = await ref.read(verifyActivationCodeProvider(code).future);
        
        
        if (result == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código de activación inválido o expirado'),
              backgroundColor: Colors.red,
            ),
          );}
        } else {
          preRegisteredUser.value = result;
        }
      } catch (e) {
        if (context.mounted) { 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        developer.log('ERROR: ActivationScreen - Error al verificar código: $e - lib/features/auth/screens/activation_screen.dart - verifyCode');
      } finally {
        isVerifying.value = false;
      }
    }
    
    // Completar el registro
    Future<void> completeRegistration() async {
      if (passwordForm.invalid || preRegisteredUser.value == null) return;
      
      isCompleting.value = true;
      
      try {
        final password = passwordForm.control('password').value as String;
        
        await ref.read(completeRegistrationProvider(
          activationCode: preRegisteredUser.value['activationCode'] as String,
          password: password,
        ).future);
        
        // Registro exitoso, mostrar mensaje y redirigir al login
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro completado! Ahora puede iniciar sesión.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Redirigir al login después de un breve retraso
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
      } catch (e) {
        if (context.mounted) {  
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        developer.log('ERROR: ActivationScreen - Error al completar registro: $e - lib/features/auth/screens/activation_screen.dart - completeRegistration');
      } finally {
        isCompleting.value = false;
      }
    }
    
    return BaseScaffold(
      showNavigation: false,
      appBar: AppBar(
        title: const Text('Activar Cuenta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: preRegisteredUser.value == null
                    ? _buildCodeVerification(
                        context,
                        codeController,
                        isVerifying.value,
                        verifyCode,
                      )
                    : _buildPasswordSetup(
                        context,
                        passwordForm,
                        preRegisteredUser.value,
                        isCompleting.value,
                        completeRegistration,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Widget para verificación de código
  Widget _buildCodeVerification(
    BuildContext context,
    TextEditingController codeController,
    bool isVerifying,
    VoidCallback onVerify,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.vpn_key_outlined,
          size: 64,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        const Text(
          'Activación de Cuenta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ingrese el código de activación proporcionado por el administrador.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Código de Activación',
            hintText: 'Ejemplo: ABC12345',
            prefixIcon: Icon(Icons.code),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isVerifying ? null : onVerify,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: isVerifying
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verificar Código'),
        ),
      ],
    );
  }
  
  // Widget para configuración de contraseña
  Widget _buildPasswordSetup(
    BuildContext context,
    FormGroup passwordForm,
    dynamic user,
    bool isCompleting,
    VoidCallback onComplete,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.person_add_outlined,
          size: 64,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Código Verificado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Bienvenido/a, ${user['name'] as String}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          user['email'] as String,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rol: ${_getRoleName(user['role'])}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Complete su registro estableciendo una contraseña:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        ReactiveForm(
          formGroup: passwordForm,
          child: Column(
            children: [
              ReactiveTextField<String>(
                formControlName: 'password',
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 8 caracteres',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  'required': (error) => 'La contraseña es obligatoria',
                  'minLength': (error) => 'Mínimo 8 caracteres',
                  'pattern': (error) => 'Debe contener mayúsculas, minúsculas y números',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField<String>(
                formControlName: 'confirmPassword',
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  'required': (error) => 'Debe confirmar su contraseña',
                  'mustMatch': (error) => 'Las contraseñas no coinciden',
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            return ElevatedButton(
              onPressed: form.valid && !isCompleting ? onComplete : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: isCompleting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Completar Registro',
                      style: TextStyle(fontSize: 16),
                    ),
            );
          },
        ),
      ],
    );
  }
  
  String _getRoleName(dynamic role) {
    final roleStr = role.toString();
    if (roleStr.contains('owner')) return 'Propietario';
    if (roleStr.contains('manager')) return 'Gerente';
    if (roleStr.contains('coach')) return 'Entrenador';
    if (roleStr.contains('athlete')) return 'Atleta';
    if (roleStr.contains('parent')) return 'Padre/Tutor';
    if (roleStr.contains('superAdmin')) return 'Administrador';
    return 'Usuario';
  }
} 