import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/features/theme/ux/app_theme.dart';

/// Configuración para personalizar la apariencia de [ManagerShell] desde una pantalla hija.
@immutable // Es buena práctica para clases usadas en StateProviders si se comparan.
class ManagerShellConfig {
  final bool extendBodyBehindAppBar;
  final Color appBarBackgroundColor;
  final List<Widget>? appBarActions;
  final String? appBarTitle; // Si es null, ManagerShell usará currentScreenTitleProvider
  final Color appBarIconColor; // Para el ícono del drawer y las acciones
  final Color appBarTitleColor; // Color del título del AppBar

  const ManagerShellConfig({
    this.extendBodyBehindAppBar = false,
    this.appBarBackgroundColor = AppTheme.blackSwarm,
    this.appBarActions,
    this.appBarTitle,
    this.appBarIconColor = AppTheme.magnoliaWhite,
    this.appBarTitleColor = AppTheme.magnoliaWhite,
  });

  ManagerShellConfig copyWith({
    bool? extendBodyBehindAppBar,
    Color? appBarBackgroundColor,
    List<Widget>? appBarActions,
    String? appBarTitle,
    Color? appBarIconColor,
    Color? appBarTitleColor,
  }) {
    return ManagerShellConfig(
      extendBodyBehindAppBar: extendBodyBehindAppBar ?? this.extendBodyBehindAppBar,
      appBarBackgroundColor: appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarActions: appBarActions ?? this.appBarActions,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      appBarIconColor: appBarIconColor ?? this.appBarIconColor,
      appBarTitleColor: appBarTitleColor ?? this.appBarTitleColor,
    );
  }

  // Implementar == y hashCode si se necesita comparar instancias directamente.
  // Por ahora, lo omitimos para simplicidad, pero es recomendable con @immutable.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagerShellConfig &&
          runtimeType == other.runtimeType &&
          extendBodyBehindAppBar == other.extendBodyBehindAppBar &&
          appBarBackgroundColor == other.appBarBackgroundColor &&
          // Comparar listas de widgets puede ser complejo, usualmente por referencia o longitud/tipo.
          // Para este caso, una comparación superficial puede ser suficiente si las acciones no cambian frecuentemente.
          // Considerar package:collection deepCollectionEquality si es necesario.
          appBarActions == other.appBarActions && 
          appBarTitle == other.appBarTitle &&
          appBarIconColor == other.appBarIconColor &&
          appBarTitleColor == other.appBarTitleColor;

  @override
  int get hashCode =>
      extendBodyBehindAppBar.hashCode ^
      appBarBackgroundColor.hashCode ^
      appBarActions.hashCode ^ // Similar a ==, la comparación de hashCode para listas es delicada.
      appBarTitle.hashCode ^
      appBarIconColor.hashCode ^
      appBarTitleColor.hashCode;
}

/// Provider para que las pantallas hijas configuren dinámicamente el ManagerShell.
final managerShellConfigProvider = StateProvider<ManagerShellConfig?>((ref) => null); 