import 'package:arcinus/shared/constants/permissions.dart';
import 'package:arcinus/shared/models/custom_role.dart';
import 'package:arcinus/ui/shared/widgets/permission_builder.dart';
import 'package:arcinus/ux/features/roles/services/custom_role_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla para gestionar roles personalizados
class CustomRolesScreen extends ConsumerWidget {
  const CustomRolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo usuarios con permiso de assignPermissions pueden acceder a esta pantalla
    return PermissionGate(
      permissions: [Permissions.assignPermissions],
      fallback: _buildNoPermissionView(context),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildRolesList(context, ref),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddRoleDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// Construye la cabecera de la pantalla
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Roles Personalizados',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Crea y gestiona roles personalizados con combinaciones específicas de permisos.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// Construye la lista de roles
  Widget _buildRolesList(BuildContext context, WidgetRef ref) {
    final rolesAsyncValue = ref.watch(customRolesProvider);
    
    return rolesAsyncValue.when(
      data: (roles) {
        if (roles.isEmpty) {
          return _buildEmptyState(context, ref);
        }
        
        return Expanded(
          child: ListView.builder(
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return _buildRoleCard(context, ref, role);
            },
          ),
        );
      },
      loading: () => const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Expanded(
        child: Center(
          child: Text(
            'Error al cargar roles: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  /// Construye una tarjeta para un rol
  Widget _buildRoleCard(BuildContext context, WidgetRef ref, CustomRole role) {
    // Obtener los permisos activos del rol
    final Map<String, bool> permissions = role.permissions;
    
    final activePermissions = permissions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  role.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditRoleDialog(context, ref, role),
                      tooltip: 'Editar rol',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteRole(context, ref, role),
                      tooltip: 'Eliminar rol',
                    ),
                  ],
                ),
              ],
            ),
            if (role.description != null && role.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                role.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Permisos activos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activePermissions.map((permission) {
                return Chip(
                  label: Text(_getPermissionName(permission.toString())),
                  backgroundColor: Colors.blue.withAlpha(25),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Usuarios asignados: ${role.assignedUserIds.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a la pantalla de gestión de usuarios asignados
                    Navigator.pushNamed(
                      context,
                      '/roles/assign',
                      arguments: {'roleId': role.id, 'roleName': role.name},
                    );
                  },
                  child: const Text('Gestionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la vista cuando no hay roles
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay roles personalizados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea tu primer rol personalizado',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddRoleDialog(context, ref),
              child: const Text('Crear rol'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la vista cuando no tiene permisos
  Widget _buildNoPermissionView(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Acceso denegado',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No tienes permisos para gestionar roles',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra el diálogo para añadir un nuevo rol
  Future<void> _showAddRoleDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    final roleService = ref.read(customRoleServiceProvider);
    
    // Inicializar todos los permisos como falsos
    final Map<String, bool> selectedPermissions = {};
    for (final permission in _getAllPermissions()) {
      selectedPermissions[permission] = false;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Crear Rol Personalizado'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del rol',
                      hintText: 'Ej: Entrenador Senior',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      hintText: 'Describe el propósito de este rol',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Permisos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...selectedPermissions.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(_getPermissionName(entry.key)),
                      subtitle: Text(_getPermissionDescription(entry.key)),
                      value: entry.value,
                      onChanged: (value) {
                        setState(() {
                          selectedPermissions[entry.key] = value ?? false;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('El nombre del rol es obligatorio'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
    
    if (result == true) {
      try {
        await roleService.createCustomRole(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          permissions: selectedPermissions,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rol creado exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear rol: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Muestra el diálogo para editar un rol existente
  Future<void> _showEditRoleDialog(BuildContext context, WidgetRef ref, CustomRole role) async {
    final nameController = TextEditingController(text: role.name);
    final descriptionController = TextEditingController(text: role.description ?? '');
    
    final roleService = ref.read(customRoleServiceProvider);
    
    // Inicializar con los permisos actuales del rol
    final Map<String, bool> selectedPermissions = {...role.permissions};
    
    // Asegurar que todos los permisos estén presentes
    for (final permission in _getAllPermissions()) {
      if (!selectedPermissions.containsKey(permission)) {
        selectedPermissions[permission] = false;
      }
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Rol Personalizado'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del rol',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Permisos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...selectedPermissions.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(_getPermissionName(entry.key)),
                      subtitle: Text(_getPermissionDescription(entry.key)),
                      value: entry.value,
                      onChanged: (value) {
                        setState(() {
                          selectedPermissions[entry.key] = value ?? false;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('El nombre del rol es obligatorio'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop(true);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
    
    if (result == true) {
      try {
        await roleService.updateCustomRole(
          roleId: role.id,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          permissions: selectedPermissions,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rol actualizado exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar rol: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Confirmar eliminación de un rol
  Future<void> _confirmDeleteRole(BuildContext context, WidgetRef ref, CustomRole role) async {
    final roleService = ref.read(customRoleServiceProvider);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar rol?'),
        content: Text(
          'Esta acción eliminará el rol "${role.name}" y no se puede deshacer. No afectará a los permisos ya asignados a los usuarios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        await roleService.deleteCustomRole(role.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rol eliminado exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar rol: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Obtiene todos los permisos disponibles
  List<String> _getAllPermissions() {
    return [
      Permissions.managePlatform,
      Permissions.viewAllAcademies,
      Permissions.manageSubscriptions,
      Permissions.managePaymentPlans,
      Permissions.createAcademy,
      Permissions.manageAcademy,
      Permissions.manageUsers,
      Permissions.manageCoaches,
      Permissions.manageGroups,
      Permissions.assignPermissions,
      Permissions.managePayments,
      Permissions.viewFinancials,
      Permissions.createTraining,
      Permissions.viewAllTrainings,
      Permissions.editTraining,
      Permissions.scheduleClass,
      Permissions.takeAttendance,
      Permissions.viewAllAttendance,
      Permissions.evaluateAthletes,
      Permissions.viewAllEvaluations,
      Permissions.sendNotifications,
      Permissions.useChat,
    ];
  }

  /// Obtiene un nombre amigable para un permiso
  String _getPermissionName(String permission) {
    final nameMap = {
      Permissions.managePlatform: 'Gestionar plataforma',
      Permissions.viewAllAcademies: 'Ver todas las academias',
      Permissions.manageSubscriptions: 'Gestionar suscripciones',
      Permissions.managePaymentPlans: 'Gestionar planes de pago',
      Permissions.createAcademy: 'Crear academia',
      Permissions.manageAcademy: 'Gestionar academia',
      Permissions.manageUsers: 'Gestionar usuarios',
      Permissions.manageCoaches: 'Gestionar entrenadores',
      Permissions.manageGroups: 'Gestionar grupos',
      Permissions.assignPermissions: 'Asignar permisos',
      Permissions.managePayments: 'Gestionar pagos',
      Permissions.viewFinancials: 'Ver finanzas',
      Permissions.createTraining: 'Crear entrenamientos',
      Permissions.viewAllTrainings: 'Ver todos los entrenamientos',
      Permissions.editTraining: 'Editar entrenamientos',
      Permissions.scheduleClass: 'Programar clases',
      Permissions.takeAttendance: 'Tomar asistencia',
      Permissions.viewAllAttendance: 'Ver toda la asistencia',
      Permissions.evaluateAthletes: 'Evaluar atletas',
      Permissions.viewAllEvaluations: 'Ver todas las evaluaciones',
      Permissions.sendNotifications: 'Enviar notificaciones',
      Permissions.useChat: 'Usar chat',
    };
    
    return nameMap[permission] ?? permission;
  }

  /// Obtiene una descripción para un permiso
  String _getPermissionDescription(String permission) {
    final descriptionMap = {
      Permissions.managePlatform: 'Gestionar configuración de la plataforma completa',
      Permissions.viewAllAcademies: 'Ver el listado de todas las academias registradas',
      Permissions.manageSubscriptions: 'Gestionar suscripciones de academias',
      Permissions.managePaymentPlans: 'Configurar planes de pago disponibles',
      Permissions.createAcademy: 'Crear nuevas academias',
      Permissions.manageAcademy: 'Editar configuración de la academia',
      Permissions.manageUsers: 'Crear, editar y gestionar usuarios',
      Permissions.manageCoaches: 'Gestionar entrenadores y sus asignaciones',
      Permissions.manageGroups: 'Crear y gestionar grupos/equipos',
      Permissions.assignPermissions: 'Asignar permisos a usuarios',
      Permissions.managePayments: 'Registrar y gestionar pagos',
      Permissions.viewFinancials: 'Ver reportes e información financiera',
      Permissions.createTraining: 'Crear nuevos entrenamientos',
      Permissions.viewAllTrainings: 'Ver todos los entrenamientos de la academia',
      Permissions.editTraining: 'Modificar entrenamientos existentes',
      Permissions.scheduleClass: 'Programar clases en el calendario',
      Permissions.takeAttendance: 'Registrar asistencia a clases',
      Permissions.viewAllAttendance: 'Ver registros de asistencia de todos los grupos',
      Permissions.evaluateAthletes: 'Realizar evaluaciones de atletas',
      Permissions.viewAllEvaluations: 'Ver evaluaciones de todos los atletas',
      Permissions.sendNotifications: 'Enviar notificaciones a usuarios',
      Permissions.useChat: 'Utilizar el sistema de chat interno',
    };
    
    return descriptionMap[permission] ?? 'Sin descripción';
  }
} 