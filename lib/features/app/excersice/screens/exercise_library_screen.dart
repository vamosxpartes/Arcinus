import 'dart:developer' as developer;

import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/excersice/core/models/exercise.dart';
import 'package:arcinus/features/app/sports/core/models/sport_characteristics.dart';
import 'package:arcinus/features/app/trainings/core/services/exercise_service.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:arcinus/features/navigation/core/models/navigation_item.dart';
import 'package:arcinus/features/theme/components/feedback/empty_state.dart';
import 'package:arcinus/features/theme/components/feedback/error_display.dart';
import 'package:arcinus/features/theme/components/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Item de navegación para Ejercicios
const NavigationItem exerciseNavigationItem = NavigationItem(
  icon: Icons.fitness_center,
  label: 'Ejercicios',
  destination: '/exercises',
  hasCreationFunction: true,
);

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedSport = 'All';
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  // Listas dinámicas basadas en deportes
  List<String> _sports = ['All'];
  List<String> _categories = ['All'];
  final List<String> _difficulties = ['All', 'Principiante', 'Intermedio', 'Avanzado'];
  
  // Características del deporte seleccionado
  SportCharacteristics? _sportCharacteristics;

  @override
  void initState() {
    super.initState();
    _loadSportData();
  }

  void _loadSportData() {
    final currentAcademy = ref.read(currentAcademyProvider);
    if (currentAcademy != null) {
      try {
        // Cargar características específicas del deporte
        _sportCharacteristics = SportCharacteristics.forSport(currentAcademy.sport);
        
        // Actualizar categorías según el deporte
        setState(() {
          _sports = ['All', currentAcademy.sport];
          _selectedSport = currentAcademy.sport;
          
          // Actualizar categorías con las del deporte
          _categories = ['All', ..._sportCharacteristics!.exerciseCategories];
        });
      } catch (e) {
        // Si el deporte no está soportado, mantener categorías genéricas
        setState(() {
          _sports = ['All', 'Fútbol', 'Baloncesto', 'Atletismo', 'Natación', 'Tenis'];
          _categories = ['All', 'Cardio', 'Fuerza', 'Flexibilidad', 'Técnica', 'Velocidad', 'Resistencia'];
        });
        developer.log('Error cargando características del deporte: $e');
      }
    } else {
      // Si no hay deporte seleccionado, usar categorías genéricas
      setState(() {
        _sports = ['All', 'Fútbol', 'Baloncesto', 'Atletismo', 'Natación', 'Tenis'];
        _categories = ['All', 'Cardio', 'Fuerza', 'Flexibilidad', 'Técnica', 'Velocidad', 'Resistencia'];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Obtener el ID de la academia actual
  String _getAcademyId() {
    return ref.read(currentAcademyIdProvider) ?? '';
  }

  void _navigateToExerciseDetail(BuildContext context, {Exercise? exercise}) {
    Navigator.pushNamed(
      context,
      '/exercises/detail',
      arguments: {
        'academyId': _getAcademyId(),
        'exercise': exercise,
      },
    ).then((_) => setState(() {})); // Refrescar al volver
  }
  
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Filtrar Ejercicios',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deporte',
                      style: TextStyle(color: Color(0xFF8A8A8A)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _sports.map((sport) {
                        final isSelected = _selectedSport == sport;
                        return ChoiceChip(
                          label: Text(sport),
                          selected: isSelected,
                          selectedColor: const Color(0xFFa00c30),
                          backgroundColor: const Color(0xFF323232),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF8A8A8A),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedSport = sport;
                              
                              // Si cambia el deporte, actualizar categorías disponibles
                              if (sport != 'All') {
                                try {
                                  _sportCharacteristics = SportCharacteristics.forSport(sport);
                                  _categories = ['All', ..._sportCharacteristics!.exerciseCategories];
                                  _selectedCategory = 'All'; // Resetear categoría seleccionada
                                } catch (e) {
                                  // Mantener categorías genéricas
                                  developer.log('Error cargando características del deporte: $e');
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Categoría',
                      style: TextStyle(color: Color(0xFF8A8A8A)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: const Color(0xFFa00c30),
                          backgroundColor: const Color(0xFF323232),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF8A8A8A),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dificultad',
                      style: TextStyle(color: Color(0xFF8A8A8A)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _difficulties.map((difficulty) {
                        final isSelected = _selectedDifficulty == difficulty;
                        return ChoiceChip(
                          label: Text(difficulty),
                          selected: isSelected,
                          selectedColor: const Color(0xFFa00c30),
                          backgroundColor: const Color(0xFF323232),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF8A8A8A),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedDifficulty = difficulty;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'Reiniciar Filtros',
                    style: TextStyle(color: Color(0xFF8A8A8A)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedSport = 'All';
                      _selectedCategory = 'All';
                      _selectedDifficulty = 'All';
                    });
                  },
                ),
                TextButton(
                  child: const Text(
                    'Aplicar',
                    style: TextStyle(color: Color(0xFFa00c30)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Actualizar la vista principal con los nuevos filtros
                    this.setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final academyId = _getAcademyId();
    final exerciseService = ref.watch(exerciseServiceProvider);
    
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Ejercicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ejercicios...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Chips de filtros activos
          if (_selectedSport != 'All' || _selectedCategory != 'All' || _selectedDifficulty != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedSport != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(_selectedSport),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedSport = 'All';
                            });
                          },
                        ),
                      ),
                    if (_selectedCategory != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(_selectedCategory),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = 'All';
                            });
                          },
                        ),
                      ),
                    if (_selectedDifficulty != 'All')
                      Chip(
                        label: Text(_selectedDifficulty),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedDifficulty = 'All';
                          });
                        },
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSport = 'All';
                          _selectedCategory = 'All';
                          _selectedDifficulty = 'All';
                        });
                      },
                      child: const Text('Limpiar todo'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Contenido principal
          Expanded(
            child: StreamBuilder<List<Exercise>>(
              stream: _searchQuery.isNotEmpty
                ? exerciseService.searchExercises(academyId, _searchQuery)
                : exerciseService.getExercisesByAcademy(academyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }
                
                if (snapshot.hasError) {
                  return ErrorDisplay(
                    error: snapshot.error.toString(),
                    onRetry: () {
                      setState(() {});
                    },
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyState(
                    icon: Icons.fitness_center,
                    message: 'No se encontraron ejercicios',
                    suggestion: 'Intenta cambiar los filtros o crear un nuevo ejercicio',
                  );
                }
                
                final exercises = snapshot.data!;
                
                // Filtrar ejercicios
                final filteredExercises = exercises.where((exercise) {
                  // Filtro por deporte
                  final matchesSport = _selectedSport == 'All' || exercise.sport == _selectedSport;
                  
                  // Filtro por categoría
                  final matchesCategory = _selectedCategory == 'All' || exercise.category == _selectedCategory;
                  
                  // Filtro por dificultad
                  final matchesDifficulty = _selectedDifficulty == 'All' || exercise.difficulty == _selectedDifficulty;
                  
                  return matchesSport && matchesCategory && matchesDifficulty;
                }).toList();
                
                if (filteredExercises.isEmpty) {
                  return const EmptyState(
                    icon: Icons.fitness_center,
                    message: 'No se encontraron ejercicios',
                    suggestion: 'Intenta cambiar los filtros o crear un nuevo ejercicio',
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return _buildExerciseCard(
                      exercise: exercise,
                      onTap: () => _navigateToExerciseDetail(context, exercise: exercise),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      onAddButtonTap: () => _navigateToExerciseDetail(context),
    );
  }
  
  // Widget para mostrar una tarjeta de ejercicio
  Widget _buildExerciseCard({required Exercise exercise, required VoidCallback onTap}) {
    // Definir colores según la categoría
    Color cardColor;
    
    // Asignar color según la categoría
    switch (exercise.category) {
      case 'Cardio':
        cardColor = const Color(0xFF1E88E5); // Azul
        break;
      case 'Fuerza':
        cardColor = const Color(0xFFE53935); // Rojo
        break;
      case 'Flexibilidad':
        cardColor = const Color(0xFF43A047); // Verde
        break;
      case 'Técnica':
        cardColor = const Color(0xFF8E24AA); // Púrpura
        break;
      case 'Velocidad':
        cardColor = const Color(0xFFEF6C00); // Naranja
        break;
      case 'Resistencia':
        cardColor = const Color(0xFF0097A7); // Cyan
        break;
      default:
        cardColor = const Color(0xFF5C6BC0); // Índigo (por defecto)
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con categoría y dificultad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exercise.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Nombre del ejercicio
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Deporte y categoría
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exercise.sport,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exercise.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Imagen de ejercicio o icono por defecto
            Expanded(
              child: Center(
                child: exercise.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          exercise.imageUrls.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.fitness_center,
                              size: 60,
                              color: Colors.white54,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.white54,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 