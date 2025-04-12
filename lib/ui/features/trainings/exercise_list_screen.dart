import 'package:arcinus/shared/models/exercise.dart';
import 'package:arcinus/shared/widgets/loading_indicator.dart';
import 'package:arcinus/shared/widgets/error_display.dart';
import 'package:arcinus/shared/widgets/empty_state.dart';
import 'package:arcinus/ux/features/trainings/services/exercise_service.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  final String? academyId;
  final String? sportFilter;
  final String? categoryFilter;
  final bool isSelectionMode;
  final Function(Exercise)? onExerciseSelected;

  const ExerciseListScreen({
    super.key,
    this.academyId,
    this.sportFilter,
    this.categoryFilter,
    this.isSelectionMode = false,
    this.onExerciseSelected,
  });

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedSport = 'All';
  String _selectedCategory = 'All';

  // Lista de deportes y categorías disponibles
  final List<String> _sports = ['All', 'Fútbol', 'Baloncesto', 'Atletismo', 'Natación', 'Tenis'];
  final List<String> _categories = ['All', 'Cardio', 'Fuerza', 'Flexibilidad', 'Técnica', 'Velocidad', 'Resistencia'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Inicializar filtros si se proporcionan
    if (widget.sportFilter != null) {
      _selectedSport = widget.sportFilter!;
    }
    
    if (widget.categoryFilter != null) {
      _selectedCategory = widget.categoryFilter!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Obtener el ID de la academia actual
  String _getAcademyId() {
    return widget.academyId ?? ref.read(currentAcademyIdProvider) ?? '';
  }

  void _navigateToExerciseDetail(BuildContext context, {Exercise? exercise}) {
    Navigator.pushNamed(
      context,
      '/trainings/exercises/detail',
      arguments: {
        'academyId': _getAcademyId(),
        'exercise': exercise,
      },
    ).then((_) => setState(() {})); // Refrescar al volver
  }

  @override
  Widget build(BuildContext context) {
    final academyId = _getAcademyId();
    final exerciseService = ref.watch(exerciseServiceProvider);
    
    // Si estamos en modo selección, no mostrar AppBar completo
    final bool isFullScreen = !widget.isSelectionMode;

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: isFullScreen 
        ? AppBar(
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
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFa00c30), // Embers
              labelColor: const Color(0xFFFFFFFF), // Magnolia White
              unselectedLabelColor: const Color(0xFF8A8A8A), // Light Gray
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Favoritos'),
                Tab(text: 'Recientes'),
              ],
            ),
          )
        : AppBar(
            backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
            title: const Text(
              'Seleccionar Ejercicio',
              style: TextStyle(
                color: Color(0xFFFFFFFF), // Magnolia White
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFFFFFFF)),
              onPressed: () => Navigator.pop(context),
            ),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Filtros activos (chips)
          if (_selectedSport != 'All' || _selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                ],
              ),
            ),
            
          // Lista de ejercicios
          Expanded(
            child: isFullScreen 
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExerciseList(exerciseService, academyId, false),
                    _buildFavoriteExercises(exerciseService, academyId),
                    _buildRecentExercises(exerciseService, academyId),
                  ],
                )
              : _buildExerciseList(exerciseService, academyId, true),
          ),
        ],
      ),
      floatingActionButton: isFullScreen ? FloatingActionButton(
        backgroundColor: const Color(0xFFda1a32), // Bonfire Red
        onPressed: () => _navigateToExerciseDetail(context),
        child: const Icon(Icons.add, color: Color(0xFFFFFFFF)),
      ) : null,
    );
  }

  Widget _buildExerciseList(ExerciseService exerciseService, String academyId, bool isSelection) {
    Stream<List<Exercise>> exercisesStream;
    
    // Aplicar filtros
    if (_selectedSport != 'All' && _selectedCategory != 'All') {
      // Filtro combinado (en la UI filtramos ya que no hay método exacto en el service)
      exercisesStream = exerciseService.getExercisesByCategory(academyId, _selectedCategory);
    } else if (_selectedSport != 'All') {
      exercisesStream = exerciseService.getExercisesBySport(academyId, _selectedSport);
    } else if (_selectedCategory != 'All') {
      exercisesStream = exerciseService.getExercisesByCategory(academyId, _selectedCategory);
    } else {
      // Sin filtros específicos
      exercisesStream = exerciseService.getExercisesByAcademy(academyId);
    }
    
    // Si hay texto de búsqueda, filtrar los resultados
    if (_searchQuery.isNotEmpty) {
      exercisesStream = exerciseService.searchExercises(academyId, _searchQuery);
    }
    
    return StreamBuilder<List<Exercise>>(
      stream: exercisesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        
        if (snapshot.hasError) {
          return ErrorDisplay(error: snapshot.error.toString());
        }
        
        final exercises = snapshot.data ?? [];
        
        // Filtrar ejercicios por deporte si seleccionamos ambos filtros
        if (_selectedSport != 'All' && _selectedCategory != 'All') {
          exercises.removeWhere((exercise) => exercise.sport != _selectedSport);
        }
        
        if (exercises.isEmpty) {
          return EmptyState(
            icon: Icons.fitness_center,
            message: 'No hay ejercicios disponibles',
            suggestion: 'Agrega nuevos ejercicios para comenzar',
          );
        }
        
        return ListView.builder(
          itemCount: exercises.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _buildExerciseCard(exercise, isSelection);
          },
        );
      },
    );
  }

  Widget _buildFavoriteExercises(ExerciseService exerciseService, String academyId) {
    // En una implementación real, esto podría consumir un stream de favoritos
    // Por ahora simulamos con los ejercicios de la academia
    return StreamBuilder<List<Exercise>>(
      stream: exerciseService.getExercisesByAcademy(academyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        
        if (snapshot.hasError) {
          return ErrorDisplay(error: snapshot.error.toString());
        }
        
        // Simulamos favoritos tomando los primeros 3
        final exercises = snapshot.data ?? [];
        final favorites = exercises.take(3).toList();
        
        if (favorites.isEmpty) {
          return EmptyState(
            icon: Icons.favorite,
            message: 'No hay ejercicios favoritos',
            suggestion: 'Marca ejercicios como favoritos para acceder rápidamente',
          );
        }
        
        return ListView.builder(
          itemCount: favorites.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final exercise = favorites[index];
            return _buildExerciseCard(exercise, false);
          },
        );
      },
    );
  }

  Widget _buildRecentExercises(ExerciseService exerciseService, String academyId) {
    // Similar a favoritos, en una implementación real tendríamos un stream específico
    return StreamBuilder<List<Exercise>>(
      stream: exerciseService.getExercisesByAcademy(academyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        
        if (snapshot.hasError) {
          return ErrorDisplay(error: snapshot.error.toString());
        }
        
        // Simulamos recientes tomando los últimos 5
        final exercises = snapshot.data ?? [];
        final recents = exercises.reversed.take(5).toList();
        
        if (recents.isEmpty) {
          return EmptyState(
            icon: Icons.history,
            message: 'No hay ejercicios recientes',
            suggestion: 'Los ejercicios que veas aparecerán aquí',
          );
        }
        
        return ListView.builder(
          itemCount: recents.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final exercise = recents[index];
            return _buildExerciseCard(exercise, false);
          },
        );
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise, bool isSelection) {
    // Indicador de dificultad con color
    Color difficultyColor;
    switch (exercise.difficulty.toLowerCase()) {
      case 'principiante':
        difficultyColor = const Color(0xFF00C853); // Court Green
        break;
      case 'intermedio':
        difficultyColor = const Color(0xFFFFC400); // Gold Trophy
        break;
      case 'avanzado':
        difficultyColor = const Color(0xFFda1a32); // Bonfire Red
        break;
      default:
        difficultyColor = const Color(0xFF8A8A8A); // Light Gray
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1E1E1E), // Dark Gray
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          if (isSelection && widget.onExerciseSelected != null) {
            widget.onExerciseSelected!(exercise);
            Navigator.pop(context);
          } else {
            _navigateToExerciseDetail(context, exercise: exercise);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF), // Magnolia White
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: difficultyColor),
                    ),
                    child: Text(
                      exercise.difficulty,
                      style: TextStyle(
                        color: difficultyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: const TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Chip de deporte
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFa00c30).withOpacity(0.2), // Embers
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      exercise.sport,
                      style: const TextStyle(
                        color: Color(0xFFa00c30), // Embers
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chip de categoría
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF323232), // Medium Gray
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      exercise.category,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF), // Magnolia White
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Icono de equipo si necesita equipamiento
                  if (exercise.equipment.isNotEmpty)
                    const Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Color(0xFF8A8A8A), // Light Gray
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: const Text(
          'Filtrar Ejercicios',
          style: TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deporte',
                style: TextStyle(
                  color: Color(0xFFFFFFFF), // Magnolia White
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _sports.map((sport) {
                  final isSelected = _selectedSport == sport;
                  return FilterChip(
                    label: Text(sport),
                    selected: isSelected,
                    checkmarkColor: const Color(0xFFFFFFFF),
                    selectedColor: const Color(0xFFa00c30), // Embers
                    backgroundColor: const Color(0xFF323232), // Medium Gray
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF8A8A8A),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedSport = selected ? sport : 'All';
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Categoría',
                style: TextStyle(
                  color: Color(0xFFFFFFFF), // Magnolia White
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    checkmarkColor: const Color(0xFFFFFFFF),
                    selectedColor: const Color(0xFFa00c30), // Embers
                    backgroundColor: const Color(0xFF323232), // Medium Gray
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF8A8A8A),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : 'All';
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSport = 'All';
                _selectedCategory = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Limpiar Filtros',
              style: TextStyle(color: Color(0xFFda1a32)), // Bonfire Red
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFFFFFFF)), // Magnolia White
            ),
          ),
        ],
      ),
    );
  }
} 