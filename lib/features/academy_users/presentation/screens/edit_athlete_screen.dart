import 'package:arcinus/features/academy_users/data/repositories/academy_users_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditAthleteScreen extends ConsumerStatefulWidget {
  final String academyId;
  final String userId;
  final AcademyUserModel initialUserData;

  const EditAthleteScreen({
    super.key,
    required this.academyId,
    required this.userId,
    required this.initialUserData,
  });

  @override
  ConsumerState<EditAthleteScreen> createState() => _EditAthleteScreenState();
}

class _EditAthleteScreenState extends ConsumerState<EditAthleteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos de texto
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicalConditionsController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  
  // Fecha de nacimiento
  DateTime? _birthDate;
  
  // Estado para controlar la carga
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con datos del usuario
    _firstNameController = TextEditingController(text: widget.initialUserData.firstName);
    _lastNameController = TextEditingController(text: widget.initialUserData.lastName);
    _phoneController = TextEditingController(text: widget.initialUserData.phoneNumber ?? '');
    _positionController = TextEditingController(text: widget.initialUserData.position ?? '');
    _heightController = TextEditingController(
      text: widget.initialUserData.heightCm != null ? widget.initialUserData.heightCm.toString() : '',
    );
    _weightController = TextEditingController(
      text: widget.initialUserData.weightKg != null ? widget.initialUserData.weightKg.toString() : '',
    );
    _allergiesController = TextEditingController(text: widget.initialUserData.allergies ?? '');
    _medicalConditionsController = TextEditingController(text: widget.initialUserData.medicalConditions ?? '');
    
    // Inicializar fecha de nacimiento
    _birthDate = widget.initialUserData.birthDate;
    
    // Inicializar datos de contacto de emergencia
    if (widget.initialUserData.emergencyContact != null) {
      _emergencyNameController = TextEditingController(
        text: widget.initialUserData.emergencyContact!['name']?.toString() ?? '',
      );
      _emergencyPhoneController = TextEditingController(
        text: widget.initialUserData.emergencyContact!['phone']?.toString() ?? '',
      );
    } else {
      _emergencyNameController = TextEditingController();
      _emergencyPhoneController = TextEditingController();
    }
    
    // Añadir listeners para detectar cambios
    _addChangeListeners();
  }
  
  void _addChangeListeners() {
    void onChanged() {
      if (!mounted) return;
      setState(() {
        _hasChanges = true;
      });
    }
    
    _firstNameController.addListener(onChanged);
    _lastNameController.addListener(onChanged);
    _phoneController.addListener(onChanged);
    _positionController.addListener(onChanged);
    _heightController.addListener(onChanged);
    _weightController.addListener(onChanged);
    _allergiesController.addListener(onChanged);
    _medicalConditionsController.addListener(onChanged);
    _emergencyNameController.addListener(onChanged);
    _emergencyPhoneController.addListener(onChanged);
  }

  @override
  void dispose() {
    // Liberar controladores
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }
  
  Future<void> _selectBirthDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null && pickedDate != _birthDate) {
      setState(() {
        _birthDate = pickedDate;
        _hasChanges = true;
      });
    }
  }
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Preparar datos actualizados
      final Map<String, dynamic> updatedData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'updatedAt': DateTime.now(),
      };
      
      // Añadir campos opcionales
      final phoneText = _phoneController.text.trim();
      if (phoneText.isNotEmpty) {
        updatedData['phoneNumber'] = phoneText;
      }
      
      final positionText = _positionController.text.trim();
      if (positionText.isNotEmpty) {
        updatedData['position'] = positionText;
      }
      
      final heightText = _heightController.text.trim();
      if (heightText.isNotEmpty) {
        final heightValue = int.tryParse(heightText);
        if (heightValue != null) {
          updatedData['heightCm'] = heightValue;
        }
      }
      
      final weightText = _weightController.text.trim();
      if (weightText.isNotEmpty) {
        final weightValue = int.tryParse(weightText);
        if (weightValue != null) {
          updatedData['weightKg'] = weightValue;
        }
      }
      
      if (_birthDate != null) {
        updatedData['birthDate'] = _birthDate;
      }
      
      final allergiesText = _allergiesController.text.trim();
      if (allergiesText.isNotEmpty) {
        updatedData['allergies'] = allergiesText;
      }
      
      final medicalText = _medicalConditionsController.text.trim();
      if (medicalText.isNotEmpty) {
        updatedData['medicalConditions'] = medicalText;
      }
      
      final emergencyNameText = _emergencyNameController.text.trim();
      final emergencyPhoneText = _emergencyPhoneController.text.trim();
      if (emergencyNameText.isNotEmpty || emergencyPhoneText.isNotEmpty) {
        updatedData['emergencyContact'] = {
          'name': emergencyNameText,
          'phone': emergencyPhoneText,
        };
      }
      
      // Guardar en Firestore
      final repository = ref.read(academyUsersRepositoryProvider);
      await repository.updateUser(widget.academyId, widget.userId, updatedData);
      
      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Datos actualizados con éxito!')),
        );
        
        // Actualizar el estado
        setState(() {
          _isLoading = false;
          _hasChanges = false;
        });
        
        // Volver a la pantalla anterior
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Atleta'),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _isLoading ? null : _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección Información Personal
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Información Personal',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const Divider(),
                            // Nombre
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                hintText: 'Ingrese el nombre',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, ingrese el nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Apellido
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Apellido',
                                hintText: 'Ingrese el apellido',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, ingrese el apellido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Fecha de nacimiento
                            GestureDetector(
                              onTap: _selectBirthDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de nacimiento',
                                  hintText: 'Seleccione la fecha de nacimiento',
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _birthDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                                      : 'No seleccionada',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Teléfono
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                hintText: 'Ingrese el número de teléfono',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Sección Información Deportiva
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.sports_soccer, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Información Deportiva',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const Divider(),
                            // Posición
                            TextFormField(
                              controller: _positionController,
                              decoration: const InputDecoration(
                                labelText: 'Posición',
                                hintText: 'Ingrese la posición del atleta',
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Altura
                            TextFormField(
                              controller: _heightController,
                              decoration: const InputDecoration(
                                labelText: 'Altura (cm)',
                                hintText: 'Ingrese la altura en centímetros',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            // Peso
                            TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Peso (kg)',
                                hintText: 'Ingrese el peso en kilogramos',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Sección Información Médica
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.medical_services, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Información Médica',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const Divider(),
                            // Alergias
                            TextFormField(
                              controller: _allergiesController,
                              decoration: const InputDecoration(
                                labelText: 'Alergias',
                                hintText: 'Ingrese alergias conocidas',
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            // Condiciones médicas
                            TextFormField(
                              controller: _medicalConditionsController,
                              decoration: const InputDecoration(
                                labelText: 'Condiciones médicas',
                                hintText: 'Ingrese condiciones médicas relevantes',
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Sección Contacto de Emergencia
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emergency, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Contacto de Emergencia',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const Divider(),
                            // Nombre del contacto
                            TextFormField(
                              controller: _emergencyNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del contacto',
                                hintText: 'Ingrese el nombre del contacto de emergencia',
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Teléfono del contacto
                            TextFormField(
                              controller: _emergencyPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono del contacto',
                                hintText: 'Ingrese el teléfono del contacto de emergencia',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botón guardar
                    ElevatedButton.icon(
                      onPressed: _isLoading || !_hasChanges ? null : _saveChanges,
                      icon: const Icon(Icons.save),
                      label: Text(_isLoading ? 'Guardando...' : 'Guardar cambios'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 