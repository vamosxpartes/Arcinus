import 'dart:developer' as developer;

import 'package:arcinus/features/navigation/core/providers/navigation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Observador de navegación que actualiza el estado de la ruta actual.
class AppRouteObserver extends NavigatorObserver {
  final WidgetRef ref;

  AppRouteObserver(this.ref);

  void _updateRoute(Route<dynamic> route) {
    // Usar microtask para asegurar que la actualización del estado
    // no ocurra durante un build.
    Future.microtask(() {
      final routeName = route.settings.name;
      developer.log('DEBUG: AppRouteObserver - Evaluando actualización de ruta. Nombre: $routeName');
      
      // Si la ruta es '/' y venimos de un popUntil, mantenemos '/dashboard'
      if (routeName == '/') {
        final currentRoute = ref.read(currentRouteProvider);
        developer.log('DEBUG: AppRouteObserver - Ruta es "/". Ruta actual en provider: $currentRoute');
        if (currentRoute == '/dashboard') {
          developer.log('DEBUG: AppRouteObserver - Manteniendo /dashboard como ruta actual');
          return; // No actualizamos el provider, mantenemos /dashboard
        }
      }
      
      if (routeName != null) {
        developer.log('DEBUG: AppRouteObserver - Actualizando ruta a: $routeName');
        ref.read(currentRouteProvider.notifier).state = routeName;
      }
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    developer.log('DEBUG: AppRouteObserver.didPush - Nueva ruta: ${route.settings.name}, Ruta anterior: ${previousRoute?.settings.name}');
    _updateRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    developer.log('DEBUG: AppRouteObserver.didPop - Ruta actual: ${route.settings.name}, Ruta anterior: ${previousRoute?.settings.name}');
    if (previousRoute != null) {
      _updateRoute(previousRoute);
    } else {
      // Si no hay ruta previa, establecemos /dashboard
      Future.microtask(() {
        developer.log('DEBUG: AppRouteObserver.didPop - No hay ruta anterior, estableciendo /dashboard por defecto');
        ref.read(currentRouteProvider.notifier).state = '/dashboard';
      });
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateRoute(newRoute);
    }
  }
} 