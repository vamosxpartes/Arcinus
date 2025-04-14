import 'dart:async';

import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/local_user_repository.dart';
import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/storage/sync/connectivity_service.dart';
import 'package:arcinus/features/storage/sync/offline_operations_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor para el servicio de sincronización
final syncServiceProvider = Provider<SyncService>((ref) {
  final userService = ref.watch(userServiceProvider);
  final localUserRepository = ref.watch(localUserRepositoryProvider);
  final offlineOperationsService = ref.watch(offlineOperationsServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return SyncService(
    userService: userService,
    localUserRepository: localUserRepository,
    offlineOperationsService: offlineOperationsService,
    connectivityService: connectivityService,
  );
});

/// Servicio para gestionar la sincronización entre la base de datos local y remota
class SyncService {
  final UserService _userService;
  final LocalUserRepository _localUserRepository;
  final OfflineOperationsService _offlineOperationsService;
  final ConnectivityService _connectivityService;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  SyncService({
    required UserService userService,
    required LocalUserRepository localUserRepository,
    required OfflineOperationsService offlineOperationsService,
    required ConnectivityService connectivityService,
  }) : _userService = userService,
       _localUserRepository = localUserRepository,
       _offlineOperationsService = offlineOperationsService,
       _connectivityService = connectivityService {
    // Iniciar sincronización automática
    _startAutomaticSync();
    
    // Suscribirse a cambios de conectividad
    _connectivityService.onConnectivityChanged.listen((hasConnectivity) {
      if (hasConnectivity) {
        // Sincronizar cuando hay conectividad
        syncData();
      }
    });
  }

  /// Inicia sincronización automática cada cierto tiempo
  void _startAutomaticSync() {
    // Sincronizar cada 15 minutos
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      syncData();
    });
  }

  /// Detiene la sincronización automática
  void stopAutomaticSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Sincroniza los datos entre la base de datos local y remota
  Future<void> syncData() async {
    if (_isSyncing || !await _connectivityService.hasConnectivity()) {
      return;
    }
    
    try {
      _isSyncing = true;
      debugPrint('Iniciando sincronización de datos...');
      
      // 1. Procesar operaciones pendientes
      await _processPendingOperations();
      
      // 2. Sincronizar usuarios
      await _syncUsers();
      
      // 3. Limpiar operaciones completadas
      await _offlineOperationsService.clearCompletedOperations();
      
      debugPrint('Sincronización completada exitosamente');
    } catch (e) {
      debugPrint('Error durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Procesa las operaciones pendientes
  Future<void> _processPendingOperations() async {
    debugPrint('Procesando operaciones pendientes...');
    final pendingOperations = _offlineOperationsService.getPendingOperations();
    
    for (final operation in pendingOperations) {
      try {
        if (!await _connectivityService.hasConnectivity()) {
          debugPrint('No hay conectividad. Deteniendo procesamiento de operaciones');
          break;
        }
        
        await _processOperation(operation);
        await _offlineOperationsService.markOperationAsCompleted(operation.id);
      } catch (e) {
        debugPrint('Error al procesar operación ${operation.id}: $e');
        // Continuamos con la siguiente operación
      }
    }
  }

  /// Procesa una operación individual
  Future<void> _processOperation(OfflineOperation operation) async {
    switch (operation.entity) {
      case 'user':
        await _processUserOperation(operation);
        break;
      // Aquí se pueden agregar más entidades según sea necesario
      default:
        debugPrint('Entidad desconocida: ${operation.entity}');
    }
  }

  /// Procesa una operación de usuario
  Future<void> _processUserOperation(OfflineOperation operation) async {
    switch (operation.type) {
      case OperationType.create:
        final user = User.fromJson(Map<String, dynamic>.from(operation.data));
        await _userService.createUserOnly(user);
        break;
        
      case OperationType.update:
        final user = User.fromJson(Map<String, dynamic>.from(operation.data));
        await _userService.updateUser(user);
        break;
        
      case OperationType.delete:
        final userId = operation.entityId;
        final academyId = operation.data['academyId']?.toString() ?? '';
        final roleStr = operation.data['role']?.toString() ?? 'athlete';
        
        // Convertir string a UserRole
        UserRole role;
        switch (roleStr.toLowerCase()) {
          case 'manager':
            role = UserRole.manager;
            break;
          case 'coach':
            role = UserRole.coach;
            break;
          case 'athlete':
            role = UserRole.athlete;
            break;
          case 'parent':
            role = UserRole.parent;
            break;
          case 'owner':
            role = UserRole.owner;
            break;
          case 'superadmin':
            role = UserRole.superAdmin;
            break;
          default:
            role = UserRole.athlete; // Valor por defecto
        }
        
        await _userService.deleteUser(
          userId: userId,
          academyId: academyId,
          role: role,
        );
        break;
    }
  }

  /// Sincroniza usuarios entre la base de datos local y remota
  Future<void> _syncUsers() async {
    debugPrint('Sincronizando usuarios...');
    
    try {
      // Obtener usuario actual (como referencia de autenticación)
      final currentUser = await _userService.getCurrentUser();
      if (currentUser == null) {
        debugPrint('No hay usuario autenticado');
        return;
      }
      
      // Obtener academias del usuario actual
      final academyIds = currentUser.academyIds;
      
      // Para cada academia, sincronizar sus usuarios
      for (final academyId in academyIds) {
        // Verificar conectividad antes de cada operación
        if (!await _connectivityService.hasConnectivity()) {
          debugPrint('No hay conectividad. Deteniendo sincronización de usuarios');
          break;
        }
        
        // Obtener usuarios remotos (Firestore)
        final remoteUsers = await _userService.getUsersByAcademy(academyId);
        
        // Obtener usuarios locales (Hive)
        final localUsers = await _localUserRepository.getUsersByAcademy(academyId);
        
        // Identificar usuarios que están en remoto pero no en local
        final remoteUserIds = remoteUsers.map((u) => u.id).toSet();
        final localUserIds = localUsers.map((u) => u.id).toSet();
        
        // Usuarios para añadir localmente
        final usersToAdd = remoteUsers.where((u) => !localUserIds.contains(u.id));
        
        // Guardar usuarios en local
        for (final user in usersToAdd) {
          await _localUserRepository.saveUser(user);
        }
        
        // Actualizar usuarios que existen en ambos
        final commonUserIds = remoteUserIds.intersection(localUserIds);
        for (final userId in commonUserIds) {
          final remoteUser = remoteUsers.firstWhere((u) => u.id == userId);
          await _localUserRepository.updateUser(remoteUser);
        }
        
        debugPrint('Sincronizado ${usersToAdd.length} nuevos usuarios para academia $academyId');
      }
    } catch (e) {
      debugPrint('Error al sincronizar usuarios: $e');
      rethrow;
    }
  }

  /// Libera recursos
  void dispose() {
    stopAutomaticSync();
  }
} 