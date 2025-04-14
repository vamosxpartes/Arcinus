import 'dart:developer' as developer;

import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/auth/core/providers/pre_registration_providers.dart';
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
    final preRegisteredUsersAsync = ref.watch(preRegisteredUsersProvider);
    
    // Form para crear nuevo pre-registro
    final form = useMemoized(() => FormGroup({
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email]
      ),
      'name': FormControl<String>(validators: [Validators.required]),
      'role': FormControl<UserRole>(validators: [Validators.required]),
    }));
    
    final isCreating = useState(false);
    final createdCode = useState<String?>(null);
    
    // Función para crear un nuevo pre-registro
    Future<void> createNewPreRegistration() async {
      if (form.invalid || currentUser == null) return;
      
      isCreating.value = true;
      createdCode.value = null;
      
      try {
        final email = form.control('email').value as String;
        final name = form.control('name').value as String;
        final role = form.control('role').value as UserRole;
        
        final preRegisteredUser = await ref.read(createPreRegisteredUserProvider(
          email: email, 
          name: name, 
          role: role, 
          createdBy: currentUser.id
        ).future);
        
        createdCode.value = preRegisteredUser.activationCode;
        form.reset();
        
        developer.log('DEBUG: PreRegisterScreen - Usuario pre-registrado creado con código: ${preRegisteredUser.activationCode} - lib/features/auth/screens/pre_register_screen.dart - createNewPreRegistration');
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        developer.log('ERROR: PreRegisterScreen - Error al crear pre-registro: $e - lib/features/auth/screens/pre_register_screen.dart - createNewPreRegistration');
      } finally {
        isCreating.value = false;
      }
    }
    
    // Función para eliminar un pre-registro
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
                            formControlName: 'email',
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              hintText: 'ejemplo@correo.com',
                            ),
                            validationMessages: {
                              'required': (error) => 'El correo es obligatorio',
                              'email': (error) => 'Ingrese un correo válido',
                            },
                          ),
                          const SizedBox(height: 16),
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
                            Text(
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
            ),
            
            // Lista de usuarios pre-registrados
            const Text(
              'Usuarios Pre-registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            preRegisteredUsersAsync.when(
              data: (preRegisteredUsers) {
                if (preRegisteredUsers.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('No hay usuarios pre-registrados'),
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: preRegisteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = preRegisteredUsers[index];
                    final isExpired = user.expiresAt.isBefore(DateTime.now());
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text('Rol: ${_getRoleName(user.role)}'),
                            Text(
                              user.isUsed 
                                ? 'Código utilizado' 
                                : isExpired 
                                  ? 'Código expirado' 
                                  : 'Expiración: ${_formatDate(user.expiresAt)}',
                              style: TextStyle(
                                color: user.isUsed || isExpired
                                  ? Colors.red
                                  : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!user.isUsed && !isExpired)
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: user.activationCode),
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
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deletePreRegistration(user.id),
                              tooltip: 'Eliminar pre-registro',
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRoleName(UserRole role) {
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
  
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
} 