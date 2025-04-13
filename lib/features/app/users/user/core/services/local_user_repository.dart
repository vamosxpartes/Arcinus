import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/storage/hive/hive_config.dart';
import 'package:arcinus/features/storage/hive/user_hive_model.dart';
import 'package:arcinus/features/storage/sync/offline_operations_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Proveedor para el repositorio local de usuarios
final localUserRepositoryProvider = Provider<LocalUserRepository>((ref) {
  final offlineOperationsService = ref.watch(offlineOperationsServiceProvider);
  return LocalUserRepository(offlineOperationsService);
});

/// Repositorio para gestión local de usuarios utilizando Hive
class LocalUserRepository {
  final OfflineOperationsService _offlineOperationsService;
  Box<dynamic>? _userBox;
  final String _entityName = 'user';

  LocalUserRepository(this._offlineOperationsService) {
    _init();
  }

  Future<void> _init() async {
    _userBox = Hive.box(HiveConfig.userBox);
  }

  /// Guarda un usuario en la base de datos local
  Future<void> saveUser(User user) async {
    try {
      final hiveModel = UserHiveModel.fromUser(user);
      await _userBox?.put(user.id, hiveModel.toJson());
      debugPrint('Usuario guardado localmente: ${user.id}');
    } catch (e) {
      debugPrint('Error al guardar usuario localmente: $e');
      rethrow;
    }
  }

  /// Obtiene un usuario por su ID
  Future<User?> getUserById(String userId) async {
    try {
      final userData = _userBox?.get(userId);
      if (userData == null) {
        return null;
      }
      
      final userHiveModel = UserHiveModel.fromJson(
        Map<dynamic, dynamic>.from(userData as Map),
      );
      return userHiveModel.toUser();
    } catch (e) {
      debugPrint('Error al obtener usuario localmente: $e');
      return null;
    }
  }

  /// Obtiene todos los usuarios
  Future<List<User>> getAllUsers() async {
    try {
      final users = <User>[];
      
      _userBox?.values.forEach((userData) {
        try {
          final userHiveModel = UserHiveModel.fromJson(
            Map<dynamic, dynamic>.from(userData as Map),
          );
          users.add(userHiveModel.toUser());
        } catch (e) {
          debugPrint('Error al convertir usuario: $e');
        }
      });
      
      return users;
    } catch (e) {
      debugPrint('Error al obtener todos los usuarios localmente: $e');
      return [];
    }
  }

  /// Elimina un usuario por su ID
  Future<void> deleteUser(String userId) async {
    try {
      await _userBox?.delete(userId);
      debugPrint('Usuario eliminado localmente: $userId');
    } catch (e) {
      debugPrint('Error al eliminar usuario localmente: $e');
      rethrow;
    }
  }

  /// Actualiza un usuario existente
  Future<void> updateUser(User user) async {
    try {
      final userData = _userBox?.get(user.id);
      if (userData != null) {
        final hiveModel = UserHiveModel.fromUser(user);
        await _userBox?.put(user.id, hiveModel.toJson());
        debugPrint('Usuario actualizado localmente: ${user.id}');
      } else {
        throw Exception('Usuario no encontrado localmente: ${user.id}');
      }
    } catch (e) {
      debugPrint('Error al actualizar usuario localmente: $e');
      rethrow;
    }
  }

  /// Guarda un usuario y encola una operación para sincronización
  Future<void> saveUserWithSync(User user) async {
    await saveUser(user);
    
    // Encolar operación para sincronización
    await _offlineOperationsService.enqueueOperation(
      _entityName,
      user.id,
      OperationType.create,
      user.toJson(),
    );
  }

  /// Actualiza un usuario y encola una operación para sincronización
  Future<void> updateUserWithSync(User user) async {
    await updateUser(user);
    
    // Encolar operación para sincronización
    await _offlineOperationsService.enqueueOperation(
      _entityName,
      user.id,
      OperationType.update,
      user.toJson(),
    );
  }

  /// Elimina un usuario y encola una operación para sincronización
  Future<void> deleteUserWithSync(String userId) async {
    await deleteUser(userId);
    
    // Encolar operación para sincronización
    await _offlineOperationsService.enqueueOperation(
      _entityName,
      userId,
      OperationType.delete,
      {'id': userId},
    );
  }

  /// Obtiene todos los usuarios con un rol específico
  Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((user) => user.role == role).toList();
    } catch (e) {
      debugPrint('Error al obtener usuarios por rol localmente: $e');
      return [];
    }
  }

  /// Obtiene todos los usuarios asociados a una academia específica
  Future<List<User>> getUsersByAcademy(String academyId) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((user) => user.academyIds.contains(academyId)).toList();
    } catch (e) {
      debugPrint('Error al obtener usuarios por academia localmente: $e');
      return [];
    }
  }

  /// Obtiene todos los usuarios con un rol específico y asociados a una academia
  Future<List<User>> getUsersByRoleAndAcademy(UserRole role, String academyId) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where(
        (user) => user.role == role && user.academyIds.contains(academyId)
      ).toList();
    } catch (e) {
      debugPrint('Error al obtener usuarios por rol y academia localmente: $e');
      return [];
    }
  }
} 