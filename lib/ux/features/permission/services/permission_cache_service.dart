import 'package:arcinus/shared/models/user.dart';

/// Servicio para cachear permisos y optimizar la verificación
class PermissionCacheService {
  final Map<String, bool> _permissionCache = {};
  final Map<String, bool> _batchPermissionCache = {};
  DateTime _lastCacheUpdate = DateTime.now();
  User? _cachedUser;
  
  /// Inicializa o actualiza la caché con los permisos del usuario
  void updateCache(User? user) {
    // Si el usuario es el mismo que ya está en caché, no hacemos nada
    if (_cachedUser?.id == user?.id) return;
    
    // Limpiamos la caché
    _permissionCache.clear();
    _batchPermissionCache.clear();
    _cachedUser = user;
    _lastCacheUpdate = DateTime.now();
  }
  
  /// Invalida la caché si ha pasado demasiado tiempo o si el usuario ha cambiado
  void _validateCache(User? currentUser) {
    final now = DateTime.now();
    final cacheAge = now.difference(_lastCacheUpdate);
    
    // Si han pasado más de 5 minutos o el usuario ha cambiado, actualizamos la caché
    if (cacheAge.inMinutes > 5 || currentUser?.id != _cachedUser?.id) {
      updateCache(currentUser);
    }
  }

  /// Verifica si el usuario tiene un permiso específico, usando caché
  bool hasPermission(User? user, String permission) {
    if (user == null) return false;
    
    _validateCache(user);
    
    // Verificar si el permiso ya está en caché
    if (_permissionCache.containsKey(permission)) {
      return _permissionCache[permission]!;
    }
    
    // Si no está en caché, verificamos y lo guardamos
    final hasPermission = user.permissions[permission] == true;
    _permissionCache[permission] = hasPermission;
    
    return hasPermission;
  }
  
  /// Verifica si el usuario tiene todos los permisos especificados, usando caché
  bool hasAllPermissions(User? user, List<String> permissions) {
    if (user == null) return false;
    if (permissions.isEmpty) return true;
    
    _validateCache(user);
    
    // Creamos una key para esta combinación de permisos
    final cacheKey = 'all:${permissions.join(',')}';
    
    // Verificar si esta combinación ya está en caché
    if (_batchPermissionCache.containsKey(cacheKey)) {
      return _batchPermissionCache[cacheKey]!;
    }
    
    // Si no está en caché, verificamos individualmente usando la caché individual
    // y guardamos el resultado en la caché de lotes
    final result = permissions.every((permission) => hasPermission(user, permission));
    _batchPermissionCache[cacheKey] = result;
    
    return result;
  }
  
  /// Verifica si el usuario tiene al menos uno de los permisos especificados, usando caché
  bool hasAnyPermission(User? user, List<String> permissions) {
    if (user == null) return false;
    if (permissions.isEmpty) return false;
    
    _validateCache(user);
    
    // Creamos una key para esta combinación de permisos
    final cacheKey = 'any:${permissions.join(',')}';
    
    // Verificar si esta combinación ya está en caché
    if (_batchPermissionCache.containsKey(cacheKey)) {
      return _batchPermissionCache[cacheKey]!;
    }
    
    // Si no está en caché, verificamos individualmente usando la caché individual
    // y guardamos el resultado en la caché de lotes
    final result = permissions.any((permission) => hasPermission(user, permission));
    _batchPermissionCache[cacheKey] = result;
    
    return result;
  }
  
  /// Obtiene un mapa de permisos precalculados para un conjunto de acciones específicas
  /// Útil para UI que necesita verificar múltiples permisos a la vez
  Map<String, bool> getPermissionBatch(User? user, List<String> permissions) {
    if (user == null) {
      return {for (var permission in permissions) permission: false};
    }
    
    _validateCache(user);
    
    // Creamos un mapa con los resultados, aprovechando la caché individual
    return {
      for (var permission in permissions) 
        permission: hasPermission(user, permission)
    };
  }
  
  /// Limpia la caché completamente
  void clearCache() {
    _permissionCache.clear();
    _batchPermissionCache.clear();
    _cachedUser = null;
  }
} 