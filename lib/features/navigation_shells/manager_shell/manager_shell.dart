import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/widgets/manager_drawer.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/widgets/manager_app_bar.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

// Provider para manejar el título de la pantalla actual
final currentScreenTitleProvider = StateProvider<String>((ref) => 'Arcinus');

/// Widget Shell para roles de gestión (Propietario y Colaborador).
///
/// Construye la estructura base de UI para las pantallas de gestión con un AppBar
/// estándar en todas las pantallas.
class ManagerShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;
  
  /// Título opcional para la pantalla, se pasará al ManagerAppBar.
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
  void initState() {
    super.initState();
    AppLogger.logInfo(
      'ManagerShell inicializado',
      className: 'ManagerShell',
      functionName: 'initState',
      params: {
        'screenTitle': widget.screenTitle,
      },
    );
  }

  @override
  void didUpdateWidget(ManagerShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar el título cuando cambia el widget
    if (widget.screenTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppLogger.logInfo(
          'Actualizando título en ManagerShell',
          className: 'ManagerShell',
          functionName: 'didUpdateWidget',
          params: {'nuevoTítulo': widget.screenTitle},
        );
        ref.read(currentScreenTitleProvider.notifier).state = widget.screenTitle!;
      });
    }
  }

  @override
  void dispose() {
    AppLogger.logInfo(
      'ManagerShell dispose',
      className: 'ManagerShell',
      functionName: 'dispose',
    );
    super.dispose();
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
    final currentScreenTitle = ref.watch(currentScreenTitleProvider);
    final finalTitle = widget.screenTitle ?? currentScreenTitle;
    
    AppLogger.logInfo(
      'ManagerShell building...',
      className: 'ManagerShell',
      functionName: 'build',
      params: {
        'widget.screenTitle': widget.screenTitle,
        'currentScreenTitle': currentScreenTitle,
        'finalTitle': finalTitle,
        'userRole': userRole?.name,
      },
    );
    
    return Scaffold(
      // Siempre usar configuración estándar para todas las pantallas
      extendBodyBehindAppBar: false, 
      appBar: ManagerAppBar(
        title: finalTitle,
        backgroundColor: AppTheme.blackSwarm,
        iconColor: AppTheme.magnoliaWhite,
        titleColor: AppTheme.magnoliaWhite,
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