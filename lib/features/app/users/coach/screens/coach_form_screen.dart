import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/components/profile_image_picker.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum CoachFormMode { create, edit }

class CoachFormScreen extends ConsumerStatefulWidget {
  final CoachFormMode mode;
  final String? userId; // Requerido para modo edición
  final String? academyId; // Si es nulo, se usará la academia actual

  const CoachFormScreen({
    super.key,
    required this.mode,
    this.userId,
    this.academyId,
  }) : assert(mode == CoachFormMode.create || userId != null,
            'userId es requerido en modo edición');

  @override
  ConsumerState<CoachFormScreen> createState() => _CoachFormScreenState();
}

class _CoachFormScreenState extends ConsumerState<CoachFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationsController = TextEditingController();
  
  DateTime? _birthDate;
  User? _user;
  bool _isLoading = false;
  String? _errorMsg;
  
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
    if (widget.mode == CoachFormMode.edit) {
      _loadCoachData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _loadCoachData() async {
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
      _user = await userService.getUserById(widget.userId!);
      
      if (_user == null) {
        throw Exception('Usuario no encontrado');
      }
      
      // Llenar formulario con datos básicos del usuario
      _nameController.text = _user!.name;
      _emailController.text = _user!.email;
      
      // Aquí se podría cargar información adicional específica del coach
      // como certificaciones, especialidades, etc. si se implementa un repositorio específico
      
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
  
  Future<void> _saveCoach() async {
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
      
      // Modo creación
      if (widget.mode == CoachFormMode.create) {
        final String? profileImageUrl = _profileImageUrl;
        
        await userService.createCoach(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          academyId: academyId,
          profileImageUrl: profileImageUrl,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrenador creado correctamente')),
          );
          Navigator.of(context).pop(true);
        }
      }
      // Modo edición
      else if (_user != null) {
        // Actualizar datos básicos del usuario
        final updatedUser = _user!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          profileImageUrl: _profileImageUrl ?? _user!.profileImageUrl,
        );
        
        // Aquí se podría guardar información adicional específica del coach
        
        // Guardar cambios del usuario
        await userService.updateUser(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrenador actualizado correctamente')),
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
      firstDate: DateTime(1950),
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
    final screenTitle = widget.mode == CoachFormMode.create
        ? 'Crear Nuevo Entrenador'
        : 'Editar Entrenador';
        
    final buttonText = widget.mode == CoachFormMode.create
        ? 'Crear Entrenador'
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
              readOnly: widget.mode == CoachFormMode.edit,
            ),
            const SizedBox(height: 16),
            
            // Contraseña (solo en modo creación)
            if (widget.mode == CoachFormMode.create)
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
            if (widget.mode == CoachFormMode.create)
              const SizedBox(height: 24),
            
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
                labelText: 'Dirección (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sección de información profesional
            const Text(
              'Información Profesional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Especialidad
            TextFormField(
              controller: _specialtyController,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
                border: OutlineInputBorder(),
                hintText: 'Ej: Fútbol juvenil, Entrenamiento de fuerza...',
              ),
            ),
            const SizedBox(height: 16),
            
            // Años de experiencia
            TextFormField(
              controller: _experienceController,
              decoration: const InputDecoration(
                labelText: 'Años de experiencia',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Certificaciones
            TextFormField(
              controller: _certificationsController,
              decoration: const InputDecoration(
                labelText: 'Certificaciones (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Lista de certificaciones relevantes',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveCoach,
                child: Text(buttonText, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 