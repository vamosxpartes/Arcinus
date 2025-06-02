import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/navigation/navigation_shells/super_admin_shell/super_admin_shell.dart';

/// Pantalla principal del dashboard de Arcinus Manager
/// 
/// Proporciona una vista general del sistema con:
/// - Estadísticas globales
/// - Alertas críticas  
/// - Métricas de rendimiento
/// - Acceso rápido a funciones principales
class ArcinusManagerDashboardScreen extends ConsumerStatefulWidget {
  const ArcinusManagerDashboardScreen({super.key});

  @override
  ConsumerState<ArcinusManagerDashboardScreen> createState() => _ArcinusManagerDashboardScreenState();
}

class _ArcinusManagerDashboardScreenState extends ConsumerState<ArcinusManagerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Configurar título de pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(superAdminScreenTitleProvider.notifier).state = 'Dashboard Principal';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjetas de estadísticas principales
              _buildStatisticsCards(),
              
              const SizedBox(height: 24),
              
              // Alertas críticas
              _buildCriticalAlertsSection(),
              
              const SizedBox(height: 24),
              
              // Métricas de rendimiento
              _buildPerformanceMetricsSection(),
              
              const SizedBox(height: 24),
              
              // Accesos rápidos
              _buildQuickActionsSection(),
              
              const SizedBox(height: 24),
              
              // Resumen de actividad reciente
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye las tarjetas de estadísticas principales
  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas del Sistema',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Total Academias',
              value: '248',
              subtitle: '+12 este mes',
              icon: Icons.school,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'Usuarios Activos',
              value: '15,234',
              subtitle: '+1,205 este mes',
              icon: Icons.people,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'Ingresos Totales',
              value: '\$142,580',
              subtitle: '+8.2% vs mes anterior',
              icon: Icons.attach_money,
              color: Colors.orange,
            ),
            _buildStatCard(
              title: 'Rendimiento',
              value: '99.8%',
              subtitle: 'Uptime del sistema',
              icon: Icons.speed,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  /// Construye una tarjeta de estadística individual
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la sección de alertas críticas
  Widget _buildCriticalAlertsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alertas Críticas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: const Text('3'),
                  backgroundColor: Colors.red,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAlertItem(
              title: 'Múltiples fallos de login - Academia Delta Sports',
              severity: 'CRÍTICO',
              time: 'Hace 5 minutos',
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            _buildAlertItem(
              title: 'Uso elevado de almacenamiento - Sistema Global',
              severity: 'ALTO',
              time: 'Hace 15 minutos',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildAlertItem(
              title: 'Pagos pendientes - 12 academias afectadas',
              severity: 'MEDIO',
              time: 'Hace 1 hora',
              color: Colors.amber.shade700,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navegar a vista completa de alertas
                },
                child: const Text('Ver Todas las Alertas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un elemento de alerta individual
  Widget _buildAlertItem({
    required String title,
    required String severity,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        severity,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Resolver alerta
            },
            icon: const Icon(Icons.check_circle_outline),
            color: color,
          ),
        ],
      ),
    );
  }

  /// Construye la sección de métricas de rendimiento
  Widget _buildPerformanceMetricsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas de Rendimiento',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    label: 'Tiempo de Respuesta',
                    value: '145ms',
                    trend: 'Bueno',
                    trendColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    label: 'Peticiones/min',
                    value: '2,847',
                    trend: 'Normal',
                    trendColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    label: 'Tasa de Error',
                    value: '0.12%',
                    trend: 'Excelente',
                    trendColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    label: 'CPU Usage',
                    value: '34%',
                    trend: 'Normal',
                    trendColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un elemento de métrica individual
  Widget _buildMetricItem({
    required String label,
    required String value,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: trendColor,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye la sección de acciones rápidas
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildQuickActionCard(
              title: 'Gestionar Academias',
              subtitle: 'Ver, suspender, transferir',
              icon: Icons.school,
              onTap: () {
                // Navegar a gestión de academias
              },
            ),
            _buildQuickActionCard(
              title: 'Super Administradores',
              subtitle: 'Promover, revocar permisos',
              icon: Icons.admin_panel_settings,
              onTap: () {
                // Navegar a gestión de super admins
              },
            ),
            _buildQuickActionCard(
              title: 'Logs de Auditoría',
              subtitle: 'Ver actividad del sistema',
              icon: Icons.history,
              onTap: () {
                // Navegar a logs de auditoría
              },
            ),
            _buildQuickActionCard(
              title: 'Exportar Datos',
              subtitle: 'Generar reportes',
              icon: Icons.download,
              onTap: () {
                // Abrir diálogo de exportación
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Construye una tarjeta de acción rápida
  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  /// Construye la sección de actividad reciente
  Widget _buildRecentActivitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad Reciente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              action: 'Academia suspendida',
              target: 'SportCenter Elite',
              user: 'admin@arcinus.com',
              time: 'Hace 2 horas',
              icon: Icons.pause_circle,
              color: Colors.orange,
            ),
            const Divider(),
            _buildActivityItem(
              action: 'Propietario transferido',
              target: 'Football Academy Pro',
              user: 'superadmin@arcinus.com',
              time: 'Hace 4 horas',
              icon: Icons.transfer_within_a_station,
              color: Colors.blue,
            ),
            const Divider(),
            _buildActivityItem(
              action: 'Nuevo super administrador',
              target: 'Maria González',
              user: 'ceo@arcinus.com',
              time: 'Hace 1 día',
              icon: Icons.person_add,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navegar a logs completos
                },
                child: const Text('Ver Historial Completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un elemento de actividad
  Widget _buildActivityItem({
    required String action,
    required String target,
    required String user,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: action,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ': '),
                      TextSpan(
                        text: target,
                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Por $user • $time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Ver detalles
            },
            icon: const Icon(Icons.info_outline),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  /// Refresca los datos del dashboard
  Future<void> _refreshDashboard() async {
    // Simular recarga de datos
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard actualizado'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
} 