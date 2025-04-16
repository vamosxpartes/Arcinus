import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

class PreRegisterScreen extends HookConsumerWidget {
  const PreRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    
    // Form para crear nuevo pre-registro
    final form = useMemoized(() => FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'role': FormControl<UserRole>(validators: [Validators.required]),
    }));
    
    final isCreating = useState(false);
    final createdCode = useState<String?>(null);
    
    // Función para crear un nuevo pre-registro
    Future<void> createNewPreRegistration() async {
      if (form.invalid || currentUser == null) return;
      
      final currentAcademyId = ref.read(currentAcademyIdProvider);
      if (currentAcademyId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: No se pudo determinar la academia actual.')),
            );
          }
          developer.log('ERROR: PreRegisterScreen - academyId es nulo al crear pre-registro');
          return;
      }
      // Asignar a variable local no nula para ayudar al linter
      final String academyId = currentAcademyId;
      
      isCreating.value = true;
      createdCode.value = null;
      
      try {
        final name = form.control('name').value as String;
        final role = form.control('role').value as UserRole;
        
        // Usar el provider correcto: createPendingActivationProvider
        final String activationCode = await ref.read(createPendingActivationProvider(
          academyId: academyId, // Pasar la variable local no nula
          userName: name,
          role: role,
          createdBy: currentUser.id // Linter puede marcar esto, pero la lógica es correcta
        ).future);
        
        createdCode.value = activationCode;
        form.reset();
        
        developer.log('DEBUG: PreRegisterScreen - Usuario pre-registrado creado con código: $activationCode - lib/features/auth/screens/pre_register_screen.dart - createNewPreRegistration');
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear pre-registro: $e')),
          );
        }
        developer.log('ERROR: PreRegisterScreen - Error al crear pre-registro: $e - lib/features/auth/screens/pre_register_screen.dart - createNewPreRegistration');
      } finally {
        isCreating.value = false;
      }
    }
    
    // Función para eliminar un pre-registro (Comentada - Provider inexistente)
    /*
    Future<void> deletePreRegistration(String id) async {
      try {
        await ref.read(deletePreRegisteredUserProvider(id).future);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pre-registro eliminado')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
    */
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-registro de Usuarios'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulario de pre-registro
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crear Nuevo Pre-registro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReactiveForm(
                      formGroup: form,
                      child: Column(
                        children: [
                          ReactiveTextField<String>(
                            formControlName: 'name',
                            decoration: const InputDecoration(
                              labelText: 'Nombre Completo',
                              hintText: 'Nombre y Apellido',
                            ),
                            validationMessages: {
                              'required': (error) => 'El nombre es obligatorio',
                            },
                          ),
                          const SizedBox(height: 16),
                          ReactiveDropdownField<UserRole>(
                            formControlName: 'role',
                            items: UserRole.values
                                .where((role) => role != UserRole.superAdmin && role != UserRole.guest)
                                .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(_getRoleName(role)),
                                ))
                                .toList(),
                            decoration: const InputDecoration(
                              labelText: 'Rol del Usuario',
                            ),
                            validationMessages: {
                              'required': (error) => 'El rol es obligatorio',
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isCreating.value ? null : createNewPreRegistration,
                            child: isCreating.value 
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Crear Pre-registro'),
                          ),
                        ],
                      ),
                    ),
                    
                    // Mostrar código si se creó uno
                    if (createdCode.value != null) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Pre-registro creado!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Comparta este código con el usuario:',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SelectableText(
                              createdCode.value!,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: createdCode.value!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Código copiado al portapapeles'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              tooltip: 'Copiar código',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),            // Mostrar mensaje temporal mientras no se implementa el listado
             const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Funcionalidad de listar/eliminar pre-registros pendiente de implementación.'),
             )),
          ],
        ),
      ),
    );
  }
  
  String _getRoleName(UserRole? role) {
    if (role == null) return 'Rol desconocido';
    switch (role) {
      case UserRole.owner:
        return 'Propietario';
      case UserRole.manager:
        return 'Gerente';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.athlete:
        return 'Atleta';
      case UserRole.parent:
        return 'Padre/Tutor';
      case UserRole.superAdmin:
        return 'Administrador';
      case UserRole.guest:
        return 'Invitado';
    }
  }
  
} 