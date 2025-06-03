import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/super_admin/presentation/providers/owners_management_provider.dart';

/// Pantalla de detalles de un propietario específico
/// 
/// Muestra información completa del propietario, su academia,
/// métricas de actividad e historial.
class OwnerDetailsScreen extends ConsumerStatefulWidget {
  const OwnerDetailsScreen({
    super.key,
    required this.ownerId,
  });

  final String ownerId;

  @override
  ConsumerState<OwnerDetailsScreen> createState() => _OwnerDetailsScreenState();
}

class _OwnerDetailsScreenState extends ConsumerState<OwnerDetailsScreen> {
  OwnerData? owner;

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'Pantalla de detalles del propietario inicializada',
      className: 'OwnerDetailsScreen',
      functionName: 'initState',
      params: {'ownerId': widget.ownerId},
    );
    
    _loadOwnerData();
  }

  /// Carga los datos del propietario
  void _loadOwnerData() {
    final state = ref.read(ownersManagementProvider);
    owner = state.owners.firstWhere(
      (o) => o.id == widget.ownerId,
      orElse: () => state.filteredOwners.firstWhere(
        (o) => o.id == widget.ownerId,
        orElse: () => throw Exception('Propietario no encontrado'),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (owner == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Propietario'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Propietario no encontrado'),
            ],
          ),
        ),
      );
    }

    AppLogger.logInfo(
      'Building OwnerDetailsScreen',
      className: 'OwnerDetailsScreen',
      functionName: 'build',
      params: {
        'ownerName': '${owner!.firstName} ${owner!.lastName}',
        'ownerStatus': owner!.status.toString(),
      },
    );

    return Scaffold(
      backgroundColor: AppTheme.magnoliaWhite,
      body: CustomScrollView(
        slivers: [
          // App Bar con información básica
          _buildSliverAppBar(),
          
          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información personal
                  _buildPersonalInfoCard(),
                  const SizedBox(height: 16),
                  
                  // Información de la academia
                  if (owner!.academy != null) ...[
                    _buildAcademyInfoCard(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Métricas y estadísticas
                  _buildMetricsCards(),
                  const SizedBox(height: 16),
                  
                  // Actividad reciente
                  _buildActivityCard(),
                  const SizedBox(height: 16),
                  
                  // Acciones de administrador
                  _buildAdminActionsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el SliverAppBar con información del propietario
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.deepPurple.shade600,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${owner!.firstName} ${owner!.lastName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade600,
                Colors.deepPurple.shade800,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withAlpha(50),
                      backgroundImage: owner!.profileImageUrl != null
                          ? NetworkImage(owner!.profileImageUrl!)
                          : null,
                      child: owner!.profileImageUrl == null
                          ? Text(
                              _getInitials(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    
                    // Información básica
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32), // Espacio para el título
                          Text(
                            owner!.email,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la tarjeta de información personal
  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.deepPurple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Nombre Completo', '${owner!.firstName} ${owner!.lastName}'),
            _buildInfoRow('Email', owner!.email),
            if (owner!.phoneNumber != null)
              _buildInfoRow('Teléfono', owner!.phoneNumber!),
            _buildInfoRow('Fecha de Registro', _formatDate(owner!.createdAt)),
            if (owner!.lastLoginAt != null)
              _buildInfoRow('Último Acceso', _formatDateTime(owner!.lastLoginAt!)),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta de información de la academia
  Widget _buildAcademyInfoCard() {
    final academy = owner!.academy!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: Colors.deepPurple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Academia Asociada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildAcademyStatusBadge(academy.status),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Nombre', academy.name),
            _buildInfoRow('Deporte', academy.sport),
            _buildInfoRow('Ubicación', '${academy.city}, ${academy.country}'),
            
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Navegar a detalles de la academia
                AppLogger.logInfo(
                  'Navegando a detalles de academia',
                  className: 'OwnerDetailsScreen',
                  functionName: '_buildAcademyInfoCard',
                  params: {'academyId': academy.id},
                );
              },
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Ver Academia'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye las tarjetas de métricas
  Widget _buildMetricsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas de Rendimiento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Usuarios Totales',
                owner!.totalUsers.toString(),
                Icons.people_outline,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Usuarios Activos',
                owner!.activeUsers.toString(),
                Icons.people_alt_outlined,
                Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Ingresos Mensuales',
                _formatCurrency(owner!.monthlyRevenue),
                Icons.attach_money_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Tasa de Actividad',
                '${_calculateActivityRate()}%',
                Icons.trending_up_outlined,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la tarjeta de actividad reciente
  Widget _buildActivityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_outlined, color: Colors.deepPurple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Simulación de actividad reciente
            _buildActivityItem(
              'Inicio de sesión',
              owner!.lastLoginAt ?? DateTime.now(),
              Icons.login_outlined,
              Colors.green,
            ),
            _buildActivityItem(
              'Registro en la plataforma',
              owner!.createdAt,
              Icons.person_add_outlined,
              Colors.blue,
            ),
            if (owner!.lastActivityAt != null)
              _buildActivityItem(
                'Última actividad',
                owner!.lastActivityAt!,
                Icons.touch_app_outlined,
                Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta de acciones de administrador
  Widget _buildAdminActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, color: Colors.deepPurple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Acciones de Administrador',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botones de acción
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (owner!.status != OwnerStatus.active)
                  _buildActionButton(
                    'Activar',
                    Icons.check_circle_outline,
                    Colors.green,
                    () => _changeStatus(OwnerStatus.active),
                  ),
                if (owner!.status != OwnerStatus.inactive)
                  _buildActionButton(
                    'Desactivar',
                    Icons.pause_circle_outline,
                    Colors.orange,
                    () => _changeStatus(OwnerStatus.inactive),
                  ),
                if (owner!.status != OwnerStatus.suspended)
                  _buildActionButton(
                    'Suspender',
                    Icons.block_outlined,
                    Colors.red,
                    () => _changeStatus(OwnerStatus.suspended),
                  ),
                _buildActionButton(
                  'Enviar Mensaje',
                  Icons.message_outlined,
                  Colors.blue,
                  () => _sendMessage(),
                ),
                _buildActionButton(
                  'Ver Logs',
                  Icons.receipt_long_outlined,
                  Colors.purple,
                  () => _viewLogs(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de métrica
  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un item de actividad
  Widget _buildActivityItem(String title, DateTime date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withAlpha(30),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatRelativeTime(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un botón de acción
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Construye el badge de estado del propietario
  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (owner!.status) {
      case OwnerStatus.active:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Activo';
        break;
      case OwnerStatus.inactive:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Inactivo';
        break;
      case OwnerStatus.suspended:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Suspendido';
        break;
      case OwnerStatus.pending:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Pendiente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Construye el badge de estado de la academia
  Widget _buildAcademyStatusBadge(AcademyStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case AcademyStatus.active:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Activa';
        break;
      case AcademyStatus.inactive:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Inactiva';
        break;
      case AcademyStatus.suspended:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Suspendida';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Cambia el estado del propietario
  void _changeStatus(OwnerStatus newStatus) {
    AppLogger.logInfo(
      'Cambiando estado del propietario',
      className: 'OwnerDetailsScreen',
      functionName: '_changeStatus',
      params: {
        'ownerId': owner!.id,
        'currentStatus': owner!.status.toString(),
        'newStatus': newStatus.toString(),
      },
    );

    ref.read(ownersManagementProvider.notifier).changeOwnerStatus(owner!.id, newStatus);
    
    // Actualizar el estado local
    setState(() {
      owner = owner!.copyWith(status: newStatus);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado actualizado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Envía un mensaje al propietario
  void _sendMessage() {
    AppLogger.logInfo(
      'Enviando mensaje al propietario',
      className: 'OwnerDetailsScreen',
      functionName: '_sendMessage',
      params: {'ownerId': owner!.id},
    );

    // TODO: Implementar funcionalidad de mensajería
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de mensajería en desarrollo'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Ve los logs del propietario
  void _viewLogs() {
    AppLogger.logInfo(
      'Viendo logs del propietario',
      className: 'OwnerDetailsScreen',
      functionName: '_viewLogs',
      params: {'ownerId': owner!.id},
    );

    // TODO: Implementar vista de logs
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vista de logs en desarrollo'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  /// Obtiene las iniciales del nombre
  String _getInitials() {
    return '${owner!.firstName.isNotEmpty ? owner!.firstName[0] : ''}${owner!.lastName.isNotEmpty ? owner!.lastName[0] : ''}'.toUpperCase();
  }

  /// Calcula la tasa de actividad
  int _calculateActivityRate() {
    if (owner!.totalUsers == 0) return 0;
    return ((owner!.activeUsers / owner!.totalUsers) * 100).round();
  }

  /// Formatea fecha
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea fecha y hora
  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formatea tiempo relativo
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  /// Formatea moneda
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
} 