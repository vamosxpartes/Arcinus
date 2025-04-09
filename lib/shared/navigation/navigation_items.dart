import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:flutter/material.dart';

/// Clase para centralizar y administrar los elementos de navegación de la aplicación
class NavigationItems {
  /// Lista de todos los elementos de navegación disponibles en la aplicación
  static final List<NavigationItem> allItems = [
    const NavigationItem(
      icon: Icons.dashboard,
      label: 'Inicio',
      destination: '/dashboard',
    ),
    const NavigationItem(
      icon: Icons.group,
      label: 'Usuarios',
      destination: '/users-management',
    ),
    const NavigationItem(
      icon: Icons.sports,
      label: 'Entrenamientos',
      destination: '/trainings',
    ),
    const NavigationItem(
      icon: Icons.calendar_today,
      label: 'Calendario',
      destination: '/calendar',
    ),
    const NavigationItem(
      icon: Icons.bar_chart,
      label: 'Estadísticas',
      destination: '/stats',
    ),
    const NavigationItem(
      icon: Icons.settings,
      label: 'Configuración',
      destination: '/settings',
    ),
    const NavigationItem(
      icon: Icons.payments,
      label: 'Pagos',
      destination: '/payments',
    ),
    const NavigationItem(
      icon: Icons.school,
      label: 'Academias',
      destination: '/academies',
    ),
    const NavigationItem(
      icon: Icons.person,
      label: 'Perfil',
      destination: '/profile',
    ),
  ];
  
  /// Obtiene los elementos predeterminados que deberían estar fijados inicialmente
  static List<NavigationItem> getDefaultPinnedItems() {
    return allItems.take(5).toList();
  }
  
  /// Método deprecado - Reemplazado por filtrado basado en permisos
  @Deprecated('Use getItemsByPermissions from PermissionService instead')
  static List<NavigationItem> getItemsByRole(String role) {
    // Este método ahora está obsoleto, se debe usar getItemsByPermissions del PermissionService
    return allItems;
  }
} 