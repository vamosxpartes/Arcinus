import 'package:arcinus/shared/models/exercise.dart';
import 'package:arcinus/shared/widgets/loading_indicator.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/trainings/services/exercise_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseSelectorScreen extends ConsumerStatefulWidget {
  final List<Exercise>? initiallySelectedExercises;
  final bool allowMultiple;

  const ExerciseSelectorScreen({
    super.key,
    this.initiallySelectedExercises,
    this.allowMultiple = true,
  });

  @override
  ConsumerState<ExerciseSelectorScreen> createState() => _ExerciseSelectorScreenState();
}

class _ExerciseSelectorScreenState extends ConsumerState<ExerciseSelectorScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedSport = 'All';
  String _selectedCategory = 'All';
  
  // Lista de categorías disponibles
  final List<String> _sports = ['All', 'Fútbol', 'Baloncesto', 'Atletismo', 'Natación', 'Tenis'];
  final List<String> _categories = ['All', 'Cardio', 'Fuerza', 'Flexibilidad', 'Técnica', 'Velocidad', 'Resistencia'];
  
  // Lista de ejercicios seleccionados
  late List<Exercise> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _selectedExercises = widget.initiallySelectedExercises?.toList() ?? [];
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

  void _toggleExerciseSelection(Exercise exercise) {
    setState(() {
      if (_selectedExercises.contains(exercise)) {
        _selectedExercises.remove(exercise);
      } else {
        if (!widget.allowMultiple) {
          _selectedExercises.clear();
        }
        _selectedExercises.add(exercise);
      }
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedExercises);
  }

  @override
  Widget build(BuildContext context) {
    final academyId = _getAcademyId();
    final exerciseService = ref.watch(exerciseServiceProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: const Text(
          'Seleccionar Ejercicios',
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
          if (_selectedSport != 'All' || _selectedCategory != 'All')
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
                  ],
                ),
              ),
            ),
            
          // Lista de ejercicios seleccionados
          if (_selectedExercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Seleccionados (${_selectedExercises.length})',
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedExercises.clear());
                        },
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(color: Color(0xFFa00c30)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _selectedExercises[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(exercise.name),
                            backgroundColor: const Color(0xFFa00c30), // Embers
                            labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                            deleteIcon: const Icon(Icons.clear, size: 18, color: Color(0xFFFFFFFF)),
                            onDeleted: () {
                              setState(() => _selectedExercises.remove(exercise));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Color(0xFF8A8A8A),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay ejercicios disponibles',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Crea ejercicios para poder seleccionarlos',
                          style: TextStyle(color: Color(0xFF8A8A8A)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFa00c30), // Embers
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/exercises/detail',
                              arguments: {
                                'academyId': academyId,
                              },
                            ).then((_) => setState(() {}));
                          },
                          icon: const Icon(Icons.add, color: Color(0xFFFFFFFF)),
                          label: const Text(
                            'Crear Ejercicio',
                            style: TextStyle(color: Color(0xFFFFFFFF)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final exercises = snapshot.data!;
                
                // Aplicar filtros
                final filteredExercises = exercises.where((exercise) {
                  bool matchesSport = _selectedSport == 'All' || exercise.sport == _selectedSport;
                  bool matchesCategory = _selectedCategory == 'All' || exercise.category == _selectedCategory;
                  return matchesSport && matchesCategory;
                }).toList();
                
                if (filteredExercises.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_alt_off,
                          size: 48,
                          color: Color(0xFF8A8A8A),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay resultados con estos filtros',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Intenta con otros filtros o limpialos',
                          style: TextStyle(color: Color(0xFF8A8A8A)),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    final isSelected = _selectedExercises.contains(exercise);
                    
                    return Card(
                      color: const Color(0xFF1E1E1E), // Dark Gray
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF323232), // Medium Gray
                            borderRadius: BorderRadius.circular(4.0),
                            image: exercise.imageUrls.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(exercise.imageUrls.first),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: exercise.imageUrls.isEmpty
                              ? const Icon(
                                  Icons.fitness_center,
                                  color: Color(0xFF8A8A8A),
                                )
                              : null,
                        ),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFa00c30), // Embers
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    exercise.difficulty,
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF323232), // Medium Gray
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    exercise.category,
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? const Color(0xFFa00c30) : const Color(0xFF8A8A8A),
                          ),
                          onPressed: () => _toggleExerciseSelection(exercise),
                        ),
                        onTap: () => _toggleExerciseSelection(exercise),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedExercises.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFF1E1E1E), // Dark Gray
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFa00c30), // Embers
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _confirmSelection,
                child: Text(
                  'Confirmar ${_selectedExercises.length} ${_selectedExercises.length == 1 ? 'ejercicio' : 'ejercicios'}',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar Ejercicios',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF), // Magnolia White
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sección: Deporte
                  const Text(
                    'Deporte',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF), // Magnolia White
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _sports.map((sport) {
                      final isSelected = _selectedSport == sport;
                      return ChoiceChip(
                        label: Text(sport),
                        selected: isSelected,
                        selectedColor: const Color(0xFFa00c30), // Embers
                        backgroundColor: const Color(0xFF323232), // Medium Gray
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF8A8A8A),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedSport = selected ? sport : 'All';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sección: Categoría
                  const Text(
                    'Categoría',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF), // Magnolia White
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: const Color(0xFFa00c30), // Embers
                        backgroundColor: const Color(0xFF323232), // Medium Gray
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF8A8A8A),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : 'All';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedSport = 'All';
                            _selectedCategory = 'All';
                          });
                        },
                        child: const Text(
                          'Limpiar Filtros',
                          style: TextStyle(color: Color(0xFF8A8A8A)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFa00c30), // Embers
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // Actualizar los filtros en la pantalla principal
                          this.setState(() {
                            _selectedSport = _selectedSport;
                            _selectedCategory = _selectedCategory;
                          });
                        },
                        child: const Text(
                          'Aplicar',
                          style: TextStyle(color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 