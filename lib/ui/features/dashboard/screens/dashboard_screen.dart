import 'dart:math' as math;

import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

// Añadir el enum para los períodos en la parte superior de la clase
enum MetricsPeriod {
  week,
  month,
  year,
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  // Controlador para la navegación deslizable
  late PageController _pageController;
  late int _currentPageIndex;
  
  // Controlador para el panel deslizable
  late AnimationController _panelController;
  late Animation<double> _panelAnimation;
  
  // Estado para controlar si el panel está siendo arrastrado
  bool _isDragging = false;
  double _dragExtent = 0.0;
  
  // Altura del panel cuando está completamente expandido
  final double _expandedPanelHeight = 240.0;
  
  // Lista de botones de navegación
  final List<NavigationItem> _allNavigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Inicio',
      destination: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.group,
      label: 'Usuarios',
      destination: '/users-management',
    ),
    NavigationItem(
      icon: Icons.sports,
      label: 'Entrenamientos',
      destination: '/trainings',
    ),
    NavigationItem(
      icon: Icons.calendar_today,
      label: 'Calendario',
      destination: '/calendar',
    ),
    NavigationItem(
      icon: Icons.bar_chart,
      label: 'Estadísticas',
      destination: '/stats',
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'Configuración',
      destination: '/settings',
    ),
    NavigationItem(
      icon: Icons.payments,
      label: 'Pagos',
      destination: '/payments',
    ),
    NavigationItem(
      icon: Icons.school,
      label: 'Academias',
      destination: '/academies',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Perfil',
      destination: '/profile',
    ),
    NavigationItem(
      icon: Icons.chat,
      label: 'Chat',
      destination: '/chats',
    ),
    NavigationItem(
      icon: Icons.notifications,
      label: 'Notificaciones',
      destination: '/notifications',
    ),
  ];
  
  // Lista de botones fijados (inicialmente los primeros 5)
  List<NavigationItem> _pinnedItems = [];
  
  // Añadir la variable para el período seleccionado (mes por defecto)
  MetricsPeriod _selectedPeriod = MetricsPeriod.month;
  
  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de página con la página del dashboard
    _pageController = PageController(initialPage: 1);
    _currentPageIndex = 1;
    
    // Inicialmente fijamos los primeros 5 elementos
    _pinnedItems = _allNavigationItems.take(5).toList();
    
    // Inicializar el controlador de animación para el panel deslizable
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _panelAnimation = Tween<double>(
      begin: 0.0,
      end: _expandedPanelHeight,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    
    _panelController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  // Navegar a una página específica (notificaciones, dashboard, chat)
  void _navigateToPage(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Método para navegar a una ruta
  void _navigateToRoute(String route) {
    // Si es el dashboard y ya estamos en el dashboard, no hacemos nada
    if (route == '/dashboard' && ModalRoute.of(context)?.settings.name == '/dashboard') {
      // Cerramos el panel si está abierto
      if (_panelController.value > 0) {
        _panelController.reverse();
      }
      return;
    }
    
    Navigator.of(context).pushNamed(route);
  }

  // Fijar/soltar un elemento de navegación
  void _togglePinItem(NavigationItem item) {
    setState(() {
      if (_pinnedItems.contains(item)) {
        // Si ya está fijado y hay más de 1 elemento, lo quitamos
        if (_pinnedItems.length > 1) {
          _pinnedItems.remove(item);
        }
      } else {
        // Si no está fijado y hay menos de 5, lo añadimos
        if (_pinnedItems.length < 5) {
          _pinnedItems.add(item);
        } else {
          // Si ya hay 5, mostramos un mensaje
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solo puedes fijar 5 elementos. Quita uno primero.')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal (PageView para navegación deslizable)
          SafeArea(
            // Solo aplicamos SafeArea en la parte superior, ya que la parte inferior
            // está ocupada por nuestro panel de navegación personalizado
            bottom: false,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                // Página de Notificaciones (índice 0) - Cambiado de posición
                _buildNotificationsPage(),
                
                // Página Dashboard (índice 1)
                userAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                  data: (user) {
                    if (user == null) {
                      return const Center(child: Text('No hay usuario autenticado'));
                    }
                    
                    return _buildDashboardContent(context, user);
                  },
                ),
                
                // Página de Chat (índice 2) - Cambiado de posición
                _buildChatPage(),
              ],
            ),
          ),
          
          // Panel deslizable desde abajo (ahora como componente único)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onVerticalDragStart: (details) {
                setState(() {
                  _isDragging = true;
                  // Empezamos desde la posición actual de la animación
                  _dragExtent = _panelAnimation.value;
                });
              },
              onVerticalDragUpdate: (details) {
                // Solo procesamos si estamos arrastrando
                if (!_isDragging) return;
                
                setState(() {
                  // Actualizamos la extensión del arrastre (negativo porque hacia arriba es negativo en el sistema de coordenadas)
                  _dragExtent -= details.delta.dy;
                  
                  // Limitamos la extensión entre 0 y la altura máxima
                  _dragExtent = _dragExtent.clamp(0.0, _expandedPanelHeight);
                  
                  // Actualizamos el valor del controlador de animación
                  _panelController.value = _dragExtent / _expandedPanelHeight;
                });
              },
              onVerticalDragEnd: (details) {
                // Terminamos el arrastre
                setState(() {
                  _isDragging = false;
                  
                  // Determinamos si debemos expandir o contraer basado en la velocidad y la posición actual
                  if (details.velocity.pixelsPerSecond.dy < -500 || 
                      (_panelController.value > 0.5 && details.velocity.pixelsPerSecond.dy.abs() < 500)) {
                    // Expandimos si:
                    // - Se arrastró rápidamente hacia arriba (velocidad negativa grande)
                    // - O está más de la mitad expandido y no hay una velocidad significativa
                    _panelController.forward();
                  } else {
                    // En otro caso, contraemos
                    _panelController.reverse();
                  }
                });
              },
              // Aseguramos que el área de detección del gesto cubra todo el panel
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 100 + math.max(0, _panelAnimation.value), // Garantizamos que la altura nunca sea menor a 80
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de arrastre (visible siempre)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Panel expandido con el resto de opciones
                    if (_panelAnimation.value > 10) // Solo mostramos si hay suficiente espacio
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                                  child: Text(
                                    'Todas las opciones',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                
                                // Grid de iconos adicionales
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 16,
                                  children: _allNavigationItems
                                      .where((item) => !_pinnedItems.contains(item))
                                      .map((item) => _buildNavigationButton(
                                        item, 
                                        onTap: () => _navigateToRoute(item.destination),
                                        onLongPress: () => _togglePinItem(item),
                                        isPinned: false,
                                      ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    // Contenedor para crear separación visual
                    if (_panelAnimation.value > 10)
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                        color: theme.colorScheme.outlineVariant.withAlpha(90),
                      ),
                    
                    // Barra principal con los elementos fijados (siempre visible)
                    SizedBox(
                      height: 75,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _pinnedItems.map((item) => _buildNavigationButton(
                            item,
                            onTap: () => _navigateToRoute(item.destination),
                            onLongPress: () => _togglePinItem(item),
                            isPinned: true,
                            isActive: item.destination == '/dashboard' && _currentPageIndex == 1,
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Construir un botón de navegación
  Widget _buildNavigationButton(
    NavigationItem item, {
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required bool isPinned,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primaryContainer
                    : isPinned
                        ? theme.colorScheme.surfaceContainerHighest.withAlpha(170)
                        : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: isActive
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.icon,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  if (isPinned)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.push_pin,
                          size: 6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Etiqueta con elipsis
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive || isPinned ? FontWeight.bold : FontWeight.normal,
                color: isActive ? theme.colorScheme.primary : null,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Chat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Desliza a la izquierda para ir al Dashboard'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToPage(1), // Ir al dashboard
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
          const Icon(Icons.notifications, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Notificaciones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Desliza a la derecha para ir al Dashboard'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToPage(1), // Ir al dashboard
            child: const Text('Ir al Dashboard'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDashboardContent(BuildContext context, User user) {
    // Personalizar el dashboard según el rol del usuario
    switch (user.role) {
      case UserRole.owner:
        return _buildOwnerDashboard(context, user);
      case UserRole.manager:
        return _buildManagerDashboard(context, user);
      case UserRole.coach:
        return _buildCoachDashboard(context, user);
      case UserRole.athlete:
        return _buildAthleteDashboard(context, user);
      case UserRole.parent:
        return _buildParentDashboard(context, user);
      default:
        return const Center(child: Text('Bienvenido a Arcinus'));
    }
  }
  
  Widget _buildOwnerDashboard(BuildContext context, User user) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, ${user.name}!',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          if (user.academyIds.isEmpty) 
            _buildCreateAcademyCard(context)
          else
            Consumer(
              builder: (context, ref, child) {
                final academiesAsync = ref.watch(userAcademiesProvider);
                
                return academiesAsync.when(
                  data: (academies) {
                    if (academies.isEmpty) {
                      return _buildCreateAcademyCard(context);
                    }
                    
                    // Para propietarios, siempre mostramos la información de su única academia
                    final academy = academies.first;
                    return _buildAcademyStatsSection(context, academy);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Error al cargar academias: $error'),
                  ),
                );
              },
            ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildAcademyStatsSection(BuildContext context, Academy academy) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con el nombre de la academia
        Row(
          children: [
            Expanded(
              child: Text(
                academy.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/academy-details');
              },
              tooltip: 'Configurar academia',
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Tarjeta de información general
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deporte: ${academy.sport}', style: theme.textTheme.titleMedium),
                if (academy.location != null)
                  Text('Ubicación: ${academy.location}', 
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (academy.description != null)
                  Text('Descripción: ${academy.description}', 
                    style: theme.textTheme.bodyLarge,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Sección de métricas principales
        _buildMetricsSection(context, 'Métricas Generales'),
        
        const SizedBox(height: 16),
        
        // Sección única de métricas de período con selector
        _buildPeriodMetricsSection(context),
        
        const SizedBox(height: 16),
        
        _buildPaymentsSection(context),
        
        const SizedBox(height: 16),
        
        _buildUsersActivitySection(context),
      ],
    );
  }
  
  Widget _buildMetricsSection(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tarjetas de estadísticas
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              'Entrenadores',
              '5',
              Icons.sports,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Atletas',
              '28',
              Icons.fitness_center,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'Grupos',
              '4',
              Icons.group,
              Colors.amber,
            ),
            _buildStatCard(
              context,
              'Clases/Semana',
              '15',
              Icons.event,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPeriodMetricsSection(BuildContext context) {
    // Título del período según selección
    String periodTitle;
    String periodData;
    switch (_selectedPeriod) {
      case MetricsPeriod.week:
        periodTitle = 'Actividad Semanal';
        periodData = 'Últimos 7 días';
        break;
      case MetricsPeriod.month:
        periodTitle = 'Actividad Mensual';
        periodData = 'Últimos 30 días';
        break;
      case MetricsPeriod.year:
        periodTitle = 'Actividad Anual';
        periodData = 'Últimos 12 meses';
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila con título y botones de período
        Row(
          children: [
            Expanded(
              child: Text(
                periodTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Botones de período
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPeriodButton(context, MetricsPeriod.week, 'S'),
                  _buildPeriodButton(context, MetricsPeriod.month, 'M'),
                  _buildPeriodButton(context, MetricsPeriod.year, 'A'),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Período que se está visualizando
                Text(
                  periodData,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Simulación de un gráfico
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text('Gráfico de actividad - $_getPeriodText'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Métricas resumidas - Usando Wrap para prevenir overflow
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _buildSmallMetricItem(
                      context, 
                      'Asistencia', 
                      _getMetricValueForPeriod('asistencia'), 
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                    _buildSmallMetricItem(
                      context, 
                      'Ausencias', 
                      _getMetricValueForPeriod('ausencias'), 
                      Icons.cancel_outlined,
                      Colors.red,
                    ),
                    _buildSmallMetricItem(
                      context, 
                      'Clases', 
                      _getMetricValueForPeriod('clases'), 
                      Icons.event_note,
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Método para construir botones de período
  Widget _buildPeriodButton(BuildContext context, MetricsPeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimary 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  // Método para obtener el texto del período seleccionado
  String get _getPeriodText {
    switch (_selectedPeriod) {
      case MetricsPeriod.week:
        return 'Semanal';
      case MetricsPeriod.month:
        return 'Mensual';
      case MetricsPeriod.year:
        return 'Anual';
    }
  }
  
  // Método para simular valores según el período
  String _getMetricValueForPeriod(String metric) {
    switch (_selectedPeriod) {
      case MetricsPeriod.week:
        if (metric == 'asistencia') return '82%';
        if (metric == 'ausencias') return '18%';
        if (metric == 'clases') return '12';
        break;
      case MetricsPeriod.month:
        if (metric == 'asistencia') return '86%';
        if (metric == 'ausencias') return '14%';
        if (metric == 'clases') return '48';
        break;
      case MetricsPeriod.year:
        if (metric == 'asistencia') return '89%';
        if (metric == 'ausencias') return '11%';
        if (metric == 'clases') return '576';
        break;
    }
    return '0';
  }
  
  Widget _buildPaymentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado de Pagos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Gráfico de donut para pagos
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart, size: 48, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        const Text('Gráfico de pagos'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Métricas de pagos - Usando Wrap
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _buildSmallMetricItem(
                      context, 
                      'Pagados', 
                      '78%', 
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildSmallMetricItem(
                      context, 
                      'Pendientes', 
                      '15%', 
                      Icons.warning_amber,
                      Colors.amber,
                    ),
                    _buildSmallMetricItem(
                      context, 
                      'Atrasados', 
                      '7%', 
                      Icons.error_outline,
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                
                // Total recaudado
                _buildTotalPaymentItem(context),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTotalPaymentItem(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Recaudado ($_getPeriodText)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text(
                '\$1,250,000',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad no implementada')),
            );
          },
          icon: const Icon(Icons.receipt),
          label: const Text('Ver Detalle'),
        ),
      ],
    );
  }
  
  Widget _buildUsersActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad de Usuarios',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Métricas de usuarios - Usando Wrap
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _buildUserActivityMetric(
                      context,
                      'Nuevos',
                      '+5',
                      Icons.person_add,
                      Colors.green,
                    ),
                    _buildUserActivityMetric(
                      context,
                      'Retirados',
                      '-2',
                      Icons.person_off,
                      Colors.red,
                    ),
                    _buildUserActivityMetric(
                      context,
                      'Activos',
                      '28',
                      Icons.people,
                      Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Lista de usuarios recientes
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.primaries[index % Colors.primaries.length],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          'Usuario Ejemplo ${index + 1}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          index == 0 ? 'Nuevo registro' : 'Última actividad: hace ${index + 1} días',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          index == 0 ? Icons.new_releases : Icons.accessibility_new,
                          color: index == 0 ? Colors.green : Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSmallMetricItem(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon, 
    Color color,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 80),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserActivityMetric(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildManagerDashboard(BuildContext context, User user) {
    // Simplificado para este ejemplo
    return _buildOwnerDashboard(context, user);
  }
  
  Widget _buildCoachDashboard(BuildContext context, User user) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, ${user.name}!',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // Sección de grupos
          Text(
            'Mis grupos',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Gestionar mis grupos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad no implementada')),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sección de acciones rápidas
          Text(
            'Acciones rápidas',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildActionCard(
                context, 
                'Tomar asistencia', 
                Icons.fact_check, 
                Colors.blue,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
              _buildActionCard(
                context, 
                'Programar clase', 
                Icons.calendar_today, 
                Colors.green,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
              _buildActionCard(
                context, 
                'Evaluar atletas', 
                Icons.assignment_turned_in, 
                Colors.orange,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
              _buildActionCard(
                context, 
                'Crear entrenamiento', 
                Icons.sports, 
                Colors.purple,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAthleteDashboard(BuildContext context, User user) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, ${user.name}!',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // Próximas clases
          Text(
            'Próximas clases',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No hay clases programadas'),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sección de acciones rápidas
          Text(
            'Acciones rápidas',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildActionCard(
                context, 
                'Mi progreso', 
                Icons.trending_up, 
                Colors.blue,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
              _buildActionCard(
                context, 
                'Mis entrenamientos', 
                Icons.fitness_center, 
                Colors.green,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildParentDashboard(BuildContext context, User user) {
    // Simplificado para este ejemplo
    return _buildAthleteDashboard(context, user);
  }
  
  Widget _buildActionCard(
    BuildContext context, 
    String title, 
    IconData icon, 
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCreateAcademyCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.sports_gymnastics,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Crea tu academia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configura tu academia para empezar a gestionar atletas, entrenadores y más.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navegación a crear academia
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad no implementada')),
                );
              },
              child: const Text('Crear Academia'),
            ),
          ],
        ),
      ),
    );
  }
}

// Clase para representar un elemento de navegación
class NavigationItem {
  final IconData icon;
  final String label;
  final String destination;
  
  NavigationItem({
    required this.icon,
    required this.label,
    required this.destination,
  });
} 