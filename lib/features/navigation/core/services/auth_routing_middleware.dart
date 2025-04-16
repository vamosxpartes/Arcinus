import 'dart:developer' as developer;

import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/auth/core/providers/auth_providers.dart';
import 'package:arcinus/features/navigation/core/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Middleware para gestionar enrutamiento basado en autenticación
/// 
/// Este servicio centraliza la lógica de navegación basada en el estado de autenticación,
/// evitando duplicar código en múltiples pantallas y asegurando un comportamiento consistente.
class AuthRoutingMiddleware {
  
  /// Verifica si el usuario está autenticado y redirige según corresponda
  /// 
  /// Retorna true si el usuario está autenticado, false en caso contrario.
  /// Si el usuario no está autenticado y [shouldRedirect] es true, redirige a la pantalla de login.
  static bool checkAuthentication(BuildContext context, WidgetRef ref, {bool shouldRedirect = true}) {
    final authState = ref.read(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null && shouldRedirect) {
          developer.log('Usuario no autenticado, redirigiendo a login - AuthMiddleware', name: 'AuthMiddleware');
          _redirectToLogin(context, ref);
          return false;
        }
        return user != null;
      },
      loading: () => false,
      error: (_, __) {
        if (shouldRedirect) {
          developer.log('Error en estado de autenticación, redirigiendo a login - AuthMiddleware', name: 'AuthMiddleware');
          _redirectToLogin(context, ref);
        }
        return false;
      },
    );
  }
  
  /// Configura un listener para cambios en el estado de autenticación
  /// 
  /// Útil para pantallas que necesitan responder automáticamente a cambios
  /// en el estado de autenticación (por ejemplo, logout).
  static void setupAuthListener(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, current) {
      // Si el usuario acaba de cerrar sesión
      if (previous?.value != null && current.value == null) {
        developer.log('Usuario cerró sesión, redirigiendo a login - AuthMiddleware', name: 'AuthMiddleware');
        _redirectToLogin(context, ref);
      }
      
      // Si el usuario acaba de iniciar sesión
      if (previous?.value == null && current.value != null) {
        final user = current.value as User;
        developer.log('Usuario autenticado, redirigiendo a dashboard - AuthMiddleware - ${user.role}', name: 'AuthMiddleware');
        _redirectToDashboard(context, ref);
      }
    });
  }
  
  /// Decide la pantalla inicial basada en el estado de autenticación
  static Widget determineInitialScreen(User? user, Widget authenticatedScreen, Widget unauthenticatedScreen) {
    if (user == null) {
      developer.log('Determinando pantalla inicial: usuario no autenticado - AuthMiddleware', name: 'AuthMiddleware');
      return unauthenticatedScreen;
    } else {
      developer.log('Determinando pantalla inicial: usuario autenticado - AuthMiddleware', name: 'AuthMiddleware');
      return authenticatedScreen;
    }
  }
  
  /// Redirige al usuario a la pantalla de login
  static void _redirectToLogin(BuildContext context, WidgetRef ref) {
    if (context.mounted) {
      // Usar el provider para obtener el servicio, usando la ref pasada
      final navigationService = ref.read(navigationServiceProvider);
      navigationService.navigateToRoute(context, '/login');
    }
  }
  
  /// Redirige al usuario al dashboard
  static void _redirectToDashboard(BuildContext context, WidgetRef ref) {
    if (context.mounted) {
      // Usar el provider para obtener el servicio, usando la ref pasada
      final navigationService = ref.read(navigationServiceProvider);
      navigationService.navigateToRoute(context, '/dashboard');
    }
  }
} 