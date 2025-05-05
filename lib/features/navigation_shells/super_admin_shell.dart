import 'package:flutter/material.dart';

/// Widget Shell para el rol SuperAdmin.
///
/// Construye la estructura base de UI para las pantallas del superadmin.
class SuperAdminShell extends StatelessWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;

  /// Crea una instancia de [SuperAdminShell].
  const SuperAdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel SuperAdmin'),
      ),
      // drawer: SuperAdminDrawer(), // Ejemplo
      body: child, // Muestra la pantalla de la ruta hija actual
    );
  }
} 