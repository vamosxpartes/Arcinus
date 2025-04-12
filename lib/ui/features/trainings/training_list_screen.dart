import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/shared/navigation/navigation_service.dart';
import 'package:arcinus/ui/shared/widgets/custom_navigation_bar.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/trainings/services/training_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TrainingListScreen extends ConsumerStatefulWidget {
  final String academyId;

  const TrainingListScreen({
    super.key,
    required this.academyId,
  });

  @override
  ConsumerState<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends ConsumerState<TrainingListScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  final NavigationService _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    // Generar los días de la semana actual
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    _weekDays = List.generate(7, (index) {
      return firstDayOfWeek.add(Duration(days: index));
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.black, // Black Swarm del brandbook
      body: SafeArea(
        child: Column(
          children: [
            _buildCalendarStrip(),
            Expanded(
              child: _buildTrainingList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        pinnedItems: _navigationService.pinnedItems,
        allItems: NavigationItems.allItems,
        activeRoute: '/trainings',
        onItemTap: (item) {
          _navigationService.navigateToRoute(context, item.destination);
        },
        onItemLongPress: (item) {
          if (_navigationService.togglePinItem(item, context: context)) {
            setState(() {});
          }
        },
        onAddButtonTap: () {
          _showAddTrainingOptions();
        },
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark Gray del brandbook
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final day = _weekDays[index];
          final isSelected = day.day == _selectedDate.day &&
                            day.month == _selectedDate.month &&
                            day.year == _selectedDate.year;
          
          return GestureDetector(
            onTap: () => _onDateSelected(day),
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFda1a32) : Colors.transparent, // Bonfire Red si está seleccionado
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrainingList() {
    final trainingService = ref.watch(trainingServiceProvider);
    final dateFormatter = DateFormat('hh:mm a');
    
    return StreamBuilder<List<Training>>(
      stream: trainingService.getTrainingsByAcademy(widget.academyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFda1a32)));
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        
        final trainings = snapshot.data
          ?.where((training) => !training.isTemplate)
          .toList() ?? [];
        
        if (trainings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, color: Color(0xFFa00c30), size: 48),
                SizedBox(height: 16),
                Text(
                  'No hay entrenamientos programados',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        // Para propósitos de demostración, simulamos algunos estado de completado
        // En una implementación real, esto vendría de tus datos
        final completedStates = {
          0: true,  // Primer entrenamiento completado
          2: false, // Tercer entrenamiento no completado
        };
        
        return ListView.builder(
          itemCount: trainings.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final training = trainings[index];
            // Simulamos una hora para cada entrenamiento
            final time = DateTime.now().add(Duration(hours: index + 9));
            final isCompleted = completedStates[index] ?? false;
            
            return _buildTrainingCard(
              training, 
              dateFormatter.format(time),
              isCompleted,
            );
          },
        );
      },
    );
  }

  Widget _buildTrainingCard(Training training, String time, bool isCompleted) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/trainings/sessions',
          arguments: training.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF323232) : Colors.black, // Medium Gray si está completado
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF323232), // Medium Gray del brandbook
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: isCompleted 
                        ? const Color(0xFF00C853) // Court Green del brandbook
                        : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          training.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          training.description,
                          style: const TextStyle(
                            color: Color(0xFF8A8A8A), // Light Gray del brandbook
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), // Dark Gray del brandbook
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Dark Gray del brandbook
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF00C853), // Court Green del brandbook
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Sesión completada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ver detalles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddTrainingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E), // Dark Gray del brandbook
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Crear nuevo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionButton(
                icon: Icons.fitness_center,
                label: 'Nuevo Entrenamiento',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/trainings/new');
                },
              ),
              const SizedBox(height: 12),
              _buildOptionButton(
                icon: Icons.content_copy,
                label: 'Nueva Plantilla',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/trainings/template/new');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF323232), // Medium Gray del brandbook
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFda1a32), // Bonfire Red del brandbook
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 