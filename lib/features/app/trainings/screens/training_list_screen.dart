import 'dart:math' as math; // Para PageView Controller

import 'package:arcinus/features/app/trainings/core/models/training.dart';
import 'package:arcinus/features/app/trainings/core/services/training_service.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
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
  late List<DateTime> _allDaysInRange;
  final int _yearRange = 5; // Años hacia atrás y adelante para generar días
  late PageController _monthPageController;
  late PageController _dayPageController; // Reemplaza ScrollController
  int _currentMonthPage = 0;
  int _currentDayPage = 0; // Página inicial del día actual

  // Simulación: Días que tienen entrenamientos (para mostrar el punto indicador)
  // En una implementación real, esto debería consultarse basado en el rango visible o _selectedDate
  final Set<int> _daysWithTraining = { DateTime.now().day, DateTime.now().add(const Duration(days: 2)).day };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateDaysInRange(); // Genera el rango amplio de días

    // Calcular la página inicial para el mes actual
    final now = DateTime.now();
    final firstMonth = DateTime(now.year - _yearRange);
    _currentMonthPage = (now.year - firstMonth.year) * 12 + now.month - 1;

    _monthPageController = PageController(
      initialPage: _currentMonthPage,
      viewportFraction: 0.35, // Muestra parte de los meses adyacentes
    );

    // Calcular índice inicial para el día actual
    _currentDayPage = _dateToIndex(_selectedDate);

    // Inicializar PageController para los días
    _dayPageController = PageController(
        initialPage: _currentDayPage,
        viewportFraction: 1 / 5, // Mostrar 5 días a la vez (ajustar según diseño)
        );

    // Listener para actualizar el offset si la página del mes cambia drásticamente
     _monthPageController.addListener(() {
      // Podríamos ajustar el scroll de días aquí si fuera necesario,
      // pero _onMonthPageChanged ya lo maneja al cambiar _selectedDate
     });
  }

  @override
  void dispose() {
    _monthPageController.dispose();
    _dayPageController.dispose(); // Añadir dispose
    super.dispose();
  }

  void _generateDaysInRange() {
    final now = DateTime.now();
    final startDate = DateTime(now.year - _yearRange, now.month, now.day);
    final endDate = DateTime(now.year + _yearRange, now.month, now.day);
    _allDaysInRange = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      _allDaysInRange.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  // --- Funciones Helper para Índice/Fecha ---
  int _dateToIndex(DateTime date) {
     final index = _allDaysInRange.indexWhere((day) =>
          day.year == date.year &&
          day.month == date.month &&
          day.day == date.day);
      // Devolver 0 si no se encuentra (aunque no debería pasar con el rango generado)
     return math.max(0, index);
  }

  DateTime _indexToDate(int index) {
    if (index >= 0 && index < _allDaysInRange.length) {
      return _allDaysInRange[index];
    }
    // Devolver el primer día como fallback (no debería ocurrir)
    return _allDaysInRange.first;
  }
  // --- Fin Funciones Helper ---
   void _onMonthPageChanged(int page) {
     final now = DateTime.now();
     final firstMonthOfYear = DateTime(now.year - _yearRange);
     final selectedMonth = DateTime(
        firstMonthOfYear.year + (page ~/ 12), // Año
        firstMonthOfYear.month + (page % 12), // Mes
     );

    // Calcula la fecha objetivo (intentar mantener el día, o el último día del mes)
    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final targetDay = math.min(_selectedDate.day, daysInMonth);
    final DateTime newSelectedDate = DateTime(selectedMonth.year, selectedMonth.month, targetDay);

     // Solo actualiza si el mes realmente cambió
     if (_selectedDate.year != newSelectedDate.year || _selectedDate.month != newSelectedDate.month) {
        setState(() {
          _currentMonthPage = page;
          _selectedDate = newSelectedDate; // Actualizar fecha seleccionada
          _currentDayPage = _dateToIndex(_selectedDate); // Actualizar índice de día

          // Saltar PageView de días a la nueva fecha SIN animación
          if (_dayPageController.hasClients) {
             _dayPageController.jumpToPage(_currentDayPage);
          }
        });
     }
  }

  // Nueva función para manejar cambio de página en días
  void _onDayPageChanged(int page) {
     final newSelectedDate = _indexToDate(page);

     // Solo actualizar si la fecha es diferente
     if (newSelectedDate.year != _selectedDate.year ||
         newSelectedDate.month != _selectedDate.month ||
         newSelectedDate.day != _selectedDate.day) {
        setState(() {
           final oldSelectedDate = _selectedDate;
           _selectedDate = newSelectedDate;
           _currentDayPage = page;

           // Si el mes/año cambió, animar PageView de meses
            if (oldSelectedDate.year != _selectedDate.year || oldSelectedDate.month != _selectedDate.month) {
              final firstMonth = DateTime(DateTime.now().year - _yearRange);
              final targetMonthPage = (_selectedDate.year - firstMonth.year) * 12 + _selectedDate.month - 1;
             if (targetMonthPage != _currentMonthPage && _monthPageController.hasClients) {
                _monthPageController.animateToPage(
                   targetMonthPage,
                   duration: const Duration(milliseconds: 400),
                   curve: Curves.easeInOut,
                 );
                 _currentMonthPage = targetMonthPage;
              }
           }
        });
     }
  }

  // Nueva función para manejar taps en los días
  void _onDateTapped(int index) {
    if (index != _currentDayPage && _dayPageController.hasClients) {
      _dayPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // _onDayPageChanged se llamará cuando la animación termine
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Entrenamientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Lógica para filtrar entrenamientos
            },
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarStrip(),
          Expanded(
            child: _buildTrainingList(),
          ),
        ],
      ),
      onAddButtonTap: () {
        Navigator.pushNamed(
          context,
          '/trainings/create',
          arguments: {
            'academyId': widget.academyId,
            'date': _selectedDate,
          },
        );
      },
    );
  }

  Widget _buildCalendarStrip() {
    // final Set<int> daysWithTraining = { DateTime.now().day, DateTime.now().add(const Duration(days: 2)).day }; // Movido a estado

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark Gray del brandbook
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // PageView para Mes y Año
          SizedBox(
            height: 40, // Aumentar altura para acomodar escala
            child: PageView.builder(
              controller: _monthPageController,
              itemCount: _yearRange * 2 * 12, // Total de meses en el rango
              onPageChanged: _onMonthPageChanged,
              itemBuilder: (context, index) {
                final now = DateTime.now();
                final firstMonth = DateTime(now.year - _yearRange);
                final month = DateTime(
                  firstMonth.year + (index ~/ 12),
                  firstMonth.month + (index % 12),
                );

                // Calcular diferencia con la página actual para escala y opacidad/color
                double difference = 0.0;
                if (_monthPageController.position.haveDimensions) {
                  double page = _monthPageController.page ?? _currentMonthPage.toDouble();
                  difference = (page - index).abs();
                }

                // Calcular escala: 1.0 para el centro, disminuye hasta ~0.8
                final double scale = math.max(0.8, 1.0 - difference * 0.2);
                // Calcular opacidad/color: Blanco brillante para el centro, grisáceo para otros
                final Color color = Color.lerp(Colors.white, Colors.grey[600], math.min(1.0, difference)) ?? Colors.grey;

                return Transform.scale(
                  scale: scale,
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: TextStyle(
                        color: color, // Usar color calculado
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12), // Espacio entre mes y días

          // Fila de días (Tarjetas) - Ahora con PageView
          SizedBox(
            height: 95, // Altura ajustada para las tarjetas + posible escala
            // Reemplazar NotificationListener y ListView por PageView
            child: PageView.builder(
              controller: _dayPageController,
              itemCount: _allDaysInRange.length,
              onPageChanged: _onDayPageChanged, // Usar nueva función
              // scrollDirection: Axis.horizontal, // Implícito en PageView
              itemBuilder: (context, index) {
                final day = _allDaysInRange[index];
                // final isSelected = day.day == _selectedDate.day &&
                //                   day.month == _selectedDate.month &&
                //                   day.year == _selectedDate.year;
                final isSelected = index == _currentDayPage; // Selección basada en índice de página

                // Simula si este día tiene un entrenamiento (basado en el día del mes)
                final hasTraining = _daysWithTraining.contains(day.day) && day.month == DateTime.now().month && day.year == DateTime.now().year; // Simplificado a mes actual

                 // Calcular diferencia con la página actual para escala
                double difference = 0.0;
                if (_dayPageController.position.haveDimensions) {
                  double page = _dayPageController.page ?? _currentDayPage.toDouble();
                  difference = (page - index).abs();
                }
                 // Calcular escala: 1.1 para el centro, disminuye hasta ~0.9
                final double scale = math.max(0.9, 1.1 - difference * 0.2);

                return GestureDetector(
                  // onTap: () => _onDateSelected(day), // Cambiar a _onDateTapped
                  onTap: () => _onDateTapped(index),
                  child: Transform.scale( // Aplicar escala calculada
                    scale: scale,
                    child: Container(
                      // width: 60, // PageView maneja el ancho con viewportFraction
                      margin: const EdgeInsets.symmetric(horizontal: 4), // Mantener margen horizontal
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF323232) : const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: const Color(0xFF4d4d4d)) : null,
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(90),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Indicador de entrenamiento (punto)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: hasTraining ? const Color(0xFFda1a32) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Día de la semana (ej. Tue)
                          Text(
                            DateFormat('E').format(day).substring(0, 3),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Número del día (ej. 09)
                          Text(
                            DateFormat('dd').format(day),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 18,
                            ),
                          ),
                          // Indicador de selección (línea inferior)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 3,
                            width: 20,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFda1a32) : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E), // Dark Gray del brandbook
                  borderRadius: BorderRadius.only(
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
                        color: Colors.white.withAlpha(30),
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
} 