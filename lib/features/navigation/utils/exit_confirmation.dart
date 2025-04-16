import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para controlar si se muestra el diálogo de confirmación para salir
final confirmExitProvider = StateProvider<bool>((ref) => true);

// Muestra un diálogo para confirmar la salida de la aplicación.
// Devuelve `true` si el usuario confirma, `false` en caso contrario.
Future<bool> confirmAppExit(BuildContext context, WidgetRef ref) async {
  // Si la característica está desactivada, permitir salir directamente
  if (!ref.read(confirmExitProvider)) {
    return true;
  }
  
  // En iOS, no es común mostrar diálogos de confirmación para salir
  if (Platform.isIOS) {
    return true;
  }
  
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Seguro que quieres salir?'),
      content: const Text('¿Estás seguro de que quieres salir de Arcinus?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Salir'),
        ),
      ],
    ),
  );
  
  // Si el diálogo se cierra sin seleccionar opción (ej. tocando fuera), devuelve false
  return result ?? false; 
} 