import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/athlete/screens/athlete_form_screen.dart';
import 'package:arcinus/features/app/users/coach/screens/coach_form_screen.dart';
import 'package:arcinus/features/app/users/manager/screens/manager_form_screen.dart';
import 'package:arcinus/features/app/users/parent/screens/parent_form_screen.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDetailsScreen extends ConsumerWidget {
  final String userId;
  final UserRole userRole;
  final User user;
  
  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.userRole,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de ${_getRoleName(userRole)}'),
        actions: [
          // Botón de editar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditForm(context, ref),
          ),
          // Botón de eliminar
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto de perfil y nombre
            Center(
              child: Column(
                children: [
                  // Foto de perfil
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple.withAlpha(50),
                    child: user.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.profileImageUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            _getIconForRole(userRole),
                            size: 50,
                            color: Colors.deepPurple,
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Nombre completo
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Información general del usuario
            _buildDetailCard(
              context,
              'Información General',
              [
                _buildDetailItem('Email', user.email),
                _buildDetailItem('Rol', _getRoleName(userRole)),
                _buildDetailItem('Academia', currentAcademy?.academyName ?? 'Sin academia'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botones de acción adicionales
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acciones',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          'Editar',
                          Icons.edit,
                          () => _navigateToEditForm(context, ref),
                        ),
                        _buildActionButton(
                          context,
                          'Eliminar',
                          Icons.delete,
                          () => _showDeleteConfirmation(context, ref),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, List<Widget> items) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: 140, // Ancho fijo para evitar el error de constraints infinitos
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isDestructive ? Colors.red : null,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive 
              ? Colors.red.withAlpha(30) 
              : Theme.of(context).colorScheme.primary.withAlpha(30),
        ),
      ),
    );
  }

  void _navigateToEditForm(BuildContext context, WidgetRef ref) {
    developer.log(
      'Iniciando navegación a formulario de edición - Usuario: ${user.name} (${user.id}) - Rol: $userRole',
      name: 'UserDetails',
    );
    
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy == null) {
      developer.log(
        'Error: No hay academia seleccionada para edición',
        name: 'UserDetails',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay academia seleccionada')),
      );
      return;
    }
    
    developer.log(
      'Academia seleccionada: ${currentAcademy.academyName} (${currentAcademy.academyId})',
      name: 'UserDetails',
    );
    
    Widget formScreen;
    switch (userRole) {
      case UserRole.athlete:
        developer.log('Navegando a AthleteFormScreen', name: 'UserDetails');
        formScreen = AthleteFormScreen(
          mode: AthleteFormMode.edit,
          userId: userId,
          academyId: currentAcademy.academyId,
        );
        break;
      case UserRole.coach:
        developer.log('Navegando a CoachFormScreen', name: 'UserDetails');
        formScreen = CoachFormScreen(
          mode: CoachFormMode.edit,
          userId: userId,
          academyId: currentAcademy.academyId,
        );
        break;
      case UserRole.manager:
        developer.log('Navegando a ManagerFormScreen', name: 'UserDetails');
        formScreen = ManagerFormScreen(
          mode: ManagerFormMode.edit,
          userId: userId,
          academyId: currentAcademy.academyId,
        );
        break;
      case UserRole.parent:
        developer.log('Navegando a ParentFormScreen', name: 'UserDetails');
        formScreen = ParentFormScreen(
          mode: ParentFormMode.edit,
          userId: userId,
          academyId: currentAcademy.academyId,
        );
        break;
      default:
        developer.log(
          'Error: Tipo de usuario no soportado para edición: $userRole',
          name: 'UserDetails',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edición de este tipo de usuario no implementada aún')),
        );
        return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => formScreen),
    ).then((result) {
      developer.log(
        'Regresando de pantalla de edición con resultado: $result',
        name: 'UserDetails',
      );
      
      if (result == true) {
        if (context.mounted) {
          developer.log(
            'La edición fue exitosa, regresando a la pantalla anterior',
            name: 'UserDetails',
          );
          Navigator.pop(context, true);
        }
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    developer.log(
      '----INICIO: Proceso de eliminación desde UI----',
      name: 'UserDetails-Delete',
    );
    
    developer.log(
      'Mostrando diálogo de confirmación - Usuario: ${user.name} (${user.id}) - Rol: $userRole',
      name: 'UserDetails-Delete',
    );
    
    final userService = ref.read(userServiceProvider);
    final currentAcademy = ref.read(currentAcademyProvider);
    
    if (currentAcademy == null) {
      developer.log(
        'ERROR: No hay academia seleccionada para eliminación',
        name: 'UserDetails-Delete',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay academia seleccionada')),
      );
      return;
    }
    
    developer.log(
      'Academia para eliminación: ${currentAcademy.academyName} (${currentAcademy.academyId})',
      name: 'UserDetails-Delete',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar ${_getRoleName(userRole)}'),
        content: Text('¿Estás seguro que deseas eliminar a ${user.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              developer.log(
                'Eliminación cancelada por el usuario',
                name: 'UserDetails-Delete',
              );
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              developer.log(
                'Confirmada eliminación del usuario, cerrando diálogo',
                name: 'UserDetails-Delete',
              );
              Navigator.pop(context); // Cerrar diálogo
              
              // Guardamos una referencia al contexto antes de mostrar el diálogo
              final contextMounted = context.mounted;
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context, rootNavigator: true);
              bool indicatorShown = false; // Declarar aquí para que sea accesible
              
              // Mostrar indicador de carga
              if (contextMounted) {
                developer.log(
                  'Mostrando indicador de carga para eliminación',
                  name: 'UserDetails-Delete',
                );
                
                // Usar el contexto del navigator raíz para mayor robustez
                final rootContext = navigator.context;
                if (navigator.mounted && rootContext.mounted) {
                  
                  // ignore: unawaited_futures
                  showDialog(
                    context: rootContext, 
                    barrierDismissible: false,
                    builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
                  );
                  indicatorShown = true;
                  developer.log('INDICADOR MOSTRADO (lanzado sin await), entrando a TRY', name: 'UserDetails-Delete');
                } else {
                  developer.log('ERROR: Contexto del navigator raíz no montado, no se puede mostrar indicador', name: 'UserDetails-Delete');
                  // Si no podemos mostrar el indicador, probablemente no deberíamos continuar.
                  // Mostramos un error y salimos.
                  scaffoldMessenger.showSnackBar(const SnackBar(content: Text('No se pudo iniciar la eliminación')));
                  return;
                }
              } else {
                // Si el contexto original no está montado, tampoco continuamos
                developer.log('Contexto original no montado antes de mostrar indicador', name: 'UserDetails-Delete');
                return;
              }
              
              try {
                developer.log(
                  'Iniciando proceso de eliminación - Usuario: $userId - Academia: ${currentAcademy.academyId} - Rol: $userRole',
                  name: 'UserDetails-Delete',
                );
                
                // Llamada al método de eliminación específico
                switch (userRole) {
                  case UserRole.manager:
                    developer.log('Llamando a userService.deleteManager', name: 'UserDetails-Delete');
                    await userService.deleteManager(userId, currentAcademy.academyId);
                    break;
                  case UserRole.coach:
                    developer.log('Llamando a userService.deleteCoach', name: 'UserDetails-Delete');
                    await userService.deleteCoach(userId, currentAcademy.academyId);
                    break;
                  case UserRole.athlete:
                    developer.log('Llamando a userService.deleteAthlete', name: 'UserDetails-Delete');
                    await userService.deleteAthlete(userId, currentAcademy.academyId);
                    break;
                  case UserRole.parent:
                    developer.log('Llamando a userService.deleteParent', name: 'UserDetails-Delete');
                    await userService.deleteParent(userId, currentAcademy.academyId);
                    break;
                  default:
                    developer.log('Rol no soportado para eliminación directa: $userRole', name: 'UserDetails-Delete');
                    throw Exception('Rol no soportado para eliminación');
                }
                
                developer.log(
                  'Eliminación completada exitosamente en backend',
                  name: 'UserDetails-Delete',
                );
                
                // Ocultar indicador de carga ANTES de mostrar SnackBar y hacer pop
                if (indicatorShown && navigator.mounted) {
                  developer.log('Ocultando indicador de carga (ÉXITO)', name: 'UserDetails-Delete');
                  navigator.pop(); // Cierra el diálogo del indicador
                }

                // Mostrar SnackBar de éxito y navegar hacia atrás si el contexto sigue montado
                if (contextMounted) {
                   developer.log('Mostrando SnackBar de éxito y haciendo pop(true)', name: 'UserDetails-Delete');
                   scaffoldMessenger.showSnackBar(
                     SnackBar(content: Text('${_getRoleName(userRole)} eliminado con éxito')),
                   );
                   // Volver a la pantalla anterior indicando éxito
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                } else {
                  developer.log('Contexto original no montado después de eliminación exitosa.', name: 'UserDetails-Delete');
                }

              } catch (e) {
                developer.log(
                  'ERROR durante el proceso de eliminación: $e',
                  name: 'UserDetails-Delete',
                  error: e,
                );
                
                // Asegurarse de ocultar indicador de carga en caso de error
                if (indicatorShown && navigator.mounted) {
                  developer.log('Ocultando indicador de carga (ERROR)', name: 'UserDetails-Delete');
                   navigator.pop(); // Cierra el diálogo del indicador
                }
                
                // Mostrar SnackBar de error si el contexto sigue montado
                if (contextMounted) {
                  developer.log('Mostrando SnackBar de error', name: 'UserDetails-Delete');
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error al eliminar ${_getRoleName(userRole)}: ${e.toString()}')),
                  );
                } else {
                   developer.log('Contexto original no montado después de error en eliminación.', name: 'UserDetails-Delete');
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return 'Gerente';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.athlete:
        return 'Atleta';
      case UserRole.parent:
        return 'Padre/Responsable';
      case UserRole.owner:
        return 'Propietario';
      default:
        return 'Usuario';
    }
  }
  
  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return Icons.admin_panel_settings;
      case UserRole.coach:
        return Icons.sports;
      case UserRole.athlete:
        return Icons.fitness_center;
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.owner:
        return Icons.business;
      default:
        return Icons.person;
    }
  }
} 