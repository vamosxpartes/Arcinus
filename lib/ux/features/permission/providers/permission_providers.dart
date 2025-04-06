import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/shared/constants/permissions.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';

/// Proveedor del servicio de permisos
final permissionServiceProvider = Provider<PermissionService>((ref) {
  final authState = ref.watch(authStateProvider);
  return PermissionService(ref, authState.valueOrNull);
});

/// Servicio para gestionar los permisos y accesos basados en permisos
class PermissionService {
  final Ref _ref;
  final User? _currentUser;

  PermissionService(this._ref, this._currentUser);

  /// Verifica si el usuario actual tiene un permiso específico
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    return _currentUser.permissions[permission] == true;
  }

  /// Verifica si el usuario actual tiene todos los permisos especificados
  bool hasAllPermissions(List<String> permissions) {
    if (_currentUser == null) return false;
    return permissions.every((p) => _currentUser.permissions[p] == true);
  }

  /// Verifica si el usuario actual tiene al menos uno de los permisos especificados
  bool hasAnyPermission(List<String> permissions) {
    if (_currentUser == null) return false;
    return permissions.any((p) => _currentUser.permissions[p] == true);
  }
  
  /// Obtiene los elementos de navegación filtrados por los permisos del usuario actual
  List<NavigationItem> getNavigationItemsByPermissions() {
    if (_currentUser == null) return [];
    
    return NavigationItems.allItems.where((item) {
      // Mapear destinos a permisos requeridos
      switch (item.destination) {
        case '/dashboard':
          return true; // Todos pueden acceder al dashboard
        case '/users-management':
          return hasAnyPermission([
            Permissions.manageUsers,
            Permissions.manageCoaches,
          ]);
        case '/trainings':
          return hasAnyPermission([
            Permissions.createTraining,
            Permissions.viewAllTrainings,
            Permissions.editTraining,
          ]);
        case '/calendar':
          return hasAnyPermission([
            Permissions.scheduleClass,
            Permissions.takeAttendance,
          ]);
        case '/stats':
          return hasAnyPermission([
            Permissions.evaluateAthletes,
            Permissions.viewAllEvaluations,
          ]);
        case '/settings':
          return hasAnyPermission([
            Permissions.manageAcademy,
            Permissions.assignPermissions,
          ]);
        case '/payments':
          return hasAnyPermission([
            Permissions.managePayments,
            Permissions.viewFinancials,
          ]);
        case '/academies':
          return hasAnyPermission([
            Permissions.viewAllAcademies,
            Permissions.manageAcademy,
            Permissions.createAcademy,
          ]);
        case '/profile':
          return true; // Todos pueden acceder a su perfil
        case '/chats':
          return hasPermission(Permissions.useChat);
        case '/notifications':
          return true; // Todos pueden ver notificaciones
        default:
          return false;
      }
    }).toList();
  }

  /// Verifica si el usuario puede acceder a una ruta específica
  bool canAccessRoute(String route) {
    if (_currentUser == null) return false;
    
    // Rutas públicas que no requieren permisos específicos
    if (['/login', '/register', '/forgot-password'].contains(route)) {
      return true;
    }
    
    // Verificar permisos específicos por ruta
    switch (route) {
      case '/dashboard':
        return true; // Todos los usuarios autenticados pueden acceder al dashboard
      case '/users-management':
        return hasAnyPermission([
          Permissions.manageUsers,
          Permissions.manageCoaches,
        ]);
      case '/create-academy':
        return hasPermission(Permissions.createAcademy);
      case '/academies':
        return hasAnyPermission([
          Permissions.viewAllAcademies,
          Permissions.manageAcademy,
        ]);
      case '/trainings':
        return hasAnyPermission([
          Permissions.createTraining,
          Permissions.viewAllTrainings,
          Permissions.editTraining,
        ]);
      case '/profile':
        return true; // Todos pueden acceder a su perfil
      // Añadir más rutas según sea necesario
      default:
        // Para rutas no especificadas, permitir acceso por defecto a usuarios autenticados
        return true;
    }
  }
  
  /// Verifica si el usuario puede realizar una acción específica
  bool canPerformAction(String action) {
    if (_currentUser == null) return false;
    
    // Mapear acciones a permisos requeridos
    switch (action) {
      case 'inviteUser':
        return hasPermission(Permissions.manageUsers);
      case 'createGroup':
        return hasPermission(Permissions.manageGroups);
      case 'assignCoach':
        return hasAnyPermission([Permissions.manageCoaches, Permissions.manageGroups]);
      case 'editAcademy':
        return hasPermission(Permissions.manageAcademy);
      case 'viewFinancialReports':
        return hasPermission(Permissions.viewFinancials);
      // Añadir más acciones según sea necesario
      default:
        return false;
    }
  }
} 