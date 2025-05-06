import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/academies/presentation/providers/owner_academies_provider.dart';
import 'package:arcinus/features/academies/presentation/providers/current_academy_provider.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/navigation_shells/owner_shell/widgets/owner_drawer.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart'; // Necesario para el tipo de dato

/// Widget Shell para el rol Propietario.
///
/// Construye la estructura base de UI para las pantallas del propietario.
class OwnerShell extends ConsumerStatefulWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;

  /// Crea una instancia de [OwnerShell].
  const OwnerShell({super.key, required this.child});

  @override
  ConsumerState<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends ConsumerState<OwnerShell> {
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

    // Obtener la academia actual seleccionada para el título
    final currentAcademyId = ref.watch(currentAcademyIdProvider);
    final academiesAsync = ref.watch(ownerAcademiesProvider(userId));

    String appBarTitle = 'Arcinus'; // Título por defecto

    if (currentAcademyId != null) {
      academiesAsync.whenData((academies) {
        final foundAcademy = academies.firstWhere(
          (academy) => academy.id == currentAcademyId,
          orElse: () => academies.isNotEmpty ? academies.first : const AcademyModel(ownerId: '', name: 'Arcinus', sportCode: '', location: ''), // Modelo vacío o por defecto si no se encuentra
        );
        if (foundAcademy.id != null) { // Asegurarse que la academia encontrada no sea el placeholder vacío
          appBarTitle = foundAcademy.name;
        } else if (academies.isNotEmpty) {
           appBarTitle = academies.first.name;
           // Actualizar el provider si currentAcademyId no correspondía a una academia válida pero hay otras.
           WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ref.read(currentAcademyIdProvider) != academies.first.id) {
              ref.read(currentAcademyIdProvider.notifier).state = academies.first.id;
            }
           });
        }
      });
    } else {
       academiesAsync.whenData((academies) {
         if (academies.isNotEmpty) {
           appBarTitle = academies.first.name;
           // Si no hay currentAcademyId pero hay academias, seleccionar la primera.
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (ref.read(currentAcademyIdProvider) != academies.first.id) {
              ref.read(currentAcademyIdProvider.notifier).state = academies.first.id;
             }
           });
         }
       });
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
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