import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/shared/models/athlete_profile.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/services/user_service.dart';
import 'package:flutter/material.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
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
      final academyId = widget.academyId ?? currentAcademy?.id;
      
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
      _emailController.text = _user!.email;
      
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
  
  Future<void> _saveAthlete() async {
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
      
      Map<String, dynamic> medicalInfo = {};
      if (_medicalNotesController.text.isNotEmpty) {
        medicalInfo['notes'] = _medicalNotesController.text;
      }
      
      // Modo creación
      if (widget.mode == AthleteFormMode.create) {
        await userService.createAthlete(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
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
          number: _numberController.text.isNotEmpty 
              ? int.parse(_numberController.text) 
              : null,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Atleta creado correctamente')),
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
          number: _numberController.text.isNotEmpty 
              ? int.parse(_numberController.text) 
              : null,
        );
        
        // Crear o actualizar perfil
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
        
        // Guardar cambios
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
  

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.mode == AthleteFormMode.create
        ? 'Crear Nuevo Atleta'
        : 'Editar Atleta';
        
    final buttonText = widget.mode == AthleteFormMode.create
        ? 'Crear Atleta'
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
              readOnly: widget.mode == AthleteFormMode.edit,
            ),
            const SizedBox(height: 16),
            
            // Contraseña (solo en modo creación)
            if (widget.mode == AthleteFormMode.create)
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
            if (widget.mode == AthleteFormMode.create)
              const SizedBox(height: 24),
            
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveAthlete,
                child: Text(buttonText, style: const TextStyle(fontSize: 16)),
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
    if (_academy == null || _academy!.sportConfig == null) {
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

    final sportConfig = _academy!.sportConfig!;
    
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