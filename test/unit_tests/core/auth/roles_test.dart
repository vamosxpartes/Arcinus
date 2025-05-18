import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/core/auth/roles.dart';

/// Pruebas unitarias para el manejo de roles de usuario (AppRole) en la aplicación.
/// 
/// Estas pruebas verifican que:
/// - AppRole.fromString convierta strings a enum AppRole correctamente
/// - AppRole.fromString gestione strings inválidos o nulos de forma segura
/// - AppRole.toJson serialize correctamente a string
/// - AppRoleExtension.fromJson funcione adecuadamente para todos los valores
/// 
/// Mejores prácticas implementadas:
/// - Pruebas exhaustivas para todos los valores posibles del enum
/// - Validación de casos límite (strings inválidos, valores nulos)
/// - Pruebas específicas para cada funcionalidad

void main() {
  group('AppRole', () {
    test('fromString convierte correctamente strings válidos', () {
      // Arrange & Act & Assert
      expect(AppRole.fromString('superAdmin'), AppRole.superAdmin);
      expect(AppRole.fromString('propietario'), AppRole.propietario);
      expect(AppRole.fromString('colaborador'), AppRole.colaborador);
      expect(AppRole.fromString('atleta'), AppRole.atleta);
      expect(AppRole.fromString('padre'), AppRole.padre);
      expect(AppRole.fromString('desconocido'), AppRole.desconocido);
    });
    
    test('fromString devuelve AppRole.desconocido para strings inválidos', () {
      // Arrange & Act & Assert
      expect(AppRole.fromString('invalidRole'), AppRole.desconocido);
      expect(AppRole.fromString(''), AppRole.desconocido);
      expect(AppRole.fromString(null), AppRole.desconocido);
    });
    
    test('toJson convierte roles a su representación string', () {
      // Arrange & Act & Assert
      expect(AppRole.superAdmin.toJson(), 'superAdmin');
      expect(AppRole.propietario.toJson(), 'propietario');
      expect(AppRole.colaborador.toJson(), 'colaborador');
      expect(AppRole.atleta.toJson(), 'atleta');
      expect(AppRole.padre.toJson(), 'padre');
      expect(AppRole.desconocido.toJson(), 'desconocido');
    });
    
    test('fromJson convierte strings a roles correctamente', () {
      // Arrange & Act & Assert
      expect(AppRoleExtension.fromJson('superAdmin'), AppRole.superAdmin);
      expect(AppRoleExtension.fromJson('propietario'), AppRole.propietario);
      expect(AppRoleExtension.fromJson('colaborador'), AppRole.colaborador);
      expect(AppRoleExtension.fromJson('atleta'), AppRole.atleta);
      expect(AppRoleExtension.fromJson('padre'), AppRole.padre);
      expect(AppRoleExtension.fromJson('desconocido'), AppRole.desconocido);
      expect(AppRoleExtension.fromJson('invalidRole'), AppRole.desconocido);
    });
  });
} 