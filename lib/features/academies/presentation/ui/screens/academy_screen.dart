import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell_config.dart'; // Importar config y provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_stats_provider.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';
import 'package:arcinus/features/academies/presentation/ui/widgets/custom_segmented_tabbar.dart'; // Importar el nuevo widget

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

class _AcademyScreenState extends ConsumerState<AcademyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _primaryColor = AppTheme.blackSwarm;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Configurar el ManagerShell. Hacemos esto en initState con addPostFrameCallback
    // para asegurarnos de que ref esté disponible y no cause problemas de build.
    // También podría hacerse en build cuando los datos estén listos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Leer la academia directamente para obtener el ID para la acción
        // Es posible que aún no esté cargada, por eso la acción debe manejarlo.
        final academy = ref.read(academyProvider(widget.academyId)).asData?.value;

        final config = ManagerShellConfig(
          extendBodyBehindAppBar: true,
          appBarBackgroundColor: Colors.transparent,
          appBarActions: [
            // Construir la acción aquí. El color se tomará de appBarIconColor.
            if (academy != null) // Solo mostrar si la academia está cargada
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar Academia',
                onPressed: () {
                  // Asegurarnos de que academy no sea null aquí también (aunque raro)
                  if (academy != null) {
                     context.go('/manager/academy/${academy.id}/edit');
                  }
                },
              )
            else // Opcional: mostrar un placeholder o nada mientras carga
              const SizedBox(width: 48), // Espacio similar a un IconButton
          ],
          appBarTitle: '', // Título vacío explícito para el AppBar
          appBarIconColor: AppTheme.magnoliaWhite, // Íconos blancos sobre fondo transparente
          appBarTitleColor: Colors.transparent, // Título transparente
        );
        // Actualizar el provider
        ref.read(managerShellConfigProvider.notifier).state = config;
      }
    });
  }

  @override
  void dispose() {
    // Resetear la configuración del ManagerShell al salir de esta pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Usamos ref.context.read para evitar errores si el widget se desmonta rápido
        // O simplemente leemos directamente el notifier si aún está montado.
        // Comprobar si el provider sigue montado antes de interactuar.
        final notifier = ref.read(managerShellConfigProvider.notifier);
        if (notifier.mounted) {
            notifier.state = null; 
        }
      } catch (e) {
        AppLogger.logWarning('Error al resetear managerShellConfigProvider en dispose: $e');
      }
    });
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academyAsync = ref.watch(academyProvider(widget.academyId));
    final goRouter = GoRouter.of(context);
    
    // Actualizar el título global cuando la academia carga
    ref.listen(academyProvider(widget.academyId), (_, next) {
      if (next is AsyncData<AcademyModel?> && next.value != null) {
        // Actualizar el título global (ManagerShell puede usarlo si appBarTitle es null en config)
        ref.read(currentScreenTitleProvider.notifier).state = next.value!.name;
        
        // Re-evaluar y potencialmente actualizar la configuración del shell si es necesario
        // (por ejemplo, si la acción de editar depende de datos que acaban de llegar)
        // Esto asegura que el botón de editar aparezca una vez cargada la academia.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
              final currentConfig = ref.read(managerShellConfigProvider);
              // Reconstruir la acción con el ID ahora disponible
              final newActions = [
                IconButton(
                  icon: const Icon(Icons.edit), // Color viene de config
                  tooltip: 'Editar Academia',
                  onPressed: () {
                     context.go('/manager/academy/${next.value!.id}/edit');
                  },
                ),
              ];
              // Actualizar solo si las acciones cambiaron (evitar bucles)
              // Nota: La comparación de listas de widgets es superficial.
              if (currentConfig?.appBarActions?.length != newActions.length) { // Comparación simple
                ref.read(managerShellConfigProvider.notifier).update((state) => 
                  state?.copyWith(appBarActions: newActions) ?? // Necesita método copyWith en ManagerShellConfig
                  // O reconstruir todo el config si no hay copyWith
                  ManagerShellConfig(
                    extendBodyBehindAppBar: true,
                    appBarBackgroundColor: Colors.transparent,
                    appBarActions: newActions,
                    appBarTitle: '',
                    appBarIconColor: AppTheme.magnoliaWhite,
                    appBarTitleColor: Colors.transparent,
                  )
                );
              }
          }
        });
      }
    });

    return academyAsync.when(
      data: (academy) {
        if (academy == null) {
          return const Center(
            child: Text('Academia no encontrada'),
          );
        }
        
        // El provider de academia actual y el color primario se manejan aquí
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
        // Considerar resetear la config del shell en caso de error también
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
              ref.read(managerShellConfigProvider.notifier).state = null;
          }
        });
        return Center(
          child: Text('Error al cargar la academia: $error'),
        );
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
            decoration: BoxDecoration(
              color: _primaryColor,
            ),
            child: Stack(
              children: [                
                
                // Nombre de la academia (más grande, centrado)
                Positioned( // Posicionar el título donde estaba el title del FlexibleSpaceBar
                  bottom: 16, // Ajustar posición vertical
                  left: 16, // Ajustar posición horizontal
                  right: 16, // Asegurar que pueda centrarse si es necesario
                  child: Align(
                    alignment: Alignment.bottomLeft, // Alineación similar a FlexibleSpaceBar
                    child: Text(
                      academy.name,
                      style: TextStyle(
                        color: AppTheme.magnoliaWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        shadows: [
                          Shadow( // Sombra ligera para legibilidad
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
                  right: 20,
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + 10, // Ajustar top considerando el AppBar transparente
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
            color: _primaryColor, // Mantiene el color de fondo de la sección de stats
            padding: EdgeInsets.only(bottom: 0), // Sin padding inferior aquí, se maneja en CustomSegmentedTabbar
            child: Column(
              children: [
                // Estadísticas principales (sin cambios)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Añadir padding vertical para stats
                  child: stats.when(
                    data: (academyStats) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('MIEMBROS', '${academyStats?.totalMembers ?? 0}', 'activos'),
                        _buildStatColumn('INGRESOS', '\$${academyStats?.monthlyRevenue?.toStringAsFixed(0) ?? '0'}', 'mensual'),
                        _buildStatColumn('ASISTENCIA', '${academyStats?.attendanceRate?.toStringAsFixed(0) ?? '0'}%', 'promedio'),
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
                
                // Usar el nuevo CustomSegmentedTabbar
                CustomSegmentedTabbar(
                  controller: _tabController,
                  tabs: const ['RESUMEN', 'HORARIOS', 'EQUIPOS'],
                  selectedColor: AppTheme.blackSwarm, // Negro cuando está seleccionado
                  unselectedColor: AppTheme.mediumGray, // Gris medio cuando no está seleccionado
                  selectedTextColor: AppTheme.magnoliaWhite, // Texto blanco
                  unselectedTextColor: AppTheme.lightGray, // Texto gris claro
                  borderRadius: 8.0, // Bordes ligeramente redondeados
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Ajustar padding interno
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
                    subtitle: Text(academy.email, style: TextStyle(color: AppTheme.lightGray)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: _primaryColor),
                    title: Text('Teléfono'),
                    subtitle: Text(academy.phone, style: TextStyle(color: AppTheme.lightGray)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: _primaryColor),
                    title: Text('Dirección'),
                    subtitle: Text(academy.address, style: TextStyle(color: AppTheme.lightGray)),
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
      color: AppTheme.mediumGray,
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
                  color: AppTheme.magnoliaWhite,
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