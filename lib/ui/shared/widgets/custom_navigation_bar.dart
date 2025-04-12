import 'package:arcinus/shared/models/navigation_item.dart';
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  final List<NavigationItem> pinnedItems;
  final List<NavigationItem> allItems;
  final String activeRoute;
  final Function(NavigationItem) onItemTap;
  final Function(NavigationItem)? onItemLongPress;
  final double expandedPanelHeight;
  final bool enableDrag;
  final VoidCallback? onAddButtonTap;

  const CustomNavigationBar({
    super.key,
    required this.pinnedItems,
    this.allItems = const [],
    required this.activeRoute,
    required this.onItemTap,
    this.onItemLongPress,
    this.expandedPanelHeight = 240.0,
    this.enableDrag = true,
    this.onAddButtonTap,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

// Item de navegación para Entrenamientos
const NavigationItem trainingNavigationItem = NavigationItem(
  icon: Icons.fitness_center,
  label: 'Entrenamientos',
  destination: '/trainings',
  hasCreationFunction: true,
);

class _CustomNavigationBarState extends State<CustomNavigationBar> with TickerProviderStateMixin {
  // Controlador para el panel deslizable
  late AnimationController _panelController;
  late Animation<double> _panelAnimation;
  
  // Controlador para animar el cambio de posición del botón agregar
  late AnimationController _addButtonPositionController;
  
  // Estado para controlar si el panel está siendo arrastrado
  bool _isDragging = false;
  double _dragExtent = 0.0;
  
  // Variable para rastrar la última cantidad de elementos fijados
  int _lastPinnedItemsCount = 0;
  bool _isButtonAtEnd = true;

  @override
  void initState() {
    super.initState();
    
    // Inicializar el controlador de animación para el panel deslizable
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _panelAnimation = Tween<double>(
      begin: 0.0,
      end: widget.expandedPanelHeight,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    
    _panelController.addListener(() {
      setState(() {});
    });
    
    // Inicializar el controlador para la animación del botón agregar
    _addButtonPositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    
    // Inicializar estado de la posición del botón
    _lastPinnedItemsCount = widget.pinnedItems.length;
    _isButtonAtEnd = widget.pinnedItems.length % 2 != 0;
  }
  
  @override
  void didUpdateWidget(CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verificar si el número de elementos fijados ha cambiado
    if (widget.pinnedItems.length != _lastPinnedItemsCount) {
      // La cantidad ha cambiado, actualizamos estado
      final bool newIsButtonAtEnd = widget.pinnedItems.length % 2 != 0;
      
      // Solo animamos si la posición ha cambiado
      if (newIsButtonAtEnd != _isButtonAtEnd) {
        if (newIsButtonAtEnd) {
          _addButtonPositionController.forward();
        } else {
          _addButtonPositionController.reverse();
        }
        _isButtonAtEnd = newIsButtonAtEnd;
      }
      
      _lastPinnedItemsCount = widget.pinnedItems.length;
    }
  }

  @override
  void dispose() {
    _panelController.dispose();
    _addButtonPositionController.dispose();
    super.dispose();
  }
  
  // Verifica si la ruta actual tiene función de creación
  bool _routeHasCreationFunction() {
    return widget.allItems.any((item) => 
      item.destination == widget.activeRoute && item.hasCreationFunction);
  }
  
  // Construye los elementos de navegación con el botón de agregar en la posición adecuada
  List<Widget> _buildNavigationItems() {
    final List<Widget> items = widget.pinnedItems.map((item) => _buildNavigationButton(
      context,
      item,
      onTap: () => widget.onItemTap(item),
      onLongPress: widget.onItemLongPress != null 
          ? () => widget.onItemLongPress!(item)
          : null,
      isPinned: true,
      isActive: item.destination == widget.activeRoute,
    )).toList();
    
    // Verificar si debemos mostrar el botón de agregar
    if (_routeHasCreationFunction() && widget.onAddButtonTap != null) {
      // Calcular la posición del botón según si el número de items es par o impar
      final bool isOdd = widget.pinnedItems.length % 2 != 0;
      
      // Posición inicial y final para la animación
      final int middlePosition = items.length ~/ 2;
      final int endPosition = items.length;
      
      // Posición actual basada en la animación
      final int insertPosition = isOdd 
          ? endPosition
          : middlePosition;
          
      // Insertar el botón en la posición calculada
      items.insert(insertPosition, _buildAddButton(context));
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final hasAdditionalItems = widget.allItems.isNotEmpty;
    
    return GestureDetector(
      onVerticalDragStart: widget.enableDrag ? (details) {
        setState(() {
          _isDragging = true;
          // Empezamos desde la posición actual de la animación
          _dragExtent = _panelAnimation.value;
        });
      } : null,
      onVerticalDragUpdate: widget.enableDrag ? (details) {
        // Solo procesamos si estamos arrastrando
        if (!_isDragging) return;
        
        setState(() {
          // Actualizamos la extensión del arrastre (negativo porque hacia arriba es negativo)
          _dragExtent -= details.delta.dy;
          
          // Limitamos la extensión entre 0 y la altura máxima
          _dragExtent = _dragExtent.clamp(0.0, widget.expandedPanelHeight);
          
          // Actualizamos el valor del controlador de animación
          _panelController.value = _dragExtent / widget.expandedPanelHeight;
        });
      } : null,
      onVerticalDragEnd: widget.enableDrag ? (details) {
        // Terminamos el arrastre
        setState(() {
          _isDragging = false;
          
          // Si la velocidad es significativa, completamos la animación en esa dirección
          if (details.velocity.pixelsPerSecond.dy.abs() > 200) {
            if (details.velocity.pixelsPerSecond.dy > 0) {
              // Deslizamiento hacia abajo, cerramos el panel
              _panelController.reverse();
            } else {
              // Deslizamiento hacia arriba, abrimos el panel
              _panelController.forward();
            }
          } else {
            // Si la velocidad no es significativa, abrimos o cerramos según la posición
            if (_panelController.value > 0.5) {
              _panelController.forward();
            } else {
              _panelController.reverse();
            }
          }
        });
      } : null,
      child: Container(
        height: 90 + (hasAdditionalItems ? _panelAnimation.value : 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de arrastre
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Panel expandido con opciones adicionales
            if (hasAdditionalItems && _panelAnimation.value > 0)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                          child: Text(
                            'Todas las opciones',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // Grid de iconos adicionales
                        Wrap(
                          spacing: 12,
                          runSpacing: 16,
                          children: widget.allItems
                              .where((item) => !widget.pinnedItems.contains(item))
                              .map((item) => _buildNavigationButton(
                                context,
                                item, 
                                onTap: () => widget.onItemTap(item),
                                onLongPress: widget.onItemLongPress != null 
                                    ? () => widget.onItemLongPress!(item)
                                    : null,
                                isPinned: false,
                                isActive: item.destination == widget.activeRoute,
                              ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Separador visual
            if (hasAdditionalItems && _panelAnimation.value > 10)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                color: Theme.of(context).colorScheme.outlineVariant.withAlpha(90),
              ),
            
            // Barra principal con elementos fijados
            SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildNavigationItems(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construir el botón de agregar
  Widget _buildAddButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: widget.onAddButtonTap,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Etiqueta
            Text(
              'Agregar',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
  
  // Construir un botón de navegación
  Widget _buildNavigationButton(
    BuildContext context,
    NavigationItem item, {
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    required bool isPinned,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.surfaceContainerLowest
                    : isPinned
                        ? theme.colorScheme.surfaceContainerHighest.withAlpha(170)
                        : theme.colorScheme.surfaceContainerHigh,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.icon,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Etiqueta con elipsis
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive || isPinned ? FontWeight.bold : FontWeight.normal,
                color: isActive ? theme.colorScheme.primary : null,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
} 