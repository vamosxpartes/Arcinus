import 'package:arcinus/core/auth/presentation/providers/auth_state.dart';
import 'package:flutter/material.dart';

/// Widget que muestra un mensaje de error de autenticación
/// basado en el estado de autenticación.
class AuthErrorMessage extends StatelessWidget {
  /// Construye el widget que muestra el mensaje de error de autenticación.
  const AuthErrorMessage({required this.authState, super.key});

  /// El estado actual de autenticación que contiene la información del error.
  final AuthState authState;

  /// Construye el widget que muestra el mensaje de error de autenticación.
  /// Si no hay error, retorna un widget vacío.
  @override
  Widget build(BuildContext context) {
    // Si no hay error, no mostrar nada
    if (!authState.hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getErrorMessage(),
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el mensaje de error del estado de autenticación o
  /// un mensaje por defecto.
  String _getErrorMessage() {
    return authState.errorMessage ??
        'Ha ocurrido un error durante la autenticación. Inténtalo nuevamente.';
  }
}
