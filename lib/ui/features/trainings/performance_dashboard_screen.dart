import 'package:arcinus/shared/models/session.dart';
import 'package:arcinus/shared/models/training.dart';
import 'package:arcinus/shared/widgets/loading_indicator.dart';
import 'package:arcinus/shared/widgets/error_display.dart';
import 'package:arcinus/shared/widgets/empty_state.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/trainings/services/performance_service.dart';
import 'package:arcinus/ux/features/trainings/services/training_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class PerformanceDashboardScreen extends ConsumerStatefulWidget {
  final String? athleteId; // Si es null, muestra datos generales
  final String? groupId; // Si es null, muestra datos de todos los grupos
  final String? trainingId; // Si es null, muestra datos de todos los entrenamientos
  final String? academyId;

  const PerformanceDashboardScreen({
    super.key,
    this.athleteId,
    this.groupId,
    this.trainingId,
    this.academyId,
  });

  @override
  ConsumerState<PerformanceDashboardScreen> createState() => _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState extends ConsumerState<PerformanceDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filtros de fecha
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // Estado de carga
  bool _isLoading = false;
  String? _error;
  
  // Datos de rendimiento
  Map<String, dynamic>? _effectivenessData;
  Map<String, Map<String, dynamic>>? _attendanceData;
  Map<String, List<Map<String, dynamic>>>? _performanceData;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  String _getAcademyId() {
    return widget.academyId ?? ref.read(currentAcademyIdProvider) ?? '';
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final performanceService = ref.read(performanceServiceProvider);
      final academyId = _getAcademyId();
      
      // Cargar datos según el contexto
      if (widget.trainingId != null) {
        // Datos de efectividad para un entrenamiento específico
        _effectivenessData = await performanceService.calculateTrainingEffectiveness(
          widget.trainingId!,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
      
      if (widget.groupId != null) {
        // Datos de asistencia para un grupo
        _attendanceData = await performanceService.getAttendanceDataForGroup(
          widget.groupId!,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
      
      if (widget.athleteId != null) {
        // Datos de rendimiento para un atleta
        _performanceData = await performanceService.getAthletePerformanceData(
          widget.athleteId!,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
      
      // Si no tenemos un ID específico, cargaremos datos genéricos más adelante
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFa00c30), // Embers
              onPrimary: Color(0xFFFFFFFF), // Magnolia White
              surface: Color(0xFF1E1E1E), // Dark Gray
              onSurface: Color(0xFFFFFFFF), // Magnolia White
            ),
            dialogBackgroundColor: const Color(0xFF000000), // Black Swarm
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Black Swarm
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E), // Dark Gray
        title: const Text(
          'Métricas de Rendimiento',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // Magnolia White
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Color(0xFFFFFFFF)),
            onPressed: _showDateRangePicker,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFFFFF)),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFa00c30), // Embers
          labelColor: const Color(0xFFFFFFFF), // Magnolia White
          unselectedLabelColor: const Color(0xFF8A8A8A), // Light Gray
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Asistencia'),
            Tab(text: 'Progreso'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Cargando datos de rendimiento...')
          : _error != null
              ? ErrorDisplay(
                  error: _error!,
                  onRetry: _loadData,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(),
                    _buildAttendanceTab(),
                    _buildProgressTab(),
                  ],
                ),
    );
  }
  
  Widget _buildGeneralTab() {
    if (_effectivenessData == null && widget.trainingId != null) {
      return const EmptyState(
        icon: Icons.analytics,
        message: 'No hay datos de efectividad disponibles',
        suggestion: 'Intenta seleccionar un rango de fechas diferente',
      );
    }
    
    // Si no tenemos un entrenamiento específico, mostramos un dashboard general
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Periodo seleccionado
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark Gray
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Periodo de Análisis',
                style: TextStyle(
                  color: Color(0xFFa00c30), // Embers
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Desde: ${DateFormat('dd/MM/yyyy').format(_startDate)}',
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF), // Magnolia White
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Hasta: ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF), // Magnolia White
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Mostrar métricas de efectividad si hay datos disponibles
        if (_effectivenessData != null) ...[
          // Tarjeta de efectividad general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark Gray
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Efectividad del Entrenamiento',
                  style: TextStyle(
                    color: Color(0xFFa00c30), // Embers
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricBox(
                      'Asistencia',
                      '${_effectivenessData!['attendanceRate'].toStringAsFixed(1)}%',
                      const Color(0xFFa00c30), // Embers
                    ),
                    _buildMetricBox(
                      'Finalización',
                      '${_effectivenessData!['completionRate'].toStringAsFixed(1)}%',
                      const Color(0xFF00C853), // Court Green
                    ),
                    _buildMetricBox(
                      'Mejora',
                      '${_effectivenessData!['performanceImprovementRate'].toStringAsFixed(1)}%',
                      const Color(0xFFFFC400), // Gold Trophy
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Sesiones: ${_effectivenessData!['sessionCount']}',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF), // Magnolia White
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Dashboard general si no hay datos específicos
          _buildTrainingSummary(),
        ],
        
        const SizedBox(height: 24),
        
        // Más widgets según necesidad...
      ],
    );
  }
  
  Widget _buildAttendanceTab() {
    if (_attendanceData == null || _attendanceData!.isEmpty) {
      return const EmptyState(
        icon: Icons.person,
        message: 'No hay datos de asistencia disponibles',
        suggestion: 'Intenta seleccionar un grupo o un rango de fechas diferente',
      );
    }
    
    // Calcular promedio de asistencia global
    double averageAttendance = 0;
    _attendanceData!.forEach((athleteId, data) {
      averageAttendance += data['attendanceRate'] as double;
    });
    averageAttendance = _attendanceData!.isNotEmpty 
        ? averageAttendance / _attendanceData!.length 
        : 0;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resumen de asistencia
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark Gray
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen de Asistencia',
                style: TextStyle(
                  color: Color(0xFFa00c30), // Embers
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAttendanceGauge(averageAttendance),
              const SizedBox(height: 16),
              Text(
                'Promedio: ${averageAttendance.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF), // Magnolia White
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total de atletas: ${_attendanceData!.length}',
                style: const TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Lista de asistencia por atleta
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark Gray
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asistencia por Atleta',
                style: TextStyle(
                  color: Color(0xFFa00c30), // Embers
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._attendanceData!.entries.map((entry) {
                final athleteId = entry.key;
                final data = entry.value;
                final rate = data['attendanceRate'] as double;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Aquí iría la foto del atleta en una implementación real
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF323232), // Medium Gray
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF8A8A8A), // Light Gray
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Atleta $athleteId', // En implementación real, mostrar nombre
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF), // Magnolia White
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${data['sessionsAttended']} de ${data['totalSessions']} sesiones',
                              style: const TextStyle(
                                color: Color(0xFF8A8A8A), // Light Gray
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getAttendanceColor(rate).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${rate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: _getAttendanceColor(rate),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressTab() {
    if (_performanceData == null || _performanceData!.isEmpty) {
      return const EmptyState(
        icon: Icons.trending_up,
        message: 'No hay datos de progreso disponibles',
        suggestion: 'Intenta seleccionar un atleta o un rango de fechas diferente',
      );
    }
    
    // Organizar los datos para el gráfico
    final categories = _performanceData!.keys.toList();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Periodo seleccionado
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark Gray
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progreso por Categoría',
                style: TextStyle(
                  color: Color(0xFFa00c30), // Embers
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecciona una categoría para ver detalles:',
                style: TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: false, // En una implementación real, mantendríamos estado
                    backgroundColor: const Color(0xFF323232), // Medium Gray
                    labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
                    onSelected: (selected) {
                      // Mostrar detalles de la categoría
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Gráfico de progreso simplificado
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark Gray
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildPerformanceChart(),
        ),
        
        // Lista de ejercicios con progreso
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark Gray
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ejercicios con Mayor Progreso',
                style: TextStyle(
                  color: Color(0xFFa00c30), // Embers
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Simulación de lista de ejercicios (en real usaríamos los datos de _performanceData)
              _buildExerciseProgressItem(
                'Press de Banca', 
                '+15% en peso', 
                const Color(0xFF00C853), // Court Green
              ),
              const Divider(color: Color(0xFF323232)), // Medium Gray
              _buildExerciseProgressItem(
                'Sentadillas', 
                '+10% en repeticiones', 
                const Color(0xFF00C853), // Court Green
              ),
              const Divider(color: Color(0xFF323232)), // Medium Gray
              _buildExerciseProgressItem(
                'Sprints', 
                '-5% en tiempo', 
                const Color(0xFFda1a32), // Bonfire Red
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetricBox(String title, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttendanceGauge(double percentage) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 12,
              backgroundColor: const Color(0xFF323232), // Medium Gray
              valueColor: AlwaysStoppedAnimation<Color>(_getAttendanceColor(percentage)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF), // Magnolia White
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Asistencia',
                style: TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getAttendanceColor(double rate) {
    if (rate >= 80) {
      return const Color(0xFF00C853); // Court Green
    } else if (rate >= 50) {
      return const Color(0xFFFFC400); // Gold Trophy
    } else {
      return const Color(0xFFda1a32); // Bonfire Red
    }
  }
  
  Widget _buildTrainingSummary() {
    // En una implementación real, obtendrías estos datos de servicios
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark Gray
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(
              color: Color(0xFFa00c30), // Embers
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricBox(
                'Entrenamientos',
                '12',
                const Color(0xFFa00c30), // Embers
              ),
              _buildMetricBox(
                'Sesiones',
                '45',
                const Color(0xFF00C853), // Court Green
              ),
              _buildMetricBox(
                'Asistencia',
                '72%',
                const Color(0xFFFFC400), // Gold Trophy
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceChart() {
    // Datos simulados para el gráfico (en real usaríamos _performanceData)
    final List<FlSpot> cardioData = [
      const FlSpot(0, 2),
      const FlSpot(1, 3),
      const FlSpot(2, 2.5),
      const FlSpot(3, 4),
      const FlSpot(4, 3.5),
      const FlSpot(5, 5),
    ];
    
    final List<FlSpot> strengthData = [
      const FlSpot(0, 1),
      const FlSpot(1, 1.5),
      const FlSpot(2, 2),
      const FlSpot(3, 2.2),
      const FlSpot(4, 3),
      const FlSpot(5, 3.8),
    ];
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFF323232), // Medium Gray
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: const Color(0xFF323232), // Medium Gray
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                  fontSize: 12,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Sem 1';
                    break;
                  case 1:
                    text = 'Sem 2';
                    break;
                  case 2:
                    text = 'Sem 3';
                    break;
                  case 3:
                    text = 'Sem 4';
                    break;
                  case 4:
                    text = 'Sem 5';
                    break;
                  case 5:
                    text = 'Sem 6';
                    break;
                  default:
                    text = '';
                    break;
                }
                return Text(text, style: style);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xFF8A8A8A), // Light Gray
                  fontSize: 12,
                );
                return Text('${value.toInt()}', style: style);
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xFF323232)), // Medium Gray
        ),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: cardioData,
            isCurved: true,
            color: const Color(0xFFa00c30), // Embers
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFa00c30).withOpacity(0.1), // Embers
            ),
          ),
          LineChartBarData(
            spots: strengthData,
            isCurved: true,
            color: const Color(0xFF00C853), // Court Green
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF00C853).withOpacity(0.1), // Court Green
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF1E1E1E), // Dark Gray
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final textColor = touchedSpot.barIndex == 0 
                    ? const Color(0xFFa00c30) // Embers 
                    : const Color(0xFF00C853); // Court Green
                
                return LineTooltipItem(
                  '${touchedSpot.barIndex == 0 ? 'Cardio' : 'Fuerza'}: ${touchedSpot.y.toStringAsFixed(1)}',
                  TextStyle(color: textColor, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildExerciseProgressItem(String name, String progress, Color progressColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.fitness_center,
            color: Color(0xFF8A8A8A), // Light Gray
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFFFFFFFF), // Magnolia White
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: progressColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              progress,
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 