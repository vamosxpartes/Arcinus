import 'dart:io';
import 'package:arcinus/shared/models/sport_characteristics.dart';
import 'package:arcinus/ux/features/academy/academy_controller.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

class CreateAcademyScreen extends ConsumerStatefulWidget {
  const CreateAcademyScreen({super.key});

  @override
  ConsumerState<CreateAcademyScreen> createState() => _CreateAcademyScreenState();
}

class _CreateAcademyScreenState extends ConsumerState<CreateAcademyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSport;
  File? _logoFile;
  bool _isLoading = false;
  
  // Lista de deportes disponibles con códigos normalizados
  final Map<String, String> _sports = {
    'basketball': 'Baloncesto',
    'volleyball': 'Voleibol',
    'skating': 'Patinaje',
    'soccer': 'Fútbol',
    'futsal': 'Fútbol de Salón',
    'otro': 'Otro'
  };

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _taxIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Método para seleccionar logo desde galería
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  // Método para crear la academia
  Future<void> _createAcademy() async {
    if (!_formKey.currentState!.validate() || _selectedSport == null) {
      // Mostrar error si no se ha seleccionado deporte
      if (_selectedSport == null) {
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Validación fallida: deporte no seleccionado');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona un deporte')),
        );
      } else {
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Validación fallida: formulario inválido');
      }
      return;
    }
    
    developer.log('DEBUG: CreateAcademyScreen._createAcademy - Validación exitosa, iniciando creación');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Crear academia
      final academyController = ref.read(academyControllerProvider);
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Obtenido controlador de academia');
      
      // Obtener características del deporte
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Deporte seleccionado: $_selectedSport');
      final sportConfig = _selectedSport == 'otro' 
          ? null 
          : SportCharacteristics.forSport(_selectedSport!);
      
      // Convertir SportCharacteristics a Map<String, dynamic> para evitar errores de serialización
      final sportConfigMap = sportConfig?.toJson();
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - SportConfig generado: ${sportConfigMap != null ? 'sí' : 'no'}');
      
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Llamando a academyController.createAcademy');
      final academy = await academyController.createAcademy(
        name: _nameController.text.trim(),
        sport: _sports[_selectedSport!] ?? _selectedSport!,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        taxId: _taxIdController.text.trim().isNotEmpty ? _taxIdController.text.trim() : null,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        sportConfig: sportConfigMap,
      );
      
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Academia creada exitosamente: ${academy.id}');
      
      // Subir logo si se seleccionó
      if (_logoFile != null) {
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Subiendo logo para academia ${academy.id}');
        await academyController.uploadAcademyLogo(
          academy.id,
          _logoFile!.path,
        );
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Logo subido exitosamente');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Navegando al dashboard');
        // Navegar al dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Usar unawaited intencionalmente para permitir la navegación inmediata
        // ignore: unawaited_futures
        Navigator.pushReplacementNamed(context, '/dashboard');
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Academia creada con éxito!')),
        );
      }
    } catch (e) {
      developer.log('ERROR: CreateAcademyScreen._createAcademy - Error al crear academia: $e', error: e);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar un mensaje más informativo para el error específico
        String errorMessage = e.toString();
        if (errorMessage.contains('propietario ya tiene una academia')) {
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Error de academia duplicada');
          // Si es el error específico de academia duplicada
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Un propietario solo puede tener una academia. No es posible crear múltiples academias.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          
          // Redirigir al dashboard donde verá su academia existente
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Redirigiendo al dashboard después de error de academia duplicada');
          Navigator.of(context).popUntil((route) => route.isFirst);
          await Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (errorMessage.contains('not-found')) {
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Error de documento no encontrado: $errorMessage');
          // Error específico de documento no encontrado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear academia: Documento no encontrado. Contacta al soporte técnico.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 7),
            ),
          );
        } else {
          // Para otros errores
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Error general: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la academia: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsAcademyCreation = ref.watch(needsAcademyCreationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Academia'),
        // Mostrar botón de cancelar solo si no es obligatoria la creación
        leading: needsAcademyCreation.maybeWhen(
          data: (needsCreation) => needsCreation ? null : const BackButton(),
          orElse: () => const BackButton(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Si es obligatorio crear academia, mostrar mensaje explicativo
                needsAcademyCreation.maybeWhen(
                  data: (needsCreation) => needsCreation
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Información',
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Para comenzar a usar la aplicación, primero debes crear una academia deportiva.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
                
                // Logo
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        image: _logoFile != null
                            ? DecorationImage(
                                image: FileImage(_logoFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _logoFile == null
                          ? const Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Campo de nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Academia',
                    hintText: 'Ej. Academia Deportiva Campeones',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Selector de deporte
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Deporte',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSport,
                  hint: const Text('Selecciona un deporte'),
                  items: _sports.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedSport = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // NUEVOS CAMPOS
                
                // Campo de ubicación
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    hintText: 'Ej. Calle 123 # 45-67, Ciudad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo de NIT
                TextFormField(
                  controller: _taxIdController,
                  decoration: const InputDecoration(
                    labelText: 'NIT o Identificador Fiscal',
                    hintText: 'Ej. 901.234.567-8',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Campo de descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe brevemente tu academia deportiva',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: OutlinedButton(
                          onPressed: needsAcademyCreation.maybeWhen(
                            data: (needsCreation) => needsCreation 
                              ? null  // Deshabilitamos si es obligatorio crear
                              : (_isLoading ? null : () => Navigator.pop(context)),
                            orElse: () => _isLoading ? null : () => Navigator.pop(context),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createAcademy,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Crear Academia'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Espacio adicional al final
              ],
            ),
          ),
        ),
      ),
    );
  }
} 