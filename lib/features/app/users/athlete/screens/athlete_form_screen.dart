import 'dart:developer' as developer;
import 'dart:io';
import 'package:arcinus/features/app/academy/core/models/academy_model.dart';
import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/athlete/core/models/athlete_profile.dart';
import 'package:arcinus/features/app/users/user/components/profile_image_picker.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AthleteFormMode { create, edit }

class AthleteFormScreen extends ConsumerStatefulWidget {
  final AthleteFormMode mode;
  final String? userId; // Requerido para modo edición
  final String? academyId; // Si es nulo, se usará la academia actual

  const AthleteFormScreen({
    super.key,
    required this.mode,
    this.userId,
    this.academyId,
  }) : assert(mode == AthleteFormMode.create || userId != null,
            'userId es requerido en modo edición');

  @override
  ConsumerState<AthleteFormScreen> createState() => _AthleteFormScreenState();
}

class _AthleteFormScreenState extends ConsumerState<AthleteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _numberController = TextEditingController();
  
  DateTime? _birthDate;
  User? _user;
  AthleteProfile? _profile;
  bool _isLoading = false;
  String? _errorMsg;
  
  // Variables para los nuevos campos deportivos
  String? _selectedPosition;
  List<String> _selectedSpecializations = [];
  Academy? _academy;
  
  // Variable para la ruta de la imagen de perfil seleccionada
  String? _newProfileImagePath; // Se usa para guardar la ruta local temporal
  
  // Añadir nuevas variables de estado para control de pre-registro
  String? _preRegCode;
  
  // Método para manejar cuando se selecciona una nueva imagen (actualiza la ruta local)
  void _handleProfileImageSelected(String imagePath) {
    setState(() {
      _newProfileImagePath = imagePath;
    });
  }
  
  @override
  void initState() {
    super.initState();
    if (widget.mode == AthleteFormMode.edit) {
      _loadAthleteData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicalNotesController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadAthleteData() async {
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
      final result = await userService.getAthleteWithProfile(widget.userId!, academyId);
      
      _user = result['user'] as User;
      _profile = result['profile'] as AthleteProfile?;
      _academy = currentAcademy; // Guardar referencia a la academia

      if (_user == null) {
        throw Exception('Usuario no encontrado');
      }
      
      // Llenar formulario con datos existentes
      _nameController.text = _user!.name;
      
      // Cargar número del atleta si existe
      if (_user!.number != null) {
        _numberController.text = _user!.number.toString();
      }
      
      if (_profile != null) {
        _birthDate = _profile!.birthDate;
        
        if (_profile!.height != null) {
          _heightController.text = _profile!.height.toString();
        }
        
        if (_profile!.weight != null) {
          _weightController.text = _profile!.weight.toString();
        }
        
        if (_profile!.medicalInfo != null && _profile!.medicalInfo!.containsKey('notes')) {
          _medicalNotesController.text = _profile!.medicalInfo!['notes'] as String;
        }

        // Cargar datos deportivos específicos
        _selectedPosition = _profile!.position;
        _selectedSpecializations = _profile!.specializations ?? [];
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
      final currentAcademy = ref.read(currentAcademyProvider);
      final academyId = widget.academyId ?? currentAcademy?.academyId;
      final currentUser = ref.read(authStateProvider).valueOrNull;
      String? finalProfileImageUrl = _user?.profileImageUrl; // Inicializar con la URL existente

      if (academyId == null) {
        setState(() {
          _errorMsg = 'Error: No se pudo determinar la academia actual.';
          _isLoading = false;
        });
        developer.log('ERROR: _saveForm - academyId es nulo.', name: 'AthleteForm');
        return;
      }
      
      final userService = ref.read(userServiceProvider);
      
      // Subir imagen si se seleccionó una nueva (solo en modo edición)
      if (_newProfileImagePath != null && widget.mode == AthleteFormMode.edit && _user != null) {
        developer.log('INFO: Subiendo nueva imagen de perfil para ${_user!.id} desde $_newProfileImagePath', name: 'AthleteForm');
        File imageFileToUpload = File(_newProfileImagePath!); // Crear File desde la ruta local
        final imageUrl = await ref.read(authRepositoryProvider).uploadProfileImage(
              imageFileToUpload, // Pasar el File
              _user!.id,
            );
        finalProfileImageUrl = imageUrl; // Actualizar la URL final
      } else if (_newProfileImagePath != null && widget.mode == AthleteFormMode.create) {
         developer.log('WARN: _saveForm - Selección de imagen en modo creación ignorada.', name: 'AthleteForm');
      }
      
      Map<String, dynamic> medicalInfo = {};
      if (_medicalNotesController.text.isNotEmpty) {
        medicalInfo['notes'] = _medicalNotesController.text;
      }
      
      // Modo creación (pre-registro)
      if (widget.mode == AthleteFormMode.create) {
        final String userName = _nameController.text.trim();
        final String createdBy = currentUser?.id ?? 'unknown';
        
        developer.log('INFO: Llamando a createPendingActivationProvider para Atleta - academyId: $academyId, name: $userName, createdBy: $createdBy', name: 'AthleteForm');

        // Usar createPendingActivationProvider
        final String activationCode = await ref.read(createPendingActivationProvider(
          academyId: academyId,
          userName: userName,
          role: UserRole.athlete,
          createdBy: createdBy,
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
        final updatedUser = _user!.copyWith(
          name: _nameController.text.trim(),
          number: _numberController.text.isNotEmpty 
              ? int.parse(_numberController.text) 
              : null,
          profileImageUrl: finalProfileImageUrl, // Usar URL final
        );
        
        final updatedProfile = _profile != null 
            ? _profile!.copyWith(
                birthDate: _birthDate,
                height: _heightController.text.isNotEmpty 
                    ? double.parse(_heightController.text) 
                    : null,
                weight: _weightController.text.isNotEmpty 
                    ? double.parse(_weightController.text) 
                    : null,
                medicalInfo: medicalInfo.isNotEmpty ? medicalInfo : null,
                position: _selectedPosition,
                specializations: _selectedSpecializations.isNotEmpty ? _selectedSpecializations : null,
              )
            : AthleteProfile(
                userId: _user!.id,
                academyId: academyId,
                birthDate: _birthDate,
                height: _heightController.text.isNotEmpty 
                    ? double.parse(_heightController.text) 
                    : null,
                weight: _weightController.text.isNotEmpty 
                    ? double.parse(_weightController.text) 
                    : null,
                medicalInfo: medicalInfo.isNotEmpty ? medicalInfo : null,
                position: _selectedPosition,
                specializations: _selectedSpecializations.isNotEmpty ? _selectedSpecializations : null,
                createdAt: DateTime.now(),
              );
        
        await userService.updateAthlete(
          user: updatedUser,
          profile: updatedProfile,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Atleta actualizado correctamente')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e, stack) {
      developer.log('ERROR: _saveForm - Error: $e\nStack: $stack', name: 'AthleteForm', error: e, stackTrace: stack);
      setState(() {
        _errorMsg = 'Error al guardar: $e';
        _isLoading = false;
      });
    } finally {
      if (mounted && widget.mode == AthleteFormMode.edit && _errorMsg == null) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Diálogo para mostrar el código de activación (nombre y contenido actualizados)
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
              'Comparte este código con el atleta para que pueda activar su cuenta:',
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
              Navigator.of(context).pop(true); // Cierra la pantalla del formulario
            },
            child: const Text('Cerrar y Finalizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.mode == AthleteFormMode.create
        ? 'Pre-registrar Nuevo Atleta'
        : 'Editar Atleta';
        
    final buttonText = widget.mode == AthleteFormMode.create
        ? 'Generar Código Atleta' // Texto del botón actualizado
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
            
            // Email - Eliminado en modo creación, solo visible/readonly en edición
            if (widget.mode == AthleteFormMode.edit && _user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  initialValue: _user!.email,
                  decoration: const InputDecoration(
                    labelText: 'Email (no editable)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                  readOnly: true,
                ),
              ),
            
            // Información física
            const SizedBox(height: 16),
            const Text(
              'Información deportiva',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Campos específicos del deporte
            _buildSportSpecificFields(),
            
            // Sección de información médica
            const SizedBox(height: 24),
            const Text(
              'Información médica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            TextFormField(
              controller: _medicalNotesController,
              decoration: const InputDecoration(
                labelText: 'Notas médicas',
                border: OutlineInputBorder(),
                hintText: 'Alergias, condiciones médicas, etc.',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Botón de guardar
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveForm, // Llamar a _saveForm
                  child: Text(buttonText, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Método para construir la sección de campos deportivos específicos
  Widget _buildSportSpecificFields() {
    // Si no hay academia o sport config, mostrar campos generales
    if (_academy == null || _academy!.academySportConfig == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campos genéricos
          _buildHeightWeightFields(),
          
          const SizedBox(height: 16),
          
          // Campo para número de jugador
          TextFormField(
            controller: _numberController,
            decoration: const InputDecoration(
              labelText: 'Número de jugador',
              hintText: 'Ej. 10',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      );
    }

    final sportConfig = _academy!.academySportConfig!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campos generales de altura y peso
        _buildHeightWeightFields(),
        
        const SizedBox(height: 16),
        
        // Campo para número de jugador
        TextFormField(
          controller: _numberController,
          decoration: const InputDecoration(
            labelText: 'Número de jugador',
            hintText: 'Ej. 10',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        
        const SizedBox(height: 16),
        
        // Posiciones disponibles
        if (sportConfig.positions.isNotEmpty && sportConfig.positions.first != 'No aplica')
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Posición',
              border: OutlineInputBorder(),
            ),
            value: _selectedPosition,
            hint: const Text('Selecciona una posición'),
            items: sportConfig.positions.map((String position) {
              return DropdownMenuItem<String>(
                value: position,
                child: Text(position),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedPosition = value;
              });
            },
          ),
        
        if (sportConfig.positions.isNotEmpty && sportConfig.positions.first != 'No aplica')
          const SizedBox(height: 16),
        
        // Especializaciones (múltiple selección)
        if (sportConfig.athleteSpecializations.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Especializaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: sportConfig.athleteSpecializations.map((specialization) {
                  final isSelected = _selectedSpecializations.contains(specialization);
                  return FilterChip(
                    label: Text(specialization),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedSpecializations.add(specialization);
                        } else {
                          _selectedSpecializations.remove(specialization);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }
  
  // Extraer los campos de altura y peso para reutilizarlos
  Widget _buildHeightWeightFields() {
    return Column(
      children: [
        // Altura
        TextFormField(
          controller: _heightController,
          decoration: const InputDecoration(
            labelText: 'Altura (cm)',
            hintText: 'Ej. 175',
            border: OutlineInputBorder(),
            suffixText: 'cm',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        
        // Peso
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Peso (kg)',
            hintText: 'Ej. 70',
            border: OutlineInputBorder(),
            suffixText: 'kg',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
} 