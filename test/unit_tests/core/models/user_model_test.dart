import 'package:flutter_test/flutter_test.dart';
import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/core/auth/roles.dart';

/// Pruebas unitarias para el modelo User en la aplicación.
/// 
/// Estas pruebas verifican que:
/// - El modelo se cree correctamente con valores requeridos
/// - Los valores por defecto se asignen correctamente
/// - La creación con todos los valores opcionales funcione
/// - La serialización/deserialización a/desde JSON funcione correctamente
/// - El método copyWith funcione para modificar propiedades específicas
/// 
/// Mejores prácticas implementadas:
/// - Validación de todos los campos del modelo
/// - Pruebas para valores por defecto (null-safety)
/// - Conversión completa de ida y vuelta (roundtrip) para JSON
/// - Verificación del funcionamiento de copyWith

void main() {
  group('User Model', () {
    test('se crea correctamente con valores requeridos', () {
      // Arrange & Act
      const user = User(
        id: 'test-id',
        email: 'test@example.com',
      );
      
      // Assert
      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      // Verificar valores por defecto
      expect(user.role, AppRole.desconocido);
      expect(user.name, isNull);
      expect(user.photoUrl, isNull);
      expect(user.academyId, isNull);
      expect(user.permissions, isNull);
      expect(user.athleteIds, isNull);
    });
    
    test('se crea correctamente con todos los valores', () {
      // Arrange & Act
      const user = User(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        role: AppRole.propietario,
        photoUrl: 'https://example.com/photo.jpg',
        academyId: 'academy-1',
        permissions: ['edit', 'view'],
        athleteIds: ['athlete-1', 'athlete-2'],
      );
      
      // Assert
      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, AppRole.propietario);
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.academyId, 'academy-1');
      expect(user.permissions, ['edit', 'view']);
      expect(user.athleteIds, ['athlete-1', 'athlete-2']);
    });
    
    test('fromJson crea un User correctamente', () {
      // Arrange
      final json = {
        'id': 'json-id',
        'email': 'json@example.com',
        'name': 'JSON User',
        'role': 'atleta',
        'photoUrl': 'https://example.com/json.jpg',
        'academyId': 'academy-json',
        'permissions': ['view'],
        'athleteIds': ['athlete-json'],
      };
      
      // Act
      final user = User.fromJson(json);
      
      // Assert
      expect(user.id, 'json-id');
      expect(user.email, 'json@example.com');
      expect(user.name, 'JSON User');
      expect(user.role, AppRole.atleta);
      expect(user.photoUrl, 'https://example.com/json.jpg');
      expect(user.academyId, 'academy-json');
      expect(user.permissions, ['view']);
      expect(user.athleteIds, ['athlete-json']);
    });
    
    test('toJson convierte User a JSON correctamente', () {
      // Arrange
      const user = User(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        role: AppRole.propietario,
        photoUrl: 'https://example.com/photo.jpg',
        academyId: 'academy-1',
        permissions: ['edit', 'view'],
        athleteIds: ['athlete-1', 'athlete-2'],
      );
      
      // Act
      final json = user.toJson();
      
      // Assert
      expect(json['id'], 'test-id');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['role'], 'propietario'); // Se serializa como string
      expect(json['photoUrl'], 'https://example.com/photo.jpg');
      expect(json['academyId'], 'academy-1');
      expect(json['permissions'], ['edit', 'view']);
      expect(json['athleteIds'], ['athlete-1', 'athlete-2']);
    });
    
    test('copyWith modifica propiedades correctamente', () {
      // Arrange
      const originalUser = User(
        id: 'original-id',
        email: 'original@example.com',
      );
      
      // Act
      final updatedUser = originalUser.copyWith(
        name: 'Updated Name',
        role: AppRole.colaborador,
      );
      
      // Assert
      expect(updatedUser.id, 'original-id'); // No cambia
      expect(updatedUser.email, 'original@example.com'); // No cambia
      expect(updatedUser.name, 'Updated Name'); // Actualizado
      expect(updatedUser.role, AppRole.colaborador); // Actualizado
    });
  });
} 