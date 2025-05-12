import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_providers.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_stats_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';

/// Pantalla que muestra los detalles de una academia deportiva.
/// 
/// Inspirado en el diseño de la NBA App para mostrar información clave de manera visual.
class AcademyScreen extends ConsumerStatefulWidget {
  /// ID de la academia a mostrar.
  final String academyId;

  /// Crea una instancia de [AcademyScreen].
  const AcademyScreen({required this.academyId, super.key});

  @override
  ConsumerState<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends ConsumerState<AcademyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _primaryColor = AppTheme.blackSwarm;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // No establecer el título aquí si queremos que la pantalla de miembros tenga prioridad inicial
      // O, establecer un título genérico que las sub-pantallas puedan sobrescribir.
      // Por ahora, lo comentaremos para que el título de la sub-pantalla (si se navega directamente)
      // no sea sobrescrito inmediatamente.
      // ref.read(currentScreenTitleProvider.notifier).state = 'Detalles de Academia';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academyAsync = ref.watch(academyProvider(widget.academyId));
    final goRouter = GoRouter.of(context);
    
    return Scaffold(
      body: academyAsync.when(
        data: (academy) {
          if (academy == null) {
            return Center(
              child: Text('Academia no encontrada'),
            );
          }
          
          // Actualizar el provider de academia actual
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentAcademyProvider.notifier).state = academy;
            
            // Mover la lógica de actualización del título aquí
            final currentRoutePath = goRouter.routerDelegate.currentConfiguration.uri.toString();
            final membersRoutePath = '/owner/academy/${widget.academyId}/members';
            
            // Solo actualizar el título si no estamos en la pantalla de miembros o sus sub-rutas
            if (!currentRoutePath.startsWith(membersRoutePath)) {
              ref.read(currentScreenTitleProvider.notifier).state = academy.name;
            } else {
              // Si estamos en la pantalla de miembros, asegurarnos de que su título persista
              // Esto puede ser redundante si AcademyMembersScreen lo hace en su initState,
              // pero es una salvaguarda.
              if (ref.read(currentScreenTitleProvider) != 'Miembros de la Academia') {
                ref.read(currentScreenTitleProvider.notifier).state = 'Miembros de la Academia';
              }
            }
          });
          
          // Usar color primario de la academia si existe
          _primaryColor = AppTheme.bonfireRed;
          
          return _buildAcademyDetails(academy);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          AppLogger.logError(
            message: 'Error al cargar academia: ${widget.academyId}',
            error: error,
            stackTrace: stack,
          );
          return Center(
            child: Text('Error al cargar la academia: $error'),
          );
        },
      ),
    );
  }
  
  Widget _buildAcademyDetails(AcademyModel academy) {
    final stats = ref.watch(academyStatsProvider(academy.id!));
    
    return CustomScrollView(
      slivers: [
        // AppBar con gradiente y efectos
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: _primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              academy.name,
              style: TextStyle(
                color: AppTheme.magnoliaWhite,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _primaryColor.withAlpha(170),
                    _primaryColor,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Imagen de fondo (logo de la academia)
                  if (academy.logoUrl != null)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.network(
                          academy.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(),
                        ),
                      ),
                    ),
                  
                  // Logo de la academia
                  Positioned(
                    right: 20,
                    bottom: 60,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.magnoliaWhite,
                      child: academy.logoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                academy.logoUrl!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  Icon(Icons.sports, size: 40, color: _primaryColor),
                              ),
                            )
                          : Icon(Icons.sports, size: 40, color: _primaryColor),
                    ),
                  ),
                  
                  // Posición o estatus 
                  Positioned(
                    left: 20,
                    top: 60,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.magnoliaWhite.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        academy.sportCode,
                        style: TextStyle(
                          color: AppTheme.magnoliaWhite,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.magnoliaWhite),
              onPressed: () {
                // Navegar a la edición de academia
                context.go('/manager/academy/${academy.id}/edit');
              },
            ),
          ],
        ),
        
        // Sección de estadísticas estilo NBA
        SliverToBoxAdapter(
          child: Container(
            color: _primaryColor,
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                // Estadísticas principales en filas de 3
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: stats.when(
                    data: (academyStats) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('MIEMBROS', 
                          '${academyStats?.totalMembers ?? 0}', 
                          'activos'),
                        _buildStatColumn('INGRESOS', 
                          '\$${academyStats?.monthlyRevenue?.toStringAsFixed(0) ?? '0'}', 
                          'mensual'),
                        _buildStatColumn('ASISTENCIA', 
                          '${academyStats?.attendanceRate?.toStringAsFixed(0) ?? '0'}%', 
                          'promedio'),
                      ],
                    ),
                    loading: () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('MIEMBROS', '...', ''),
                        _buildStatColumn('INGRESOS', '...', ''),
                        _buildStatColumn('ASISTENCIA', '...', ''),
                      ],
                    ),
                    error: (error, stack) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('MIEMBROS', '0', ''),
                        _buildStatColumn('INGRESOS', '\$0', ''),
                        _buildStatColumn('ASISTENCIA', '0%', ''),
                      ],
                    ),
                  ),
                ),
                
                // Barra de navegación tipo pestañas
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.magnoliaWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: _primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: _primaryColor,
                    tabs: [
                      Tab(text: 'RESUMEN'),
                      Tab(text: 'HORARIOS'),
                      Tab(text: 'EQUIPOS'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Contenido de pestañas
        SliverFillRemaining(
          child: Container(
            color: Colors.white,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(academy),
                _buildScheduleTab(academy),
                _buildTeamsTab(academy),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatColumn(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.magnoliaWhite.withAlpha(170),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.magnoliaWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.magnoliaWhite.withAlpha(170),
              fontSize: 12,
            ),
          ),
      ],
    );
  }
  
  Widget _buildSummaryTab(AcademyModel academy) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (academy.description != null && academy.description!.isNotEmpty)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acerca de',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(academy.description!),
                  ],
                ),
              ),
            ),
            
          SizedBox(height: 16),
          
          // Tarjeta de información de contacto
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de contacto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (academy.email != null)
                    ListTile(
                      leading: Icon(Icons.email, color: _primaryColor),
                      title: Text('Email'),
                      subtitle: Text(academy.email!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  if (academy.phone != null)
                    ListTile(
                      leading: Icon(Icons.phone, color: _primaryColor),
                      title: Text('Teléfono'),
                      subtitle: Text(academy.phone!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  if (academy.address != null)
                    ListTile(
                      leading: Icon(Icons.location_on, color: _primaryColor),
                      title: Text('Dirección'),
                      subtitle: Text(academy.address!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Acciones rápidas
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard('Miembros', Icons.people, () {
                context.go('/manager/academy/${academy.id}/members');
              }),
              _buildActionCard('Pagos', Icons.payment, () {
                context.go('/manager/academy/${academy.id}/payments');
              }),
              _buildActionCard('Suscripciones', Icons.subscriptions, () {
                context.go('/manager/academy/${academy.id}/subscription-plans');
              }),
              _buildActionCard('Editar Detalles', Icons.edit, () {
                context.go('/manager/academy/${academy.id}/edit');
              }),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildScheduleTab(AcademyModel academy) {
    // Implementar vista de horarios
    return Center(
      child: Text('Próximamente: Horarios de la academia'),
    );
  }
  
  Widget _buildTeamsTab(AcademyModel academy) {
    // Implementar vista de equipos
    return Center(
      child: Text('Próximamente: Equipos de la academia'),
    );
  }
  
  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _primaryColor, size: 32),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 