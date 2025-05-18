import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/academy_stats_provider.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';

/// Provider para obtener anuncios de la aplicación
final appAnnouncementsProvider = FutureProvider<List<AppAnnouncement>>((ref) async {
  // Simulamos una carga de datos
  await Future.delayed(const Duration(seconds: 1));
  
  // En una implementación real, estos datos vendrían de Firestore
  return [
    AppAnnouncement(
      id: '1',
      title: 'Nueva función de estadísticas',
      description: 'Ahora puedes ver estadísticas detalladas de tu academia en el Dashboard.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      priority: AnnouncementPriority.high,
      icon: Icons.insights,
    ),
    AppAnnouncement(
      id: '2',
      title: 'Mejoras en la gestión de miembros',
      description: 'Hemos mejorado la interfaz para añadir y gestionar miembros de tus academias.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      priority: AnnouncementPriority.medium,
      icon: Icons.people,
    ),
    AppAnnouncement(
      id: '3',
      title: 'Próximamente: Calendario de eventos',
      description: 'Estamos trabajando en un nuevo calendario para gestionar los eventos de tu academia.',
      date: DateTime.now().subtract(const Duration(days: 10)),
      priority: AnnouncementPriority.low,
      icon: Icons.calendar_today,
    ),
  ];
});

/// Modelo para representar un anuncio en la aplicación
class AppAnnouncement {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final AnnouncementPriority priority;
  final IconData icon;
  
  AppAnnouncement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.icon,
  });
}

/// Prioridad de un anuncio
enum AnnouncementPriority { low, medium, high }

/// Pantalla de inicio para el Manager
class ManagerHomeScreen extends ConsumerStatefulWidget {
  /// Constructor de ManagerHomeScreen
  const ManagerHomeScreen({super.key});

  @override
  ConsumerState<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends ConsumerState<ManagerHomeScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Establecer el título de la pantalla
      ref.read(currentScreenTitleProvider.notifier).state = 'Mis Academias';
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    final username = 'Administrador'; // En una implementación real, obtendríamos el nombre del usuario
    
    return Scaffold(
      backgroundColor: AppTheme.blackSwarm,
      body: RefreshIndicator(
        color: AppTheme.embers,
        onRefresh: () async {
          // Recargar datos
          ref.refresh(appAnnouncementsProvider);
          if (currentAcademy != null) {
            ref.refresh(academyStatsProvider(currentAcademy.id!));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de bienvenida
                _buildWelcomeSection(username, currentAcademy?.name),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                _buildQuickActionsSection(context),
                
                const SizedBox(height: 24),
                
                // Sección de anuncios
                _buildAnnouncementsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection(String username, String? academyName) {
    final now = DateTime.now();
    String greeting;
    
    // Determinar saludo según la hora del día
    if (now.hour < 12) {
      greeting = '¡Buenos días';
    } else if (now.hour < 18) {
      greeting = '¡Buenas tardes';
    } else {
      greeting = '¡Buenas noches';
    }
    
    return Card(
      color: AppTheme.embers,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, $username!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.magnoliaWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        academyName != null 
                            ? 'Academia actual: $academyName' 
                            : 'No has seleccionado una academia',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.magnoliaWhite.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.blackSwarm,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.magnoliaWhite,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (academyName != null)
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar al dashboard
                  context.go('/manager/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blackSwarm,
                  foregroundColor: AppTheme.magnoliaWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.dashboard),
                label: const Text('Ver dashboard'),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar a selección de academia
                  context.go('/manager/academies');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blackSwarm,
                  foregroundColor: AppTheme.magnoliaWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.sports),
                label: const Text('Seleccionar academia'),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Acciones rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.magnoliaWhite,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActionCard(
              title: 'Gestionar miembros',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () {
                // Navegar a gestión de miembros
                context.go('/manager/members');
              },
            ),
            _buildActionCard(
              title: 'Ver estadísticas',
              icon: Icons.insights,
              color: Colors.purple,
              onTap: () {
                // Navegar a estadísticas
                context.go('/manager/dashboard');
              },
            ),
            _buildActionCard(
              title: 'Añadir academia',
              icon: Icons.add_circle,
              color: Colors.green,
              onTap: () {
                // Navegar a crear academia
                context.go('/manager/academies/create');
              },
            ),
            _buildActionCard(
              title: 'Configuración',
              icon: Icons.settings,
              color: Colors.orange,
              onTap: () {
                // Navegar a configuración
                context.go('/manager/settings');
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.magnoliaWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnnouncementsSection() {
    final announcementsAsync = ref.watch(appAnnouncementsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Anuncios y novedades',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.magnoliaWhite,
            ),
          ),
        ),
        announcementsAsync.when(
          data: (announcements) {
            if (announcements.isEmpty) {
              return const Card(
                color: AppTheme.mediumGray,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No hay anuncios disponibles',
                      style: TextStyle(color: AppTheme.magnoliaWhite),
                    ),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: AppTheme.embers,
              ),
            ),
          ),
          error: (error, stack) {
            AppLogger.logError(
              message: 'Error al cargar anuncios',
              error: error,
              stackTrace: stack,
            );
            return Card(
              color: AppTheme.mediumGray,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Error al cargar anuncios: $error',
                    style: const TextStyle(color: AppTheme.magnoliaWhite),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildAnnouncementCard(AppAnnouncement announcement) {
    // Definir color según prioridad
    Color priorityColor;
    switch (announcement.priority) {
      case AnnouncementPriority.high:
        priorityColor = Colors.red;
        break;
      case AnnouncementPriority.medium:
        priorityColor = Colors.orange;
        break;
      case AnnouncementPriority.low:
        priorityColor = Colors.blue;
        break;
    }
    
    // Formatear fecha
    final day = announcement.date.day.toString().padLeft(2, '0');
    final month = announcement.date.month.toString().padLeft(2, '0');
    final dateStr = '$day/$month/${announcement.date.year}';
    
    return Card(
      color: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    announcement.icon,
                    color: priorityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.magnoliaWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.magnoliaWhite.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.description,
              style: TextStyle(
                color: AppTheme.magnoliaWhite.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 