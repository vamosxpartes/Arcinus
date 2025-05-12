import 'package:flutter/material.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';

/// Un widget de barra de pestañas personalizado que se parece a segmentos redondeados.
class CustomSegmentedTabbar extends StatefulWidget {
  final TabController controller;
  final List<String> tabs;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const CustomSegmentedTabbar({
    super.key,
    required this.controller,
    required this.tabs,
    this.selectedColor = AppTheme.blackSwarm, 
    this.unselectedColor = AppTheme.mediumGray,
    this.selectedTextColor = AppTheme.magnoliaWhite,
    this.unselectedTextColor = AppTheme.lightGray,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.borderRadius = 20.0,
  });

  @override
  State<CustomSegmentedTabbar> createState() => _CustomSegmentedTabbarState();
}

class _CustomSegmentedTabbarState extends State<CustomSegmentedTabbar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.controller.index;
    widget.controller.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabSelection);
    super.dispose();
  }

  void _handleTabSelection() {
    // Actualizar el estado local solo si el índice realmente cambió
    if (widget.controller.index != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.controller.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Espacio alrededor de la barra
      color: AppTheme.blackSwarm, // Fondo para el contenedor de la barra
      child: Row(
        children: List.generate(widget.tabs.length, (index) {
          final isSelected = index == _selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                // Solo animar si el índice es diferente
                if (widget.controller.index != index) {
                    widget.controller.animateTo(index);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0), // Espacio entre segmentos
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: isSelected ? widget.selectedColor : widget.unselectedColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Text(
                  widget.tabs[index].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? widget.selectedTextColor : widget.unselectedTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13, // Ajustar tamaño según sea necesario
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
} 