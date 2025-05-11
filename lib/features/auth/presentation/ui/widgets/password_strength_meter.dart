import 'package:flutter/material.dart';

/// Widget que muestra visualmente la fortaleza de una contraseña
class PasswordStrengthMeter extends StatelessWidget {
  /// Contraseña a evaluar
  final String password;

  /// Constructor del widget
  const PasswordStrengthMeter({
    super.key, 
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final strengthText = _getTextForStrength(strength);
    final strengthColor = _getColorForStrength(strength);

    // No mostrar nada si no hay contraseña
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength / 4,
            backgroundColor: Colors.grey[200],
            color: strengthColor,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          strengthText,
          style: TextStyle(
            fontSize: 12,
            color: strengthColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Calcula la fortaleza de la contraseña en una escala de 0-4
  int _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    
    // Verificar longitud mínima
    if (password.length >= 8) strength++;
    
    // Verificar presencia de números
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    
    // Verificar presencia de letras minúsculas y mayúsculas
    if (password.contains(RegExp(r'[a-z]')) && 
        password.contains(RegExp(r'[A-Z]'))) strength++;
    
    // Verificar presencia de caracteres especiales
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  /// Obtiene el color según la fortaleza
  Color _getColorForStrength(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el texto descriptivo según la fortaleza
  String _getTextForStrength(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Muy débil';
      case 2:
        return 'Débil';
      case 3:
        return 'Buena';
      case 4:
        return 'Fuerte';
      default:
        return '';
    }
  }
} 