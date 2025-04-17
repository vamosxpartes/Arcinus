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
  
  // Variables para la imagen
  String? _newProfileImagePath; // Ruta local de la nueva imagen seleccionada
  
  // Añadir variables para el control de pre-registro
  String? _preRegCode;
  
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
      final academyId = widget.academyId ?? currentAcademy?.academyId;
      
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
      final academyId = widget.academyId ?? currentAcademy?.academyId;
      
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
  
  void _handleProfileImageSelected(String imagePath) {
    setState(() {
      _newProfileImagePath = imagePath; // Guardar la ruta local
    });
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
    
    final userService = ref.read(userServiceProvider);
    final userImageService = ref.read(userImageServiceProvider);
    final currentUser = await ref.read(authStateProvider.future);
    String? finalProfileImageUrl = _user?.profileImageUrl;
    
    try {
      // Construir datos específicos del Parent ANTES de las operaciones de red
      Map<String, dynamic> parentData = {};
      if (_phoneController.text.isNotEmpty) parentData['phone'] = _phoneController.text;
      if (_addressController.text.isNotEmpty) parentData['address'] = _addressController.text;
      if (_birthDate != null) parentData['birthDate'] = _birthDate!.toIso8601String();
      if (_selectedAthleteIds.isNotEmpty) parentData['childrenIds'] = _selectedAthleteIds.toList();

      // Modo creación -> Generar código de activación
      if (widget.mode == ParentFormMode.create) {
        developer.log('INFO: Iniciando pre-registro de Padre/Responsable', name: 'ParentForm');
        
        final String? academyId = ref.watch(currentAcademyIdProvider);
        if (academyId == null) {
          setState(() {
            _errorMsg = 'Error: No se pudo determinar la academia actual.';
            _isLoading = false;
          });
          developer.log('ERROR: _saveForm - academyId es nulo.', name: 'ParentForm');
          return;
        }

        final String userName = _nameController.text.trim();
        final String createdBy = currentUser?.id ?? 'unknown';
        
        // Subir imagen ANTES si existe
        if (_newProfileImagePath != null) {
           developer.log('INFO: Subiendo imagen para pre-registro de Parent desde $_newProfileImagePath', name: 'ParentForm');
           try {
              final String uploadedUrl = await userImageService.uploadProfileImage(
                imagePath: _newProfileImagePath!,
                academyId: academyId,
              );
              finalProfileImageUrl = uploadedUrl;
              developer.log('INFO: Imagen subida para pre-registro, URL: $finalProfileImageUrl', name: 'ParentForm');
           } catch (imgErr) {
             developer.log('WARN: Error al subir imagen durante pre-registro: $imgErr. Continuando sin imagen.', name: 'ParentForm');
             finalProfileImageUrl = null;
           }
        } else {
           developer.log('INFO: No se seleccionó imagen para pre-registro de Parent.', name: 'ParentForm');
        }
        
        developer.log('INFO: Llamando a createPendingActivationProvider (sin imageUrl por ahora)', name: 'ParentForm');
        // TODO: Modificar createPendingActivationProvider para aceptar profileImageUrl
        final String activationCode = await ref.read(createPendingActivationProvider(
          academyId: academyId,
          userName: userName,
          role: UserRole.parent,
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
      // Modo edición -> Actualizar usuario existente
      else if (_user != null) {
         // Subir imagen si se seleccionó una nueva
        if (_newProfileImagePath != null) {
          developer.log('INFO: Subiendo nueva imagen de perfil para ${_user!.id} desde $_newProfileImagePath', name: 'ParentForm');
          try {
            final String newImageUrl = await userImageService.uploadProfileImage(
              imagePath: _newProfileImagePath!,
              userId: _user!.id,
              academyId: widget.academyId ?? ref.read(currentAcademyIdProvider), // Obtener academyId actual
            );
            finalProfileImageUrl = newImageUrl;
            developer.log('INFO: Nueva imagen subida, URL: $finalProfileImageUrl', name: 'ParentForm');
          } catch (imgErr) {
            developer.log('WARN: Error al subir nueva imagen de perfil: $imgErr. Se mantendrá la imagen anterior si existe.', name: 'ParentForm', error: imgErr);
          }
        } else {
          developer.log('INFO: No se seleccionó nueva imagen de perfil.', name: 'ParentForm');
        }

        developer.log('INFO: Llamando a userService.updateParent - userId: ${_user!.id}', name: 'ParentForm');

        await userService.updateParent(
          userId: _user!.id,
          name: _nameController.text.trim(),
          email: _user!.email, // Mantener el email existente
          parentData: parentData, // Pasar los datos específicos actualizados
          profileImageUrl: finalProfileImageUrl, // Pasar la URL final de la imagen
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Padre/Responsable actualizado correctamente')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e, stack) {
       developer.log(
         'ERROR: _saveForm - Error al guardar padre/responsable: $e\nStack: $stack',
         name: 'ParentForm',
         error: e,
         stackTrace: stack
       );
      setState(() {
        _errorMsg = 'Error al guardar: $e';
        _isLoading = false;
      });
    } finally {
      if (mounted && (widget.mode == ParentFormMode.edit || _errorMsg != null)) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              const Text('Comparte este código con el padre/responsable para que pueda activar su cuenta:'),
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

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.mode == ParentFormMode.create
        ? 'Pre-registrar Nuevo Padre/Responsable'
        : 'Editar Padre/Responsable';
        
    final buttonText = widget.mode == ParentFormMode.create
        ? 'Pre-registrar Padre/Responsable'
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
            if (widget.mode == ParentFormMode.edit && _user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  initialValue: _user!.email,
                  decoration: const InputDecoration(
                    labelText: 'Email (no editable)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ),
            
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
                onPressed: _isLoading ? null : _saveForm,
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
} 