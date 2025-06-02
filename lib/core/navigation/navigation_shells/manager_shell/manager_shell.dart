import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arcinus/core/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/core/navigation/navigation_shells/manager_shell/widgets/manager_drawer.dart';
import 'package:arcinus/core/navigation/navigation_shells/manager_shell/widgets/manager_app_bar.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';

// Provider para manejar el título de la pantalla actual
final currentScreenTitleProvider = StateProvider<String>((ref) => 'Arcinus');

// Provider para manejar un stack de títulos para restaurar al hacer pop
final titleStackProvider = StateProvider<List<String>>((ref) => ['Arcinus']);

// Provider para manejar el título con stack
final titleManagerProvider = StateNotifierProvider<TitleManager, String>((ref) {
  return TitleManager();
});

/// Clase para manejar el stack de títulos
class TitleManager extends StateNotifier<String> {
  final List<String> _titleStack = ['Arcinus'];
  
  TitleManager() : super('Arcinus');
  
  /// Empuja un nuevo título al stack
  void pushTitle(String title) {
    _titleStack.add(title);
    state = title;
  }
  
  /// Hace pop del título actual y restaura el anterior
  String popTitle() {
    if (_titleStack.length > 1) {
      _titleStack.removeLast();
      state = _titleStack.last;
    }
    return state;
  }
  
  /// Actualiza el título actual sin afectar el stack
  void updateCurrentTitle(String title) {
    if (_titleStack.isNotEmpty) {
      _titleStack[_titleStack.length - 1] = title;
      state = title;
    }
  }
  
  /// Obtiene el título actual
  String get currentTitle => state;
  
  /// Limpia el stack y establece un título base
  void resetToTitle(String title) {
    _titleStack.clear();
    _titleStack.add(title);
    state = title;
  }
}

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

    // Usar el TitleManager para obtener el título actual
    final currentTitle = ref.watch(titleManagerProvider);
    final finalTitle = widget.screenTitle ?? currentTitle;
    
    // Detectar si estamos en el dashboard para mostrar iconos de notificaciones
    final isDashboard = finalTitle.contains('Panel') || finalTitle.contains('Dashboard') || finalTitle == 'Panel de control';
    
    // Detectar si podemos hacer pop (hay pantallas en el stack)
    final canPop = Navigator.of(context).canPop();
    
    AppLogger.logInfo(
      'ManagerShell building...',
      className: 'ManagerShell',
      functionName: 'build',
      params: {
        'widget.screenTitle': widget.screenTitle,
        'currentTitle': currentTitle,
        'finalTitle': finalTitle,
        'userRole': userRole?.name,
        'isDashboard': isDashboard,
        'canPop': canPop,
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
        showNotificationIcons: isDashboard, // Solo mostrar en dashboard
      ),
      // Solo mostrar drawer si no podemos hacer pop
      drawer: canPop ? null : ManagerDrawer(
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