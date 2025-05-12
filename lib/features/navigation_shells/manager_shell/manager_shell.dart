import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/widgets/manager_drawer.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';

// Provider para manejar el título de la pantalla actual
final currentScreenTitleProvider = StateProvider<String>((ref) => 'Arcinus');

/// Widget Shell para roles de gestión (Propietario y Colaborador).
///
/// Construye la estructura base de UI para las pantallas de gestión.
class ManagerShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;
  
  /// Título opcional para la pantalla
  final String? screenTitle;

  /// Crea una instancia de [ManagerShell].
  const ManagerShell({
    super.key, 
    required this.child, 
    this.screenTitle,
  });

  @override
  ConsumerState<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends ConsumerState<ManagerShell> {
  @override
  void didUpdateWidget(ManagerShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el título cuando cambia el widget
    if (widget.screenTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentScreenTitleProvider.notifier).state = widget.screenTitle!;
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

    // Verificar que el usuario es un gestor (propietario o colaborador)
    final isManager = userRole == AppRole.propietario || userRole == AppRole.colaborador;
    if (!isManager) {
      AppLogger.logWarning(
        'Usuario con rol no autorizado intentando acceder a ManagerShell',
        className: 'ManagerShell',
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
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No tienes permisos para acceder a esta sección'),
        ),
      );
    }

    // Obtener el título actual de la pantalla
    final currentTitleFromProvider = ref.watch(currentScreenTitleProvider);
    AppLogger.logInfo(
      'ManagerShell building...',
      className: 'ManagerShell',
      functionName: 'build',
      params: {
        'widget.screenTitle': widget.screenTitle,
        'currentScreenTitleProvider': currentTitleFromProvider,
        'userRole': userRole?.name,
      },
    );
    final screenTitle = widget.screenTitle ?? currentTitleFromProvider;

    // Color del appBar según el rol (visualmente distinguible)
    final Color appBarColor = userRole == AppRole.propietario
        ? AppTheme.bonfireRed
        : AppTheme.nbaBluePrimary; // Propietario: bonfireRed, Colaborador: nbaBluePrimary

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.25,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.blackSwarm,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, size: 22),
            onPressed: () {
              // Placeholder para notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Notificaciones')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, size: 22), // Icono de mensajes
            onPressed: () {
              // Placeholder para mensajes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Mensajes')),
              );
            },
          ),
          // Badge para mostrar el rol actual
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: appBarColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userRole == AppRole.propietario ? 'Propietario' : 'Colaborador',
                style: TextStyle(
                  fontSize: AppTheme.captionSize,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.magnoliaWhite,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: ManagerDrawer(
        context: context,
        userRole: userRole,
      ),
      body: Container(
        color: AppTheme.blackSwarm,
        child: widget.child,
      ),
    );
  }
} 