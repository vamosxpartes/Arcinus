import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/auth/presentation/providers/complete_profile_provider.dart';
import 'package:arcinus/features/auth/presentation/state/complete_profile_state.dart';
import 'package:arcinus/features/theme/ui/loading/loading_indicator.dart';
import 'package:arcinus/features/theme/ui/feedback/error_display.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

// Instancia de Logger
final _logger = Logger();

class CompleteProfileScreen extends ConsumerWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(completeProfileProvider.notifier);
    final state = ref.watch(completeProfileProvider);
    final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

    // Escuchar cambios de estado para efectos secundarios (navegación, snackbars)
    ref.listen<CompleteProfileState>(completeProfileProvider, (previous, next) {
      next.maybeWhen(
        error: (failure) {
          // Usar el mensaje de Failure si está disponible, o un mensaje genérico
          final errorMessage = failure.maybeMap(
            authError: (f) => f.message,
            serverError: (f) => f.message,
            validationError: (f) => f.message,
            orElse: () => 'Ocurrió un error inesperado',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)), 
          );
        },
        success: () {
          // La navegación debería manejarse por GoRouter.redirect observando el estado de autenticación/perfil
          _logger.i('Perfil guardado con éxito, GoRouter debería redirigir.');
          
          // Redirección manual como fallback si el router no redirecciona automáticamente
          // (Podría eliminarse si GoRouter.redirect es robusto)
          final authState = ref.read(authStateNotifierProvider);
          if (authState.isAuthenticated && authState.user != null) {
            final user = authState.user!;
            // Forzar actualización del userProfileProvider
            ref.invalidate(userProfileProvider(user.id));
            
            // Esperar un momento y luego redirigir manualmente
            Future.delayed(const Duration(milliseconds: 500), () {
              if (user.role == AppRole.propietario) {
                _logger.d('Redirigiendo manualmente a la pantalla de creación de academia');
                if (context.mounted) {
                  context.go(AppRoutes.createAcademy);
                }
              } else {
                final targetRoute = _getRoleRootRoute(user.role);
                _logger.d('Redirigiendo manualmente a $targetRoute');
                if (context.mounted) {
                  context.go(targetRoute);
                }
              }
            });
          }
        },
        orElse: () {}, // No hacer nada para otros estados (initial, loading)
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        actions: [
          // Mostrar botón de guardar solo si no está cargando
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: notifier.submitProfile,
            )
          else
            // Mostrar indicador de progreso pequeño en la AppBar durante la carga
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: notifier.formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: notifier.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading, // Deshabilitar campos durante la carga
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notifier.lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu apellido';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: !isLoading ? (_) => notifier.submitProfile() : null,
                    enabled: !isLoading, // Deshabilitar campos durante la carga
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : notifier.submitProfile,
                    child: const Text('Guardar Perfil'),
                  ),
                  // Mostrar widget de error si el estado es error
                  state.maybeWhen(
                    error: (failure) => Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ErrorDisplay(error: failure.toString()),
                    ),
                    orElse: () => const SizedBox.shrink(), // No mostrar nada en otros casos
                  ),
                ],
              ),
            ),
          ),
          // Indicador de carga superpuesto opcional
          if (isLoading)
            const LoadingIndicator(message: 'Guardando...'),
        ],
      ),
    );
  }

  // Método para obtener la ruta raíz según el rol
  String _getRoleRootRoute(AppRole? role) {
    switch (role) {
      case AppRole.propietario:
        return AppRoutes.ownerRoot;
      case AppRole.atleta:
        return AppRoutes.athleteRoot;
      case AppRole.colaborador:
        return AppRoutes.collaboratorRoot;
      case AppRole.superAdmin:
        return AppRoutes.superAdminRoot;
      case AppRole.padre:
        return AppRoutes.parentRoot;
      default:
        return AppRoutes.welcome;
    }
  }
} 