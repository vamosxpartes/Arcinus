import 'package:arcinus/features/navigation/components/custom_navigation_bar.dart';
import 'package:arcinus/features/navigation/core/models/navigation_item.dart';
import 'package:arcinus/features/navigation/core/providers/navigation_providers.dart';
import 'package:arcinus/features/navigation/core/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scaffold personalizado que incluye la barra de navegación de Arcinus.
/// 
/// Este componente encapsula la lógica de navegación común para todas las pantallas
/// de la aplicación, permitiendo mostrar u ocultar la barra de navegación según sea necesario.
class BaseScaffold extends ConsumerWidget {
  /// El contenido principal del scaffold
  final Widget body;
  
  /// Si se debe mostrar la barra de navegación inferior
  final bool showNavigation;
  
  /// AppBar opcional
  final PreferredSizeWidget? appBar;
  
  /// Botón de acción flotante opcional
  final Widget? floatingActionButton;
  
  /// Color de fondo del scaffold
  final Color? backgroundColor;
  
  /// Si el cuerpo debe extenderse debajo de la barra de navegación
  final bool extendBody;
  
  /// Padding opcional para el contenido principal
  final EdgeInsets? padding;
  
  /// Opcional: función para manejar el tap en el botón de agregar
  final VoidCallback? onAddButtonTap;
  
  const BaseScaffold({
    super.key,
    required this.body,
    this.showNavigation = true,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBody = false,
    this.padding,
    this.onAddButtonTap,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el servicio de navegación desde el provider
    final navigationService = ref.read(navigationServiceProvider);
    
    // Obtener la ruta actual y los items fijados desde los providers
    final String currentRoute = ref.watch(currentRouteProvider);
    final List<NavigationItem> pinnedItems = ref.watch(pinnedItemsProvider);
    
    // Obtener todos los items (podría obtenerse del servicio o directamente)
    final List<NavigationItem> allItems = navigationService.getAllItems(); // O NavigationItems.allItems
    
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      extendBody: extendBody || showNavigation, // Extender el cuerpo si hay navegación
      body: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showNavigation 
          ? CustomNavigationBar(
              pinnedItems: pinnedItems, // Usar items del provider
              allItems: allItems,
              activeRoute: currentRoute, // Usar ruta del provider
              onItemTap: (item) => navigationService.navigateToRoute(context, item.destination),
              onItemLongPress: (item) {
                // Llamar a togglePinItem. El provider se actualizará y reconstruirá este widget.
                navigationService.togglePinItem(item, context: context);
                // No necesitamos setState aquí porque el watch del provider lo maneja.
              },
              onAddButtonTap: onAddButtonTap,
            )
          : null,
    );
  }
} 