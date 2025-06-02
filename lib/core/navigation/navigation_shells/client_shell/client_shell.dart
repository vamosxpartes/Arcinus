import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para manejar el título de la pantalla actual en el ClientShell
final clientScreenTitleProvider = StateProvider<String>((ref) => 'Arcinus');

/// Widget Shell para usuarios tipo cliente (Atleta y Padre).
///
/// Construye la estructura base de UI para las pantallas de usuarios cliente.
class ClientShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;
  
  /// Título opcional para la pantalla
  final String? screenTitle;

  /// Crea una instancia de [ClientShell].
  const ClientShell({
    super.key, 
    required this.child,
    this.screenTitle,
  });

  @override
  ConsumerState<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends ConsumerState<ClientShell> {
  // Índice actual de la barra de navegación inferior
  int _currentIndex = 0;
  
  @override
  void didUpdateWidget(ClientShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el título cuando cambia el widget
    if (widget.screenTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(clientScreenTitleProvider.notifier).state = widget.screenTitle!;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Obtener el usuario actual
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.user;
    final userId = user?.id;
    final userRole = user?.role;

    // Si no hay usuario, mostrar un indicador de carga
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Verificar que el usuario es un cliente (atleta o padre)
    final isClient = userRole == AppRole.atleta || userRole == AppRole.padre;
    if (!isClient) {
      AppLogger.logWarning(
        'Usuario con rol no autorizado intentando acceder a ClientShell',
        className: 'ClientShell',
        functionName: 'build',
        params: {
          'userId': userId,
          'role': userRole?.name ?? 'null',
        },
      );
      // Mostramos un mensaje de error en lugar de crashear
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso no autorizado'),
        ),
        body: const Center(
          child: Text('No tienes permisos para acceder a esta sección'),
        ),
      );
    }
    
    // A este punto, sabemos que userRole no es null
    final safeUserRole = userRole!;
    
    // Obtener el título actual de la pantalla
    final String screenTitle = widget.screenTitle ?? ref.watch(clientScreenTitleProvider);
    
    // Color del appBar según el rol (visualmente distinguible)
    final Color appBarColor = safeUserRole == AppRole.atleta
        ? Colors.green
        : Colors.orange; // Atleta: verde, Padre: naranja
    
    AppLogger.logInfo(
      'ClientShell building...',
      className: 'ClientShell',
      functionName: 'build',
      params: {
        'screenTitle': screenTitle,
        'userRole': safeUserRole.name,
      },
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: appBarColor,
        actions: [
          // Badge para mostrar el rol actual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text(
                safeUserRole == AppRole.atleta ? 'Atleta' : 'Padre',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              backgroundColor: appBarColor.withAlpha(178),
              visualDensity: VisualDensity.compact,
            ),
          ),
          // Botón de notificaciones
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Notificaciones')),
              );
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: appBarColor,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Horarios',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Pagos',
          ),
          if (safeUserRole == AppRole.padre) // Opción exclusiva para padres
            const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Mis Atletas',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
  
  // Manejar tap en la barra de navegación inferior
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Obtener el rol del usuario
    final userRole = ref.read(authStateNotifierProvider).user?.role;
    
    // Implementar la navegación según la pestaña seleccionada
    switch (index) {
      case 0: // Inicio
        _navigateToTab('/client/dashboard');
        break;
      case 1: // Horarios
        _navigateToTab('/client/schedule');
        break;
      case 2: // Pagos
        _navigateToTab('/client/payments');
        break;
      case 3: // Mis Atletas (solo para padres) o Perfil (para atletas)
        if (userRole == AppRole.padre) {
          _navigateToTab('/client/my-athletes');
        } else {
          _navigateToTab('/client/profile');
        }
        break;
      case 4: // Perfil (solo para padres, para atletas es 3)
        if (userRole == AppRole.padre) {
          _navigateToTab('/client/profile');
        }
        break;
    }
  }
  
  // Navegar a una ruta específica
  void _navigateToTab(String route) {
    // Por ahora, solo registramos la navegación
    // La implementación completa requerirá actualizar el router
    AppLogger.logInfo(
      'Intento de navegación mediante tab',
      className: 'ClientShell',
      functionName: '_navigateToTab',
      params: {'route': route},
    ); 
  }
} 