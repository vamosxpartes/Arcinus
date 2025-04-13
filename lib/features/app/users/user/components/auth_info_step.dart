import 'package:arcinus/features/app/users/user/core/services/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInfoStep extends ConsumerWidget {
  const AuthInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userFormProvider);
    final formNotifier = ref.read(userFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Información de autenticación:'),
        const Text(
          'Estos datos serán utilizados para que el usuario pueda acceder al sistema.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        // Email
        TextFormField(
          initialValue: formState.email,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa un correo electrónico';
            }
            if (!value.contains('@')) {
              return 'Por favor ingresa un correo electrónico válido';
            }
            return null;
          },
          onChanged: (value) => formNotifier.updateEmail(value),
        ),
        const SizedBox(height: 16),
        
        // Contraseña
        TextFormField(
          initialValue: formState.password,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
          onChanged: (value) => formNotifier.updatePassword(value),
        ),
        const SizedBox(height: 16),
        
        // Opción para generar contraseña automática
        CheckboxListTile(
          title: const Text('Generar contraseña aleatoria'),
          subtitle: const Text('Se enviará por correo electrónico'),
          value: false,
          onChanged: (value) {
            // Implementar generación de contraseña
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
} 