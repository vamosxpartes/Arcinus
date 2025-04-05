import 'package:flutter/material.dart';

/// Clase para representar un elemento de navegación en la barra inferior
class NavigationItem {
  final IconData icon;
  final String label;
  final String destination;
  
  NavigationItem({
    required this.icon,
    required this.label,
    required this.destination,
  });
} 