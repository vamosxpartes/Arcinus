import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/super_admin/presentation/providers/super_admin_dashboard_provider.dart';
import 'package:arcinus/features/super_admin/presentation/widgets/platform_metrics_card.dart';
import 'package:arcinus/features/super_admin/presentation/widgets/system_alerts_card.dart';
import 'package:arcinus/features/super_admin/presentation/widgets/quick_actions_card.dart';
import 'package:arcinus/features/super_admin/presentation/widgets/activity_overview_card.dart';

/// Pantalla del Dashboard del SuperAdmin
/// 
/// Proporciona una vista integral de métricas globales, alertas del sistema,
/// y acciones rápidas para la administración de la plataforma Arcinus.
class SuperAdminDashboardScreen extends ConsumerStatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  ConsumerState<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends ConsumerState<SuperAdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'SuperAdmin Dashboard inicializado',
      className: 'SuperAdminDashboardScreen',
      functionName: 'initState',
    );
    
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(superAdminDashboardProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(superAdminDashboardProvider);
    
    AppLogger.logInfo(
      'Building SuperAdminDashboardScreen - Dashboard loaded',
      className: 'SuperAdminDashboardScreen',
      functionName: 'build',
    );
    
    return Scaffold(
      backgroundColor: AppTheme.magnoliaWhite,
      body: RefreshIndicator(
        onRefresh: () async {
          AppLogger.logInfo(
            'Refrescando dashboard',
            className: 'SuperAdminDashboardScreen', 
            functionName: 'onRefresh',
          );
          await ref.read(superAdminDashboardProvider.notifier).refreshDashboard();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y fecha
              _buildHeader(),
              const SizedBox(height: 24),
              
              // Métricas principales en grid
              _buildMetricsGrid(dashboardState),
              const SizedBox(height: 24),
              
              // Alertas del sistema
              const SystemAlertsCard(),
              const SizedBox(height: 24),
              
              // Row con acciones rápidas y actividad
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Acciones rápidas
                    Expanded(
                      flex: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 200,
                          maxHeight: 600,
                        ),
                        child: const QuickActionsCard(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Resumen de actividad
                    Expanded(
                      flex: 2,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 200,
                          maxHeight: 600,
                        ),
                        child: const ActivityOverviewCard(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Gráficos y estadísticas adicionales
              _buildAnalyticsSection(dashboardState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade600,
            Colors.deepPurple.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de SuperAdmin',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Administración Global de Arcinus',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white.withAlpha(200),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatCurrentDate(),
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(SuperAdminDashboardState state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        PlatformMetricsCard(
          title: 'Total Propietarios',
          value: state.totalOwners.toString(),
          icon: Icons.person_outline,
          color: Colors.blue,
          subtitle: '${state.pendingOwners} pendientes',
          onTap: () => _navigateToOwners(),
        ),
        PlatformMetricsCard(
          title: 'Academias Activas',
          value: state.totalAcademies.toString(),
          icon: Icons.school_outlined,
          color: Colors.green,
          subtitle: '${state.activeAcademies} activas',
          onTap: () => _navigateToAcademies(),
        ),
        PlatformMetricsCard(
          title: 'Usuarios Globales',
          value: state.totalUsers.toString(),
          icon: Icons.people_outline,
          color: Colors.orange,
          subtitle: '${state.activeUsers} activos',
          onTap: () => _navigateToUsers(),
        ),
        PlatformMetricsCard(
          title: 'Ingresos MRR',
          value: '\$${state.monthlyRevenue.toStringAsFixed(0)}',
          icon: Icons.monetization_on_outlined,
          color: Colors.purple,
          subtitle: '${state.revenueGrowth > 0 ? '+' : ''}${state.revenueGrowth.toStringAsFixed(1)}%',
          onTap: () => _navigateToPayments(),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(SuperAdminDashboardState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Análisis de Uso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton.icon(
                    onPressed: _navigateToAnalytics,
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('Ver detalles'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Placeholder para gráficos de analytics
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gráficos de Analytics',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Implementación pendiente',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // Métodos de navegación
  void _navigateToOwners() {
    AppLogger.logInfo(
      'Navegando a gestión de propietarios',
      className: 'SuperAdminDashboardScreen',
      functionName: '_navigateToOwners',
    );
    context.go('/superadmin/owners');
  }

  void _navigateToAcademies() {
    AppLogger.logInfo(
      'Navegando a gestión de academias',
      className: 'SuperAdminDashboardScreen',
      functionName: '_navigateToAcademies',
    );
    // TODO: Implementar navegación a SuperAdminRoutes.academies
  }

  void _navigateToUsers() {
    AppLogger.logInfo(
      'Navegando a gestión de usuarios',
      className: 'SuperAdminDashboardScreen',
      functionName: '_navigateToUsers',
    );
    // TODO: Implementar navegación a SuperAdminRoutes.users
  }

  void _navigateToPayments() {
    AppLogger.logInfo(
      'Navegando a gestión de pagos',
      className: 'SuperAdminDashboardScreen',
      functionName: '_navigateToPayments',
    );
    // TODO: Implementar navegación a SuperAdminRoutes.subscriptionBilling
  }

  void _navigateToAnalytics() {
    AppLogger.logInfo(
      'Navegando a analytics detallados',
      className: 'SuperAdminDashboardScreen',
      functionName: '_navigateToAnalytics',
    );
    // TODO: Implementar navegación a SuperAdminRoutes.analytics
  }
} 