import 'package:arcinus/ux/features/auth/providers/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhysicalInfoStep extends ConsumerWidget {
  const PhysicalInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userFormProvider);
    final formNotifier = ref.read(userFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Información física:'),
        const SizedBox(height: 24),
        
        // Altura
        TextFormField(
          initialValue: formState.height,
          decoration: const InputDecoration(
            labelText: 'Altura (cm)',
            prefixIcon: Icon(Icons.height),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa la altura';
            }
            return null;
          },
          onChanged: (value) => formNotifier.updateHeight(value),
        ),
        const SizedBox(height: 16),
        
        // Peso
        TextFormField(
          initialValue: formState.weight,
          decoration: const InputDecoration(
            labelText: 'Peso (kg)',
            prefixIcon: Icon(Icons.monitor_weight_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el peso';
            }
            return null;
          },
          onChanged: (value) => formNotifier.updateWeight(value),
        ),
        const SizedBox(height: 16),
        
        // Condiciones médicas
        TextFormField(
          initialValue: formState.medicalConditions,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Condiciones médicas (opcional)',
            prefixIcon: Icon(Icons.medical_services_outlined),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: (value) => formNotifier.updateMedicalConditions(value),
        ),
      ],
    );
  }
} 