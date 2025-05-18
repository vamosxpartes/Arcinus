import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Esta clase es una versión simplificada de la lógica utilizada en los providers de permiso
class PermissionChecker {
  /// Verifica si un usuario tiene un permiso específico en una academia
  static bool hasPermission({
    required User? user,
    required String academyId,
    required String permission,
    required List<MembershipModel> academyMemberships,
  }) {
    // Si no hay usuario autenticado, nunca tiene permisos
    if (user == null) {
      return false;
    }
 
    final userId = user.id;
    
    // SuperAdmin siempre tiene todos los permisos
    if (user.role == AppRole.superAdmin) {
      return true;
    }
    
    // Propietario siempre tiene todos los permisos en su academia
    if (user.role == AppRole.propietario) {
      return true;
    }
    
    // Para colaboradores, verificar permisos específicos
    if (user.role == AppRole.colaborador) {
      try {
        // Buscar la membresía de este usuario
        final membership = academyMemberships.firstWhere(
          (m) => m.userId == userId,
          // Si no se encuentra, retornar una membresía sin permisos
          orElse: () => MembershipModel(
            userId: '',
            academyId: '',
            role: AppRole.desconocido,
            addedAt: DateTime.now(),
            permissions: const [],
          ),
        );
        
        // Verificar si tiene el permiso específico
        return membership.permissions.contains(permission);
      } catch (e) {
        // Si hay error al obtener permisos, negar acceso por seguridad
        return false;
      }
    }
    
    // Atletas y padres no tienen permisos administrativos
    return false;
  }

  /// Obtiene todos los permisos que tiene un usuario en una academia
  static List<String> getUserPermissions({
    required User? user,
    required String academyId,
    required List<MembershipModel> academyMemberships,
  }) {
    // Si no hay usuario autenticado, no tiene permisos
    if (user == null) {
      return [];
    }
 
    final userId = user.id;
    
    // SuperAdmin tiene todos los permisos
    if (user.role == AppRole.superAdmin) {
      return AppPermissions.allPermissions;
    }
    
    // Propietario tiene todos los permisos en su academia
    if (user.role == AppRole.propietario) {
      return AppPermissions.allPermissions;
    }
    
    // Para colaboradores, obtener permisos específicos de su membresía
    if (user.role == AppRole.colaborador) {
      try {
        // Buscar la membresía de este usuario
        final membership = academyMemberships.firstWhere(
          (m) => m.userId == userId,
          orElse: () => MembershipModel(
            userId: '',
            academyId: '',
            role: AppRole.desconocido,
            addedAt: DateTime.now(),
            permissions: const [],
          ),
        );
        
        // Retornar los permisos que tiene
        return membership.permissions;
      } catch (e) {
        return [];
      }
    }
    
    // Atletas y padres por ahora no tienen permisos administrativos
    return [];
  }
}

