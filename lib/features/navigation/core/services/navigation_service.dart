import 'dart:developer' as developer;

import 'package:arcinus/features/navigation/components/navigation_items.dart';
import 'package:arcinus/features/navigation/core/models/navigation_item.dart';
import 'package:arcinus/features/navigation/core/providers/navigation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para el servicio de navegación.
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});

/// Servicio que gestiona la lógica de navegación y estado relacionado.
class NavigationService {
  final Ref _ref; // Referencia para interactuar con otros providers
  
  /// Clave para almacenar elementos fijados en SharedPreferences
  static const String _pinnedItemsKey = 'pinned_navigation_items';
  
  /// Constructor que requiere Ref
  NavigationService(this._ref) {
    // Cargar configuración guardada al inicializar el servicio
    loadNavigationSettings();
  }
  
  /// Método para obtener todos los elementos de navegación disponibles
  List<NavigationItem> getAllItems() => NavigationItems.allItems;
  
  /// Método para fijar o soltar un elemento de navegación
  /// Retorna true si la operación fue exitosa, false si no se pudo realizar
  bool togglePinItem(NavigationItem item, {required BuildContext context}) {
    final notifier = _ref.read(pinnedItemsProvider.notifier);
    final currentPinnedItems = _ref.read(pinnedItemsProvider);
    bool result = false;
    
    if (currentPinnedItems.any((i) => i.destination == item.destination)) {
      // Intentar quitar el ítem
      result = notifier.removeItem(item);
      if (!result && currentPinnedItems.length <= 1 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes tener al menos un elemento fijado.')),
        );
      }
    } else {
      // Intentar añadir el ítem
      result = notifier.addItem(item);
      if (!result && currentPinnedItems.length >= 4 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solo puedes fijar 4 elementos. Quita uno primero.')),
        );
      }
    }
    
    // Si se realizó algún cambio, guardamos la configuración
    if (result) {
      saveNavigationSettings(); // Guardar los nuevos items del provider
    }
    
    return result;
  }
  
  /// Método para navegar a una ruta específica
  void navigateToRoute(BuildContext context, String route) {
    final currentRoute = _ref.read(currentRouteProvider); // Leer ruta actual del provider
    developer.log('DEBUG: NavigationService - Intentando navegar a $route desde $currentRoute');
    // Si ya estamos en la pantalla actual, no hacemos nada
    if (currentRoute == route) {
      developer.log('DEBUG: NavigationService - Ya estamos en la ruta $route, no se navega.');
      return;
    }
    
    // Manejo especial para la ruta de dashboard
    if (route == '/dashboard') {
      developer.log('DEBUG: NavigationService - Navegando a /dashboard. Ruta actual antes de pop: $currentRoute');
      Navigator.of(context).popUntil((route) => route.isFirst);
      developer.log('DEBUG: NavigationService - popUntil ejecutado. Actualizando manualmente el provider a /dashboard');
      _ref.read(currentRouteProvider.notifier).state = route;
      final newState = _ref.read(currentRouteProvider);
      developer.log('DEBUG: NavigationService - Estado del provider después de actualización manual: $newState');
      return;
    }
    
    // Para otras rutas, simplemente empujar. El AppRouteObserver actualizará el provider.
    Navigator.of(context).pushNamed(route);
  }
  
  /// Método para guardar la configuración de navegación usando SharedPreferences
  Future<void> saveNavigationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Obtener los items actuales del provider
      final currentPinnedItems = _ref.read(pinnedItemsProvider);
      final List<String> pinnedDestinations = currentPinnedItems.map((item) => item.destination).toList();
      
      await prefs.setStringList(_pinnedItemsKey, pinnedDestinations);
      
      debugPrint('Configuración de navegación guardada: ${pinnedDestinations.join(', ')}');
    } catch (e) {
      debugPrint('Error al guardar configuración de navegación: $e');
    }
  }
  
  /// Método para cargar la configuración de navegación desde SharedPreferences
  Future<void> loadNavigationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? pinnedDestinations = prefs.getStringList(_pinnedItemsKey);
      
      List<NavigationItem> loadedItems = NavigationItems.getDefaultPinnedItems(); // Por defecto
      
      if (pinnedDestinations != null && pinnedDestinations.isNotEmpty) {
        final List<NavigationItem> foundItems = [];
        for (final destination in pinnedDestinations) {
          final item = NavigationItems.allItems.firstWhere(
            (item) => item.destination == destination,
            orElse: () => NavigationItems.allItems.first, // Fallback
          );
          foundItems.add(item);
        }
        // Solo usar los cargados si encontramos alguno válido
        if (foundItems.isNotEmpty) {
          loadedItems = foundItems;
        }
      }
      
      // Actualizar el estado del provider
      _ref.read(pinnedItemsProvider.notifier).setItems(loadedItems);
      debugPrint('Configuración de navegación cargada en provider: ${loadedItems.map((i) => i.destination).join(', ')}');
      
    } catch (e) {
      debugPrint('Error al cargar configuración de navegación: $e');
      // En caso de error, asegurar que el provider tenga los valores por defecto
      _ref.read(pinnedItemsProvider.notifier).resetToDefaults();
    }
  }
  
  /// Resetea los elementos fijados a los valores predeterminados
  Future<void> resetToDefaults() async {
    _ref.read(pinnedItemsProvider.notifier).resetToDefaults();
    await saveNavigationSettings();
  }
} 