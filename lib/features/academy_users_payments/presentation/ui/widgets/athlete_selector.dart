import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/auth/data/models/user_model.dart';

/// Widget para seleccionar un atleta de la lista de atletas de la academia
class AthleteSelector extends ConsumerWidget {
  final String? selectedAthleteId;
  final ValueChanged<String?> onAthleteChanged;
  final AsyncValue<List<UserModel>> athletesAsyncValue;

  const AthleteSelector({
    super.key,
    required this.selectedAthleteId,
    required this.onAthleteChanged,
    required this.athletesAsyncValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return athletesAsyncValue.when(
      data: (athletes) {
        if (athletes.isEmpty) {
          return const Card(
            color: Colors.orange,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay atletas registrados en la academia',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Atleta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Atleta',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: 'Selecciona un atleta...',
              ),
              value: selectedAthleteId,
              items: athletes.map((athlete) {
                return DropdownMenuItem<String>(
                  value: athlete.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          (athlete.displayName ?? athlete.email).substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              athlete.displayName ?? 'Sin nombre',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              athlete.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onAthleteChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debes seleccionar un atleta';
                }
                return null;
              },
              isExpanded: true,
              menuMaxHeight: 300,
            ),
          ],
        );
      },
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccionar Atleta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Cargando atletas...'),
                ],
              ),
            ),
          ),
        ],
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccionar Atleta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.red.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Error al cargar atletas',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error.toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 