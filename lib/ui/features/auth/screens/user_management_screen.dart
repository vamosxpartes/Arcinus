import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    // Inicialmente creamos 4 tabs: Managers, Coaches, Atletas, Grupos
    _tabController = TabController(length: 4, vsync: this);
    
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
            default:
              // La pestaña de grupos no tiene un rol asociado directamente
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;
    final bool canManageAllUsers = user?.role == UserRole.owner || user?.role == UserRole.manager;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Managers'),
            Tab(text: 'Entrenadores'),
            Tab(text: 'Atletas'),
            Tab(text: 'Grupos'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Tab de Managers
              _buildUserCategoryTab(UserRole.manager),
              
              // Tab de Entrenadores
              _buildUserCategoryTab(UserRole.coach),
              
              // Tab de Atletas
              _buildUserCategoryTab(UserRole.athlete),
              
              // Tab de Grupos
              _buildGroupsTab(),
            ],
          ),
          
          // Formulario de invitación por etapas
          if (_showInviteForm)
            _buildMultiStepForm(theme, canManageAllUsers),
        ],
      ),
    );
  }

  Widget _buildUserCategoryTab(UserRole role) {
    return Column(
      children: [
        // Barra de búsqueda con botón de agregar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barra de búsqueda
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar ${_getRoleName(role).toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      // ignore: avoid_redundant_argument_values
                      vertical: 0.0,
                    ),
                  ),
                ),
              ),
              
              // Botón de agregar usuario
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  onPressed: _toggleInviteForm,
                  icon: Icon(
                    _showInviteForm ? Icons.close : Icons.person_add,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  tooltip: _showInviteForm 
                      ? 'Cancelar' 
                      : 'Agregar ${_getRoleName(role)}',
                ),
              ),
            ],
          ),
        ),
        
        // Etiquetas para filtrado
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos'),
                _buildFilterChip('Activos'),
                _buildFilterChip('Inactivos'),
                if (role == UserRole.coach) _buildFilterChip('Con grupos'),
                if (role == UserRole.athlete) _buildFilterChip('Sin grupo'),
              ],
            ),
          ),
        ),
        
        const Divider(),
        
        // Lista de usuarios (simulada)
        Expanded(
          child: _buildPlaceholderUserList(role),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool selected) {
          // Implementar filtrado
        },
      ),
    );
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
        
        // Etiquetas para filtrado
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos'),
                _buildFilterChip('Activos'),
                _buildFilterChip('Inactivos'),
              ],
            ),
          ),
        ),
        
        const Divider(),
        
        // Lista de grupos (simulada)
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Gestión de Grupos en desarrollo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('La gestión de grupos se implementará próximamente.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMultiStepForm(ThemeData theme, bool canManageAllUsers) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Encabezado con pasos
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  'Crear nuevo ${_getRoleName(_selectedRole)}',
                  style: theme.textTheme.titleLarge,
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
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
                  _getStepTitle(_currentFormStep),
                  style: theme.textTheme.titleMedium,
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
                child: _buildCurrentStepContent(theme, canManageAllUsers),
              ),
            ),
          ),
          
          // Barra inferior con botones
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
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
      default:
        return '';
    }
  }
} 