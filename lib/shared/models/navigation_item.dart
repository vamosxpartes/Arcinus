import 'package:flutter/material.dart';

/// Modelo que representa un elemento de navegación en la aplicación
class NavigationItem {
  /// Ícono que se muestra para el elemento
  final IconData icon;
  
  /// Etiqueta que se muestra para el elemento
  final String label;
  
  /// Ruta de destino cuando se selecciona el elemento
  final String destination;
  
  /// Constructor que requiere todos los campos
  const NavigationItem({
    required this.icon,
    required this.label,
    required this.destination,
  });
  
  /// Sobreescribe el operador de igualdad para comparar elementos
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem &&
        other.icon == icon &&
        other.label == label &&
        other.destination == destination;
  }
  
  /// Sobreescribe el método hashCode para mantener la consistencia con el operador de igualdad
  @override
  int get hashCode => Object.hash(icon, label, destination);
  
  /// Crea una copia del elemento con algunos campos modificados
  NavigationItem copyWith({
    IconData? icon,
    String? label,
    String? destination,
  }) {
    return NavigationItem(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      destination: destination ?? this.destination,
    );
  }
} 