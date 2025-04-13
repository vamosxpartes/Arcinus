import 'package:arcinus/features/app/users/user/core/services/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactInfoStep extends ConsumerWidget {
  const ContactInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userFormProvider);
    final formNotifier = ref.read(userFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Información de contacto:'),
        const SizedBox(height: 24),
        
        // Teléfono
        TextFormField(
          initialValue: formState.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => formNotifier.updatePhone(value),
        ),
        const SizedBox(height: 16),
        
        // Dirección
        TextFormField(
          initialValue: formState.address,
          decoration: const InputDecoration(
            labelText: 'Dirección (opcional)',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => formNotifier.updateAddress(value),
        ),
        const SizedBox(height: 16),
        
        // Contacto de emergencia
        TextFormField(
          initialValue: formState.emergencyContact,
          decoration: const InputDecoration(
            labelText: 'Contacto de emergencia (opcional)',
            prefixIcon: Icon(Icons.emergency),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => formNotifier.updateEmergencyContact(value),
        ),
      ],
    );
  }
} 