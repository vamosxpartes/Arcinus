import 'package:flutter/material.dart';

/// Widget para mostrar mensajes de error amigables y contextuales
class SmartErrorText extends StatelessWidget {
  /// Mensaje de error original
  final String? error;
  
  /// Campo al que está asociado el error
  final String field;
  
  /// Constructor
  const SmartErrorText({
    super.key, 
    this.error, 
    required this.field,
  });
  
  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline, 
            size: 14, 
            color: Colors.red[700],
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _getSmartErrorMessage() ?? error!,
              style: TextStyle(
                color: Colors.red[700], 
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Convierte errores técnicos en mensajes amigables
  String? _getSmartErrorMessage() {
    if (error == null) return null;
    
    // Errores de Firebase
    if (error!.contains('email-already-in-use')) {
      return 'Este correo ya está registrado. ¿Quieres iniciar sesión?';
    }
    
    if (error!.contains('weak-password')) {
      return 'Esta contraseña es demasiado débil. Elige una más segura.';
    }
    
    if (error!.contains('invalid-email')) {
      return 'El formato de este correo electrónico no es válido.';
    }
    
    if (error!.contains('user-disabled')) {
      return 'Esta cuenta ha sido deshabilitada. Contacta con soporte.';
    }
    
    if (error!.contains('user-not-found') || error!.contains('wrong-password')) {
      return 'Credenciales incorrectas. Revisa tu email y contraseña.';
    }
    
    if (error!.contains('operation-not-allowed')) {
      return 'Esta operación no está permitida en este momento.';
    }
    
    if (error!.contains('too-many-requests')) {
      return 'Demasiados intentos fallidos. Inténtalo más tarde.';
    }
    
    if (error!.contains('network-request-failed')) {
      return 'Error de conexión. Verifica tu conexión a internet.';
    }
    
    // Errores específicos por campo
    if (field == 'email') {
      if (error!.contains('invalid')) {
        return 'Por favor ingresa un correo electrónico válido.';
      }
    }
    
    if (field == 'password') {
      if (error!.contains('length')) {
        return 'La contraseña debe tener al menos 6 caracteres.';
      }
    }
    
    // Devolver null para usar el mensaje original si no hay coincidencia
    return null;
  }
} 