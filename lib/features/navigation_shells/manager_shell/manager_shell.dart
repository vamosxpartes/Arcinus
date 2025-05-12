import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/widgets/manager_drawer.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/widgets/manager_app_bar.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell_config.dart';
import 'package:arcinus/core/utils/app_logger.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';

// Provider para manejar el título de la pantalla actual
final currentScreenTitleProvider = StateProvider<String>((ref) => 'Arcinus');

/// Widget Shell para roles de gestión (Propietario y Colaborador).
///
/// Construye la estructura base de UI para las pantallas de gestión.
/// Su apariencia puede ser configurada dinámicamente por la pantalla hija
/// a través del [managerShellConfigProvider].
class ManagerShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;
  
  /// Título opcional para la pantalla, se pasará al ManagerAppBar.
  final String? screenTitle;
  
  /// Determina si el body del Scaffold debe extenderse detrás del AppBar.
  /// Útil para pantallas con AppBar transparente o efectos visuales.
  final bool extendBodyBehindAppBar;

  /// Parámetros para configuración por defecto si no hay config del provider
  final Color defaultAppBarBackgroundColor;
  final List<Widget>? defaultAppBarActions;
  final Color defaultAppBarIconColor;
  final Color defaultAppBarTitleColor;

  /// Crea una instancia de [ManagerShell].
  const ManagerShell({
    super.key, 
    required this.child, 
    this.screenTitle,
    this.extendBodyBehindAppBar = false, // Valor por defecto es false
    this.defaultAppBarBackgroundColor = AppTheme.blackSwarm,
    this.defaultAppBarActions, // Null para usar los internos de ManagerAppBar
    this.defaultAppBarIconColor = AppTheme.magnoliaWhite,
    this.defaultAppBarTitleColor = AppTheme.magnoliaWhite,
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

    // --- Leer configuración dinámica y determinar valores finales --- 
    final shellConfig = ref.watch(managerShellConfigProvider);
    final globalScreenTitle = ref.watch(currentScreenTitleProvider);

    final bool finalExtendBody = shellConfig?.extendBodyBehindAppBar ?? widget.extendBodyBehindAppBar;
    final Color finalAppBarBgColor = shellConfig?.appBarBackgroundColor ?? widget.defaultAppBarBackgroundColor;
    final List<Widget>? finalAppBarActions = shellConfig?.appBarActions ?? widget.defaultAppBarActions;
    final Color finalAppBarIconColor = shellConfig?.appBarIconColor ?? widget.defaultAppBarIconColor;
    final Color finalAppBarTitleColor = shellConfig?.appBarTitleColor ?? widget.defaultAppBarTitleColor;
    // Prioridad para el título: Configuración -> Título del widget -> Título global
    final String finalTitle = shellConfig?.appBarTitle ?? widget.screenTitle ?? globalScreenTitle;
    // --- Fin de la lógica de configuración --- 
    
    return Scaffold(
      // Aplicar extendBodyBehindAppBar según la configuración final
      extendBodyBehindAppBar: finalExtendBody, 
      appBar: ManagerAppBar(
        title: finalTitle,
        backgroundColor: finalAppBarBgColor,
        actions: finalAppBarActions, // Pasa las acciones determinadas
        iconColor: finalAppBarIconColor, // Pasa el color de íconos
        titleColor: finalAppBarTitleColor, // Pasa el color del título
      ),
      drawer: ManagerDrawer(
        context: context,
        userRole: userRole,
      ),
      body: Container(
        // El color de fondo del body podría necesitar ajustes si el AppBar es transparente
        // y el body se extiende. Considerar SafeArea si es necesario.
        color: AppTheme.blackSwarm, // Mantenemos el fondo negro por defecto
        child: widget.child,
      ),
    );
  }
} 