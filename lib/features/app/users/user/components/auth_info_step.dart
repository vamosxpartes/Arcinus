import 'package:arcinus/features/app/users/user/core/services/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInfoStep extends ConsumerWidget {
  const AuthInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {    ref.read(userFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información de pre-registro:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Se generará un código de activación para el usuario. El usuario deberá usar este código para activar su cuenta proporcionando su correo electrónico y contraseña durante el proceso de activación.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withAlpha(100)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Información', 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'El usuario recibirá un código de activación que deberá utilizar para completar su registro. Durante la activación, proporcionará su correo electrónico y establecerá su contraseña.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 