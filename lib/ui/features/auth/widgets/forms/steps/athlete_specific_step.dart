import 'package:arcinus/ux/features/auth/providers/user_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AthleteSpecificStep extends ConsumerWidget {
  const AthleteSpecificStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(userFormProvider);
    final formNotifier = ref.read(userFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Información deportiva:'),
        const SizedBox(height: 24),
        
        // Nivel
        DropdownButtonFormField<String>(
          value: formState.level.isEmpty ? null : formState.level,
          decoration: const InputDecoration(
            labelText: 'Nivel',
            prefixIcon: Icon(Icons.insights),
            border: OutlineInputBorder(),
          ),
          items: ['Principiante', 'Intermedio', 'Avanzado', 'Elite']
              .map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              formNotifier.updateLevel(value);
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Objetivos
        TextFormField(
          initialValue: formState.goals,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Objetivos',
            prefixIcon: Icon(Icons.flag),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: (value) => formNotifier.updateGoals(value),
        ),
        const SizedBox(height: 16),
        
        // Asignar a grupo
        DropdownButtonFormField<String>(
          value: formState.groupId.isEmpty ? null : formState.groupId,
          decoration: const InputDecoration(
            labelText: 'Asignar a grupo (opcional)',
            prefixIcon: Icon(Icons.group),
            border: OutlineInputBorder(),
          ),
          items: ['Grupo A', 'Grupo B', 'Grupo C']
              .map((group) => DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              formNotifier.updateGroupId(value);
            }
          },
        ),
      ],
    );
  }
} 