import 'dart:io';
import 'package:arcinus/ux/features/academy/academy_controller.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  
  // Lista de deportes disponibles
  final List<String> _sports = [
    'Fútbol',
    'Baloncesto',
    'Voleibol',
    'Natación',
    'Tenis',
    'Artes Marciales',
    'Gimnasia',
    'Atletismo',
    'Otro'
  ];

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona un deporte')),
        );
      }
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Crear academia
      final academyController = ref.read(academyControllerProvider);
      final academy = await academyController.createAcademy(
        name: _nameController.text.trim(),
        sport: _selectedSport!,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        taxId: _taxIdController.text.trim().isNotEmpty ? _taxIdController.text.trim() : null,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      );
      
      // Subir logo si se seleccionó
      if (_logoFile != null) {
        await academyController.uploadAcademyLogo(
          academy.id,
          _logoFile!.path,
        );
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar un mensaje más informativo para el error específico
        String errorMessage = e.toString();
        if (errorMessage.contains('propietario ya tiene una academia')) {
          // Si es el error específico de academia duplicada
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Un propietario solo puede tener una academia. No es posible crear múltiples academias.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          
          // Redirigir al dashboard donde verá su academia existente
          Navigator.of(context).popUntil((route) => route.isFirst);
          await Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // Para otros errores
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Título de la pantalla
                const Text(
                  'Crear Nueva Academia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Mensaje informativo para el propietario
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '¡Importante!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Como propietario, debes crear una academia para comenzar a utilizar la aplicación. Después de este paso, podrás gestionar todos los aspectos de tu academia deportiva.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Selector de logo
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
                  items: _sports.map((String sport) {
                    return DropdownMenuItem<String>(
                      value: sport,
                      child: Text(sport),
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
                    OutlinedButton(
                      onPressed: needsAcademyCreation.maybeWhen(
                        data: (needsCreation) => needsCreation 
                          ? null  // Deshabilitamos si es obligatorio crear
                          : (_isLoading ? null : () => Navigator.pop(context)),
                        orElse: () => _isLoading ? null : () => Navigator.pop(context),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
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