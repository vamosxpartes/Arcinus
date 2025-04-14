import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/components/profile_image_picker.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum ParentFormMode { create, edit }

class ParentFormScreen extends ConsumerStatefulWidget {
  final ParentFormMode mode;
  final String? userId; // Requerido para modo edición
  final String? academyId; // Si es nulo, se usará la academia actual

  const ParentFormScreen({
    super.key,
    required this.mode,
    this.userId,
    this.academyId,
  }) : assert(mode == ParentFormMode.create || userId != null,
            'userId es requerido en modo edición');

  @override
  ConsumerState<ParentFormScreen> createState() => _ParentFormScreenState();
}

class _ParentFormScreenState extends ConsumerState<ParentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  DateTime? _birthDate;
  User? _user;
  Map<String, dynamic> _parentData = {};
  bool _isLoading = false;
  String? _errorMsg;
  
  // Lista de atletas asociados al padre
  List<User> _allAthletes = [];
  Set<String> _selectedAthleteIds = {};
  
  // Nuevo campo para almacenar la URL de la imagen de perfil
  String? _profileImageUrl;
  
  // Método para manejar cuando se selecciona una nueva imagen
  void _handleProfileImageSelected(String imageUrl) {
    setState(() {
      _profileImageUrl = imageUrl;
    });
  }
  
  @override
  void initState() {
    super.initState();
    if (widget.mode == ParentFormMode.edit) {
      _loadParentData();
    } else {
      _loadAthletes();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadAthletes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentAcademy = ref.read(currentAcademyProvider);
      final academyId = widget.academyId ?? currentAcademy?.id;
      
      if (academyId == null) {
        throw Exception('No se ha seleccionado una academia');
      }
      
      final userService = ref.read(userServiceProvider);
      _allAthletes = await userService.getUsersByRole(
        UserRole.athlete,
        academyId: academyId
      );
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al cargar atletas: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadParentData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final currentAcademy = ref.read(currentAcademyProvider);
      final academyId = widget.academyId ?? currentAcademy?.id;
      
      if (academyId == null) {
        throw Exception('No se ha seleccionado una academia');
      }
      
      final userService = ref.read(userServiceProvider);
      
      // Obtener el usuario y sus datos adicionales
      final result = await userService.getParentWithData(widget.userId!, academyId);
      
      _user = result['user'] as User;
      _parentData = result['parentData'] as Map<String, dynamic>? ?? {};
      
      if (_user == null) {
        throw Exception('Usuario no encontrado');
      }
      
      // Llenar formulario con datos existentes
      _nameController.text = _user!.name;
      _emailController.text = _user!.email;
      
      // Cargar datos adicionales si los hay
      if (_parentData.containsKey('phone')) {
        _phoneController.text = _parentData['phone'] as String;
      }
      if (_parentData.containsKey('address')) {
        _addressController.text = _parentData['address'] as String;
      }
      if (_parentData.containsKey('birthDate')) {
        _birthDate = DateTime.parse(_parentData['birthDate'] as String);
      }
      
      // Cargar la lista de atletas
      await _loadAthletes();
      
      // Obtener los atletas asociados al padre
      if (_parentData.containsKey('childrenIds')) {
        final childrenIds = _parentData['childrenIds'] as List<dynamic>;
        _selectedAthleteIds = Set.from(childrenIds.map((id) => id.toString()));
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveParent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    
    try {
      final currentAcademy = ref.read(currentAcademyProvider);
      final academyId = widget.academyId ?? currentAcademy?.id;
      
      if (academyId == null) {
        throw Exception('No se ha seleccionado una academia');
      }
      
      final userService = ref.read(userServiceProvider);
      
      // Datos adicionales para el padre
      Map<String, dynamic> parentData = {};
      
      if (_phoneController.text.isNotEmpty) {
        parentData['phone'] = _phoneController.text;
      }
      
      if (_addressController.text.isNotEmpty) {
        parentData['address'] = _addressController.text;
      }
      
      if (_birthDate != null) {
        parentData['birthDate'] = _birthDate!.toIso8601String();
      }
      
      // Asociar los atletas seleccionados
      if (_selectedAthleteIds.isNotEmpty) {
        parentData['childrenIds'] = _selectedAthleteIds.toList();
      }
      
      // Modo creación
      if (widget.mode == ParentFormMode.create) {
        await userService.createParent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          academyId: academyId,
          parentData: parentData,
          profileImageUrl: _profileImageUrl,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Padre/Madre creado correctamente')),
          );
          Navigator.of(context).pop(true);
        }
      }
      // Modo edición
      else if (_user != null) {
        // Actualizar datos básicos del usuario
        await userService.updateParent(
          userId: _user!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          parentData: parentData,
          profileImageUrl: _profileImageUrl ?? _user!.profileImageUrl,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Padre/Madre actualizado correctamente')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al guardar: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(DateTime.now().year - 30),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.mode == ParentFormMode.create
        ? 'Crear Nuevo Padre/Madre'
        : 'Editar Padre/Madre';
        
    final buttonText = widget.mode == ParentFormMode.create
        ? 'Crear Padre/Madre'
        : 'Guardar Cambios';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(buttonText),
    );
  }
  
  Widget _buildForm(String buttonText) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMsg != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _errorMsg!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            
            // Selector de imagen de perfil
            Center(
              child: Column(
                children: [
                  ProfileImagePicker(
                    currentImageUrl: _user?.profileImageUrl,
                    userId: _user?.id,
                    onImageSelected: _handleProfileImageSelected,
                    iconColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Foto de perfil',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Sección de información básica
            const Text(
              'Información Básica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Nombre completo
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Por favor ingresa un email válido';
                }
                return null;
              },
              readOnly: widget.mode == ParentFormMode.edit,
            ),
            const SizedBox(height: 16),
            
            // Contraseña (solo en modo creación)
            if (widget.mode == ParentFormMode.create)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
            if (widget.mode == ParentFormMode.create)
              const SizedBox(height: 24),
            
            // Sección de información de contacto
            const Text(
              'Información de Contacto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Teléfono
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Dirección
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Fecha de nacimiento
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_birthDate == null
                        ? 'Seleccionar fecha'
                        : DateFormat('dd/MM/yyyy').format(_birthDate!)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sección de hijos (atletas)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hijos (Atletas)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_selectedAthleteIds.length} seleccionados',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildAthleteSelector(),
            
            const SizedBox(height: 32),
            
            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveParent,
                child: Text(buttonText, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAthleteSelector() {
    if (_allAthletes.isEmpty) {
      return Card(
        color: Colors.amber[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.amber[700]),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'No hay atletas disponibles. Debes crear atletas primero.',
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      height: 200,
      child: ListView.builder(
        itemCount: _allAthletes.length,
        itemBuilder: (context, index) {
          final athlete = _allAthletes[index];
          final isSelected = _selectedAthleteIds.contains(athlete.id);
          
          return CheckboxListTile(
            title: Text(athlete.name),
            subtitle: Text(athlete.email),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedAthleteIds.add(athlete.id);
                } else {
                  _selectedAthleteIds.remove(athlete.id);
                }
              });
            },
          );
        },
      ),
    );
  }
} 