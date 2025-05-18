import 'package:arcinus/core/auth/app_permissions.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_providers.dart';
import 'package:arcinus/features/auth/presentation/providers/auth_state.dart';
import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/presentation/providers/membership_providers.dart';
import 'package:arcinus/features/memberships/presentation/providers/permission_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock para AuthStateNotifier
class MockAuthStateNotifier extends Notifier<AuthState> implements AuthStateNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
  
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> signOut() async {
    throw UnimplementedError();
  }
}

void main() {
  late ProviderContainer container;

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

  setUp(() {
    // Crear el container con overrides
    container = ProviderContainer(
      overrides: [
        // Override para los providers
        authStateNotifierProvider.overrideWith(() => MockAuthStateNotifier()),
        academyMembersProvider('academy1').overrideWith(
          (ref) => Future.value(testMemberships),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('hasPermissionProvider', () {
    test('should return false when no user is authenticated', () async {
      // Act
      final result = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.manageAthletes)).future,
      );
      
      // Assert
      expect(result, false);
    });

    test('should return true for superAdmin regardless of permission', () async {
      // Arrange
      final superAdminUser = User(
        id: 'super-admin-id',
        email: 'admin@example.com',
        name: 'Super Admin',
        role: AppRole.superAdmin,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: superAdminUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final result = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.managePayments)).future,
      );
      
      // Assert
      expect(result, true);
    });

    test('should return true for propietario regardless of permission', () async {
      // Arrange
      final propietarioUser = User(
        id: 'owner-id',
        email: 'owner@example.com',
        name: 'Academy Owner',
        role: AppRole.propietario,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: propietarioUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final result = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.managePayments)).future,
      );
      
      // Assert
      expect(result, true);
    });

    test('should return true for colaborador with specific permission', () async {
      // Arrange
      final colaboradorUser = User(
        id: 'user1', // Corresponde a una membresía existente
        email: 'colaborador@example.com',
        name: 'Colaborador',
        role: AppRole.colaborador,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: colaboradorUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final resultWithPermission = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.manageAthletes)).future,
      );
      
      final resultWithoutPermission = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.managePayments)).future,
      );
      
      // Assert
      expect(resultWithPermission, true);
      expect(resultWithoutPermission, false);
    });

    test('should return false for colaborador without membership', () async {
      // Arrange
      final unknownUser = User(
        id: 'user-unknown', // No existe en las membresías de prueba
        email: 'unknown@example.com',
        name: 'Unknown User',
        role: AppRole.colaborador,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: unknownUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final result = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.manageAthletes)).future,
      );
      
      // Assert
      expect(result, false);
    });

    test('should return false for atleta/padre regardless of permission', () async {
      // Arrange - Atleta
      final atletaUser = User(
        id: 'atleta-id',
        email: 'atleta@example.com',
        name: 'Atleta User',
        role: AppRole.atleta,
      );
      
      // Cambiar override para simular usuario atleta
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: atletaUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act - Atleta
      final atletaResult = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.viewAthletes)).future,
      );
      
      // Arrange - Padre
      final padreUser = User(
        id: 'padre-id',
        email: 'padre@example.com',
        name: 'Padre User',
        role: AppRole.padre,
      );
      
      // Cambiar override para simular usuario padre
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: padreUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act - Padre
      final padreResult = await container.read(
        hasPermissionProvider((academyId: 'academy1', permission: AppPermissions.viewAthletes)).future,
      );
      
      // Assert
      expect(atletaResult, false);
      expect(padreResult, false);
    });
  });

  group('userPermissionsProvider', () {
    test('should return empty list when no user is authenticated', () async {
      // Act
      final result = await container.read(
        userPermissionsProvider('academy1').future,
      );
      
      // Assert
      expect(result, isEmpty);
    });

    test('should return all permissions for superAdmin', () async {
      // Arrange
      final superAdminUser = User(
        id: 'super-admin-id',
        email: 'admin@example.com',
        name: 'Super Admin',
        role: AppRole.superAdmin,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: superAdminUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final result = await container.read(
        userPermissionsProvider('academy1').future,
      );
      
      // Assert
      expect(result, AppPermissions.allPermissions);
    });

    test('should return all permissions for propietario', () async {
      // Arrange
      final propietarioUser = User(
        id: 'owner-id',
        email: 'owner@example.com',
        name: 'Academy Owner',
        role: AppRole.propietario,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: propietarioUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final result = await container.read(
        userPermissionsProvider('academy1').future,
      );
      
      // Assert
      expect(result, AppPermissions.allPermissions);
    });

    test('should return specific permissions for colaborador with membership', () async {
      // Arrange
      final colaboradorUser = User(
        id: 'user1', // Corresponde a una membresía existente
        email: 'colaborador@example.com',
        name: 'Colaborador',
        role: AppRole.colaborador,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: colaboradorUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final result = await container.read(
        userPermissionsProvider('academy1').future,
      );
      
      // Assert
      expect(result, containsAll([
        AppPermissions.manageAthletes,
        AppPermissions.viewAthletes,
        AppPermissions.viewPayments,
      ]));
      expect(result, isNot(contains(AppPermissions.recordAttendance)));
    });

    test('should return empty list for colaborador without membership', () async {
      // Arrange
      final unknownUser = User(
        id: 'user-unknown', // No existe en las membresías de prueba
        email: 'unknown@example.com',
        name: 'Unknown User',
        role: AppRole.colaborador,
      );
      
      // Cambiar override para simular usuario autenticado
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: unknownUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act
      final result = await container.read(
        userPermissionsProvider('academy1').future,
      );
      
      // Assert
      expect(result, isEmpty);
    });

    test('should return empty list for atleta/padre', () async {
      // Arrange - Atleta
      final atletaUser = User(
        id: 'atleta-id',
        email: 'atleta@example.com',
        name: 'Atleta User',
        role: AppRole.atleta,
      );
      
      // Cambiar override para simular usuario atleta
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: atletaUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act - Atleta
      final atletaResult = await container.read(
        userPermissionsProvider('academy1').future,
      );
      
      // Arrange - Padre
      final padreUser = User(
        id: 'padre-id',
        email: 'padre@example.com',
        name: 'Padre User',
        role: AppRole.padre,
      );
      
      // Cambiar override para simular usuario padre
      container = ProviderContainer(
        overrides: [
          authStateNotifierProvider.overrideWith(() {
            return MockAuthStateNotifier()..state = AuthState.authenticated(user: padreUser);
          }),
          academyMembersProvider('academy1').overrideWith(
            (ref) => Future.value(testMemberships),
          ),
        ],
      );
      
      // Act - Padre
      final padreResult = await container.read(
        userPermissionsProvider('academy1').future,
      );
      
      // Assert
      expect(atletaResult, isEmpty);
      expect(padreResult, isEmpty);
    });
  });
} 