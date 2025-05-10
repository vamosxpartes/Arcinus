import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget de ejemplo que muestra cómo usar el provider currentAcademyProvider
class CurrentAcademyExampleWidget extends ConsumerWidget {
  const CurrentAcademyExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener la academia actual (objeto completo)
    final AcademyModel? currentAcademy = ref.watch(currentAcademyProvider);
    
    // Si no hay academia seleccionada, mostrar un mensaje
    if (currentAcademy == null) {
      return const Center(
        child: Text('No hay academia seleccionada'),
      );
    }
    
    // Mostrar detalles de la academia actual
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID: ${currentAcademy.id}'),
        Text('Nombre: ${currentAcademy.name}'),
        Text('Deporte: ${currentAcademy.sportCode}'),
        Text('Descripción: ${currentAcademy.description}'),
        Text('Dirección: ${currentAcademy.address}'),
      ],
    );
  }
}

/// Ejemplo de cómo modificar la academia actual
void exampleSetCurrentAcademy(WidgetRef ref, AcademyModel academy) {
  // Establecer directamente el objeto AcademyModel completo
  ref.read(currentAcademyProvider.notifier).state = academy;
}

/// Ejemplo de cómo obtener el objeto AcademyModel actual
AcademyModel? exampleGetCurrentAcademy(WidgetRef ref) {
  return ref.read(currentAcademyProvider);
}

/// Ejemplo de obtener solo el ID de la academia actual
String? exampleGetCurrentAcademyId(WidgetRef ref) {
  final currentAcademy = ref.read(currentAcademyProvider);
  return currentAcademy?.id;
} 