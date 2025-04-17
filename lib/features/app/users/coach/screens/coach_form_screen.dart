import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/components/profile_image_picker.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/features/app/users/user/core/services/user_image_service.dart';

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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationsController = TextEditingController();
  
  DateTime? _birthDate;
  User? _user;
  bool _isLoading = false;
  String? _errorMsg;
  
  // Variable para la ruta local de la imagen
  String? _newProfileImagePath;
  
  String? _preRegCode;
  
  // Método para manejar cuando se selecciona una nueva imagen
  void _handleProfileImageSelected(String imagePath) {
    setState(() {
      _newProfileImagePath = imagePath; // Almacenar ruta local
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
      final academyId = widget.academyId ?? currentAcademy?.academyId;
      
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
  
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _preRegCode = null;
    });
    
    try {
      final currentUser = await ref.read(authStateProvider.future);
      final userImageService = ref.read(userImageServiceProvider);
      final userService = ref.read(userServiceProvider);
      String? finalProfileImageUrl = _user?.profileImageUrl;
      
      // Modo creación (pre-registro)
      if (widget.mode == CoachFormMode.create) {
        final academyId = await _getCurrentAcademyId();
        if (academyId.isEmpty) throw Exception('No se pudo determinar la academia actual.');
        final createdBy = currentUser?.id ?? 'sistema';
        final userName = _nameController.text.trim();

        developer.log('INFO: Iniciando pre-registro para Coach...', name: 'CoachForm');
        
        // Subir imagen ANTES de crear el registro pendiente, si existe
        if (_newProfileImagePath != null) {
          developer.log('INFO: Subiendo imagen para pre-registro de Coach desde $_newProfileImagePath', name: 'CoachForm');
          try {
            // Asegurarse de que el tipo sea String
            final String uploadedUrl = await userImageService.uploadProfileImage(
              imagePath: _newProfileImagePath!, 
              academyId: academyId,
            );
            finalProfileImageUrl = uploadedUrl;
            developer.log('INFO: Imagen subida para pre-registro, URL: $finalProfileImageUrl', name: 'CoachForm');
          } catch (imgErr) {
             developer.log('WARN: Error al subir imagen durante pre-registro: $imgErr. Continuando sin imagen.', name: 'CoachForm');
             finalProfileImageUrl = null;
          }
        } else {
           developer.log('INFO: No se seleccionó imagen para pre-registro de Coach.', name: 'CoachForm');
        }

        developer.log('INFO: Llamando a createPendingActivationProvider (sin imageUrl por ahora)', name: 'CoachForm');
        // TODO: Modificar createPendingActivationProvider para aceptar profileImageUrl y pasar finalProfileImageUrl
        final String activationCode = await ref.read(createPendingActivationProvider(
          academyId: academyId,
          userName: userName,
          role: UserRole.coach,
          createdBy: createdBy,
          // profileImageUrl: finalProfileImageUrl, // <--- Eliminar temporalmente hasta que el provider lo acepte
        ).future);

        setState(() {
          _preRegCode = activationCode;
          _isLoading = false;
        });

        if (mounted) {
          _showActivationCodeDialog(_preRegCode!);
        }
      }
      // Modo edición
      else if (_user != null) {
        if (_newProfileImagePath != null) {
           developer.log('INFO: Subiendo nueva imagen de perfil para ${_user!.id} desde $_newProfileImagePath', name: 'CoachForm');
           try {
              // Asegurarse de que el tipo sea String
              final String newImageUrl = await userImageService.uploadProfileImage(
                    imagePath: _newProfileImagePath!,
                    userId: _user!.id,
                    academyId: widget.academyId ?? await _getCurrentAcademyId(),
                  );
              finalProfileImageUrl = newImageUrl;
              developer.log('INFO: Nueva imagen subida, URL: $finalProfileImageUrl', name: 'CoachForm');
           } catch (imgErr) {
             developer.log('WARN: Error al subir nueva imagen de perfil: $imgErr. Se mantendrá la imagen anterior si existe.', name: 'CoachForm', error: imgErr);
           }
        } else {
           developer.log('INFO: No se seleccionó nueva imagen de perfil.', name: 'CoachForm');
        }

        developer.log('INFO: Llamando a userService.updateUser para Coach - userId: ${_user!.id}', name: 'CoachForm');
        
        final updatedUser = _user!.copyWith(
          name: _nameController.text.trim(),
          profileImageUrl: finalProfileImageUrl,
        );
        
        await userService.updateUser(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrenador actualizado correctamente')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e, stack) {
      developer.log('ERROR: _saveForm - Error: $e\nStack: $stack', name: 'CoachForm', error: e, stackTrace: stack);
      setState(() {
        _errorMsg = 'Error al guardar: $e';
        _isLoading = false;
      });
    } finally {
      if (mounted && (widget.mode == CoachFormMode.edit || _errorMsg != null)) {
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
        ? 'Pre-registrar Nuevo Entrenador'
        : 'Editar Entrenador';
        
    final buttonText = widget.mode == CoachFormMode.create
        ? 'Generar Código Entrenador'
        : 'Guardar Cambios';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        actions: [
          if (_user?.isPendingActivation ?? false)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Pendiente'),
                backgroundColor: Colors.orange,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _buildForm(buttonText),
                if (_user?.isPendingActivation ?? false)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(30),
                      child: Center(
                        child: Card(
                          margin: const EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.pending_outlined,
                                  size: 48,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Usuario Pendiente de Activación',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Este usuario debe activar su cuenta usando el código proporcionado.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_user != null) {
                                      _showActivationCodeDialog(_user!.id);
                                    }
                                  },
                                  child: const Text('Ver Código de Activación'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
                    currentImageUrl: _newProfileImagePath == null ? _user?.profileImageUrl : null,
                    onImageSelected: _handleProfileImageSelected,
                    userId: _user?.id,
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
            
            // Email - Eliminado en modo creación
            if (widget.mode == CoachFormMode.edit && _user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  initialValue: _user!.email, // Mostrar email en modo edición
                  decoration: const InputDecoration(
                    labelText: 'Email (no editable)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true, // No editable
                ),
              ),
            
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
                onPressed: _isLoading ? null : _saveForm,
                child: Text(buttonText, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getCurrentAcademyId() async {
    developer.log('WARN: _getCurrentAcademyId - Usando ID placeholder. Implementar lógica real.', name: 'CoachForm');
    throw UnimplementedError('Necesita implementar la lógica para obtener el academyId actual');
  }

  void _showActivationCodeDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Código de Activación Generado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Comparte este código con el entrenador para que pueda activar su cuenta:'),
              const SizedBox(height: 16),
              Center(
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'El usuario deberá ingresar este código, su email y una contraseña en la pantalla de activación.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Copiar Código'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado al portapapeles')),
                );
              },
            ),
            TextButton(
              child: const Text('Cerrar y Finalizar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
} 