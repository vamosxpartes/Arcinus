import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:flutter/material.dart';

/// Clase para centralizar y administrar los elementos de navegación de la aplicación
class NavigationItems {
  /// Lista de todos los elementos de navegación disponibles en la aplicación
  static final List<NavigationItem> allItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Inicio',
      destination: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.group,
      label: 'Usuarios',
      destination: '/users-management',
    ),
    NavigationItem(
      icon: Icons.sports,
      label: 'Entrenamientos',
      destination: '/trainings',
    ),
    NavigationItem(
      icon: Icons.calendar_today,
      label: 'Calendario',
      destination: '/calendar',
    ),
    NavigationItem(
      icon: Icons.bar_chart,
      label: 'Estadísticas',
      destination: '/stats',
    ),
    NavigationItem(
      icon: Icons.settings,
      label: 'Configuración',
      destination: '/settings',
    ),
    NavigationItem(
      icon: Icons.payments,
      label: 'Pagos',
      destination: '/payments',
    ),
    NavigationItem(
      icon: Icons.school,
      label: 'Academias',
      destination: '/academies',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Perfil',
      destination: '/profile',
    ),
    NavigationItem(
      icon: Icons.chat,
      label: 'Chat',
      destination: '/chats',
    ),
    NavigationItem(
      icon: Icons.notifications,
      label: 'Notificaciones',
      destination: '/notifications',
    ),
  ];
  
  /// Obtiene los elementos predeterminados que deberían estar fijados inicialmente
  static List<NavigationItem> getDefaultPinnedItems() {
    return allItems.take(5).toList();
  }
  
  /// Obtiene elementos de navegación filtrados por rol (para posible uso futuro)
  static List<NavigationItem> getItemsByRole(String role) {
    // Implementar lógica específica por rol en el futuro si es necesario
    return allItems;
  }
} 