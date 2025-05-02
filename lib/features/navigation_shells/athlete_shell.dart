import 'package:flutter/material.dart';

/// Widget Shell para el rol Atleta.
///
/// Construye la estructura base de UI para las pantallas del atleta.
class AthleteShell extends StatelessWidget {
  /// La pantalla hija actual que debe mostrarse dentro del Shell.
  final Widget child;

  /// Crea una instancia de [AthleteShell].
  const AthleteShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar AppBar, BottomNavigationBar/Drawer responsivo
    // TODO: La AppBar/BottomNav podría necesitar el ID de la academia actual
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Atleta'),
      ),
      // bottomNavigationBar: AthleteBottomNav(), // Ejemplo
      body: child, // Muestra la pantalla de la ruta hija actual
    );
  }
} 