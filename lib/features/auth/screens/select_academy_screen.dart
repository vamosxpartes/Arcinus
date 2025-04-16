import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/models/academy_model.dart';
import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:arcinus/features/theme/components/feedback/error_display.dart';
import 'package:arcinus/features/theme/components/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SelectAcademyScreen extends HookConsumerWidget {
  const SelectAcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academiesAsyncValue = ref.watch(allAcademiesProvider);
    final searchQuery = useState('');
    final filteredAcademies = useState<List<Academy>>([]);

    // Filtrar academias cuando cambie la búsqueda o la lista original
    useEffect(() {
      if (academiesAsyncValue.hasValue) {
        final lowerCaseQuery = searchQuery.value.toLowerCase();
        filteredAcademies.value = academiesAsyncValue.value!
            .where((academy) =>
                academy.academyName.toLowerCase().contains(lowerCaseQuery))
            .toList();
      } else {
        filteredAcademies.value = [];
      }
      return null; // No cleanup needed
    }, [academiesAsyncValue, searchQuery.value]);

    void selectAcademy(Academy academy) {
      developer.log(
          'INFO: Academia seleccionada: ${academy.academyName} (${academy.academyId})', name: 'SelectAcademy');
      // Navegar a la pantalla de activación, pasando el ID
      Navigator.of(context).pushNamed('/activate', arguments: academy.academyId);
    }

    return BaseScaffold(
      showNavigation: false, // No mostrar barra inferior antes del login
      appBar: AppBar(
        title: const Text('Selecciona tu Academia'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                searchQuery.value = value;
              },
              decoration: InputDecoration(
                labelText: 'Buscar academia por nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: academiesAsyncValue.when(
              data: (academies) {
                if (academies.isEmpty) {
                  return const Center(
                      child: Text('No se encontraron academias.'));
                }
                if (filteredAcademies.value.isEmpty &&
                    searchQuery.value.isNotEmpty) {
                  return Center(
                      child: Text(
                          'No se encontraron academias para "${searchQuery.value}".'));
                }
                return ListView.builder(
                  itemCount: filteredAcademies.value.length,
                  itemBuilder: (context, index) {
                    final academy = filteredAcademies.value[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          // Mostrar inicial o logo si existe
                          child: academy.academyLogo == null
                              ? Text(academy.academyName.isNotEmpty ? academy.academyName[0] : '?')
                              : ClipOval(
                                  child: Image.network(
                                    academy.academyLogo!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(academy.academyName.isNotEmpty ? academy.academyName[0] : '?'),
                                  ),
                                ),
                        ),
                        title: Text(academy.academyName),
                        subtitle: Text(academy.academySport),
                        onTap: () => selectAcademy(academy),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) {
                developer.log(
                    'ERROR: Error cargando academias: $error', name: 'SelectAcademy', stackTrace: stack);
                return Center(
                    child: ErrorDisplay(error: 'Error al cargar academias: $error'));
              },
            ),
          ),
        ],
      ),
    );
  }
} 