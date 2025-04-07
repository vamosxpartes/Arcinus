import 'package:arcinus/shared/constants/permissions.dart';
import 'package:arcinus/shared/models/custom_role.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/auth/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor del servicio de roles personalizados
final customRoleServiceProvider = Provider<CustomRoleService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authState = ref.watch(authStateProvider);
  
  return CustomRoleService(
    firestore,
    authState.valueOrNull,
  );
});

/// Proveedor para obtener roles personalizados de la academia actual
final customRolesProvider = StreamProvider<List<CustomRole>>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = authState.valueOrNull;
  
  if (currentUser == null || currentUser.academyIds.isEmpty) {
    return Stream.value([]);
  }
  
  // Para simplificar, usamos la primera academia del usuario
  final academyId = currentUser.academyIds.first;
  
  return FirebaseFirestore.instance
    .collection('academies')
    .doc(academyId)
    .collection('custom_roles')
    .snapshots()
    .map((snapshot) => 
      snapshot.docs.map((doc) => 
        CustomRole.fromJson({
          'id': doc.id,
          ...doc.data(),
        })
      ).toList()
    );
});

/// Servicio para gestionar roles personalizados
class CustomRoleService {
  final FirebaseFirestore _firestore;
  final User? _currentUser;
  
  CustomRoleService(this._firestore, this._currentUser);
  
