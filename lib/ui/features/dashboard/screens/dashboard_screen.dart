import 'package:arcinus/shared/constants/permissions.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/shared/navigation/navigation_service.dart';
import 'package:arcinus/ui/shared/widgets/custom_navigation_bar.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:arcinus/ux/features/permission/providers/permission_providers.dart';
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
  
  // Servicio de navegación
  final NavigationService _navigationService = NavigationService();
  
  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de página con la página del dashboard
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navegar a una página específica (notificaciones, dashboard, chat)
  void _navigateToPage(int index) {
    setState(() {
      // Actualizamos la página actual
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    
    // Obtener la ruta actual para marcar el botón activo en la barra de navegación
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/dashboard';
    
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
                // Simplemente actualizamos el estado para reflejar la página actual
                setState(() {});
              },
              children: [
                // Página de Notificaciones (índice 0)
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
                
                // Página de Chat (índice 2)
                _buildChatPage(),
              ],
            ),
          ),
          
          // Barra de navegación personalizada utilizando el componente centralizado
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavigationBar(
              pinnedItems: _navigationService.pinnedItems,
              allItems: NavigationItems.allItems,
              activeRoute: currentRoute,
              onItemTap: (item) {
                // Si es una de las páginas deslizables, navegamos con PageView
                if (item.destination == '/notifications') {
                  _navigateToPage(0);
                } else if (item.destination == '/dashboard') {
                  _navigateToPage(1);
                } else if (item.destination == '/chats') {
                  _navigateToPage(2);
                } else {
                  // Para otras rutas, usamos la navegación del servicio
                  _navigationService.navigateToRoute(context, item.destination);
                }
              },
              onItemLongPress: (item) {
                _navigationService.togglePinItem(item, context: context);
                // Actualizar el estado para reflejar los cambios
                setState(() {});
              },
            ),
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
  
  Widget _buildDashboardContent(BuildContext context, User user) {
    // El dashboard ahora se personaliza en función del contenido que el usuario puede ver según sus permisos
    // en lugar de basarse exclusivamente en el rol
    
    // Obtenemos el servicio de permisos
    final permissionService = ref.watch(permissionServiceProvider);
    
    // Widgets comunes para todos los dashboards
    final commonWidgets = <Widget>[
      // Encabezado con saludo personalizado
      Text(
        'Hola, ${user.name}',
        style: const TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold
        ),
      ),
      const SizedBox(height: 16),
      
      // Información del rol (se mantiene por claridad para el usuario)
      Text('Tu rol: ${_getUserRoleText(user.role)}', style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 24),
    ];
    
    // Widgets específicos según permisos
    final permissionBasedWidgets = <Widget>[];
    
    // Sección de academias (propietarios y managers)
    if (permissionService.hasAnyPermission([
      Permissions.manageAcademy, 
      Permissions.viewAllAcademies
    ])) {
      permissionBasedWidgets.add(_buildAcademySection(context));
      permissionBasedWidgets.add(const SizedBox(height: 24));
    }
    
    // Sección de usuarios (para quienes pueden gestionar usuarios)
    if (permissionService.hasAnyPermission([
      Permissions.manageUsers,
      Permissions.manageCoaches
    ])) {
      permissionBasedWidgets.add(_buildUsersSection(context));
      permissionBasedWidgets.add(const SizedBox(height: 24));
    }
    
    // Sección de entrenamientos (coaches o usuarios con permiso)
    if (permissionService.hasAnyPermission([
      Permissions.createTraining,
      Permissions.viewAllTrainings
    ])) {
      permissionBasedWidgets.add(_buildTrainingsSection(context));
      permissionBasedWidgets.add(const SizedBox(height: 24));
    }
    
    // Sección de estadísticas (para quienes pueden ver estadísticas)
    if (permissionService.hasAnyPermission([
      Permissions.evaluateAthletes,
      Permissions.viewAllEvaluations
    ])) {
      permissionBasedWidgets.add(_buildStatsSection(context));
      permissionBasedWidgets.add(const SizedBox(height: 24));
    }
    
    // Sección de pagos (para quienes gestionan finanzas)
    if (permissionService.hasAnyPermission([
      Permissions.managePayments,
      Permissions.viewFinancials
    ])) {
      permissionBasedWidgets.add(_buildPaymentsSection(context));
      permissionBasedWidgets.add(const SizedBox(height: 24));
    }
    
    // Si no hay widgets basados en permisos, mostrar un dashboard básico
    if (permissionBasedWidgets.isEmpty) {
      permissionBasedWidgets.add(
        const Center(
          child: Text('Bienvenido a Arcinus. Tu panel personalizado está en construcción.'),
        )
      );
    }
    
    // Combinamos widgets comunes y los específicos por permisos
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...commonWidgets,
          ...permissionBasedWidgets,
        ],
      ),
    );
  }
  
  Widget _buildAcademySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Academia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'La información de academias se está cargando...',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/academies');
                },
                icon: const Icon(Icons.school),
                label: const Text('Ver Academias'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUsersSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSimpleInfoCard(
                    title: 'Usuarios',
                    value: '...',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleInfoCard(
                    title: 'Nuevos',
                    value: '...',
                    icon: Icons.person_add,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/users-management');
                },
                icon: const Icon(Icons.manage_accounts),
                label: const Text('Gestionar Usuarios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrainingsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrenamientos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.fitness_center, size: 48, color: Colors.orange),
                  const SizedBox(height: 8),
                  const Text('Módulo de entrenamientos en desarrollo'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/trainings');
                    },
                    icon: const Icon(Icons.sports),
                    label: const Text('Ver Entrenamientos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.bar_chart, size: 48, color: Colors.purple),
                  const SizedBox(height: 8),
                  const Text('Módulo de estadísticas en desarrollo'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/stats');
                    },
                    icon: const Icon(Icons.analytics),
                    label: const Text('Ver Estadísticas'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finanzas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.payments, size: 48, color: Colors.green),
                  const SizedBox(height: 8),
                  const Text('Módulo de pagos en desarrollo'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/payments');
                    },
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Ver Finanzas'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSimpleInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
    );
  }
  
  String _getUserRoleText(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Administrador de Plataforma';
      case UserRole.owner:
        return 'Propietario de Academia';
      case UserRole.manager:
        return 'Gerente';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.athlete:
        return 'Atleta';
      case UserRole.parent:
        return 'Padre/Responsable';
      case UserRole.guest:
        return 'Invitado';
    }
  }
} 