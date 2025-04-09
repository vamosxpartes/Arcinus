import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/ux/features/academy/academy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late PageController _pageController;
  int _currentPage = 1; // Inicia en la página central (dashboard)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAcademy = ref.watch(currentAcademyProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(currentAcademy?.name ?? 'Dashboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Página izquierda: Chat
                _buildChatPage(),
                
                // Página central: Dashboard
                _buildDashboardPage(currentAcademy),
                
                // Página derecha: Notificaciones
                _buildNotificationsPage(),
              ],
            ),
          ),
          // Indicador de páginas
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    width: i == _currentPage ? 16.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: i == _currentPage 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.primary.withAlpha(100),
                    ),
                  ),
              ],
            ),
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
            onPressed: _navigateToDashboard,
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
            onPressed: _navigateToDashboard,
            child: const Text('Ir al Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPage(Academy? currentAcademy) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicadores de deslizamiento
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Notificaciones',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            
            if (currentAcademy == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No hay academia seleccionada',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu academia debería cargarse automáticamente.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Invalidar los providers relevantes para forzar una recarga
                          ref.invalidate(userAcademiesProvider);
                          ref.invalidate(autoLoadAcademyProvider);
                          
                          // Mostrar snackbar de recarga en progreso
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recargando información de academia...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recargar'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Grupos',
                    icon: Icons.group,
                    color: Colors.blue,
                    count: '3',
                    onTap: () {
                      // Navegar a la pestaña de grupos (índice 2)
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Entrenadores',
                    icon: Icons.sports,
                    color: Colors.green,
                    count: '2',
                    onTap: () {
                      // Navegar a pantalla de entrenadores
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Atletas',
                    icon: Icons.fitness_center,
                    color: Colors.orange,
                    count: '12',
                    onTap: () {
                      // Navegar a pantalla de atletas
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Eventos',
                    icon: Icons.event,
                    color: Colors.purple,
                    count: '5',
                    onTap: () {
                      // Navegar a calendario (índice 1)
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: $count',
                      style: TextStyle(
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
} 