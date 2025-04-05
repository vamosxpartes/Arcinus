import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcinus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            tooltip: 'Mi perfil',
          ),
        ],
      ),
      drawer: Drawer(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error al cargar')),
          data: (user) {
            if (user == null) {
              return const Center(child: Text('No autenticado'));
            }
            
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user.name),
                  accountEmail: Text(user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withAlpha(30),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Inicio'),
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                
                if (user.role == UserRole.owner || user.role == UserRole.manager)
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Gestionar usuarios'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/users-management');
                    },
                  ),
                
                if (user.role == UserRole.owner || user.role == UserRole.manager || user.role == UserRole.coach)
                  ListTile(
                    leading: const Icon(Icons.sports),
                    title: const Text('Entrenamientos'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navegación a entrenamientos
                    },
                  ),
                
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navegación a configuración
                  },
                ),
                
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authStateProvider.notifier).signOut();
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No hay usuario autenticado'));
          }
          
          return _buildDashboardContent(context, user);
        },
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
            _buildAcademiesSection(context, user),
          
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
                'Añadir entrenador', 
                Icons.person_add, 
                Colors.blue,
                () {
                  // Navegación para añadir entrenador
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
              _buildActionCard(
                context, 
                'Crear grupo', 
                Icons.group_add, 
                Colors.green,
                () {
                  // Navegación para crear grupo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
              _buildActionCard(
                context, 
                'Registrar atleta', 
                Icons.sports, 
                Colors.orange,
                () {
                  // Navegación para registrar atleta
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad no implementada')),
                  );
                },
              ),
              _buildActionCard(
                context, 
                'Ver estadísticas', 
                Icons.bar_chart, 
                Colors.purple,
                () {
                  // Navegación a estadísticas
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
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
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
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.add_business, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Crea tu primera academia',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Comienza a gestionar tu academia deportiva con todas las herramientas que necesitas',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
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
  
  Widget _buildAcademiesSection(BuildContext context, User user) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis academias',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Gestionar mis academias'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad no implementada')),
              );
            },
          ),
        ),
      ],
    );
  }
} 