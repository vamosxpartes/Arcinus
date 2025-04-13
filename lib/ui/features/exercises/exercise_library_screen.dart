import 'dart:developer' as developer;

import 'package:arcinus/shared/models/exercise.dart';
import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:arcinus/shared/models/sport_characteristics.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/shared/navigation/navigation_service.dart';
import 'package:arcinus/shared/widgets/empty_state.dart';
import 'package:arcinus/shared/widgets/error_display.dart';
import 'package:arcinus/shared/widgets/loading_indicator.dart';
import 'package:arcinus/ui/shared/widgets/custom_navigation_bar.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/trainings/services/exercise_service.dart';
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
    final navigationService = NavigationService();
    
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: const Text(
          'Biblioteca de Ejercicios',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // Magnolia White
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFFFFFFFF)),
            onPressed: () => _showFilterDialog(context),
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
              style: const TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
              decoration: InputDecoration(
                hintText: 'Buscar ejercicios',
                hintStyle: const TextStyle(color: Color(0xFF8A8A8A)), // Light Gray
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8A8A8A)),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF8A8A8A)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
                filled: true,
                fillColor: const Color(0xFF323232), // Medium Gray
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Filtros activos (chips)
          if (_selectedSport != 'All' || _selectedCategory != 'All' || _selectedDifficulty != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Filtros: ',
                      style: TextStyle(
                        color: Color(0xFF8A8A8A), // Light Gray
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedSport != 'All')
                      Chip(
                        label: Text(_selectedSport),
                        backgroundColor: const Color(0xFFa00c30), // Embers
                        labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                        deleteIcon: const Icon(Icons.clear, size: 18, color: Color(0xFFFFFFFF)),
                        onDeleted: () {
                          setState(() => _selectedSport = 'All');
                        },
                      ),
                    const SizedBox(width: 8),
                    if (_selectedCategory != 'All')
                      Chip(
                        label: Text(_selectedCategory),
                        backgroundColor: const Color(0xFFa00c30), // Embers
                        labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                        deleteIcon: const Icon(Icons.clear, size: 18, color: Color(0xFFFFFFFF)),
                        onDeleted: () {
                          setState(() => _selectedCategory = 'All');
                        },
                      ),
                    const SizedBox(width: 8),
                    if (_selectedDifficulty != 'All')
                      Chip(
                        label: Text(_selectedDifficulty),
                        backgroundColor: const Color(0xFFa00c30), // Embers
                        labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                        deleteIcon: const Icon(Icons.clear, size: 18, color: Color(0xFFFFFFFF)),
                        onDeleted: () {
                          setState(() => _selectedDifficulty = 'All');
                        },
                      ),
                  ],
                ),
              ),
            ),
            
          // Lista de ejercicios
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
                  return ErrorDisplay(error: snapshot.error.toString());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }
                
                final exercises = snapshot.data!;
                
                // Aplicar filtros adicionales (como no podemos filtrar en Firestore por todos los campos a la vez)
                final filteredExercises = exercises.where((exercise) {
                  bool matchesSport = _selectedSport == 'All' || exercise.sport == _selectedSport;
                  bool matchesCategory = _selectedCategory == 'All' || exercise.category == _selectedCategory;
                  bool matchesDifficulty = _selectedDifficulty == 'All' || exercise.difficulty == _selectedDifficulty;
                  
                  return matchesSport && matchesCategory && matchesDifficulty;
                }).toList();
                
                if (filteredExercises.isEmpty) {
                  return const EmptyState(
                    icon: Icons.filter_alt_off,
                    message: 'No hay resultados',
                    suggestion: 'Intenta con otros filtros',
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return _buildExerciseCard(context, exercise);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        pinnedItems: navigationService.pinnedItems,
        allItems: NavigationItems.allItems,
        activeRoute: '/exercises',
        onItemTap: (item) => navigationService.navigateToRoute(context, item.destination),
        onItemLongPress: (item) => navigationService.togglePinItem(item, context: context),
        onAddButtonTap: () => _navigateToExerciseDetail(context),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    if (_sportCharacteristics != null) {
      return EmptyState(
        icon: Icons.fitness_center,
        message: 'No hay ejercicios',
        suggestion: 'Añade ejercicios para ${_sportCharacteristics!.predefinedExercises.isNotEmpty ? "empezar con estos ejercicios predefinidos: ${_sportCharacteristics!.predefinedExercises.take(3).join(", ")}..." : "tu deporte"}',
      );
    } else {
      return const EmptyState(
        icon: Icons.fitness_center,
        message: 'No hay ejercicios',
        suggestion: 'Crea tu primer ejercicio personalizado',
      );
    }
  }
  
  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    // Definir colores según la categoría
    Color cardColor;
    
    switch (exercise.category.toLowerCase()) {
      case 'cardio':
      case 'resistencia':
        cardColor = const Color(0xFF005082); // Azul
        break;
      case 'fuerza':
      case 'power':
        cardColor = const Color(0xFF8B0000); // Rojo oscuro
        break;
      case 'técnica':
      case 'técnico':
      case 'tecnica':
        cardColor = const Color(0xFF006400); // Verde oscuro
        break;
      case 'velocidad':
      case 'speed':
        cardColor = const Color(0xFFFF8C00); // Naranja
        break;
      case 'flexibilidad':
      case 'flexibility':
        cardColor = const Color(0xFF4B0082); // Índigo
        break;
      default:
        cardColor = const Color(0xFF1E1E1E); // Gray por defecto
    }
    
    return GestureDetector(
      onTap: () => _navigateToExerciseDetail(context, exercise: exercise),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: cardColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              
              // Nivel de dificultad
              Row(
                children: [
                  const Icon(
                    Icons.signal_cellular_alt,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    exercise.difficulty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 