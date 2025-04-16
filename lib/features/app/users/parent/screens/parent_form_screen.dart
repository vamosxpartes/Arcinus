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
    final currentUser = await ref.read(authStateProvider.future);
    String? finalProfileImageUrl = _user?.profileImageUrl;
    
    try {
      // Subir imagen si se seleccionó una nueva (solo en modo edición)
      if (_newProfileImagePath != null && widget.mode == ParentFormMode.edit && _user != null) {
        developer.log('INFO: Subiendo nueva imagen de perfil para ${_user!.id} desde $_newProfileImagePath', name: 'ParentForm');
        File imageFileToUpload = File(_newProfileImagePath!); // Crear el File desde la ruta
        final imageUrl = await ref.read(authRepositoryProvider).uploadProfileImage(
              imageFileToUpload, // Pasar el File
              _user!.id,
            );
        finalProfileImageUrl = imageUrl;
      } else if (_newProfileImagePath != null && widget.mode == ParentFormMode.create) {
         developer.log('WARN: _saveForm - Selección de imagen en modo creación ignorada.', name: 'ParentForm');
      }
      
      // Construir datos específicos del Parent
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
      if (_selectedAthleteIds.isNotEmpty) {
        parentData['childrenIds'] = _selectedAthleteIds.toList();
      }
      
      // Modo creación -> Generar código de activación
      if (widget.mode == ParentFormMode.create) {
        developer.log('INFO: Iniciando pre-registro de Padre/Responsable', name: 'ParentForm');
        
        // Obtener el ID de la academia actual usando el provider
        final String? academyId = ref.watch(currentAcademyIdProvider);
        
        // Validar que el academyId no sea nulo
        if (academyId == null) {
          setState(() {
            _errorMsg = 'Error: No se pudo determinar la academia actual.';
            _isLoading = false;
          });
          developer.log('ERROR: _saveForm - academyId es nulo.', name: 'ParentForm');
          return; // Detener la ejecución si no hay ID de academia
        }

        final String userName = _nameController.text.trim();
        final String createdBy = currentUser?.id ?? 'unknown'; // Obtener ID del usuario que crea
        
        developer.log('INFO: Llamando a createPendingActivationProvider - academyId: $academyId, name: $userName, role: ${UserRole.parent}, createdBy: $createdBy', name: 'ParentForm');

        // Usar await para obtener el resultado del Future
        final String activationCode = await ref.read(createPendingActivationProvider(
          academyId: academyId, // Usar el ID obtenido
          userName: userName,
          role: UserRole.parent,
          createdBy: createdBy,
        ).future);
        
        setState(() {
          _preRegCode = activationCode; // Asignar el String resultante
          _isLoading = false;
        });
        
        if (mounted) {
          _showActivationCodeDialog(_preRegCode!);
        }
      }
      // Modo edición -> Actualizar usuario existente
      else if (_user != null) {
        developer.log(
          'INFO: Llamando a userService.updateParent - userId: ${_user!.id}', name: 'ParentForm');

        await userService.updateParent(
          userId: _user!.id,
          name: _nameController.text.trim(),
          email: _user!.email,
          parentData: parentData,
          profileImageUrl: finalProfileImageUrl,
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
      if (mounted && widget.mode == ParentFormMode.edit && _errorMsg == null) {
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