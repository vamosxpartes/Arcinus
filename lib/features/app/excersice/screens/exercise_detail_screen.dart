import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/excersice/core/models/exercise.dart';
import 'package:arcinus/features/app/trainings/core/services/exercise_service.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:arcinus/features/theme/components/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String academyId;
  final Exercise? exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.academyId,
    this.exercise,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  late bool _isEditing;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoUrlController;

  // Valores para los dropdowns
  String _currentSport = '';
  String _selectedCategory = 'Cardio';
  String _selectedDifficulty = 'Intermedio';
  
  // Valores para los campos de múltiples opciones
  List<String> _selectedMuscleGroups = [];
  List<String> _selectedEquipment = [];
  
  // Opciones para los campos de selección
  final List<String> _categoryOptions = ['Cardio', 'Fuerza', 'Flexibilidad', 'Técnica', 'Velocidad', 'Resistencia'];
  final List<String> _difficultyOptions = ['Principiante', 'Intermedio', 'Avanzado'];
  final List<String> _muscleGroupOptions = [
    'Piernas', 'Brazos', 'Pecho', 'Espalda', 'Hombros', 'Abdominales', 'Glúteos', 'Core'
  ];
  final List<String> _equipmentOptions = [
    'Ninguno', 'Balón', 'Pesas', 'Conos', 'Bandas elásticas', 'Barras', 'Esterilla', 'Steps'
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.exercise == null;
    
    // Inicializar controladores
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _descriptionController = TextEditingController(text: widget.exercise?.description ?? '');
    _videoUrlController = TextEditingController(text: widget.exercise?.videoUrl ?? '');
    
    // Inicializar valores de dropdown si estamos editando un ejercicio existente
    if (widget.exercise != null) {
      _currentSport = widget.exercise!.sport;
      _selectedCategory = widget.exercise!.category;
      _selectedDifficulty = widget.exercise!.difficulty;
      _selectedMuscleGroups = List<String>.from(widget.exercise!.muscleGroups);
      _selectedEquipment = List<String>.from(widget.exercise!.equipment);
    } else {
      // Si es un nuevo ejercicio, obtener el deporte de la academia actual
      final currentAcademy = ref.read(currentAcademyProvider);
      if (currentAcademy != null) {
        _currentSport = currentAcademy.sport;
      } else {
        // Valor por defecto si no hay deporte en la academia
        _currentSport = 'General';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  // Guardar el ejercicio
  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final exerciseService = ref.read(exerciseServiceProvider);
      
      // Preparar los datos para el ejercicio
      final Map<String, dynamic> instructions = {};
      final Map<String, dynamic> metrics = {
        'repeticiones': true,
        'series': true,
        'tiempo': _selectedCategory == 'Cardio' || _selectedCategory == 'Resistencia',
        'distancia': _selectedCategory == 'Cardio' || _selectedCategory == 'Velocidad',
        'peso': _selectedCategory == 'Fuerza',
      };
      
      // Asegurarse de que tenemos un deporte válido
      final currentAcademy = ref.read(currentAcademyProvider);
      if (_currentSport.isEmpty || _currentSport == 'General') {
        _currentSport = currentAcademy?.sport ?? 'General';
      }
      
      if (widget.exercise == null) {
        // Crear un nuevo ejercicio
        final newExercise = Exercise(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          academyId: widget.academyId,
          sport: _currentSport,
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          muscleGroups: _selectedMuscleGroups,
          equipment: _selectedEquipment,
          videoUrl: _videoUrlController.text.trim().isNotEmpty ? _videoUrlController.text.trim() : null,
          instructions: instructions,
          metrics: metrics,
          createdAt: DateTime.now(),
          createdBy: 'current_user_id', // Debería venir del sistema de autenticación
        );
        
        await exerciseService.createExercise(newExercise);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ejercicio creado correctamente')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Actualizar un ejercicio existente
        final updatedExercise = widget.exercise!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          sport: _currentSport,
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          muscleGroups: _selectedMuscleGroups,
          equipment: _selectedEquipment,
          videoUrl: _videoUrlController.text.trim().isNotEmpty ? _videoUrlController.text.trim() : null,
          instructions: instructions,
          metrics: metrics,
          updatedAt: DateTime.now(),
          updatedBy: 'current_user_id', // Debería venir del sistema de autenticación
        );
        
        await exerciseService.updateExercise(updatedExercise);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ejercicio actualizado correctamente')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Eliminar el ejercicio
  Future<void> _deleteExercise() async {
    if (widget.exercise == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Ejercicio'),
        content: const Text('¿Estás seguro de que quieres eliminar este ejercicio? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        final exerciseService = ref.read(exerciseServiceProvider);
        await exerciseService.deleteExercise(widget.exercise!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ejercicio eliminado correctamente')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const BaseScaffold(
        showNavigation: false,
        body: LoadingIndicator(),
      );
    }
    
    Widget mainBody = _isEditing || widget.exercise == null ? _buildEditMode() : _buildViewMode();
    
    return BaseScaffold(
      showNavigation: false,
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: Text(
          widget.exercise == null ? 'Nuevo Ejercicio' : (
            _isEditing ? 'Editar Ejercicio' : widget.exercise!.name
          ),
          style: const TextStyle(
            color: Color(0xFFFFFFFF), // Magnolia White
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.exercise != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFFFFFFF)),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
          if (widget.exercise != null && _isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteExercise,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: mainBody),
          if (_isEditing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: const Color(0xFF1E1E1E), // Dark Gray
              child: Row(
                children: [
                  if (widget.exercise != null)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8A8A8A)),
                          foregroundColor: const Color(0xFF8A8A8A),
                        ),
                        onPressed: () {
                          setState(() => _isEditing = false);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                  if (widget.exercise != null)
                    const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFa00c30), // Embers
                        foregroundColor: const Color(0xFFFFFFFF),
                      ),
                      onPressed: _saveExercise,
                      child: Text(widget.exercise == null ? 'Crear' : 'Guardar'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewMode() {
    final exercise = widget.exercise!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen o placeholder
          if (exercise.imageUrls.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: NetworkImage(exercise.imageUrls.first),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF323232), // Medium Gray
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ),
          const SizedBox(height: 24),
          
          // Detalles del ejercicio
          Text(
            exercise.name,
            style: const TextStyle(
              color: Color(0xFFFFFFFF), // Magnolia White
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          
          // Propiedades en chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(exercise.sport),
                backgroundColor: const Color(0xFF323232), // Medium Gray
                labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
              Chip(
                label: Text(exercise.category),
                backgroundColor: const Color(0xFF323232), // Medium Gray
                labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
              Chip(
                label: Text(exercise.difficulty),
                backgroundColor: const Color(0xFFa00c30), // Embers
                labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Descripción
          const Text(
            'Descripción',
            style: TextStyle(
              color: Color(0xFFFFFFFF), // Magnolia White
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: const TextStyle(
              color: Color(0xFFD4D4D4), // Light Gray
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          
          // Grupos musculares
          if (exercise.muscleGroups.isNotEmpty) ...[
            const Text(
              'Grupos Musculares',
              style: TextStyle(
                color: Color(0xFFFFFFFF), // Magnolia White
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.muscleGroups.map((group) => Chip(
                label: Text(group),
                backgroundColor: const Color(0xFF323232), // Medium Gray
                labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Equipo necesario
          if (exercise.equipment.isNotEmpty) ...[
            const Text(
              'Equipo Necesario',
              style: TextStyle(
                color: Color(0xFFFFFFFF), // Magnolia White
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.equipment.map((item) => Chip(
                label: Text(item),
                backgroundColor: const Color(0xFF323232), // Medium Gray
                labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Video URL
          if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) ...[
            const Text(
              'Video Demostrativo',
              style: TextStyle(
                color: Color(0xFFFFFFFF), // Magnolia White
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Aquí se podría abrir el video en un reproductor o navegador
              },
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF323232), // Medium Gray
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.play_circle_fill, color: Color(0xFFa00c30)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ver video',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.open_in_new, color: Color(0xFF8A8A8A)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    // Mostrar el deporte de solo lectura
    final currentAcademy = ref.watch(currentAcademyProvider);
    final sportDisplay = _currentSport.isEmpty ? 
        (currentAcademy?.sport ?? 'General') : 
        _currentSport;
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de nombre
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              decoration: InputDecoration(
                labelText: 'Nombre del Ejercicio',
                labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                filled: true,
                fillColor: const Color(0xFF323232),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Campo de descripción
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                filled: true,
                fillColor: const Color(0xFF323232),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Mostrar deporte (no editable)
            const Text(
              'Deporte',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF323232),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                sportDisplay,
                style: const TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Selección de categoría
            const Text(
              'Categoría',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF323232),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF323232),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8A8A8A)),
                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedCategory = newValue);
                    }
                  },
                  items: _categoryOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Selección de dificultad
            const Text(
              'Dificultad',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF323232),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDifficulty,
                  dropdownColor: const Color(0xFF323232),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8A8A8A)),
                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedDifficulty = newValue);
                    }
                  },
                  items: _difficultyOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Selección de grupos musculares
            const Text(
              'Grupos Musculares',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroupOptions.map((group) {
                final isSelected = _selectedMuscleGroups.contains(group);
                return FilterChip(
                  label: Text(group),
                  selected: isSelected,
                  selectedColor: const Color(0xFFa00c30), // Embers
                  backgroundColor: const Color(0xFF323232), // Medium Gray
                  checkmarkColor: const Color(0xFFFFFFFF),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF8A8A8A),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMuscleGroups.add(group);
                      } else {
                        _selectedMuscleGroups.remove(group);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Selección de equipamiento
            const Text(
              'Equipamiento Necesario',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _equipmentOptions.map((equipment) {
                final isSelected = _selectedEquipment.contains(equipment);
                return FilterChip(
                  label: Text(equipment),
                  selected: isSelected,
                  selectedColor: const Color(0xFFa00c30), // Embers
                  backgroundColor: const Color(0xFF323232), // Medium Gray
                  checkmarkColor: const Color(0xFFFFFFFF),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF8A8A8A),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedEquipment.add(equipment);
                      } else {
                        _selectedEquipment.remove(equipment);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // URL del video
            TextFormField(
              controller: _videoUrlController,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              decoration: InputDecoration(
                labelText: 'URL del Video (opcional)',
                labelStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                filled: true,
                fillColor: const Color(0xFF323232),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 