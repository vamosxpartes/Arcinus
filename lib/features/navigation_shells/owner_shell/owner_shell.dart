import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/navigation_shells/owner_shell/widgets/owner_drawer.dart';
import 'package:arcinus/core/utils/app_logger.dart';

// Provider para manejar el título de la pantalla actual
final currentScreenTitleProvider = StateProvider<String>((ref) => 'Arcinus');

/// Widget Shell para el rol Propietario.
///
/// Construye la estructura base de UI para las pantallas del propietario.
class OwnerShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;
  
  /// Título opcional para la pantalla
  final String? screenTitle;

  /// Crea una instancia de [OwnerShell].
  const OwnerShell({
    super.key, 
    required this.child, 
    this.screenTitle,
  });

  @override
  ConsumerState<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends ConsumerState<OwnerShell> {
  @override
  void didUpdateWidget(OwnerShell oldWidget) {
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
    final userId = authState.user?.id;

    // Si no hay usuario, mostrar un indicador de carga
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Obtener el título actual de la pantalla
    final currentTitleFromProvider = ref.watch(currentScreenTitleProvider);
    AppLogger.logInfo(
      'OwnerShell building...',
      className: 'OwnerShell',
      functionName: 'build',
      params: {
        'widget.screenTitle': widget.screenTitle,
        'currentScreenTitleProvider': currentTitleFromProvider,
      },
    );
    final screenTitle = widget.screenTitle ?? currentTitleFromProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle!),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              // Placeholder para notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Notificaciones')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined), // Icono de mensajes
            onPressed: () {
              // Placeholder para mensajes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Mensajes')),
              );
            },
          ),
        ],
      ),
      drawer: OwnerDrawer(context: context), // El context del OwnerShellState se pasa aquí
      body: widget.child,
    );
  }
} 