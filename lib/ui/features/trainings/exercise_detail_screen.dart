import 'package:arcinus/shared/models/exercise.dart';
import 'package:arcinus/shared/widgets/loading_indicator.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/trainings/services/exercise_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final String academyId;
  final Exercise? exercise; // Null si es creación, no null si es edición

  const ExerciseDetailScreen({
    super.key,
    required this.academyId,
    this.exercise,
  });

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del formulario
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sportController = TextEditingController();
  final _categoryController = TextEditingController();
  
  // Valores seleccionados
  String _selectedDifficulty = 'Intermedio';
  final List<String> _selectedMuscleGroups = [];
  final List<String> _selectedEquipment = [];
  final List<String> _imageUrls = [];
  String? _videoUrl;
  
  // Datos estructurados
  final Map<String, dynamic> _instructions = {};
  final Map<String, dynamic> _metrics = {};
  final Map<String, dynamic> _variations = {};
  
  // Listas para selección
  final List<String> _difficulties = ['Principiante', 'Intermedio', 'Avanzado'];
  final List<String> _sports = ['Fútbol', 'Baloncesto', 'Atletismo', 'Natación', 'Tenis'];
  final List<String> _categories = ['Cardio', 'Fuerza', 'Flexibilidad', 'Técnica', 'Velocidad', 'Resistencia'];
  final List<String> _muscleGroups = [
    'Pectorales', 'Dorsales', 'Deltoides', 'Bíceps', 'Tríceps', 'Cuádriceps', 
    'Isquiotibiales', 'Glúteos', 'Abdominales', 'Gemelos', 'Trapecio'
  ];
  final List<String> _equipment = [
    'Ninguno', 'Mancuernas', 'Balón', 'Barra', 'Máquina', 'Banda elástica', 
    'TRX', 'Cuerda', 'Step', 'Kettlebell', 'Bosu'
  ];

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.exercise != null;
    
    if (_isEditing) {
      _initFormWithExercise(widget.exercise!);
    }
  }

  void _initFormWithExercise(Exercise exercise) {
    _nameController.text = exercise.name;
    _descriptionController.text = exercise.description;
    _sportController.text = exercise.sport;
    _categoryController.text = exercise.category;
    _selectedDifficulty = exercise.difficulty;
    _selectedMuscleGroups.addAll(exercise.muscleGroups);
    _selectedEquipment.addAll(exercise.equipment);
    _imageUrls.addAll(exercise.imageUrls);
    _videoUrl = exercise.videoUrl;
    _instructions.addAll(exercise.instructions);
    _metrics.addAll(exercise.metrics);
    _variations.addAll(exercise.variations);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sportController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final exerciseService = ref.read(exerciseServiceProvider);
      final currentUser = ref.read(authStateProvider).valueOrNull;
      final userID = currentUser?.id ?? 'unknownUser';
      
      final exercise = Exercise(
        id: _isEditing ? widget.exercise!.id : '',
        name: _nameController.text,
        description: _descriptionController.text,
        academyId: widget.academyId,
        sport: _sportController.text,
        category: _categoryController.text,
        difficulty: _selectedDifficulty,
        muscleGroups: _selectedMuscleGroups,
        equipment: _selectedEquipment,
        instructions: _instructions,
        videoUrl: _videoUrl,
        imageUrls: _imageUrls,
        metrics: _metrics,
        variations: _variations,
        createdAt: _isEditing ? widget.exercise!.createdAt : DateTime.now(),
        createdBy: _isEditing ? widget.exercise!.createdBy : userID,
        updatedAt: _isEditing ? DateTime.now() : null,
        updatedBy: _isEditing ? userID : null,
      );
      
      if (_isEditing) {
        await exerciseService.updateExercise(exercise);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ejercicio actualizado con éxito')),
          );
          Navigator.pop(context, true);
        }
      } else {
        await exerciseService.createExercise(exercise);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ejercicio creado con éxito')),
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: Text(
          _isEditing ? 'Editar Ejercicio' : 'Nuevo Ejercicio',
          style: const TextStyle(
            color: Color(0xFFFFFFFF), // Magnolia White
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFda1a32)), // Bonfire Red
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isSaving
          ? const LoadingIndicator(message: 'Guardando ejercicio...')
          : _buildForm(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 120,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFa00c30)), // Embers
                  foregroundColor: const Color(0xFFa00c30), // Embers
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: _saveExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFda1a32), // Bonfire Red
                  foregroundColor: const Color(0xFFFFFFFF), // Magnolia White
                ),
                child: Text(_isEditing ? 'Actualizar' : 'Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de información básica
          const Text(
            'Información Básica',
            style: TextStyle(
              color: Color(0xFFa00c30), // Embers
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nombre del ejercicio
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
            decoration: const InputDecoration(
              labelText: 'Nombre',
              labelStyle: TextStyle(color: Color(0xFF8A8A8A)), // Light Gray
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF323232)), // Medium Gray
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFa00c30)), // Embers
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Descripción
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
            decoration: const InputDecoration(
              labelText: 'Descripción',
              labelStyle: TextStyle(color: Color(0xFF8A8A8A)), // Light Gray
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF323232)), // Medium Gray
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFa00c30)), // Embers
              ),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La descripción es requerida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Deporte
          DropdownButtonFormField<String>(
            value: _sportController.text.isEmpty 
                ? null 
                : (_sports.contains(_sportController.text) 
                    ? _sportController.text 
                    : null),
            decoration: const InputDecoration(
              labelText: 'Deporte',
              labelStyle: TextStyle(color: Color(0xFF8A8A8A)), // Light Gray
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF323232)), // Medium Gray
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFa00c30)), // Embers
              ),
            ),
            dropdownColor: const Color(0xFF1E1E1E), // Dark Gray
            style: const TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
            items: _sports.map((sport) => DropdownMenuItem(
              value: sport,
              child: Text(sport),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sportController.text = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona un deporte';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Categoría
          DropdownButtonFormField<String>(
            value: _categoryController.text.isEmpty 
                ? null 
                : (_categories.contains(_categoryController.text) 
                    ? _categoryController.text 
                    : null),
            decoration: const InputDecoration(
              labelText: 'Categoría',
              labelStyle: TextStyle(color: Color(0xFF8A8A8A)), // Light Gray
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF323232)), // Medium Gray
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFa00c30)), // Embers
              ),
            ),
            dropdownColor: const Color(0xFF1E1E1E), // Dark Gray
            style: const TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
            items: _categories.map((category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _categoryController.text = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona una categoría';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Dificultad
          const Text(
            'Dificultad',
            style: TextStyle(
              color: Color(0xFF8A8A8A), // Light Gray
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _difficulties.map((difficulty) {
              return ChoiceChip(
                label: Text(difficulty),
                selected: _selectedDifficulty == difficulty,
                selectedColor: _getDifficultyColor(difficulty),
                backgroundColor: const Color(0xFF323232), // Medium Gray
                labelStyle: TextStyle(
                  color: _selectedDifficulty == difficulty 
                      ? Colors.white 
                      : const Color(0xFF8A8A8A), // Light Gray
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Sección de grupos musculares
          const Text(
            'Grupos Musculares',
            style: TextStyle(
              color: Color(0xFFa00c30), // Embers
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _muscleGroups.map((group) {
              final isSelected = _selectedMuscleGroups.contains(group);
              return FilterChip(
                label: Text(group),
                selected: isSelected,
                selectedColor: const Color(0xFFa00c30).withAlpha(50), // Embers
                checkmarkColor: const Color(0xFFa00c30), // Embers
                backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFFa00c30) // Embers
                      : const Color(0xFF323232), // Medium Gray
                ),
                labelStyle: TextStyle(
                  color: isSelected 
                      ? const Color(0xFFa00c30) // Embers
                      : const Color(0xFF8A8A8A), // Light Gray
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
          
          // Sección de equipamiento
          const Text(
            'Equipamiento Necesario',
            style: TextStyle(
              color: Color(0xFFa00c30), // Embers
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _equipment.map((item) {
              final isSelected = _selectedEquipment.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                selectedColor: const Color(0xFF323232), // Medium Gray
                backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFFFFFFFF) // Magnolia White
                      : const Color(0xFF323232), // Medium Gray
                ),
                labelStyle: TextStyle(
                  color: isSelected 
                      ? const Color(0xFFFFFFFF) // Magnolia White
                      : const Color(0xFF8A8A8A), // Light Gray
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (item == 'Ninguno') {
                        _selectedEquipment.clear();
                      } else {
                        _selectedEquipment.remove('Ninguno');
                      }
                      _selectedEquipment.add(item);
                    } else {
                      _selectedEquipment.remove(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          // Aquí se podrían añadir más secciones para instrucciones, 
          // métricas, imágenes, etc., pero por simplicidad no se incluyen en esta versión
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return const Color(0xFF00C853); // Court Green
      case 'intermedio':
        return const Color(0xFFFFC400); // Gold Trophy
      case 'avanzado':
        return const Color(0xFFda1a32); // Bonfire Red
      default:
        return const Color(0xFF8A8A8A); // Light Gray
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: const Text(
          'Eliminar Ejercicio',
          style: TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este ejercicio? Esta acción no se puede deshacer.',
          style: TextStyle(color: Color(0xFF8A8A8A)), // Light Gray
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isSaving = true);
              
              try {
                final exerciseService = ref.read(exerciseServiceProvider);
                await exerciseService.deleteExercise(widget.exercise!.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ejercicio eliminado con éxito')),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFda1a32), // Bonfire Red
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 