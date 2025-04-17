import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/components/profile_image_picker.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_image_service.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum ManagerFormMode { create, edit }

class ManagerFormScreen extends ConsumerStatefulWidget {
  final ManagerFormMode mode;
  final String? userId; // Requerido para modo edición
  final String? academyId; // Es nullable

  const ManagerFormScreen({
    super.key,
    required this.mode,
    this.userId,
    required this.academyId, // Requerido en constructor
  }) : assert(mode == ManagerFormMode.create || userId != null,
            'userId es requerido en modo edición');

  @override
  ConsumerState<ManagerFormScreen> createState() => _ManagerFormScreenState();
}

class _ManagerFormScreenState extends ConsumerState<ManagerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  
  DateTime? _birthDate;
  User? _user;
  bool _isLoading = false;
  String? _errorMsg;
  String? _preRegCode; // Para almacenar el código generado
  
  // Variables para manejar la imagen de perfil
  String? _localImagePath; // Ruta local de la imagen seleccionada

  @override
  void initState() {
    super.initState();
    if (widget.mode == ManagerFormMode.edit) {
      _loadManagerData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadManagerData() async {
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
      
      // Aquí podríamos cargar información adicional específica del manager
      // si se implementa un repositorio específico para perfiles de gerentes
      
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

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _preRegCode = null;
    });

    try {
      final currentUser = ref.read(authStateProvider).valueOrNull;
      final userImageService = ref.read(userImageServiceProvider);
      final userService = ref.read(userServiceProvider);
      final String? academyId = widget.academyId;
      String? finalProfileImageUrl = _user?.profileImageUrl;

      if (academyId == null) {
        setState(() {
          _errorMsg = 'Error: No se pudo determinar la academia actual.';
          _isLoading = false;
        });
        developer.log('ERROR: _saveForm - academyId es nulo desde el widget.', name: 'ManagerForm');
        return;
      }

      // Modo creación (pre-registro)
      if (widget.mode == ManagerFormMode.create) {
        final String userName = _nameController.text.trim();
        final String createdBy = currentUser?.id ?? 'unknown';

        developer.log('INFO: Iniciando pre-registro para Manager - academyId: $academyId', name: 'ManagerForm');

        // Subir imagen ANTES si existe
        if (_localImagePath != null) {
          developer.log('INFO: Subiendo imagen para pre-registro de Manager desde $_localImagePath', name: 'ManagerForm');
          try {
            final String uploadedUrl = await userImageService.uploadProfileImage(
              imagePath: _localImagePath!,
              academyId: academyId,
            );
            finalProfileImageUrl = uploadedUrl;
            developer.log('INFO: Imagen subida para pre-registro, URL: $finalProfileImageUrl', name: 'ManagerForm');
          } catch (imgErr) {
            developer.log('WARN: Error al subir imagen durante pre-registro: $imgErr. Continuando sin imagen.', name: 'ManagerForm');
            finalProfileImageUrl = null;
          }
        } else {
          developer.log('INFO: No se seleccionó imagen para pre-registro de Manager.', name: 'ManagerForm');
        }

        developer.log('INFO: Llamando a createPendingActivationProvider (sin imageUrl por ahora)', name: 'ManagerForm');
        // TODO: Modificar createPendingActivationProvider para aceptar profileImageUrl
        final String activationCode = await ref.read(createPendingActivationProvider(
          academyId: academyId,
          userName: userName,
          role: UserRole.manager,
          createdBy: createdBy,
          // profileImageUrl: finalProfileImageUrl, // <-- Pasar URL si el provider lo acepta
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
        // Subir imagen si se seleccionó una nueva
        if (_localImagePath != null) {
          developer.log('INFO: Subiendo nueva imagen de perfil para ${_user!.id} desde $_localImagePath', name: 'ManagerForm');
          try {
            final String newImageUrl = await userImageService.uploadProfileImage(
              imagePath: _localImagePath!,
              userId: _user!.id,
              academyId: academyId,
            );
            finalProfileImageUrl = newImageUrl;
            developer.log('INFO: Nueva imagen subida, URL: $finalProfileImageUrl', name: 'ManagerForm');
          } catch (imgErr) {
            developer.log('WARN: Error al subir nueva imagen de perfil: $imgErr. Se mantendrá la imagen anterior si existe.', name: 'ManagerForm', error: imgErr);
          }
        } else {
          developer.log('INFO: No se seleccionó nueva imagen de perfil.', name: 'ManagerForm');
        }

        final updatedUser = _user!.copyWith(
          name: _nameController.text.trim(),
          profileImageUrl: finalProfileImageUrl, // Usar la URL final
        );

        await userService.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gerente actualizado correctamente')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e, stack) { 
      developer.log('ERROR: _saveForm - Error: $e\nStack: $stack', name: 'ManagerForm', error: e, stackTrace: stack);
      setState(() {
        _errorMsg = 'Error al guardar: $e';
        _isLoading = false;
      });
    } finally {
      if (mounted && (widget.mode == ManagerFormMode.edit || _errorMsg != null)) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Renombrar el método del diálogo por consistencia
  void _showActivationCodeDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Código de Activación Generado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparte este código con el usuario para que pueda activar su cuenta:',
              style: TextStyle(fontSize: 14),
            ),
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
        actions: [
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
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.of(context).pop(true); // Cierra la pantalla del formulario y retorna true
            },
            child: const Text('Cerrar y Finalizar'),
          ),
        ],
      ),
    );
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

  // Método para manejar cuando se selecciona una nueva imagen
  void _handleProfileImageSelected(String imagePath) {
    setState(() {
      _localImagePath = imagePath; // Ahora almacenamos la ruta local, no la URL
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.mode == ManagerFormMode.create
        ? 'Pre-registrar Nuevo Gerente'
        : 'Editar Gerente';
        
    final buttonText = widget.mode == ManagerFormMode.create
        ? 'Pre-registrar Gerente'
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
            
            // Email - Eliminado en modo creación
            if (widget.mode == ManagerFormMode.edit && _user != null)
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
            
            // Sección de información laboral
            const Text(
              'Información Laboral',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Cargo
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Cargo',
                border: OutlineInputBorder(),
                hintText: 'Ej: Gerente Administrativo, Director Deportivo...',
              ),
            ),
            const SizedBox(height: 16),
            
            // Departamento
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
                hintText: 'Ej: Administración, Operaciones...',
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveForm, // Deshabilitar si ya está cargando
                child: Text(buttonText, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 