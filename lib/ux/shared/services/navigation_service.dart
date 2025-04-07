import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:arcinus/ux/features/permission/providers/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor para el servicio de navegación
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});

/// Servicio para gestionar la navegación en la aplicación basada en permisos
class NavigationService {
  final Ref _ref;
  
  // Elementos fijados en la barra de navegación
  List<NavigationItem> _pinnedItems = [];
  
  // Constructor
  NavigationService(this._ref) {
    _initializePinnedItems();
  }
  
  // Getter para los elementos fijados
  List<NavigationItem> get pinnedItems => _pinnedItems;
  
  // Inicializa los elementos fijados con valores predeterminados
  void _initializePinnedItems() {
    _pinnedItems = NavigationItems.getDefaultPinnedItems();
  }
  
  /// Obtiene todos los elementos de navegación filtrados por permisos del usuario
  List<NavigationItem> getAvailableItems() {
    // Usar el servicio de permisos para filtrar los elementos
    final permissionService = _ref.read(permissionServiceProvider);
    return permissionService.getNavigationItemsByPermissions();
  }
  
  /// Navega a una ruta específica si el usuario tiene permisos
  Future<bool> navigateToRoute(BuildContext context, String route) async {
    final permissionService = _ref.read(permissionServiceProvider);
    
    // Verificar si el usuario tiene permisos para acceder a la ruta
    if (permissionService.canAccessRoute(route)) {
      await Navigator.of(context).pushNamed(route);
      return true;
    } else {
      // Mostrar mensaje de error si no tiene permisos
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes permisos para acceder a esta sección')),
        );
      }
      return false;
    }
  }
  
  /// Fijar o desfijar un elemento de navegación
  bool togglePinItem(NavigationItem item, {required BuildContext context}) {
    // Verificar si el elemento ya está fijado
    final isAlreadyPinned = _pinnedItems.any((pinnedItem) => 
      pinnedItem.destination == item.destination
    );
    
    if (isAlreadyPinned) {
      // Si ya está fijado y hay más de 3 elementos fijados, lo quitamos
      if (_pinnedItems.length > 3) {
        _pinnedItems.removeWhere((pinnedItem) => 
          pinnedItem.destination == item.destination
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.label} eliminado de favoritos')),
        );
        return true;
      } else {
        // No permitir menos de 3 elementos fijados
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes mantener al menos 3 elementos en la barra')),
        );
        return false;
      }
    } else {
      // Si no está fijado y hay menos de 5 elementos, lo añadimos
      if (_pinnedItems.length < 5) {
        _pinnedItems.add(item);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.label} añadido a favoritos')),
        );
        return true;
      } else {
        // No permitir más de 5 elementos fijados
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes tener 5 elementos en la barra. Elimina uno primero.')),
        );
        return false;
      }
    }
  }
} 