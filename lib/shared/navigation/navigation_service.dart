import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:arcinus/shared/navigation/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que gestiona la lógica de navegación de la aplicación
class NavigationService {
  /// Instancia singleton para el servicio de navegación
  static final NavigationService _instance = NavigationService._internal();
  
  /// Constructor factory que devuelve la instancia singleton
  factory NavigationService() => _instance;
  
  /// Clave para almacenar elementos fijados en SharedPreferences
  static const String _pinnedItemsKey = 'pinned_navigation_items';
  
  /// Constructor interno para inicialización
  NavigationService._internal() {
    // Cargar configuración guardada al inicializar el servicio
    loadNavigationSettings();
  }
  
  /// Lista de elementos fijados en la barra de navegación
  List<NavigationItem> _pinnedItems = NavigationItems.getDefaultPinnedItems();
  
  /// Getter para obtener los elementos fijados
  List<NavigationItem> get pinnedItems => _pinnedItems;
  
  /// Método para fijar o soltar un elemento de navegación
  /// Retorna true si la operación fue exitosa, false si no se pudo realizar
  bool togglePinItem(NavigationItem item, {required BuildContext context}) {
    bool result = false;
    
    if (_pinnedItems.contains(item)) {
      // Si ya está fijado y hay más de 1 elemento, lo quitamos
      if (_pinnedItems.length > 1) {
        _pinnedItems.remove(item);
        result = true;
      }
      // No se puede quitar si es el único elemento
    } else {
      // Si no está fijado y hay menos de 5, lo añadimos
      if (_pinnedItems.length < 5) {
        _pinnedItems.add(item);
        result = true;
      } else {
        // Si ya hay 5, mostramos un mensaje
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solo puedes fijar 5 elementos. Quita uno primero.')),
          );
        }
      }
    }
    
    // Si se realizó algún cambio, guardamos la configuración
    if (result) {
      saveNavigationSettings();
    }
    
    return result;
  }
  
  /// Método para navegar a una ruta específica
  void navigateToRoute(BuildContext context, String route) {
    // Si ya estamos en la pantalla actual, no hacemos nada
    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }
    
    // Manejo especial para la ruta de dashboard
    if (route == '/dashboard') {
      // Buscar la MainScreen en el stack de navegación
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    
    Navigator.of(context).pushNamed(route);
  }
  
  /// Método para guardar la configuración de navegación usando SharedPreferences
  Future<void> saveNavigationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convertir los elementos fijados a una lista de strings (destinos)
      final List<String> pinnedDestinations = _pinnedItems.map((item) => item.destination).toList();
      
      // Guardar la lista de destinos
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
      
      // Obtener la lista de destinos guardados
      final List<String>? pinnedDestinations = prefs.getStringList(_pinnedItemsKey);
      
      if (pinnedDestinations != null && pinnedDestinations.isNotEmpty) {
        // Buscar los items de navegación correspondientes a los destinos guardados
        final List<NavigationItem> loadedItems = [];
        
        for (final destination in pinnedDestinations) {
          // Buscar el item que corresponde al destino guardado
          final item = NavigationItems.allItems.firstWhere(
            (item) => item.destination == destination,
            // Si no se encuentra, puede ser que el destino ya no exista en la nueva versión
            orElse: () => NavigationItems.allItems.first,
          );
          
          loadedItems.add(item);
        }
        
        // Si se cargaron items válidos, actualizamos la lista
        if (loadedItems.isNotEmpty) {
          _pinnedItems = loadedItems;
          debugPrint('Configuración de navegación cargada: ${pinnedDestinations.join(', ')}');
        }
      } else {
        debugPrint('No se encontró configuración guardada, usando valores predeterminados');
      }
    } catch (e) {
      debugPrint('Error al cargar configuración de navegación: $e');
    }
  }
  
  /// Resetea los elementos fijados a los valores predeterminados
  Future<void> resetToDefaults() async {
    _pinnedItems = NavigationItems.getDefaultPinnedItems();
    await saveNavigationSettings();
  }
} 