  /// Crear un nuevo rol personalizado
  Future<CustomRole> createCustomRole({
    required String name,
    required Map<String, bool> permissions,
    String? description,
  }) async {
    if (_currentUser == null) {
      throw Exception('Usuario no autenticado');
    }
    
    if (_currentUser.academyIds.isEmpty) {
      throw Exception('Usuario no asociado a ninguna academia');
    }
    
    // Usar la primera academia del usuario (se podría mejorar para multi-academia)
    final academyId = _currentUser.academyIds.first;
    
    // Verificar que el usuario tiene permiso para crear roles
    if (_currentUser.permissions[Permissions.assignPermissions] != true) {
      throw Exception('No tienes permiso para crear roles personalizados');
    }
    
    final roleData = {
      'name': name,
      'academyId': academyId,
      'createdBy': _currentUser.id,
      'permissions': permissions,
      'description': description,
      'assignedUserIds': [],
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    final docRef = await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .add(roleData);
    
    // Construir y retornar el objeto creado
    return CustomRole.fromJson({
      'id': docRef.id,
      ...roleData,
      'createdAt': DateTime.now(), // Temporalmente para el objeto retornado
    });
  }
  
  /// Actualizar un rol personalizado existente
  Future<void> updateCustomRole({
    required String roleId,
    String? name,
    String? description,
    Map<String, bool>? permissions,
  }) async {
    if (_currentUser == null) {
      throw Exception('Usuario no autenticado');
    }
    
    if (_currentUser.academyIds.isEmpty) {
      throw Exception('Usuario no asociado a ninguna academia');
    }
    
    // Usar la primera academia del usuario
    final academyId = _currentUser.academyIds.first;
    
    // Verificar que el usuario tiene permiso para modificar roles
    if (_currentUser.permissions[Permissions.assignPermissions] != true) {
      throw Exception('No tienes permiso para modificar roles personalizados');
    }
    
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (permissions != null) updateData['permissions'] = permissions;
    
    await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .doc(roleId)
      .update(updateData);
  }
  
  /// Eliminar un rol personalizado
  Future<void> deleteCustomRole(String roleId) async {
    if (_currentUser == null) {
      throw Exception('Usuario no autenticado');
    }
    
    if (_currentUser.academyIds.isEmpty) {
      throw Exception('Usuario no asociado a ninguna academia');
    }
    
    // Usar la primera academia del usuario
    final academyId = _currentUser.academyIds.first;
    
    // Verificar que el usuario tiene permiso para eliminar roles
    if (_currentUser.permissions[Permissions.assignPermissions] != true) {
      throw Exception('No tienes permiso para eliminar roles personalizados');
    }
    
    // Verificar si hay usuarios con este rol asignado
    final roleDoc = await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .doc(roleId)
      .get();
    
    if (!roleDoc.exists) {
      throw Exception('El rol no existe');
    }
    
    final roleData = roleDoc.data()!;
    // Usamos una lista vacía si assignedUserIds es nulo o no es una lista
    final assignedUsers = roleData['assignedUserIds'] is List
        ? List<String>.from(roleData['assignedUserIds'] as List)
        : <String>[];
    
    if (assignedUsers.isNotEmpty) {
      throw Exception('No se puede eliminar el rol porque está asignado a usuarios');
    }
    
    // Eliminar el rol
    await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .doc(roleId)
      .delete();
  }
  
  /// Asignar un rol personalizado a un usuario
  Future<void> assignRoleToUser(String roleId, String userId) async {
    if (_currentUser == null) {
      throw Exception('Usuario no autenticado');
    }
    
    if (_currentUser.academyIds.isEmpty) {
      throw Exception('Usuario no asociado a ninguna academia');
    }
    
    // Usar la primera academia del usuario
    final academyId = _currentUser.academyIds.first;
    
    // Verificar que el usuario tiene permiso para asignar roles
    if (_currentUser.permissions[Permissions.assignPermissions] != true) {
      throw Exception('No tienes permiso para asignar roles personalizados');
    }
    
    // Obtener el rol para ver sus permisos
    final roleDoc = await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .doc(roleId)
      .get();
    
    if (!roleDoc.exists) {
      throw Exception('El rol no existe');
    }
    
    final roleData = roleDoc.data()!;
    final rolePermissions = Map<String, bool>.from(roleData['permissions'] as Map<dynamic, dynamic>);
    
    // Añadir el usuario a la lista de asignados del rol
    await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .doc(roleId)
      .update({
        'assignedUserIds': FieldValue.arrayUnion([userId]),
      });
    
    // Actualizar los permisos del usuario
    final userDoc = await _firestore
      .collection('users')
      .doc(userId)
      .get();
    
    if (!userDoc.exists) {
      throw Exception('El usuario no existe');
    }
    
    final userData = userDoc.data()!;
    final userPermissions = Map<String, bool>.from(userData['permissions'] as Map<dynamic, dynamic>);
    
    // Aplicar los permisos del rol al usuario
    rolePermissions.forEach((permission, value) {
      // Solo activamos permisos, no los desactivamos
      if (value == true) {
        userPermissions[permission] = true;
      }
    });
    
    // Actualizar usuario con los nuevos permisos
    await _firestore
      .collection('users')
      .doc(userId)
      .update({
        'permissions': userPermissions,
        'customRoleIds': FieldValue.arrayUnion([roleId]),
      });
  }
  
  /// Quitar un rol personalizado de un usuario
  Future<void> removeRoleFromUser(String roleId, String userId) async {
    if (_currentUser == null) {
      throw Exception('Usuario no autenticado');
    }
    
    if (_currentUser.academyIds.isEmpty) {
      throw Exception('Usuario no asociado a ninguna academia');
    }
    
    // Usar la primera academia del usuario
    final academyId = _currentUser.academyIds.first;
    
    // Verificar que el usuario tiene permiso para asignar roles
    if (_currentUser.permissions[Permissions.assignPermissions] != true) {
      throw Exception('No tienes permiso para quitar roles personalizados');
    }
    
    // Quitar al usuario de la lista de asignados del rol
    await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .doc(roleId)
      .update({
        'assignedUserIds': FieldValue.arrayRemove([userId]),
      });
    
    // Quitar el rol de la lista de roles del usuario
    await _firestore
      .collection('users')
      .doc(userId)
      .update({
        'customRoleIds': FieldValue.arrayRemove([roleId]),
      });
    
    // Nota: No quitamos los permisos que fueron otorgados por el rol
    // ya que podrían estar otorgados por otros roles o por el rol base
    // Para recalcular permisos, se puede implementar un método separado
  }
  
  /// Recalcular permisos de un usuario basado en su rol base y roles personalizados
  Future<void> recalculateUserPermissions(String userId) async {
    if (_currentUser == null) {
      throw Exception('Usuario no autenticado');
    }
    
    if (_currentUser.academyIds.isEmpty) {
      throw Exception('Usuario no asociado a ninguna academia');
    }
    
    // Usar la primera academia del usuario
    final academyId = _currentUser.academyIds.first;
    
    // Verificar que el usuario tiene permiso para gestionar permisos
    if (_currentUser.permissions[Permissions.assignPermissions] != true) {
      throw Exception('No tienes permiso para recalcular permisos');
    }
    
    // Obtener el usuario
    final userDoc = await _firestore
      .collection('users')
      .doc(userId)
      .get();
    
    if (!userDoc.exists) {
      throw Exception('El usuario no existe');
    }
    
    final userData = userDoc.data()!;
    final userRole = UserRole.values.firstWhere(
      (role) => role.toString().split('.').last == userData['role'],
      orElse: () => UserRole.guest,
    );
    
    // Obtener permisos base según rol
    final basePermissions = Permissions.getDefaultPermissions(userRole);
    
    // Obtener los IDs de roles personalizados asignados al usuario
    // Usamos una lista vacía si customRoleIds es nulo o no es una lista
    final customRoleIds = userData['customRoleIds'] is List
        ? List<String>.from(userData['customRoleIds'] as List)
        : <String>[];
    
    // Si no tiene roles personalizados, solo actualizamos con los permisos base
    if (customRoleIds.isEmpty) {
      await _firestore
        .collection('users')
        .doc(userId)
        .update({
          'permissions': basePermissions,
        });
      return;
    }
    
    // Obtener los roles personalizados y sus permisos
    final customRolesQuery = await _firestore
      .collection('academies')
      .doc(academyId)
      .collection('custom_roles')
      .where(FieldPath.documentId, whereIn: customRoleIds)
      .get();
    
    // Fusionar permisos de roles personalizados con los permisos base
    final Map<String, bool> mergedPermissions = {...basePermissions};
    
    for (final roleDoc in customRolesQuery.docs) {
      final roleData = roleDoc.data();
      final rolePermissions = Map<String, bool>.from(roleData['permissions'] as Map<dynamic, dynamic>);
      
      // Aplicar permisos del rol (solo activamos permisos, no los desactivamos)
      rolePermissions.forEach((permission, value) {
        if (value == true) {
          mergedPermissions[permission] = true;
        }
      });
    }
    
    // Actualizar usuario con los permisos recalculados
    await _firestore
      .collection('users')
      .doc(userId)
      .update({
        'permissions': mergedPermissions,
      });
  }
} 