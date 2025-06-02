import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/core/navigation/navigation_shells/manager_shell/manager_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_stats_provider.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academies/presentation/ui/widgets/custom_segmented_tabbar.dart'; // Importar el nuevo widget
import 'package:arcinus/features/academy_users_subscriptions/presentation/screens/subscription_plans_screen.dart';
import 'package:arcinus/features/academy_users_payments/presentation/screens/payment_config_screen.dart';
import 'package:arcinus/features/academy_billing/presentation/screens/billing_config_screen.dart';

/// Pantalla que muestra los detalles de una academia deportiva.
///
/// Configura el [ManagerShell] padre para tener un AppBar transparente
/// y extender el cuerpo detrás de él.
class AcademyScreen extends ConsumerStatefulWidget {
  /// ID de la academia a mostrar.
  final String academyId;

  /// Crea una instancia de [AcademyScreen].
  const AcademyScreen({required this.academyId, super.key});

  @override
  ConsumerState<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends ConsumerState<AcademyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _primaryColor = AppTheme.blackSwarm;
  bool _titleInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Aumentado a 4 tabs
  }

  void _updateTitleIfNeeded(AcademyModel academy) {
    if (!_titleInitialized && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(titleManagerProvider.notifier).updateCurrentTitle(academy.name);
          _titleInitialized = true;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // REMOVER la actualización del título aquí para evitar actualizaciones múltiples
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academyAsync = ref.watch(academyProvider(widget.academyId));

    return academyAsync.when(
      data: (academy) {
        if (academy == null) {
          return const Center(child: Text('Academia no encontrada'));
        }

        // Actualizar el título y la academia actual de forma segura
        _updateTitleIfNeeded(academy);
        
        // Establecer la academia actual de forma segura
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(currentAcademyProvider.notifier).state = academy;
          }
        });
        
        _primaryColor = AppTheme.embers; // O color de la academia si existe

        // Devolvemos el CustomScrollView que antes estaba en el body
        return _buildAcademyDetails(academy);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        AppLogger.logError(
          message: 'Error al cargar academia: ${widget.academyId}',
          error: error,
          stackTrace: stack,
        );
        return Center(child: Text('Error al cargar la academia: $error'));
      },
    );
  }

  Widget _buildAcademyDetails(AcademyModel academy) {
    final stats = ref.watch(academyStatsProvider(academy.id!));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 200, // Altura similar al SliverAppBar anterior
            decoration: BoxDecoration(color: _primaryColor),
            child: Stack(
              children: [
                // Nombre de la academia (más grande, centrado)
                Positioned(
                  // Posicionar el título donde estaba el title del FlexibleSpaceBar
                  bottom: 16, // Ajustar posición vertical
                  left: 16, // Ajustar posición horizontal
                  right: 16, // Asegurar que pueda centrarse si es necesario
                  child: Align(
                    alignment:
                        Alignment
                            .bottomLeft, // Alineación similar a FlexibleSpaceBar
                    child: Text(
                      academy.name,
                      style: TextStyle(
                        color: AppTheme.magnoliaWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        shadows: [
                          Shadow(
                            // Sombra ligera para legibilidad
                            offset: Offset(0, 1),
                            blurRadius: 2.0,
                            color: Colors.black.withAlpha(125),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Logo de la academia
                Positioned(
                  right: 20,
                  bottom: 60, // Ajustar si el nombre interfiere
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.magnoliaWhite,
                    child: ClipOval(
                      child: Image.network(
                        academy.logoUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.sports,
                              size: 40,
                              color: _primaryColor,
                            ),
                      ),
                    ),
                  ),
                ),

                // Posición o estatus
                Positioned(
                  right: 20,
                  bottom: 20, // Ajustar top considerando el AppBar transparente
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

        // Sección de estadísticas y barra de pestañas personalizada
        SliverToBoxAdapter(
          child: Container(
            color:
                _primaryColor, // Mantiene el color de fondo de la sección de stats
            padding: EdgeInsets.only(
              bottom: 0,
            ), // Sin padding inferior aquí, se maneja en CustomSegmentedTabbar
            child: Column(
              children: [
                // Estadísticas principales (sin cambios)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ), // Añadir padding vertical para stats
                  child: stats.when(
                    data:
                        (academyStats) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              'MIEMBROS',
                              '${academyStats?.totalMembers ?? 0}',
                              'activos',
                              isDynamic: academyStats != null,
                              trend: academyStats?.growthRate,
                            ),
                            _buildStatColumn(
                              'INGRESOS',
                              '\$${academyStats?.monthlyRevenue?.toStringAsFixed(0) ?? '0'}',
                              'mensual',
                              isDynamic: academyStats != null,
                              trend:
                                  academyStats?.revenueHistory.isNotEmpty ==
                                          true
                                      ? ((academyStats!
                                                      .revenueHistory
                                                      .last
                                                      .value -
                                                  academyStats
                                                      .revenueHistory[academyStats
                                                              .revenueHistory
                                                              .length -
                                                          2]
                                                      .value) /
                                              academyStats
                                                  .revenueHistory[academyStats
                                                          .revenueHistory
                                                          .length -
                                                      2]
                                                  .value) *
                                          100
                                      : null,
                            ),
                            _buildStatColumn(
                              'ASISTENCIA',
                              '${academyStats?.attendanceRate?.toStringAsFixed(0) ?? '0'}%',
                              'promedio',
                              isDynamic: academyStats != null,
                            ),
                          ],
                        ),
                    loading:
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              'MIEMBROS',
                              '...',
                              '',
                              isDynamic: false,
                            ),
                            _buildStatColumn(
                              'INGRESOS',
                              '...',
                              '',
                              isDynamic: false,
                            ),
                            _buildStatColumn(
                              'ASISTENCIA',
                              '...',
                              '',
                              isDynamic: false,
                            ),
                          ],
                        ),
                    error:
                        (error, stack) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              'MIEMBROS',
                              '0',
                              '',
                              isDynamic: false,
                            ),
                            _buildStatColumn(
                              'INGRESOS',
                              '\$0',
                              '',
                              isDynamic: false,
                            ),
                            _buildStatColumn(
                              'ASISTENCIA',
                              '0%',
                              '',
                              isDynamic: false,
                            ),
                          ],
                        ),
                  ),
                ),

                // Usar el nuevo CustomSegmentedTabbar
                CustomSegmentedTabbar(
                  controller: _tabController,
                  tabs: const ['RESUMEN', 'PLANES', 'PAGOS', 'FACTURACIÓN'],
                  selectedColor:
                      AppTheme.blackSwarm, // Negro cuando está seleccionado
                  unselectedColor:
                      AppTheme
                          .mediumGray, // Gris medio cuando no está seleccionado
                  selectedTextColor: AppTheme.magnoliaWhite, // Texto blanco
                  unselectedTextColor: AppTheme.lightGray, // Texto gris claro
                  borderRadius: 8.0, // Bordes ligeramente redondeados
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ), // Ajustar padding interno
                ),
              ],
            ),
          ),
        ),

        // Contenido de pestañas (TabBarView sin cambios)
        SliverFillRemaining(
          child: Container(
            color: AppTheme.blackSwarm,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(academy),
                _buildPlansTab(academy),
                _buildPaymentConfigTab(academy),
                _buildBillingTab(academy), // Nuevo tab de facturación
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(
    String title,
    String value,
    String subtitle, {
    bool isDynamic = true,
    double? trend,
  }) {
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color:
                    isDynamic
                        ? AppTheme.magnoliaWhite
                        : AppTheme.magnoliaWhite.withAlpha(150),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trend != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: trend > 0 ? Colors.green : Colors.red,
                  size: 14,
                ),
              ),
          ],
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
          if (academy.description.isNotEmpty)
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
                    Text(academy.description),
                  ],
                ),
              ),
            ),

          SizedBox(height: 16),

          // Tarjeta de información de contacto
          Card(
            color: AppTheme.mediumGray,
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
                  ListTile(
                    leading: Icon(Icons.email, color: _primaryColor),
                    title: Text('Email'),
                    subtitle: Text(
                      academy.email,
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: _primaryColor),
                    title: Text('Teléfono'),
                    subtitle: Text(
                      academy.phone,
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: _primaryColor),
                    title: Text('Dirección'),
                    subtitle: Text(
                      academy.address,
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab(AcademyModel academy) {
    if (academy.id == null) {
      return const Center(child: Text('ID de academia no válido'));
    }
    
    return SubscriptionPlansScreen(academyId: academy.id!);
  }

  Widget _buildPaymentConfigTab(AcademyModel academy) {
    if (academy.id == null) {
      return const Center(child: Text('ID de academia no válido'));
    }
    
    return PaymentConfigScreen(academyId: academy.id!);
  }
  
  Widget _buildBillingTab(AcademyModel academy) {
    if (academy.id == null) {
      return const Center(child: Text('ID de academia no válido'));
    }
    
    return BillingConfigScreen(academyId: academy.id!);
  }
}
