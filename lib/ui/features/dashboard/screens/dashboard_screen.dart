import 'package:arcinus/shared/models/academy.dart';
import 'package:arcinus/ui/features/dashboard/widgets/chat_page.dart';
import 'package:arcinus/ui/features/dashboard/widgets/notifications_page.dart';
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // Página izquierda: Chat
          ChatPage(onNavigateToDashboard: _navigateToDashboard),
          
          // Página central: Dashboard
          _buildDashboardPage(currentAcademy),
          
          // Página derecha: Notificaciones
          NotificationsPage(onNavigateToDashboard: _navigateToDashboard),
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