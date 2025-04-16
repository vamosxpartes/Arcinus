import 'package:arcinus/features/navigation/components/navigation_items.dart';
import 'package:arcinus/features/navigation/core/models/navigation_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que almacena el nombre de la ruta actualmente visible en la app.
final currentRouteProvider = StateProvider<String>((ref) => '/dashboard'); // Inicializar con la ruta por defecto

// --- Gestión de Ítems Fijados ---

/// Notifier para gestionar la lista de ítems de navegación fijados.
class PinnedItemsNotifier extends StateNotifier<List<NavigationItem>> {
  // Inicializar con la lista por defecto
  PinnedItemsNotifier() : super(NavigationItems.getDefaultPinnedItems());

  /// Reemplaza la lista actual de ítems fijados.
  void setItems(List<NavigationItem> items) {
    // Asegurarse de no asignar la misma instancia si no hay cambios reales
    // aunque Riverpod maneja esto internamente, es buena práctica.
    if (state != items) {
      state = items;
    }
  }

  /// Añade un ítem a la lista de fijados si no existe y hay espacio.
  bool addItem(NavigationItem item) {
    if (!state.contains(item) && state.length < 4) {
      state = [...state, item];
      return true; // Indica que se añadió
    }
    return false; // Indica que no se añadió (ya existe o límite alcanzado)
  }

  /// Elimina un ítem de la lista de fijados si existe y no es el último.
  bool removeItem(NavigationItem item) {
    if (state.contains(item) && state.length > 1) {
      state = state.where((i) => i.destination != item.destination).toList();
      return true; // Indica que se eliminó
    }
    return false; // Indica que no se eliminó (no existe o es el último)
  }

  /// Resetea a los valores por defecto.
  void resetToDefaults() {
    state = NavigationItems.getDefaultPinnedItems();
  }
}

/// Provider para el Notifier de ítems fijados.
final pinnedItemsProvider = StateNotifierProvider<PinnedItemsNotifier, List<NavigationItem>>((ref) {
  // No es necesario inicializar aquí, el Notifier lo hace en su constructor.
  return PinnedItemsNotifier();
}); 