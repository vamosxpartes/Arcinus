import 'package:flutter/material.dart';

/// Una pantalla genérica para indicar que una sección está en desarrollo.
class ScreenUnderDevelopment extends StatelessWidget {
  /// El título a mostrar en la AppBar (opcional).
  final String? title;

  /// Crea una instancia de [ScreenUnderDevelopment].
  const ScreenUnderDevelopment({this.title, super.key, required String message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'En Desarrollo'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Esta sección está en construcción',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
