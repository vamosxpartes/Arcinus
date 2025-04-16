import 'dart:developer' as developer;

import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ActivationScreen extends HookConsumerWidget {
  final String academyId;
  
  const ActivationScreen({super.key, required this.academyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeController = useTextEditingController();
    final isVerifying = useState(false);
    final isCompleting = useState(false);
    final preRegisteredData = useState<Map<String, dynamic>?>(null);
    
    final registrationForm = useMemoized(() => FormGroup({
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
        ],
      ),
      'confirmPassword': FormControl<String>(validators: [Validators.required]),
    }, validators: [
      Validators.mustMatch('password', 'confirmPassword'),
    ]));
    
    Future<void> verifyCode() async {
      final code = codeController.text.trim();
      if (code.isEmpty) return;
      
      isVerifying.value = true;
      preRegisteredData.value = null;
      
      try {
        final result = await ref.read(verifyPendingActivationProvider(
          academyId: academyId,
          activationCode: code,
        ).future);
        
        if (result == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código de activación inválido o expirado para esta academia'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          preRegisteredData.value = result;
        }
      } catch (e) {
        if (context.mounted) { 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al verificar: $e')),
          );
        }
        developer.log('ERROR: ActivationScreen - Error al verificar código: $e', name: 'Activation');
      } finally {
        isVerifying.value = false;
      }
    }
    
    Future<void> completeRegistration() async {
      if (registrationForm.invalid || preRegisteredData.value == null) return;
      
      isCompleting.value = true;
      
      try {
        final email = registrationForm.control('email').value as String;
        final password = registrationForm.control('password').value as String;
        final code = codeController.text.trim();

        await ref.read(completeActivationWithCodeProvider(
          academyId: academyId,
          activationCode: code, 
          email: email,
          password: password,
        ).future);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta activada! Ahora puede iniciar sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          await Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (context.mounted) {  
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al activar: $e')),
          );
        }
        developer.log('ERROR: ActivationScreen - Error al completar registro: $e', name: 'Activation');
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
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: preRegisteredData.value == null
                    ? _buildCodeVerification(
                        context,
                        codeController,
                        isVerifying.value,
                        verifyCode,
                      )
                    : _buildRegistrationSetup(
                        context,
                        registrationForm,
                        preRegisteredData.value!,
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
          color: Colors.blueAccent,
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
          'Ingrese el código de activación proporcionado.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Código de Activación',
            prefixIcon: Icon(Icons.code),
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isVerifying ? null : onVerify,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: isVerifying
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                )
              : const Text('Verificar Código', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
  
  Widget _buildRegistrationSetup(
    BuildContext context,
    FormGroup registrationForm,
    Map<String, dynamic> preRegData,
    bool isCompleting,
    VoidCallback onComplete,
  ) {
    final name = preRegData['name'] as String? ?? 'Usuario';
    
    return ReactiveForm(
      formGroup: registrationForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.person_add_alt_1_outlined,
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
          const SizedBox(height: 8),
          Text(
            'Bienvenido/a, $name',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Completa tu registro estableciendo tu correo y contraseña:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ReactiveTextField(
            formControlName: 'email',
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validationMessages: {
              ValidationMessage.required: (error) => 'El correo es requerido',
              ValidationMessage.email: (error) => 'Ingresa un correo válido',
            },
          ),
          const SizedBox(height: 16),
          ReactiveTextField(
            formControlName: 'password',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              helperText: 'Mínimo 8 caracteres',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validationMessages: {
              ValidationMessage.required: (error) => 'La contraseña es requerida',
              ValidationMessage.minLength: (error) => 'Debe tener al menos 8 caracteres',
            },
          ),
          const SizedBox(height: 16),
          ReactiveTextField(
            formControlName: 'confirmPassword',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            validationMessages: {
              ValidationMessage.required: (error) => 'Confirma la contraseña',
              ValidationMessage.mustMatch: (error) => 'Las contraseñas no coinciden',
            },
          ),
          const SizedBox(height: 32),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              return ElevatedButton(
                onPressed: (isCompleting || form.invalid) ? null : onComplete,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isCompleting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : const Text('Activar Cuenta', style: TextStyle(fontSize: 16)),
              );
            },
          ),
        ],
      ),
    );
  }
} 