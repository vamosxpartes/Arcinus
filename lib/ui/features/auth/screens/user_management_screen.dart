import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/shared/navigation/navigation_service.dart';
import 'package:arcinus/ui/features/auth/screens/athlete_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/athlete_list_screen.dart' show athletesProvider;
import 'package:arcinus/ui/features/auth/screens/coach_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/coach_list_screen.dart' show coachesProvider;
import 'package:arcinus/ui/features/auth/screens/manager_form_screen.dart';
import 'package:arcinus/ui/features/auth/screens/manager_list_screen.dart' show managersProvider;
import 'package:arcinus/ui/shared/widgets/custom_navigation_bar.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.coach;
  DateTime? _birthDate;
  int _currentFormStep = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showInviteForm = false;
  
  // Instancia del servicio de navegación
  final NavigationService _navigationService = NavigationService();
  
  @override
  void initState() {
    super.initState();
    // Verificar si el usuario es superAdmin para determinar el número de tabs
    final user = ref.read(authStateProvider).valueOrNull;
    final isSuperAdmin = user?.role == UserRole.superAdmin;
    
    // Tabs: Managers, Coaches, Atletas, Grupos, Padres, (Owners solo para superAdmin)
    _tabController = TabController(
      length: isSuperAdmin ? 6 : 5, 
      vsync: this
    );
    
    // Escuchar cambios en las pestañas
    _tabController.addListener(() {
      // Solo actualizamos cuando el cambio de tab es por interacción del usuario
      if (!_tabController.indexIsChanging) {
        // Si estamos mostrando el formulario y cambiamos de tab, lo ocultamos
        if (_showInviteForm) {
          setState(() {
            _showInviteForm = false;
          });
        }
        
        setState(() {
          // Actualizar el rol seleccionado basado en la pestaña
          switch (_tabController.index) {
            case 0:
              _selectedRole = UserRole.manager;
              break;
            case 1:
              _selectedRole = UserRole.coach;
              break;
            case 2:
              _selectedRole = UserRole.athlete;
              break;
            case 3:
              // Grupos - no tiene rol asociado
              break;
            case 4:
              _selectedRole = UserRole.parent;
              break;
            case 5:
              _selectedRole = UserRole.owner;
              break;
            default:
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _emailController.clear();
    _nameController.clear();
    _lastNameController.clear();
    _heightController.clear();
    _weightController.clear();
    _passwordController.clear();
    setState(() {
      _currentFormStep = 0;
      _birthDate = null;
    });
  }

  void _toggleInviteForm() {
    if (_showInviteForm) {
      _resetForm();
    } else {
      // Pre-seleccionar el rol basado en la pestaña actual
      switch (_tabController.index) {
        case 0:
          _selectedRole = UserRole.manager;
          break;
        case 1:
          _selectedRole = UserRole.coach;
          break;
        case 2:
          _selectedRole = UserRole.athlete;
          break;
        case 3:
          // Si está en la pestaña de grupos, mostramos un mensaje
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear grupo en desarrollo')),
          );
          return; // No mostramos el formulario en la pestaña de grupos
      }
    }
    
    setState(() {
      _showInviteForm = !_showInviteForm;
    });
  }

  bool _validateCurrentStep() {
    // Validamos solo los campos de la etapa actual
    switch (_currentFormStep) {
      case 0: // Información personal
        return _nameController.text.isNotEmpty && 
               _lastNameController.text.isNotEmpty &&
               _birthDate != null;
      case 1: // Información física
        if (_selectedRole == UserRole.athlete) {
          // Solo validamos peso y altura para atletas
          return _heightController.text.isNotEmpty && 
                 _weightController.text.isNotEmpty;
        }
        return true;
      case 2: // Información de autenticación
        return _emailController.text.isNotEmpty && 
               _emailController.text.contains('@') &&
               _passwordController.text.length >= 6;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentFormStep < _getTotalSteps() - 1) {
          _currentFormStep++;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos requeridos')),
      );
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentFormStep > 0) {
        _currentFormStep--;
      } else {
        // Si estamos en el primer paso, cerramos el formulario
        _showInviteForm = false;
      }
    });
  }

  int _getTotalSteps() {
    // El número total de pasos depende del rol
    switch (_selectedRole) {
      case UserRole.athlete:
        return 4; // Incluye información física y deportiva
      case UserRole.coach:
        return 4; // Incluye información de experiencia
      default:
        return 3; // Solo información básica y de autenticación
    }
  }

  Future<void> _sendInvitation() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos requeridos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Aquí iría la implementación real para enviar invitaciones
      // Por ahora mostramos un mensaje de éxito simulado
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado correctamente')),
      );
      
      _resetForm();
      _toggleInviteForm();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      // Actualizar para forzar la reconstrucción y el filtrado
    });
  }

  // Método para refrescar la lista de managers
  void _refreshManagers() {
    ref.invalidate(managersProvider);
  }

  // Método para refrescar la lista de coaches
  void _refreshCoaches() {
    ref.invalidate(coachesProvider);
  }

  // Método para refrescar la lista de atletas
  void _refreshAthletes() {
    ref.invalidate(athletesProvider);
  }

  // Método para refrescar la lista de padres
  void _refreshParents() {
    // Implementar cuando tengamos el provider de padres
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad en desarrollo')),
    );
  }

  // Método para refrescar la lista de owners
  void _refreshOwners() {
    // Implementar cuando tengamos el provider de owners
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad en desarrollo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isSuperAdmin = user?.role == UserRole.superAdmin;
    
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [            
            // TabBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  const Tab(text: 'Managers'),
                  const Tab(text: 'Entrenadores'),
                  const Tab(text: 'Atletas'),
                  const Tab(text: 'Grupos'),
                  const Tab(text: 'Padres'),
                  if (isSuperAdmin) const Tab(text: 'Owners'),
                ],
              ),
            ),
            
            // Contenido principal
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab de Managers
                      _buildUserCategoryTab(UserRole.manager),
                      
                      // Tab de Coaches
                      _buildUserCategoryTab(UserRole.coach),
                      
                      // Tab de Atletas
                      _buildUserCategoryTab(UserRole.athlete),
                      
                      // Tab de Grupos
                      _buildGroupsTab(),
                      
                      // Tab de Padres
                      _buildUserCategoryTab(UserRole.parent),
                      
                      // Tab de Owners (condicional)
                      if (isSuperAdmin) _buildUserCategoryTab(UserRole.owner),
                    ],
                  ),
                  
                  // Formulario de invitación deslizable
                  if (_showInviteForm)
                    _buildInvitationForm(),
                ],
              ),
            ),
          ],
        ),
      ),
      // Usar el componente centralizado para la barra de navegación
      bottomNavigationBar: CustomNavigationBar(
        pinnedItems: _navigationService.pinnedItems,
        allItems: NavigationItems.allItems,
        activeRoute: '/users-management',
        onItemTap: (item) => _navigationService.navigateToRoute(context, item.destination),
        onItemLongPress: (item) {
          if (_navigationService.togglePinItem(item, context: context)) {
            setState(() {
              // Actualizar la UI para reflejar cambios en elementos fijados
            });
          }
        },
      ),
    );
  }

  Widget _buildUserCategoryTab(UserRole role) {
    return role == UserRole.athlete
      ? _buildAthleteTab()
      : role == UserRole.coach
        ? _buildCoachTab()
        : role == UserRole.manager
          ? _buildManagerTab()
          : role == UserRole.parent
            ? _buildParentTab()
            : role == UserRole.owner
              ? _buildOwnerTab()
              : _buildPlaceholderUserList(role);
  }


  Widget _buildPlaceholderUserList(UserRole role) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            role == UserRole.manager ? Icons.admin_panel_settings :
            role == UserRole.coach ? Icons.sports :
            Icons.fitness_center,
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            '${_getRoleName(role)} en desarrollo',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('La lista de ${_getRoleName(role).toLowerCase()} se implementará próximamente.'),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Column(
      children: [
        // Barra de búsqueda con botón de agregar grupo
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar grupos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      // ignore: avoid_redundant_argument_values
                      vertical: 0.0,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              // Botón de agregar grupo
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: () {
                    final currentAcademy = ref.read(currentAcademyProvider);
                    if (currentAcademy == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay academia seleccionada')),
                      );
                      return;
                    }
                    
                    // Aquí iría la navegación al formulario de creación de grupo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Crear grupo en desarrollo')),
                    );
                  },
                  icon: const Icon(
                    Icons.group_add,
                    color: Colors.white,
                  ),
                  tooltip: 'Agregar Grupo',
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Lista de grupos simulada con datos de ejemplo
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final currentAcademy = ref.watch(currentAcademyProvider);
              
              if (currentAcademy == null) {
                return const Center(
                  child: Text('No hay academia seleccionada'),
                );
              }
              
              // Ejemplo de grupos (simulados)
              final List<Map<String, String>> groups = [
                {'id': '1', 'name': 'Grupo A - Principiantes', 'members': '8', 'coach': 'Carlos Rodriguez'},
                {'id': '2', 'name': 'Grupo B - Intermedios', 'members': '12', 'coach': 'Laura Gómez'},
                {'id': '3', 'name': 'Grupo C - Avanzados', 'members': '6', 'coach': 'Miguel Sanchez'},
                {'id': '4', 'name': 'Elite - Competición', 'members': '4', 'coach': 'Ana Martinez'},
              ];
              
              // Filtrar grupos según búsqueda
              final filteredGroups = groups.where((group) => 
                  (group['name'] ?? '').toLowerCase().contains(_searchController.text.toLowerCase())).toList();
              
              if (filteredGroups.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.groups, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'No hay grupos registrados'
                            : 'No se encontraron grupos con esa búsqueda',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: filteredGroups.length,
                itemBuilder: (context, index) {
                  final group = filteredGroups[index];
                  final name = group['name'] ?? 'Grupo sin nombre';
                  final members = group['members'] ?? '0';
                  final coach = group['coach'] ?? 'Sin entrenador asignado';
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.group, color: Colors.white),
                      ),
                      title: Text(name),
                      subtitle: Text('$members miembros • Entrenador: $coach'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navegación a detalle o edición de grupo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Detalle de grupo en desarrollo')),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildInvitationForm() {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final bool canManageAllUsers = user?.role == UserRole.owner || user?.role == UserRole.manager;
    
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Encabezado con pasos
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  'Crear nuevo ${_getRoleName(_selectedRole)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                    _getTotalSteps(),
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: index <= _currentFormStep
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
                  _getStepTitle(_currentFormStep),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          // Contenido del paso actual
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: _buildCurrentStepContent(Theme.of(context), canManageAllUsers),
              ),
            ),
          ),
          
          // Barra inferior con botones
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _previousStep,
                  child: Text(_currentFormStep == 0 ? 'Cancelar' : 'Atrás'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentFormStep == _getTotalSteps() - 1
                          ? _sendInvitation
                          : _nextStep),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _currentFormStep == _getTotalSteps() - 1
                              ? 'Crear Usuario'
                              : 'Siguiente',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Información Personal';
      case 1:
        return _selectedRole == UserRole.athlete
            ? 'Información Física'
            : 'Información de Contacto';
      case 2:
        return 'Información de Autenticación';
      case 3:
        return _selectedRole == UserRole.coach
            ? 'Experiencia y Especialización'
            : 'Información Deportiva';
      default:
        return '';
    }
  }
  
  Widget _buildCurrentStepContent(ThemeData theme, bool canManageAllUsers) {
    switch (_currentFormStep) {
      case 0:
        return _buildPersonalInfoStep(theme);
      case 1:
        return _selectedRole == UserRole.athlete
            ? _buildPhysicalInfoStep(theme)
            : _buildContactInfoStep(theme);
      case 2:
        return _buildAuthInfoStep(theme);
      case 3:
        return _selectedRole == UserRole.coach
            ? _buildCoachSpecificStep(theme)
            : _buildAthleteSpecificStep(theme);
      default:
        return Container();
    }
  }
  
  Widget _buildPersonalInfoStep(ThemeData theme) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final bool canManageAllUsers = user?.role == UserRole.owner || user?.role == UserRole.manager;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingresa la información personal del usuario:'),
        const SizedBox(height: 24),
        
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
            labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
          controller: _lastNameController,
              decoration: const InputDecoration(
            labelText: 'Apellidos',
            prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
          textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa los apellidos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
        // Selector de fecha de nacimiento
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
              firstDate: DateTime(1940),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != _birthDate) {
              setState(() {
                _birthDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Fecha de Nacimiento',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              _birthDate == null
                  ? 'Seleccionar fecha'
                  : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
            ),
          ),
        ),
        
        if (_selectedRole == UserRole.coach || _selectedRole == UserRole.manager) ...[
          const SizedBox(height: 24),
          const Text('Rol a asignar:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
            DropdownButtonFormField<UserRole>(
              decoration: const InputDecoration(
                labelText: 'Rol del usuario',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              value: _selectedRole,
              items: [
              if (_tabController.index == 0 || canManageAllUsers) ...[
                  DropdownMenuItem(
                    value: UserRole.manager,
                    child: _buildRoleItem(Icons.admin_panel_settings, 'Gerente'),
                  ),
                ],
              if (_tabController.index <= 1) ...[
                DropdownMenuItem(
                  value: UserRole.coach,
                  child: _buildRoleItem(Icons.sports, 'Entrenador'),
                ),
              ],
              if (_tabController.index <= 2) ...[
                DropdownMenuItem(
                  value: UserRole.athlete,
                  child: _buildRoleItem(Icons.fitness_center, 'Atleta'),
                ),
              ],
                DropdownMenuItem(
                  value: UserRole.parent,
                  child: _buildRoleItem(Icons.family_restroom, 'Padre/Responsable'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
        ],
      ],
    );
  }
  
  Widget _buildPhysicalInfoStep(ThemeData theme) {
    return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        const Text('Información física:'),
        const SizedBox(height: 24),
        
        // Altura
        TextFormField(
          controller: _heightController,
          decoration: const InputDecoration(
            labelText: 'Altura (cm)',
            prefixIcon: Icon(Icons.height),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa la altura';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Peso
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Peso (kg)',
            prefixIcon: Icon(Icons.monitor_weight_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa el peso';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Condiciones médicas
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Condiciones médicas (opcional)',
            prefixIcon: Icon(Icons.medical_services_outlined),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildContactInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Información de contacto:'),
        const SizedBox(height: 24),
        
        // Teléfono
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        
        // Dirección
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Dirección (opcional)',
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        
        // Contacto de emergencia
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Contacto de emergencia (opcional)',
            prefixIcon: Icon(Icons.emergency),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAuthInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Información de autenticación:'),
        const Text(
          'Estos datos serán utilizados para que el usuario pueda acceder al sistema.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        // Email
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa un correo electrónico';
            }
            if (!value.contains('@')) {
              return 'Por favor ingresa un correo electrónico válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Contraseña
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Opción para generar contraseña automática
        CheckboxListTile(
          title: const Text('Generar contraseña aleatoria'),
          subtitle: const Text('Se enviará por correo electrónico'),
          value: false,
          onChanged: (value) {
            // Implementar generación de contraseña
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
  
  Widget _buildCoachSpecificStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text('Experiencia y especialización:'),
        const SizedBox(height: 24),
        
        // Años de experiencia
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Años de experiencia',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
          const SizedBox(height: 16),
        
        // Especialidades
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Especialidades',
            prefixIcon: Icon(Icons.sports),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        
        // Certificaciones
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Certificaciones (opcional)',
            prefixIcon: Icon(Icons.card_membership),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAthleteSpecificStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const Text('Información deportiva:'),
        const SizedBox(height: 24),
        
        // Nivel
        DropdownButtonFormField<String>(
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
          onChanged: (value) {},
        ),
          const SizedBox(height: 16),
        
        // Objetivos
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Objetivos',
            prefixIcon: Icon(Icons.flag),
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        
        // Asignar a grupo
        DropdownButtonFormField<String>(
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
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildRoleItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
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
        return 'Owner';
      default:
        return '';
    }
  }

  // ignore: unused_element
  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return 'Puede gestionar todos los aspectos de la academia, incluyendo usuarios, grupos, pagos y configuraciones.';
      case UserRole.coach:
        return 'Puede gestionar sus grupos asignados, crear entrenamientos, registrar asistencia y evaluar atletas.';
      case UserRole.athlete:
        return 'Puede ver sus entrenamientos, clases y evaluaciones de rendimiento.';
      case UserRole.parent:
        return 'Puede ver información de sus atletas vinculados, incluyendo asistencia, pagos y rendimiento.';
      case UserRole.owner:
        return 'Puede gestionar todos los aspectos de la academia, incluyendo usuarios, grupos, pagos y configuraciones.';
      default:
        return '';
    }
  }

  Widget _buildAthleteTab() {
    return Column(
      children: [
        // Barra de búsqueda con botón de agregar atleta
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar atletas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      // ignore: avoid_redundant_argument_values
                      vertical: 0.0,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              // Botón de agregar atleta
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: () {
                    final currentAcademy = ref.read(currentAcademyProvider);
                    if (currentAcademy == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay academia seleccionada')),
                      );
                      return;
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AthleteFormScreen(
                          mode: AthleteFormMode.create,
                          academyId: currentAcademy.id,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        // Refrescar datos
                        _refreshAthletes();
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  tooltip: 'Agregar Atleta',
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Lista de atletas
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final currentAcademy = ref.watch(currentAcademyProvider);
              
              if (currentAcademy == null) {
                return const Center(
                  child: Text('No hay academia seleccionada'),
                );
              }
              
              final athletesData = ref.watch(athletesProvider(currentAcademy.id));
              
              return athletesData.when(
                data: (athletes) {
                  // Filtrar atletas según búsqueda
                  final filteredAthletes = athletes.where((athlete) => 
                      athlete.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  
                  if (filteredAthletes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No hay atletas registrados'
                                : 'No se encontraron atletas con esa búsqueda',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: filteredAthletes.length,
                    itemBuilder: (context, index) {
                      final athlete = filteredAthletes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: athlete.profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      athlete.profileImageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.fitness_center, color: Colors.white),
                          ),
                          title: Text(athlete.name),
                          subtitle: Text(athlete.email),
                          onTap: () {
                            // Navegación a detalle o edición
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AthleteFormScreen(
                                  mode: AthleteFormMode.edit,
                                  userId: athlete.id,
                                  academyId: currentAcademy.id,
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                // Refrescar datos
                                _refreshAthletes();
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCoachTab() {
    return Column(
      children: [
        // Barra de búsqueda con botón de agregar entrenador
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar entrenadores...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      // ignore: avoid_redundant_argument_values
                      vertical: 0.0,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              // Botón de agregar entrenador
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: () {
                    final currentAcademy = ref.read(currentAcademyProvider);
                    if (currentAcademy == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay academia seleccionada')),
                      );
                      return;
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoachFormScreen(
                          mode: CoachFormMode.create,
                          academyId: currentAcademy.id,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        // Refrescar datos
                        _refreshCoaches();
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  tooltip: 'Agregar Entrenador',
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Lista de entrenadores
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final currentAcademy = ref.watch(currentAcademyProvider);
              
              if (currentAcademy == null) {
                return const Center(
                  child: Text('No hay academia seleccionada'),
                );
              }
              
              final coachesData = ref.watch(coachesProvider(currentAcademy.id));
              
              return coachesData.when(
                data: (coaches) {
                  // Filtrar entrenadores según búsqueda
                  final filteredCoaches = coaches.where((coach) => 
                      coach.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  
                  if (filteredCoaches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sports, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No hay entrenadores registrados'
                                : 'No se encontraron entrenadores con esa búsqueda',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: filteredCoaches.length,
                    itemBuilder: (context, index) {
                      final coach = filteredCoaches[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: coach.profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      coach.profileImageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.sports, color: Colors.white),
                          ),
                          title: Text(coach.name),
                          subtitle: Text(coach.email),
                          onTap: () {
                            // Navegación a detalle o edición
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoachFormScreen(
                                  mode: CoachFormMode.edit,
                                  userId: coach.id,
                                  academyId: currentAcademy.id,
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                // Refrescar datos
                                _refreshCoaches();
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManagerTab() {
    return Column(
      children: [
        // Barra de búsqueda con botón de agregar manager
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar gerentes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      // ignore: avoid_redundant_argument_values
                      vertical: 0.0,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              // Botón de agregar manager
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: () {
                    final currentAcademy = ref.read(currentAcademyProvider);
                    if (currentAcademy == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay academia seleccionada')),
                      );
                      return;
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManagerFormScreen(
                          mode: ManagerFormMode.create,
                          academyId: currentAcademy.id,
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        // Refrescar datos
                        _refreshManagers();
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  tooltip: 'Agregar Gerente',
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Lista de gerentes
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final currentAcademy = ref.watch(currentAcademyProvider);
              
              if (currentAcademy == null) {
                return const Center(
                  child: Text('No hay academia seleccionada'),
                );
              }
              
              final managersData = ref.watch(managersProvider(currentAcademy.id));
              
              return managersData.when(
                data: (managers) {
                  // Filtrar gerentes según búsqueda
                  final filteredManagers = managers.where((manager) => 
                      manager.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  
                  if (filteredManagers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No hay gerentes registrados'
                                : 'No se encontraron gerentes con esa búsqueda',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: filteredManagers.length,
                    itemBuilder: (context, index) {
                      final manager = filteredManagers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: manager.profileImageUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      manager.profileImageUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.admin_panel_settings, color: Colors.white),
                          ),
                          title: Text(manager.name),
                          subtitle: Text(manager.email),
                          onTap: () {
                            // Navegación a detalle o edición
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManagerFormScreen(
                                  mode: ManagerFormMode.edit,
                                  userId: manager.id,
                                  academyId: currentAcademy.id,
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                // Refrescar datos
                                _refreshManagers();
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParentTab() {
    return Column(
      children: [
        // Barra de búsqueda con botón de agregar padre
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar padres/responsables...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      // ignore: avoid_redundant_argument_values
                      vertical: 0.0,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              // Botón de agregar padre
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: () {
                    final currentAcademy = ref.read(currentAcademyProvider);
                    if (currentAcademy == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay academia seleccionada')),
                      );
                      return;
                    }
                    
                    // Acción temporal mientras se desarrolla la pantalla de formulario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad en desarrollo')),
                    );
                    _refreshParents();
                  },
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  tooltip: 'Agregar Padre/Responsable',
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Lista de padres con datos de ejemplo
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final currentAcademy = ref.watch(currentAcademyProvider);
              
              if (currentAcademy == null) {
                return const Center(
                  child: Text('No hay academia seleccionada'),
                );
              }
              
              // Ejemplo de padres/responsables (simulados)
              final List<Map<String, String>> parents = [
                {'id': '1', 'name': 'Ana García', 'email': 'ana.garcia@ejemplo.com', 'children': '2', 'phone': '555-123-4567'},
                {'id': '2', 'name': 'Juan Pérez', 'email': 'juan.perez@ejemplo.com', 'children': '1', 'phone': '555-987-6543'},
                {'id': '3', 'name': 'María Rodríguez', 'email': 'maria.rodriguez@ejemplo.com', 'children': '3', 'phone': '555-456-7890'},
                {'id': '4', 'name': 'Carlos Martínez', 'email': 'carlos.martinez@ejemplo.com', 'children': '1', 'phone': '555-789-0123'},
              ];
              
              // Filtrar padres según búsqueda
              final filteredParents = parents.where((parent) => 
                  (parent['name'] ?? '').toLowerCase().contains(_searchController.text.toLowerCase()) ||
                  (parent['email'] ?? '').toLowerCase().contains(_searchController.text.toLowerCase())).toList();
              
              if (filteredParents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.family_restroom, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'No hay padres/responsables registrados'
                            : 'No se encontraron padres/responsables con esa búsqueda',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: filteredParents.length,
                itemBuilder: (context, index) {
                  final parent = filteredParents[index];
                  final name = parent['name'] ?? 'Sin nombre';
                  final email = parent['email'] ?? 'Sin correo';
                  final children = parent['children'] ?? '0';
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.family_restroom, color: Colors.white),
                      ),
                      title: Text(name),
                      subtitle: Text('$email • $children atleta(s)'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navegación a detalle o edición de padre/responsable
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Detalle de padre/responsable en desarrollo')),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerTab() {
    return Column(
      children: [
        // Barra de búsqueda con botón de agregar propietario
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar propietarios...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      // ignore: avoid_redundant_argument_values
                      vertical: 0.0,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              // Botón de agregar propietario
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: () {
                    // Acción temporal mientras se desarrolla la pantalla de formulario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad en desarrollo - Solo SuperAdmin')),
                    );
                    _refreshOwners();
                  },
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  tooltip: 'Agregar Propietario',
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Lista de propietarios (temporalmente un placeholder)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Gestión de Propietarios en desarrollo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Solo los super administradores pueden gestionar propietarios.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad en desarrollo - Solo SuperAdmin')),
                    );
                  },
                  child: const Text('Ver Propietarios'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 