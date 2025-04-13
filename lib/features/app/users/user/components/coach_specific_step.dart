import 'package:arcinus/features/app/users/user/core/services/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoachSpecificStep extends ConsumerWidget {
  const CoachSpecificStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userFormProvider);
    final formNotifier = ref.read(userFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Experiencia y especialización:'),
        const SizedBox(height: 24),
        
        // Años de experiencia
        TextFormField(
          initialValue: formState.experienceYears.toString(),
          decoration: const InputDecoration(
            labelText: 'Años de experiencia',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final years = int.tryParse(value) ?? 0;
            formNotifier.updateExperienceYears(years);
          },
        ),
        const SizedBox(height: 16),
        
        // Especialidades
        TextFormField(
          initialValue: formState.specialties,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Especialidades',
            prefixIcon: Icon(Icons.sports),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: (value) => formNotifier.updateSpecialties(value),
        ),
        const SizedBox(height: 16),
        
        // Certificaciones
        TextFormField(
          initialValue: formState.certifications,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Certificaciones (opcional)',
            prefixIcon: Icon(Icons.card_membership),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: (value) => formNotifier.updateCertifications(value),
        ),
      ],
    );
  }
} 