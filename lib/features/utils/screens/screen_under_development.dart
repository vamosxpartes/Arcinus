import 'package:flutter/material.dart';

/// Una pantalla genérica para indicar que una sección está en desarrollo.
class ScreenUnderDevelopment extends StatelessWidget {
  /// El título a mostrar en la AppBar (opcional).
  final String? title;
  
  /// El mensaje personalizado a mostrar.
  final String message;

  /// Crea una instancia de [ScreenUnderDevelopment].
  const ScreenUnderDevelopment({this.title, required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'En Desarrollo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Esta sección está en construcción',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
