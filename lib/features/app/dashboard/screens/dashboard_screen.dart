import 'package:arcinus/features/app/academy/core/models/academy_model.dart';
import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/theme/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late PageController _pageController;
  int _currentPage = 1; // Inicia en la página central (dashboard)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final isOwner = user?.role == UserRole.owner;
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Página izquierda: Chat
                _buildChatPage(),
                
                // Página central: Dashboard
                _buildDashboardPage(currentAcademy, isOwner, user),
                
                // Página derecha: Notificaciones
                _buildNotificationsPage(),
              ],
            ),
          ),
          // Indicador de páginas
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    width: i == _currentPage ? 16.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: i == _currentPage 
                          ? AppTheme.bonfireRed 
                          : AppTheme.bonfireRed.withAlpha(100),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble, size: 64, color: AppTheme.embers),
          const SizedBox(height: 16),
          const Text(
            'Chat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Desliza a la izquierda para ir al Dashboard'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToDashboard,
            child: const Text('Ir al Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications, size: 64, color: AppTheme.goldTrophy),
          const SizedBox(height: 16),
          const Text(
            'Notificaciones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Desliza a la derecha para ir al Dashboard'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToDashboard,
            child: const Text('Ir al Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPage(Academy? currentAcademy, bool isOwner, User? user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicadores de deslizamiento
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_back, size: 16, color: AppTheme.lightGray),
                      SizedBox(width: 4),
                      Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightGray,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Notificaciones',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightGray,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: AppTheme.lightGray),
                    ],
                  ),
                ],
              ),
            ),
            
            // Cabecera del dashboard con saludo
            if (user != null) ...[
              Text(
                '¡Bienvenido, ${user.name.split(' ').first}!',
                style: const TextStyle(
                  fontSize: AppTheme.h2Size,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getGreetingByTime(),
                style: const TextStyle(
                  fontSize: AppTheme.bodySize,
                  color: AppTheme.lightGray,
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            if (currentAcademy == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No hay academia seleccionada',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu academia debería cargarse automáticamente.',
                        style: TextStyle(fontSize: 14, color: AppTheme.lightGray),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Invalidar los providers relevantes para forzar una recarga
                          ref.invalidate(userAcademiesProvider);
                          ref.invalidate(autoLoadAcademyProvider);
                          
                          // Mostrar snackbar de recarga en progreso
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recargando información de academia...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recargar'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Dashboard específico para propietarios
              if (isOwner) ...[
                _buildOwnerDashboard(currentAcademy),
              ] else ...[
                // Dashboard para otros roles
                _buildRegularDashboard(currentAcademy),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildOwnerDashboard(Academy academy) {
    final coachCount = academy.coachIds?.length ?? 0;
    final athleteCount = academy.athleteIds?.length ?? 0;
    final groupCount = academy.groupIds?.length ?? 0;
    
    // Formato para números
    final formatter = NumberFormat("#,###");
    
    // Calcular semanas atrás para simulación de datos
    final now = DateTime.now();
    final currentMonth = DateFormat('MMMM yyyy').format(now);
    final previousMonth = DateFormat('MMMM yyyy').format(
      DateTime(now.year, now.month - 1)
    );
    
    // Datos ficticios para las gráficas
    final activityData = [0.5, 0.8, 0.3, 0.9, 0.5, 0.7, 0.8, 0.4, 0.6, 0.7, 0.5, 0.9,
                          0.7, 0.6, 0.8, 0.9, 0.5, 0.6, 0.7, 0.8, 0.9, 0.7, 0.6, 0.8,
                          0.9, 0.7, 0.8, 0.9, 0.6, 0.7, 0.8];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Academia y plan de suscripción
        _buildAcademyHeader(academy),
        const SizedBox(height: 24),
        
        // Selector de periodo con estilo segmentado
        _buildPeriodSelector(),
        const SizedBox(height: 16),
        
        // Cabecera de mes actual
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentMonth,
                  style: const TextStyle(
                    fontSize: AppTheme.h3Size,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bonfireRed,
                  ),
                ),
                Text(
                  '$previousMonth • ${formatter.format(150)}h ${formatter.format(30)}m',
                  style: const TextStyle(
                    fontSize: AppTheme.bodySize,
                    color: AppTheme.lightGray,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppTheme.lightGray),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Gráfico de actividad de la academia
        SizedBox(
          height: 200,
          child: _buildActivityChart(activityData),
        ),
        const SizedBox(height: 24),
        
        // Resumen de actividad
        _buildActivitySummary(coachCount, athleteCount, groupCount),
        const SizedBox(height: 24),
        
        // Métricas de la academia
        _buildMetricBoxes(),
        const SizedBox(height: 16),
        
        // Actividad reciente
        _buildRecentActivity(),
      ],
    );
  }
  
  Widget _buildAcademyHeader(Academy academy) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.embers, AppTheme.bonfireRed.withAlpha(80)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.magnoliaWhite.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: academy.logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          academy.logo!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.school,
                            color: AppTheme.magnoliaWhite,
                            size: 30,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.school,
                        color: AppTheme.magnoliaWhite,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      academy.name,
                      style: const TextStyle(
                        fontSize: AppTheme.h3Size,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.magnoliaWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      academy.sport,
                      style: TextStyle(
                        fontSize: AppTheme.secondarySize,
                        color: AppTheme.magnoliaWhite.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubscriptionBadge(academy.subscription),
              OutlinedButton(
                onPressed: () {
                  // Navegar a configuración de la academia
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.magnoliaWhite,
                  side: const BorderSide(color: AppTheme.magnoliaWhite),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Configurar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubscriptionBadge(String subscription) {
    Color bgColor;
    String label;
    
    switch (subscription.toLowerCase()) {
      case 'premium':
        bgColor = AppTheme.goldTrophy;
        label = 'Premium';
        break;
      case 'basic':
        bgColor = AppTheme.courtGreen;
        label = 'Básico';
        break;
      case 'free':
      default:
        bgColor = AppTheme.lightGray;
        label = 'Gratuito';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius * 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppTheme.captionSize,
          fontWeight: FontWeight.bold,
          color: AppTheme.blackSwarm,
        ),
      ),
    );
  }
  
  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      ),
      child: Row(
        children: [
          _buildPeriodOption('Semana', true),
          _buildPeriodOption('Mes', false),
          _buildPeriodOption('Año', false),
          _buildPeriodOption('Todo', false),
        ],
      ),
    );
  }
  
  Widget _buildPeriodOption(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.mediumGray : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.secondarySize,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.magnoliaWhite : AppTheme.lightGray,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityChart(List<double> data) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              
              return Stack(
                children: [
                  // Líneas de la cuadrícula
                  ...List.generate(5, (index) {
                    final y = height * (1 - index / 4);
                    return Positioned(
                      left: 0,
                      top: y,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: AppTheme.darkGray,
                      ),
                    );
                  }),
                  
                  // Etiquetas verticales
                  ...List.generate(5, (index) {
                    final label = (index * 6).toString();
                    final y = height * (1 - index / 4) - 10;
                    return Positioned(
                      right: 0,
                      top: y,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: AppTheme.captionSize,
                          color: AppTheme.lightGray,
                        ),
                      ),
                    );
                  }),
                  
                  // Gráfico lineal
                  CustomPaint(
                    size: Size(width, height),
                    painter: GraphPainter(
                      data: data,
                      lineColor: AppTheme.bonfireRed,
                      secondaryLineColor: AppTheme.lightGray.withAlpha(30),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Barras de actividad
        SizedBox(
          height: 100,
          child: Row(
            children: List.generate(31, (index) {
              final value = data[index];
              final isActive = index % 3 == 0;
              
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 8,
                                  height: constraints.maxHeight * value,
                                  decoration: BoxDecoration(
                                    color: isActive ? AppTheme.bonfireRed : AppTheme.lightGray.withAlpha(30),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? AppTheme.magnoliaWhite : AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivitySummary(int coachCount, int athleteCount, int groupCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMEN DE 18 ACTIVIDADES',
            style: TextStyle(
              fontSize: AppTheme.captionSize,
              color: AppTheme.lightGray,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Duración',
                  '22h 12m',
                  AppTheme.bonfireRed,
                  true,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Energía Activa',
                  '12,501 kcal',
                  AppTheme.magnoliaWhite,
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Distancia',
                  '83.18 km',
                  AppTheme.magnoliaWhite,
                  false,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Ganancia Elevación',
                  '2,163 m',
                  AppTheme.magnoliaWhite,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String title, String value, Color valueColor, bool highlight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: highlight 
          ? BoxDecoration(
              color: AppTheme.bonfireRed,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTheme.captionSize,
              color: highlight ? AppTheme.magnoliaWhite.withAlpha(200) : AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.subtitleSize,
              fontWeight: FontWeight.bold,
              color: highlight ? AppTheme.magnoliaWhite : valueColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricBoxes() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMetricBox(
            title: 'Asistencia',
            value: '87%',
            icon: Icons.people_alt_rounded,
            color: AppTheme.embers,
          ),
          _buildMetricBox(
            title: 'Entrenamiento',
            value: '12h',
            icon: Icons.fitness_center,
            color: AppTheme.courtGreen,
          ),
          _buildMetricBox(
            title: 'Rendimiento',
            value: '8.5',
            icon: Icons.trending_up,
            color: AppTheme.goldTrophy,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppTheme.captionSize,
                  color: AppTheme.lightGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: AppTheme.h3Size,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: AppTheme.subtitleSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.magnoliaWhite,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.bonfireRed,
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 30),
              ),
              child: const Text('Ver todo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkGray,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.directions_run,
                color: AppTheme.bonfireRed,
                size: 32,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5.15 km Entrenamiento Exterior',
                      style: TextStyle(
                        fontSize: AppTheme.bodySize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.magnoliaWhite,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '25 minutos • ',
                          style: TextStyle(
                            fontSize: AppTheme.captionSize,
                            color: AppTheme.lightGray,
                          ),
                        ),
                        Text(
                          'Hoy',
                          style: TextStyle(
                            fontSize: AppTheme.captionSize,
                            color: AppTheme.bonfireRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.mediumGray,
                child: Icon(
                  Icons.person,
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRegularDashboard(Academy currentAcademy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          title: 'Grupos',
          icon: Icons.group,
          color: Colors.blue,
          count: currentAcademy.groupIds?.length.toString() ?? '0',
          onTap: () {
            // Navegar a la pestaña de grupos (índice 2)
          },
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Entrenadores',
          icon: Icons.sports,
          color: Colors.green,
          count: currentAcademy.coachIds?.length.toString() ?? '0',
          onTap: () {
            // Navegar a pantalla de entrenadores
          },
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Atletas',
          icon: Icons.fitness_center,
          color: Colors.orange,
          count: currentAcademy.athleteIds?.length.toString() ?? '0',
          onTap: () {
            // Navegar a pantalla de atletas
          },
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Eventos',
          icon: Icons.event,
          color: Colors.purple,
          count: '5',
          onTap: () {
            // Navegar a calendario (índice 1)
          },
        ),
      ],
    );
  }
  
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: $count',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getGreetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "¡Buenos días! Comienza un gran día.";
    } else if (hour < 18) {
      return "¡Buenas tardes! Espero que estés teniendo un buen día.";
    } else {
      return "¡Buenas noches! Revisa tu resumen diario.";
    }
  }
}

// Clase para dibujar el gráfico
class GraphPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color secondaryLineColor;
  
  GraphPainter({
    required this.data,
    required this.lineColor,
    required this.secondaryLineColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint primaryPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
      
    final Paint secondaryPaint = Paint()
      ..color = secondaryLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
      
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withAlpha(90),
          lineColor.withAlpha(30),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    // Calcular las coordenadas para los puntos de datos
    final spacePerPoint = size.width / (data.length - 1);
    
    // Dibujar línea secundaria
    final secondaryPath = Path();
    secondaryPath.moveTo(0, size.height * (1 - data[0] * 0.8));
    
    for (int i = 1; i < data.length; i++) {
      secondaryPath.lineTo(
        i * spacePerPoint, 
        size.height * (1 - data[i] * 0.8),
      );
    }
    
    canvas.drawPath(secondaryPath, secondaryPaint);
    
    // Dibujar línea principal
    final primaryPath = Path();
    primaryPath.moveTo(0, size.height * (1 - data[0]));
    
    for (int i = 1; i < data.length; i++) {
      primaryPath.lineTo(
        i * spacePerPoint, 
        size.height * (1 - data[i]),
      );
    }
    
    canvas.drawPath(primaryPath, primaryPaint);
    
    // Rellenar área bajo la línea principal
    final fillPath = Path();
    fillPath.moveTo(0, size.height * (1 - data[0]));
    
    for (int i = 1; i < data.length; i++) {
      fillPath.lineTo(
        i * spacePerPoint, 
        size.height * (1 - data[i]),
      );
    }
    
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    
    canvas.drawPath(fillPath, fillPaint);
  }
  
  @override
  bool shouldRepaint(GraphPainter oldDelegate) => 
    data != oldDelegate.data || 
    lineColor != oldDelegate.lineColor;
} 