void main() {
  // Crear una lista de membresías para pruebas
  final testMemberships = [
    MembershipModel(
      id: 'membership1',
      userId: 'user1',
      academyId: 'academy1',
      role: AppRole.colaborador,
      permissions: [
        AppPermissions.manageAthletes,
        AppPermissions.viewAthletes,
        AppPermissions.viewPayments,
      ],
      addedAt: DateTime.now(),
    ),
    MembershipModel(
      id: 'membership2',
      userId: 'user2',
      academyId: 'academy1',
      role: AppRole.colaborador,
      permissions: [
        AppPermissions.viewAthletes,
        AppPermissions.recordAttendance,
      ],
      addedAt: DateTime.now(),
    ),
  ];

  group('PermissionChecker.hasPermission', () {
    test('should return false when no user is provided', () {
      // Act
      final result = PermissionChecker.hasPermission(
        user: null,
        academyId: 'academy1',
        permission: AppPermissions.manageAthletes,
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, false);
    });

    test('should return true for superAdmin regardless of permission', () {
      // Arrange
      final superAdminUser = User(
        id: 'admin-id',
        email: 'admin@example.com',
        name: 'Super Admin',
        role: AppRole.superAdmin,
      );
      
      // Act
      final result = PermissionChecker.hasPermission(
        user: superAdminUser,
        academyId: 'academy1',
        permission: AppPermissions.managePayments,
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, true);
    });

    test('should return true for propietario regardless of permission', () {
      // Arrange
      final propietarioUser = User(
        id: 'owner-id',
        email: 'owner@example.com',
        name: 'Academy Owner',
        role: AppRole.propietario,
      );
      
      // Act
      final result = PermissionChecker.hasPermission(
        user: propietarioUser,
        academyId: 'academy1',
        permission: AppPermissions.managePayments,
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, true);
    });

    test('should return true for colaborador with specific permission', () {
      // Arrange
      final colaboradorUser = User(
        id: 'user1', // Corresponde a una membresía existente
        email: 'colaborador@example.com',
        name: 'Colaborador',
        role: AppRole.colaborador,
      );
      
      // Act
      final resultWithPermission = PermissionChecker.hasPermission(
        user: colaboradorUser,
        academyId: 'academy1',
        permission: AppPermissions.manageAthletes,
        academyMemberships: testMemberships,
      );
      
      final resultWithoutPermission = PermissionChecker.hasPermission(
        user: colaboradorUser,
        academyId: 'academy1',
        permission: AppPermissions.managePayments,
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(resultWithPermission, true);
      expect(resultWithoutPermission, false);
    });

    test('should return false for colaborador without membership', () {
      // Arrange
      final unknownUser = User(
        id: 'user-unknown', // No existe en las membresías de prueba
        email: 'unknown@example.com',
        name: 'Unknown User',
        role: AppRole.colaborador,
      );
      
      // Act
      final result = PermissionChecker.hasPermission(
        user: unknownUser,
        academyId: 'academy1',
        permission: AppPermissions.manageAthletes,
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, false);
    });

    test('should return false for atleta/padre regardless of permission', () {
      // Arrange - Atleta
      final atletaUser = User(
        id: 'atleta-id',
        email: 'atleta@example.com',
        name: 'Atleta User',
        role: AppRole.atleta,
      );
      
      // Act - Atleta
      final atletaResult = PermissionChecker.hasPermission(
        user: atletaUser,
        academyId: 'academy1',
        permission: AppPermissions.viewAthletes,
        academyMemberships: testMemberships,
      );
      
      // Arrange - Padre
      final padreUser = User(
        id: 'padre-id',
        email: 'padre@example.com',
        name: 'Padre User',
        role: AppRole.padre,
      );
      
      // Act - Padre
      final padreResult = PermissionChecker.hasPermission(
        user: padreUser,
        academyId: 'academy1',
        permission: AppPermissions.viewAthletes,
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(atletaResult, false);
      expect(padreResult, false);
    });
  });

  group('PermissionChecker.getUserPermissions', () {
    test('should return empty list when no user is provided', () {
      // Act
      final result = PermissionChecker.getUserPermissions(
        user: null,
        academyId: 'academy1',
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, isEmpty);
    });

    test('should return all permissions for superAdmin', () {
      // Arrange
      final superAdminUser = User(
        id: 'admin-id',
        email: 'admin@example.com',
        name: 'Super Admin',
        role: AppRole.superAdmin,
      );
      
      // Act
      final result = PermissionChecker.getUserPermissions(
        user: superAdminUser,
        academyId: 'academy1',
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, AppPermissions.allPermissions);
    });

    test('should return all permissions for propietario', () {
      // Arrange
      final propietarioUser = User(
        id: 'owner-id',
        email: 'owner@example.com',
        name: 'Academy Owner',
        role: AppRole.propietario,
      );
      
      // Act
      final result = PermissionChecker.getUserPermissions(
        user: propietarioUser,
        academyId: 'academy1',
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, AppPermissions.allPermissions);
    });

    test('should return specific permissions for colaborador with membership', () {
      // Arrange
      final colaboradorUser = User(
        id: 'user1', // Corresponde a una membresía existente
        email: 'colaborador@example.com',
        name: 'Colaborador',
        role: AppRole.colaborador,
      );
      
      // Act
      final result = PermissionChecker.getUserPermissions(
        user: colaboradorUser,
        academyId: 'academy1',
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, containsAll([
        AppPermissions.manageAthletes,
        AppPermissions.viewAthletes,
        AppPermissions.viewPayments,
      ]));
      expect(result, isNot(contains(AppPermissions.recordAttendance)));
    });

    test('should return empty list for colaborador without membership', () {
      // Arrange
      final unknownUser = User(
        id: 'user-unknown', // No existe en las membresías de prueba
        email: 'unknown@example.com',
        name: 'Unknown User',
        role: AppRole.colaborador,
      );
      
      // Act
      final result = PermissionChecker.getUserPermissions(
        user: unknownUser,
        academyId: 'academy1',
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list for atleta/padre', () {
      // Arrange - Atleta
      final atletaUser = User(
        id: 'atleta-id',
        email: 'atleta@example.com',
        name: 'Atleta User',
        role: AppRole.atleta,
      );
      
      // Act - Atleta
      final atletaResult = PermissionChecker.getUserPermissions(
        user: atletaUser,
        academyId: 'academy1',
        academyMemberships: testMemberships,
      );
      
      // Arrange - Padre
      final padreUser = User(
        id: 'padre-id',
        email: 'padre@example.com',
        name: 'Padre User',
        role: AppRole.padre,
      );
      
      // Act - Padre
      final padreResult = PermissionChecker.getUserPermissions(
        user: padreUser,
        academyId: 'academy1',
        academyMemberships: testMemberships,
      );
      
      // Assert
      expect(atletaResult, isEmpty);
      expect(padreResult, isEmpty);
    });
  });
} 