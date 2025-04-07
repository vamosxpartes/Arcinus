import 'package:arcinus/shared/constants/permissions.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ui/shared/widgets/permission_builder.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor para la lista filtrada de usuarios
final filteredUsersProvider = StateProvider<List<User>>((ref) => []);

/// Proveedor para la lista de usuarios seleccionados
final selectedUsersProvider = StateProvider<List<String>>((ref) => []);

/// Pantalla para la gestión de permisos de usuarios
class PermissionsManagementScreen extends ConsumerStatefulWidget {
  const PermissionsManagementScreen({super.key});

  @override
  ConsumerState<PermissionsManagementScreen> createState() => _PermissionsManagementScreenState();
}

class _PermissionsManagementScreenState extends ConsumerState<PermissionsManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _selectedRole = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar la lista de usuarios al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterUsers();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  /// Filtra los usuarios según los criterios de búsqueda
  void _filterUsers() {
    final usersAsyncValue = ref.read(usersProvider);
    
    usersAsyncValue.whenData((users) {
      List<User> filteredList = users;
      
      // Filtrar por término de búsqueda
      if (_searchTerm.isNotEmpty) {
        filteredList = filteredList.where((user) {
          return user.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                 user.email.toLowerCase().contains(_searchTerm.toLowerCase());
        }).toList();
      }
      
      // Filtrar por rol
      if (_selectedRole.isNotEmpty) {
        filteredList = filteredList.where((user) {
          return user.role.toString().split('.').last == _selectedRole;
        }).toList();
      }
      
      // Actualizar el proveedor de usuarios filtrados
      ref.read(filteredUsersProvider.notifier).state = filteredList;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      permissions: [Permissions.assignPermissions],
      fallback: _buildNoPermissionView(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 16),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIndividualTab(),
                    _buildRoleTab(),
                    _buildBatchTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, _) {
            final selectedUsers = ref.watch(selectedUsersProvider);
            return selectedUsers.isNotEmpty
                ? FloatingActionButton(
                    onPressed: () => _showPermissionsDialog(),
                    child: const Icon(Icons.edit),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
  
  /// Construye la cabecera de la pantalla
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Gestión de Permisos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Asigna permisos a usuarios individuales o por roles',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  /// Construye la barra de búsqueda
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar usuarios...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchTerm.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchTerm = '';
                    });
                    _filterUsers();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
          });
          _filterUsers();
        },
      ),
    );
  }
  
  /// Construye los chips de filtrado
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('Todos'),
            selected: _selectedRole.isEmpty,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedRole = '';
                });
                _filterUsers();
              }
            },
          ),
          FilterChip(
            label: const Text('Propietarios'),
            selected: _selectedRole == 'owner',
            onSelected: (selected) {
              setState(() {
                _selectedRole = selected ? 'owner' : '';
              });
              _filterUsers();
            },
          ),
          FilterChip(
            label: const Text('Managers'),
            selected: _selectedRole == 'manager',
            onSelected: (selected) {
              setState(() {
                _selectedRole = selected ? 'manager' : '';
              });
              _filterUsers();
            },
          ),
          FilterChip(
            label: const Text('Entrenadores'),
            selected: _selectedRole == 'coach',
            onSelected: (selected) {
              setState(() {
                _selectedRole = selected ? 'coach' : '';
              });
              _filterUsers();
            },
          ),
          FilterChip(
            label: const Text('Atletas'),
            selected: _selectedRole == 'athlete',
            onSelected: (selected) {
              setState(() {
                _selectedRole = selected ? 'athlete' : '';
              });
              _filterUsers();
            },
          ),
        ],
      ),
    );
  }
  
  /// Construye los tabs
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      tabs: const [
        Tab(text: 'Individual'),
        Tab(text: 'Por Rol'),
        Tab(text: 'Por Lotes'),
      ],
    );
  }
  
  /// Construye el tab de gestión individual
  Widget _buildIndividualTab() {
    final users = ref.watch(filteredUsersProvider);
    final selectedUsers = ref.watch(selectedUsersProvider);
    
    if (users.isEmpty) {
      return const Center(child: Text('No se encontraron usuarios'));
    }
    
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = selectedUsers.contains(user.id);
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (value) {
              final currentSelectedUsers = List<String>.from(selectedUsers);
              
              if (value == true) {
                currentSelectedUsers.add(user.id);
              } else {
                currentSelectedUsers.remove(user.id);
              }
              
              ref.read(selectedUsersProvider.notifier).state = currentSelectedUsers;
            },
          ),
          onTap: () {
            final currentSelectedUsers = List<String>.from(selectedUsers);
            
            if (isSelected) {
              currentSelectedUsers.remove(user.id);
            } else {
              currentSelectedUsers.add(user.id);
            }
            
            ref.read(selectedUsersProvider.notifier).state = currentSelectedUsers;
          },
        );
      },
    );
  }
  
  /// Construye el tab de gestión por rol
  Widget _buildRoleTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permisos por Rol',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Propietario'),
              subtitle: const Text('Configurar permisos predeterminados para propietarios'),
              trailing: const Icon(Icons.settings),
              onTap: () => _showRolePermissionsDialog(UserRole.owner),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Manager'),
              subtitle: const Text('Configurar permisos predeterminados para managers'),
              trailing: const Icon(Icons.settings),
              onTap: () => _showRolePermissionsDialog(UserRole.manager),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Entrenador'),
              subtitle: const Text('Configurar permisos predeterminados para entrenadores'),
              trailing: const Icon(Icons.settings),
              onTap: () => _showRolePermissionsDialog(UserRole.coach),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Atleta'),
              subtitle: const Text('Configurar permisos predeterminados para atletas'),
              trailing: const Icon(Icons.settings),
              onTap: () => _showRolePermissionsDialog(UserRole.athlete),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nota: Los cambios en los permisos predeterminados solo afectarán a los nuevos usuarios con este rol.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construye el tab de gestión por lotes
  Widget _buildBatchTab() {
    final users = ref.watch(filteredUsersProvider);
    final selectedUsers = ref.watch(selectedUsersProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modificación en lote',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Usuarios seleccionados: ${selectedUsers.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Usa las pestañas para seleccionar usuarios y luego asigna permisos en lote.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: selectedUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay usuarios seleccionados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Selecciona usuarios en la pestaña Individual',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedUsers.length,
                    itemBuilder: (context, index) {
                      final userId = selectedUsers[index];
                      final user = users.firstWhere(
                        (u) => u.id == userId,
                        orElse: () => User.empty(),
                      );
                      
                      if (user.id.isEmpty) return const SizedBox.shrink();
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            final currentSelectedUsers = List<String>.from(selectedUsers);
                            currentSelectedUsers.remove(userId);
                            ref.read(selectedUsersProvider.notifier).state = currentSelectedUsers;
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (selectedUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _showPermissionsDialog(),
                    child: const Text('Gestionar Permisos'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  /// Muestra el diálogo de edición de permisos para usuarios seleccionados
  void _showPermissionsDialog() {
    final selectedUsers = ref.read(selectedUsersProvider);
    if (selectedUsers.isEmpty) return;
    
    final allPermissions = _getAllPermissions();
    // Estado local para mantener los cambios de permisos
    Map<String, bool?> modifiedPermissions = {};
    // null significa sin cambios, true/false son valores específicos
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Gestionar Permisos (${selectedUsers.length} usuarios)'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final permission in allPermissions)
                    CheckboxListTile(
                      title: Text(_getPermissionName(permission)),
                      subtitle: Text(_getPermissionDescription(permission)),
                      value: modifiedPermissions[permission],
                      tristate: true,
                      onChanged: (value) {
                        setState(() {
                          modifiedPermissions[permission] = value;
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _applyPermissionChanges(modifiedPermissions);
                },
                child: const Text('Aplicar Cambios'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Muestra el diálogo de edición de permisos para un rol específico
  void _showRolePermissionsDialog(UserRole role) {
    final defaultPermissions = Permissions.getDefaultPermissions(role);
    // Estado local para mantener los cambios de permisos
    Map<String, bool> modifiedPermissions = {...defaultPermissions};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Permisos predeterminados: ${role.toString().split('.').last}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Estos permisos se aplicarán a los nuevos usuarios con este rol.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  for (final entry in modifiedPermissions.entries)
                    CheckboxListTile(
                      title: Text(_getPermissionName(entry.key)),
                      subtitle: Text(_getPermissionDescription(entry.key)),
                      value: entry.value,
                      onChanged: (value) {
                        setState(() {
                          modifiedPermissions[entry.key] = value ?? false;
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Aquí se implementaría la lógica para guardar los permisos predeterminados
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Esta funcionalidad se implementará próximamente'),
                    ),
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Aplica los cambios de permisos a los usuarios seleccionados
  void _applyPermissionChanges(Map<String, bool?> modifiedPermissions) {
    // Aquí se implementaría la lógica para actualizar los permisos de los usuarios
    // por ahora mostramos un mensaje indicando que esta funcionalidad está pendiente
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta funcionalidad se implementará próximamente'),
      ),
    );
  }
  
  /// Construye la vista cuando no tiene permisos
  Widget _buildNoPermissionView() {
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
                'No tienes permisos para gestionar permisos',
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

/// Proveedor para obtener todos los usuarios de la academia actual
final usersProvider = FutureProvider<List<User>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final currentUser = authState.valueOrNull;
  
  if (currentUser == null || currentUser.academyIds.isEmpty) {
    return [];
  }
  
  // Implementar obtención de usuarios de Firebase
  final academyId = currentUser.academyIds.first;
  final userCollection = FirebaseFirestore.instance.collection('users');
  
  // Consultar usuarios que pertenecen a esta academia
  final querySnapshot = await userCollection
      .where('academyIds', arrayContains: academyId)
      .get();
  
  return querySnapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return User.fromJson(data);
  }).toList();
}); 