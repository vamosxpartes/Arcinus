import 'package:flutter/material.dart';
import 'package:arcinus/core/auth/roles.dart';

class UserRoleUtils {
  /// Obtener un color para el rol
  static Color getRoleColor(String? roleStr) {
    final role = roleStr != null
        ? AppRole.values.firstWhere(
            (r) => r.name == roleStr,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
        
    switch (role) {
      case AppRole.propietario:
        return Colors.purple;
      case AppRole.colaborador:
        return Colors.blue;
      case AppRole.atleta:
        return Colors.green;
      case AppRole.padre:
        return Colors.orange;
      case AppRole.superAdmin:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// Obtener un nombre amigable para el rol
  static String getRoleName(String? roleStr) {
    final role = roleStr != null
        ? AppRole.values.firstWhere(
            (r) => r.name == roleStr,
            orElse: () => AppRole.atleta,
          )
        : AppRole.atleta;
        
    switch (role) {
      case AppRole.propietario:
        return 'Propietario';
      case AppRole.colaborador:
        return 'Colaborador';
      case AppRole.atleta:
        return 'Atleta';
      case AppRole.padre:
        return 'Padre/Responsable';
      case AppRole.superAdmin:
        return 'Administrador';
      default:
        return 'Desconocido';
    }
  }
} 