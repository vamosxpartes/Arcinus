import 'package:flutter/material.dart';

/// Widget Shell para el rol Colaborador.
///
/// Construye la estructura base de UI para las pantallas del colaborador.
class CollaboratorShell extends StatelessWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;

  /// Crea una instancia de [CollaboratorShell].
  const CollaboratorShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar AppBar, Drawer/Panel lateral responsivo
    // TODO: La AppBar/Drawer podría necesitar el ID de la academia actual
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Colaborador'),
        // TODO: Mostrar nombre de la academia?
      ),
      // drawer: CollaboratorDrawer(), // Ejemplo
      body: child, // Muestra la pantalla de la ruta hija actual
    );
  }
} 