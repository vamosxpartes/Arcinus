import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/create_academy_provider.dart';
import 'package:arcinus/features/theme/ui/loading/loading_indicator.dart'; // Usar el mismo LoadingIndicator
import 'package:arcinus/features/theme/ui/feedback/error_display.dart'; // Usar el mismo ErrorDisplay
import 'package:go_router/go_router.dart'; // Importar GoRouter
import 'package:arcinus/core/navigation/app_routes.dart'; // Importar rutas de la app
import 'package:arcinus/core/utils/app_logger.dart';

class CreateAcademyScreen extends ConsumerWidget {
  const CreateAcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(createAcademyProvider.notifier);
    final state = ref.watch(createAcademyProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    // Extraer errores específicos del estado si existen
    String? nameErrorFromState;
    String? sportCodeErrorFromState;
    state.maybeWhen(
      error: (failure, nameError, sportCodeError) {
        nameErrorFromState = nameError;
        sportCodeErrorFromState = sportCodeError;
      },
      orElse: () {},
    );

    // Escuchar para mostrar errores como Snackbars (además del ErrorDisplay)
    ref.listen(createAcademyProvider, (previous, next) {
      next.maybeWhen(
        error: (failure, nameError, sportCodeError) {
          // Comprobar si el estado anterior NO era initial o error
          final wasNotInitialOrError = !(previous?.maybeMap(
                initial: (_) => true,
                error: (_) => true,
                orElse: () => false) ?? false);
          
          if (wasNotInitialOrError) {
            ScaffoldMessenger.of(context).showSnackBar(
              // Usar el mensaje del Failure
              SnackBar(content: Text('Error: ${failure.message}')), 
            );
          }
        },
        success: (academyId) {
          // La navegación debería ocurrir automáticamente por GoRouter.redirect
          AppLogger.logInfo('Academia creada con éxito ID: $academyId. GoRouter debería redirigir.');
          
          // Redirección manual al dashboard del propietario
          AppLogger.logInfo('Forzando redirección manual a la ruta del propietario');
          context.go(AppRoutes.ownerRoot);
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Academia'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: notifier.formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: notifier.nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Academia',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.business_rounded),
                      errorText: nameErrorFromState,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre de la academia';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: notifier.selectedSportCode, // Valor seleccionado actual
                    hint: const Text('Selecciona un Deporte'),
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Selecciona un Deporte',
                      hintText: 'Selecciona un Deporte',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.sports_soccer),
                      errorText: sportCodeErrorFromState,
                    ),
                    items: notifier.availableSports.map((sport) {
                      return DropdownMenuItem<String>(
                        value: sport['code']!,
                        child: Text(sport['name']!),
                      );
                    }).toList(),
                    onChanged: isLoading ? null : (value) {
                      notifier.selectSport(value);
                      // Forzar reconstrucción para actualizar visualmente el dropdown si es necesario
                      // Esto es un workaround, idealmente el estado del notifier manejaría esto.
                      // O usar un StateProvider local para el valor del dropdown.
                      (context as Element).markNeedsBuild(); 
                    },
                     validator: (value) {
                       if (value == null) {
                         return 'Debes seleccionar un deporte';
                       }
                       return null;
                     },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : notifier.createAcademy,
                    icon: const Icon(Icons.save),
                    label: const Text('Crear Academia'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  // Mostrar widget de error si el estado es error
                  state.maybeWhen(
                    error: (failure, nameError, sportCodeError) => Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      // Pasar el mensaje del failure genérico
                      child: ErrorDisplay(error: failure.message),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          // Indicador de carga superpuesto
          if (isLoading)
            const LoadingIndicator(message: 'Creando academia...'),
        ],
      ),
    );
  }
} 