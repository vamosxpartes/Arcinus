import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/features/app/users/athlete/core/models/athlete_profile.dart';
import 'package:arcinus/features/app/users/athlete/core/services/athlete_repository.dart';
import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:arcinus/features/app/users/user/core/services/local_user_repository.dart';
import 'package:arcinus/features/app/users/user/core/services/user_image_service.dart';
import 'package:arcinus/features/auth/core/repositories/auth_repository.dart';
import 'package:arcinus/features/auth/core/repositories/firebase_auth_repository.dart';
import 'package:arcinus/features/permissions/core/models/permissions.dart';
import 'package:arcinus/features/storage/sync/connectivity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final athleteRepository = ref.watch(athleteRepositoryProvider);
  final localUserRepository = ref.watch(localUserRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final userImageService = ref.watch(userImageServiceProvider);
  
  return UserService(
    FirebaseFirestore.instance,
    FirebaseAuthRepository(),
    athleteRepository,
    localUserRepository,
    connectivityService,
    userImageService,
  );
});

class UserService {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final AthleteRepository _athleteRepository;
  final LocalUserRepository _localUserRepository;
  final ConnectivityService _connectivityService;
  final UserImageService _userImageService;

  UserService(
    this._firestore, 
    this._authRepository, 
    this._athleteRepository,
    this._localUserRepository,
    this._connectivityService,
    this._userImageService,
  );

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _ownersCollection =>
      _firestore.collection('owners');

  CollectionReference<Map<String, dynamic>> get _superadminsCollection =>
      _firestore.collection('superadmins');

  CollectionReference<Map<String, dynamic>> _academyUsersCollection(String academyId) =>
      _firestore.collection('academies').doc(academyId).collection('users');

  // MÉTODOS GENERALES PARA TODOS LOS USUARIOS

  // Obtener el usuario actual (autenticado)
  Future<User?> getCurrentUser() async {
    return _authRepository.currentUser();
  }

  // Obtener un usuario por ID
  Future<User?> getUserById(String userId) async {
    try {
      developer.log(
        'getUserById: Buscando usuario con ID: $userId',
        name: 'UserDetails-Delete',
      );
      
      // Primero intentar obtener desde la base de datos local
      final localUser = await _localUserRepository.getUserById(userId);
      
      developer.log(
        'getUserById: Resultado local: ${localUser != null ? "Usuario encontrado localmente" : "Usuario NO encontrado localmente"}',
        name: 'UserDetails-Delete',
      );
      
      if (localUser != null) {
        debugPrint('Usuario obtenido desde DB local: $userId');
        return localUser;
      }
      
      developer.log(
        'getUserById: Usuario no encontrado localmente, buscando remotamente...',
        name: 'UserDetails-Delete',
      );
      
      // Si no está en local y no hay conectividad, retornar null
      if (!await _connectivityService.hasConnectivity()) {
        debugPrint('Sin conectividad, no se puede obtener usuario remoto');
        developer.log(
          'getUserById: Sin conectividad para buscar remotamente',
          name: 'UserDetails-Delete',
        );
        return null;
      }
      
      developer.log(
        'getUserById: Buscando en diferentes colecciones de Firestore',
        name: 'UserDetails-Delete',
      );
      
      // Buscar en las diferentes colecciones
      // 1. Superadmins
      final superadminsQuery = await _superadminsCollection.get();
      for (final doc in superadminsQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['id'] == userId) {
          return User.fromJson(data);
        }
      }
      
      // 2. Owners
      final ownersQuery = await _ownersCollection.get();
      for (final doc in ownersQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['id'] == userId) {
          return User.fromJson(data);
        }
      }
      
      // 3. Usuarios regulares
      final regularUsersQuery = await _usersCollection.get();
      for (final doc in regularUsersQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['id'] == userId) {
          return User.fromJson(data);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error al obtener usuario: $e');
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // Obtener usuarios por rol
  Future<List<User>> getUsersByRole(UserRole role, {String? academyId}) async {
    try {
      // Primero intentar obtener desde la base de datos local
      if (academyId != null) {
        final localUsers = await _localUserRepository.getUsersByRoleAndAcademy(role, academyId);
        if (localUsers.isNotEmpty) {
          debugPrint('Usuarios por rol obtenidos desde DB local: ${localUsers.length}');
          return localUsers;
        }
      } else {
        final localUsers = await _localUserRepository.getUsersByRole(role);
        if (localUsers.isNotEmpty) {
          debugPrint('Usuarios por rol obtenidos desde DB local: ${localUsers.length}');
          return localUsers;
        }
      }
      
      // Si no hay usuarios locales y no hay conectividad, retornar lista vacía
      if (!await _connectivityService.hasConnectivity()) {
        debugPrint('Sin conectividad, no se pueden obtener usuarios remotos');
        return [];
      }
      
      // Obtener desde Firestore según el rol y colección correspondiente
      final users = <User>[];
      
      if (role == UserRole.superAdmin) {
        // Superadmins están en su propia colección
        final querySnap = await _superadminsCollection.get();
        for (final doc in querySnap.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          users.add(User.fromJson(data));
        }
      } else if (role == UserRole.owner) {
        // Owners están en su propia colección
        final querySnap = await _ownersCollection.get();
        for (final doc in querySnap.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          users.add(User.fromJson(data));
        }
        
        // Si se especifica academia, filtrar por los que tengan esa academia
        if (academyId != null) {
          return users.where((user) => user.academyIds.contains(academyId)).toList();
        }
      } else if (academyId != null) {
        // Usuarios de un rol específico en una academia específica
        final querySnap = await _academyUsersCollection(academyId)
            .where('role', isEqualTo: role.toString().split('.').last)
            .get();
            
        for (final doc in querySnap.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          users.add(User.fromJson(data));
        }
      } else {
        // Buscar en todas las academias para un rol específico
        final academiesSnap = await _firestore.collection('academies').get();
        
        for (final academyDoc in academiesSnap.docs) {
          final academyId = academyDoc.id;
          final usersSnap = await _academyUsersCollection(academyId)
              .where('role', isEqualTo: role.toString().split('.').last)
              .get();
              
          for (final doc in usersSnap.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            users.add(User.fromJson(data));
          }
        }
        
        // Para compatibilidad - buscar también en colección principal
        final querySnap = await _usersCollection
            .where('role', isEqualTo: role.toString().split('.').last)
            .get();
            
        for (final doc in querySnap.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          // Verificar que no esté duplicado
          if (!users.any((u) => u.id == doc.id)) {
            users.add(User.fromJson(data));
          }
        }
      }
      
      // Guardar usuarios en la base de datos local
      for (final user in users) {
        await _localUserRepository.saveUser(user);
      }
      
      return users;
    } catch (e) {
      debugPrint('Error al obtener usuarios por rol: $e');
      throw Exception('Error al obtener usuarios por rol: $e');
    }
  }

  // Obtener usuarios por academia
  Future<List<User>> getUsersByAcademy(String academyId) async {
    try {
      // Primero intentar obtener desde la base de datos local
      final localUsers = await _localUserRepository.getUsersByAcademy(academyId);
      if (localUsers.isNotEmpty) {
        debugPrint('Usuarios por academia obtenidos desde DB local: ${localUsers.length}');
        return localUsers;
      }
      
      // Si no hay usuarios locales y no hay conectividad, retornar lista vacía
      if (!await _connectivityService.hasConnectivity()) {
        debugPrint('Sin conectividad, no se pueden obtener usuarios remotos');
        return [];
      }
      
      // Obtener desde Firestore - ahora en la subcolección de la academia
      final users = <User>[];
      
      // 1. Usuarios en la subcolección de la academia
      final academyUsersSnap = await _academyUsersCollection(academyId).get();
      
      for (final doc in academyUsersSnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        users.add(User.fromJson(data));
      }
      
      // 2. Obtener propietario de la academia (está en la colección owners)
      final academyDoc = await _firestore.collection('academies').doc(academyId).get();
      if (academyDoc.exists) {
        final academyData = academyDoc.data();
        if (academyData != null && academyData.containsKey('ownerId')) {
          final ownerId = academyData['ownerId'] as String;
          final ownerDoc = await _ownersCollection.doc(ownerId).get();
          
          if (ownerDoc.exists) {
            final ownerData = ownerDoc.data()!;
            ownerData['id'] = ownerDoc.id;
            users.add(User.fromJson(ownerData));
          }
        }
      }
      
      // 3. Para compatibilidad - buscar también en la colección principal por usuarios con esta academia
      final querySnap = await _usersCollection
          .where('academyIds', arrayContains: academyId)
          .get();
      
      for (final doc in querySnap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        // Verificar que no esté duplicado
        if (!users.any((u) => u.id == doc.id)) {
          users.add(User.fromJson(data));
        }
      }
      
      // Guardar usuarios en la base de datos local
      for (final user in users) {
        await _localUserRepository.saveUser(user);
      }
      
      return users;
    } catch (e) {
      debugPrint('Error al obtener usuarios por academia: $e');
      throw Exception('Error al obtener usuarios por academia: $e');
    }
  }

  // Crear un nuevo usuario (solo registro en Firestore)
  Future<User> createUser({
    required String name,
    required UserRole role,
    String? academyId,
    int? number,
    String? profileImageUrl,
  }) async {
    try {
      developer.log(
        'Iniciando creación de usuario (Firestore): $name - rol: $role',
        name: 'UserService',
      );
      
      // Verificar conectividad (necesaria para obtener ID y guardar)
      if (!await _connectivityService.hasConnectivity()) {
        throw Exception('No hay conectividad para crear usuario en Firestore');
      }
      
      // Determinar la colección y generar un ID
      DocumentReference userRef;
      if (role == UserRole.superAdmin) {
        userRef = _superadminsCollection.doc(); 
      } else if (role == UserRole.owner) {
        userRef = _ownersCollection.doc();
      } else if (academyId != null) {
        userRef = _academyUsersCollection(academyId).doc();
      } else {
        developer.log(
          'ADVERTENCIA: Creando usuario sin academia. Esta funcionalidad está en desuso.',
          name: 'UserService',
        );
        throw Exception('Se requiere una academia para crear un usuario regular');
      }
      
      final userId = userRef.id;

      // Crear el objeto User (sin email por defecto, podría ser añadido después)
      final user = User(
        id: userId,
        name: name, 
        email: '', // Inicializar email como vacío o nulo según el modelo
        role: role,
        permissions: Permissions.getDefaultPermissions(role),
        academyIds: academyId != null ? [academyId] : [],
        number: number,
        createdAt: DateTime.now(),
        profileImageUrl: profileImageUrl,
      );

      // Guardar usuario según su rol y academia
      final userData = user.toJson();
      userData.remove('id'); // No incluir ID en los datos a guardar

      await userRef.set(userData);
      
      // Actualizar la academia si es un usuario regular
      if (role != UserRole.superAdmin && role != UserRole.owner && academyId != null) {
        await _firestore.collection('academies').doc(academyId).update({
          'userIds': FieldValue.arrayUnion([user.id]),
          '${role.toString().split('.').last}Ids': FieldValue.arrayUnion([user.id]),
        });
      }
      
      // Guardar en DB local
      await _localUserRepository.saveUser(user);
      
      developer.log(
        'Usuario creado (Firestore) exitosamente: ${user.id} - ${user.name}',
        name: 'UserService',
      );
      return user;
      
    } catch (e) {
      developer.log(
        'Error al crear usuario (Firestore): $e',
        name: 'UserService',
        error: e,
      );
      throw Exception('Error al crear usuario (Firestore): $e');
    }
  }

  // Crear un usuario sin iniciar sesión (usado para sincronización) - Ya no necesita email/pass
  Future<User> createUserOnly(User user) async {
    try {
      final userData = user.toJson();
      userData.remove('id'); // No incluir ID
      
      // Determinar colección según rol y academias
      if (user.role == UserRole.superAdmin) {
        await _superadminsCollection.doc(user.id).set(userData);
      } else if (user.role == UserRole.owner) {
        await _ownersCollection.doc(user.id).set(userData);
      } else if (user.academyIds.isNotEmpty) {
        // Guardar en todas las academias a las que pertenece
        for (final academyId in user.academyIds) {
          await _academyUsersCollection(academyId).doc(user.id).set(userData);
        }
      } else {
        // Lanzar error si es un usuario regular sin academia
        developer.log(
          'ADVERTENCIA: Intento de crear usuario sin academia. Esta funcionalidad está en desuso.',
          name: 'UserService',
        );
        throw Exception('Se requiere una academia para crear un usuario regular');
      }
      
      return user;
    } catch (e) {
      debugPrint('Error al crear usuario sin iniciar sesión: $e');
      throw Exception('Error al crear usuario sin iniciar sesión: $e');
    }
  }

  // Actualizar un usuario existente
  Future<User> updateUser(User user) async {
    try {
      developer.log(
        'Iniciando actualización de usuario (Firestore): ${user.id} - ${user.name}',
        name: 'UserService',
      );
      
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (hasConnectivity) {
        // Actualizar SOLO en Firestore
        // Removed: await _authRepository.updateUser(user);
        
        // Determinar la colección correcta para actualizar
        DocumentReference userRef;
        if (user.role == UserRole.superAdmin) {
          userRef = _superadminsCollection.doc(user.id);
        } else if (user.role == UserRole.owner) {
          userRef = _ownersCollection.doc(user.id);
        } else if (user.academyIds.isNotEmpty) {
          // Asumimos que actualizamos en la primera academia por simplicidad,
          // o podríamos requerir academyId si la lógica de actualización es específica
          // Por ahora, actualizamos en la primera academia encontrada.
          // Idealmente, la actualización debería ocurrir en todas las academias relevantes.
          // Considerar una estrategia de actualización más robusta si un usuario puede
          // tener datos diferentes por academia.
          String academyIdToUpdate = user.academyIds.first;
          userRef = _academyUsersCollection(academyIdToUpdate).doc(user.id);
        } else {
           throw Exception('Usuario regular sin academia no puede ser actualizado.');
        }

        final userData = user.toJson();
        userData.remove('id');
        await userRef.update(userData);
        
        // Actualizar también en local
        await _localUserRepository.updateUser(user);
      } else {
        // Solo actualizar en local y encolar para sincronización
        await _localUserRepository.updateUserWithSync(user);
        debugPrint('Usuario actualizado localmente y encolado para sincronización: ${user.id}');
      }
      
      developer.log(
        'Usuario actualizado (Firestore) exitosamente: ${user.id} - ${user.name}',
        name: 'UserService',
      );
      return user;
    } catch (e) {
      developer.log(
        'Error al actualizar usuario (Firestore): $e',
        name: 'UserService',
        error: e,
      );
      throw Exception('Error al actualizar usuario (Firestore): $e');
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUser({
    required String userId,
    required String academyId,
    required UserRole role,
  }) async {
    try {
      developer.log(
        '====== INICIANDO ELIMINACIÓN DE USUARIO [Método principal deleteUser v2] ======',
        name: 'UserService-Delete',
      );
      
      developer.log(
        'Parámetros recibidos: userId=$userId, academyId=$academyId, role=$role',
        name: 'UserService-Delete',
      );

      bool deleted = false;

      // >> PASO 1: Intentar eliminar como usuario pendiente (pre-registro)
      developer.log(
        '>> PASO 1: Verificando si es un usuario pendiente (pendingActivations)...',
        name: 'UserService-Delete',
      );
      final pendingRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('pendingActivations')
          .doc(userId); // userId aquí es el código de activación

      try {
        final pendingDoc = await pendingRef.get();
        if (pendingDoc.exists) {
          developer.log(
            'Usuario PENDIENTE encontrado. Eliminando de pendingActivations...',
            name: 'UserService-Delete',
          );
          await pendingRef.delete();
          deleted = true;
          developer.log(
            'Usuario pendiente eliminado exitosamente de Firestore.',
            name: 'UserService-Delete',
          );
          // Para usuarios pendientes, no hay necesidad de actualizar academia ni limpiar dependencias complejas.
        } else {
          developer.log(
            'No encontrado en pendingActivations. Buscando como usuario activo...',
            name: 'UserService-Delete',
          );
        }
      } catch (e) {
         developer.log(
            'Error al verificar/eliminar usuario pendiente: $e. Continuando para buscar como activo.',
            name: 'UserService-Delete',
            error: e,
          );
      }

      // >> PASO 2: Si no se eliminó como pendiente, intentar eliminar como usuario activo
      if (!deleted) {
        developer.log(
          '>> PASO 2: Buscando documento de usuario activo en users...',
          name: 'UserService-Delete',
        );

        final userRef = _firestore
            .collection('academies')
            .doc(academyId)
            .collection('users')
            .doc(userId);

        developer.log(
          'Intentando acceder a ruta: ${userRef.path}',
          name: 'UserService-Delete',
        );

        final userDoc = await userRef.get();

        if (userDoc.exists) {
          developer.log(
            'Usuario ACTIVO encontrado en estructura users.',
            name: 'UserService-Delete',
          );
          developer.log(
            '>> PASO 2A: Procesando eliminación de usuario activo...',
            name: 'UserService-Delete',
          );

          // Procesar eliminación (incluye delete() y limpieza de dependencias)
          await _processUserDeletion(userRef, userDoc, userId, academyId, role);
          
          // Actualizar el documento de la academia para eliminar la referencia al usuario
          developer.log(
            '>> PASO 2B: Actualizando documento de academia para eliminar referencias...',
            name: 'UserService-Delete',
          );
          await _updateAcademyOnUserDelete(academyId, userId, role);
          
          deleted = true; // Marcar como eliminado (como activo)

        } else {
          developer.log(
            'ADVERTENCIA: ¡Usuario NO ENCONTRADO en pendingActivations ni en users!',
            name: 'UserService-Delete',
          );
           developer.log(
            '>> Continuando con limpieza local por seguridad',
            name: 'UserService-Delete',
          );
        }
      }
      
      // >> PASO 3: Eliminación de base de datos local (se intenta siempre por si acaso)
      developer.log(
        '>> PASO 3: Eliminando de base de datos local (si existe)...',
        name: 'UserService-Delete',
      );
      
      try {
        developer.log(
          'Intentando llamar a _localUserRepository.deleteUser($userId)',
          name: 'UserService-Delete',
        );
        // Usar userId que puede ser UID o código de activación. El repo local debe manejarlo.
        await _localUserRepository.deleteUser(userId); 
        developer.log(
          '_localUserRepository.deleteUser($userId) completado',
          name: 'UserService-Delete',
        );
        developer.log(
          'Usuario eliminado/intentado eliminar de la base de datos local.',
          name: 'UserService-Delete',
        );
      } catch (localError) {
        developer.log(
          'ERROR al eliminar usuario de base de datos local: $localError',
          name: 'UserService-Delete',
          error: localError,
        );
        developer.log(
          'Stack trace: ${StackTrace.current}',
          name: 'UserService-Delete',
        );
        // No relanzamos excepción para permitir que el proceso continúe
      }
      
      if (deleted) {
        developer.log(
          '====== ELIMINACIÓN DE USUARIO (Activo o Pendiente) COMPLETADA EXITOSAMENTE ======',
          name: 'UserService-Delete',
        );
      } else {
         developer.log(
          '====== ELIMINACIÓN DE USUARIO FINALIZADA (Usuario no encontrado en Firestore) ======',
          name: 'UserService-Delete',
        );
      }

    } catch (e) {
      developer.log(
        '====== ERROR FATAL EN PROCESO DE ELIMINACIÓN (v2) ======',
        name: 'UserService-Delete',
        error: e,
      );
      developer.log(
        'Stack trace: ${StackTrace.current}',
        name: 'UserService-Delete',
      );
      // Relanzar la excepción si es un error inesperado durante el proceso
      // excepto si fue un error ya manejado de "no encontrado".
       if (e is! FirebaseException || (e.code != 'not-found' && e.code != 'permission-denied')) {
         rethrow;
       }
    }
  }

  // Método auxiliar para actualizar la academia al eliminar un usuario ACTIVO
  Future<void> _updateAcademyOnUserDelete(String academyId, String userId, UserRole role) async {
     try {
        final academyRef = _firestore.collection('academies').doc(academyId);
        
        // Verificar si existe la academia
        final academyDoc = await academyRef.get();
        if (!academyDoc.exists) {
          developer.log(
            'ERROR: Academia no encontrada para actualizar referencias',
            name: 'UserService-Delete',
          );
          // No lanzar excepción, solo loguear.
          return;
        }
        
        developer.log(
          'Academia encontrada para actualización: ${academyDoc.data()?['name']}',
          name: 'UserService-Delete',
        );
        
        // Determinar qué campo actualizar según el rol
        // Importante: Asegúrate que estos campos existan o maneja el caso donde no existan.
        String? roleField; 
        switch (role) {
          case UserRole.manager: roleField = 'managerIds'; break;
          case UserRole.coach: roleField = 'coachIds'; break;
          case UserRole.athlete: roleField = 'athleteIds'; break;
          case UserRole.parent: roleField = 'parentIds'; break;
          // Owner y SuperAdmin no suelen estar en estas listas de la academia.
          default: roleField = null; 
        }
        
        final updateData = <String, dynamic>{
          'userIds': FieldValue.arrayRemove([userId]),
        };
        
        if (roleField != null) {
           developer.log(
            'Eliminando referencia de campo $roleField y userIds en la academia',
            name: 'UserService-Delete',
           );
          updateData[roleField] = FieldValue.arrayRemove([userId]);
        } else {
           developer.log(
            'Eliminando referencia solo de userIds en la academia (Rol: $role)',
            name: 'UserService-Delete',
           );
        }
        
        await academyRef.update(updateData);
        
        developer.log(
          'Academia actualizada exitosamente tras eliminación de usuario activo.',
          name: 'UserService-Delete',
        );
      } catch (academyError) {
        developer.log(
          'ERROR al actualizar la academia post-eliminación: $academyError',
          name: 'UserService-Delete',
          error: academyError,
        );
        developer.log(
          'Stack trace: ${StackTrace.current}',
          name: 'UserService-Delete',
        );
        // No lanzamos excepción para permitir que el proceso continúe
      }
  }
  
  // Método auxiliar para procesar la eliminación del usuario ACTIVO
  Future<void> _processUserDeletion(
    DocumentReference userRef,
    DocumentSnapshot userDoc,
    String userId,
    String academyId,
    UserRole role,
  ) async {
    developer.log(
      '----INICIO: Proceso de eliminación de documento de usuario----',
      name: 'UserService-ProcessDeletion',
    );
    
    developer.log(
      'Datos del documento: ${userDoc.exists ? "Existe" : "No existe"}, Ruta: ${userRef.path}',
      name: 'UserService-ProcessDeletion',
    );
    
    // Si es un padre, desasociar de los atletas relacionados
    if (role == UserRole.parent) {
      developer.log(
        'Eliminando padre: desasociando de atletas relacionados',
        name: 'UserService-ProcessDeletion',
      );
      await _removeParentFromAthletes(userId, academyId);
    }
    
    // Si es un atleta, desasociar de los grupos a los que pertenece
    if (role == UserRole.athlete) {
      developer.log(
        'Eliminando atleta: desasociando de grupos relacionados',
        name: 'UserService-ProcessDeletion',
      );
      await _removeAthleteFromGroups(userId, academyId);
    }
    
    // Si es un entrenador, desasociar de los grupos que entrena
    if (role == UserRole.coach) {
      developer.log(
        'Eliminando entrenador: desasociando de grupos relacionados',
        name: 'UserService-ProcessDeletion',
      );
      await _removeCoachFromGroups(userId, academyId);
    }
    
    // Si es un manager, verificar si hay dependencias que limpiar
    if (role == UserRole.manager) {
      developer.log(
        'Eliminando manager: verificando dependencias',
        name: 'UserService-ProcessDeletion',
      );
      // Implementar lógica específica para managers si es necesario
    }
    
    developer.log(
      'Limpieza de dependencias completada. Procediendo a eliminar documento...',
      name: 'UserService-ProcessDeletion',
    );
    
    try {
      developer.log(
        'Eliminando documento en ruta: ${userRef.path}',
        name: 'UserService-ProcessDeletion',
      );
      
      // Eliminar el documento de Firestore
      await userRef.delete();
      
      developer.log(
        'Documento eliminado exitosamente de Firestore',
        name: 'UserService-ProcessDeletion',
      );
    } catch (deleteError) {
      developer.log(
        'ERROR al eliminar documento: $deleteError, Tipo: ${deleteError.runtimeType}',
        name: 'UserService-ProcessDeletion',
        error: deleteError,
      );
      developer.log(
        'Stack trace: ${StackTrace.current}',
        name: 'UserService-ProcessDeletion',
      );
      // No lanzamos excepción para permitir que se limpie la DB local
      developer.log(
        'Continuando con la limpieza local a pesar del error en Firestore',
        name: 'UserService-ProcessDeletion',
      );
    }
    
    // Intenta eliminar el usuario de Authentication si es posible
    try {
      // Obtener email del usuario
      String? email;
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        email = userData?['email'] as String?;
      }
      
      if (email != null) {
        developer.log(
          'Intentando eliminar usuario de Authentication con email: $email',
          name: 'UserService-ProcessDeletion',
        );
        // Esta operación requiere acceso a la API de Admin de Firebase
        developer.log(
          'NOTA: La eliminación en Authentication requiere backend/funciones',
          name: 'UserService-ProcessDeletion',
        );
      } else {
        developer.log(
          'No se encontró email para eliminar usuario de Authentication',
          name: 'UserService-ProcessDeletion',
        );
      }
    } catch (authError) {
      // No podemos eliminar el usuario de Auth, pero sí de Firestore
      developer.log(
        'ERROR al intentar eliminar usuario de Authentication: $authError',
        name: 'UserService-ProcessDeletion',
        error: authError,
      );
      // No relanzan la excepción para permitir que el proceso continúe
    }
    
    developer.log(
      '----FIN: Proceso de eliminación de documento completado----',
      name: 'UserService-ProcessDeletion',
    );
  }
  
  // Método auxiliar para desvincular un padre de sus atletas
  Future<void> _removeParentFromAthletes(String parentId, String academyId) async {
    try {
      developer.log(
        'Iniciando desvinculación del padre $parentId de atletas',
        name: 'UserService-ParentRemove',
      );
      
      // Buscar atletas asociados a este padre
      final athletesRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('athletes');
      
      developer.log(
        'Buscando atletas que tienen a este padre: $parentId',
        name: 'UserService-ParentRemove',
      );
      
      final athletes = await athletesRef
          .where('parentIds', arrayContains: parentId)
          .get();
      
      developer.log(
        'Atletas encontrados: ${athletes.docs.length}',
        name: 'UserService-ParentRemove',
      );
      
      if (athletes.docs.isEmpty) {
        developer.log(
          'No se encontraron atletas asociados a este padre',
          name: 'UserService-ParentRemove',
        );
        return;
      }
      
      // Batch para actualizar múltiples documentos
      final batch = _firestore.batch();
      
      developer.log(
        'Creando batch para actualizar ${athletes.docs.length} documentos',
        name: 'UserService-ParentRemove',
      );
      
      for (final athleteDoc in athletes.docs) {
        developer.log(
          'Procesando atleta: ${athleteDoc.id}',
          name: 'UserService-ParentRemove',
        );
        
        // Obtener la lista actual de padres y eliminar el ID del padre
        final parentIds = athleteDoc.data()['parentIds'];
        if (parentIds is List) {
          final updatedParentIds = List<String>.from(parentIds)..remove(parentId);
          
          developer.log(
            'Actualizando parentIds de ${parentIds.length} a ${updatedParentIds.length}',
            name: 'UserService-ParentRemove',
          );
          
          // Actualizar el documento
          batch.update(athleteDoc.reference, {'parentIds': updatedParentIds});
        } else {
          developer.log(
            'Campo parentIds no es una lista válida para atleta ${athleteDoc.id}',
            name: 'UserService-ParentRemove',
          );
        }
      }
      
      // Ejecutar el batch
      developer.log(
        'Ejecutando batch de actualizaciones',
        name: 'UserService-ParentRemove',
      );
      
      await batch.commit();
      
      developer.log(
        'Batch completado exitosamente',
        name: 'UserService-ParentRemove',
      );
    } catch (e) {
      developer.log(
        'ERROR al desvincular padre de atletas: $e',
        name: 'UserService-ParentRemove',
        error: e,
      );
      developer.log(
        'Stack trace: ${StackTrace.current}',
        name: 'UserService-ParentRemove',
      );
      // No lanzamos excepción para permitir que el proceso principal continúe
    }
  }
  
  // Método auxiliar para desvincular un atleta de sus grupos
  Future<void> _removeAthleteFromGroups(String athleteId, String academyId) async {
    try {
      developer.log(
        'Iniciando desvinculación del atleta $athleteId de grupos',
        name: 'UserService-AthleteRemove',
      );
      
      // Buscar grupos a los que pertenece este atleta
      final groupsRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('groups');
      
      developer.log(
        'Buscando grupos que contienen a este atleta: $athleteId',
        name: 'UserService-AthleteRemove',
      );
      
      final groups = await groupsRef
          .where('athleteIds', arrayContains: athleteId)
          .get();
      
      developer.log(
        'Grupos encontrados: ${groups.docs.length}',
        name: 'UserService-AthleteRemove',
      );
      
      if (groups.docs.isEmpty) {
        developer.log(
          'No se encontraron grupos asociados a este atleta',
          name: 'UserService-AthleteRemove',
        );
        return;
      }
      
      // Batch para actualizar múltiples documentos
      final batch = _firestore.batch();
      
      developer.log(
        'Creando batch para actualizar ${groups.docs.length} grupos',
        name: 'UserService-AthleteRemove',
      );
      
      for (final groupDoc in groups.docs) {
        developer.log(
          'Procesando grupo: ${groupDoc.id}',
          name: 'UserService-AthleteRemove',
        );
        
        // Obtener la lista actual de atletas y eliminar el ID del atleta
        final athleteIds = groupDoc.data()['athleteIds'];
        if (athleteIds is List) {
          final updatedAthleteIds = List<String>.from(athleteIds)..remove(athleteId);
          
          developer.log(
            'Actualizando athleteIds de ${athleteIds.length} a ${updatedAthleteIds.length}',
            name: 'UserService-AthleteRemove',
          );
          
          // Actualizar el documento
          batch.update(groupDoc.reference, {'athleteIds': updatedAthleteIds});
        } else {
          developer.log(
            'Campo athleteIds no es una lista válida para grupo ${groupDoc.id}',
            name: 'UserService-AthleteRemove',
          );
        }
      }
      
      // Ejecutar el batch
      developer.log(
        'Ejecutando batch de actualizaciones',
        name: 'UserService-AthleteRemove',
      );
      
      await batch.commit();
      
      developer.log(
        'Batch completado exitosamente',
        name: 'UserService-AthleteRemove',
      );
    } catch (e) {
      developer.log(
        'ERROR al desvincular atleta de grupos: $e',
        name: 'UserService-AthleteRemove',
        error: e,
      );
      developer.log(
        'Stack trace: ${StackTrace.current}',
        name: 'UserService-AthleteRemove',
      );
    }
  }
  
  // Método auxiliar para desvincular un entrenador de sus grupos
  Future<void> _removeCoachFromGroups(String coachId, String academyId) async {
    try {
      developer.log(
        'Iniciando desvinculación del entrenador $coachId de grupos',
        name: 'UserService-CoachRemove',
      );
      
      // Buscar grupos que entrena este coach
      final groupsRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('groups');
      
      developer.log(
        'Buscando grupos que contienen a este entrenador: $coachId',
        name: 'UserService-CoachRemove',
      );
      
      final groups = await groupsRef
          .where('coachIds', arrayContains: coachId)
          .get();
      
      developer.log(
        'Grupos encontrados: ${groups.docs.length}',
        name: 'UserService-CoachRemove',
      );
      
      if (groups.docs.isEmpty) {
        developer.log(
          'No se encontraron grupos asociados a este entrenador',
          name: 'UserService-CoachRemove',
        );
        return;
      }
      
      // Batch para actualizar múltiples documentos
      final batch = _firestore.batch();
      
      developer.log(
        'Creando batch para actualizar ${groups.docs.length} grupos',
        name: 'UserService-CoachRemove',
      );
      
      for (final groupDoc in groups.docs) {
        developer.log(
          'Procesando grupo: ${groupDoc.id}',
          name: 'UserService-CoachRemove',
        );
        
        // Obtener la lista actual de coaches y eliminar el ID del coach
        final coachIds = groupDoc.data()['coachIds'];
        if (coachIds is List) {
          final updatedCoachIds = List<String>.from(coachIds)..remove(coachId);
          
          developer.log(
            'Actualizando coachIds de ${coachIds.length} a ${updatedCoachIds.length}',
            name: 'UserService-CoachRemove',
          );
          
          // Actualizar el documento
          batch.update(groupDoc.reference, {'coachIds': updatedCoachIds});
        } else {
          developer.log(
            'Campo coachIds no es una lista válida para grupo ${groupDoc.id}',
            name: 'UserService-CoachRemove',
          );
        }
      }
      
      // Ejecutar el batch
      developer.log(
        'Ejecutando batch de actualizaciones',
        name: 'UserService-CoachRemove',
      );
      
      await batch.commit();
      
      developer.log(
        'Batch completado exitosamente',
        name: 'UserService-CoachRemove',
      );
    } catch (e) {
      developer.log(
        'ERROR al desvincular entrenador de grupos: $e',
        name: 'UserService-CoachRemove',
        error: e,
      );
      developer.log(
        'Stack trace: ${StackTrace.current}',
        name: 'UserService-CoachRemove',
      );
    }
  }

  // MÉTODOS ESPECÍFICOS PARA ATLETAS
  
  // Crear un nuevo atleta y su perfil (sin email/password)
  Future<Map<String, dynamic>> createAthlete({
    required String name,
    required String academyId,
    DateTime? birthDate,
    double? height,
    double? weight,
    List<String>? groupIds,
    List<String>? parentIds,
    Map<String, dynamic>? medicalInfo,
    Map<String, dynamic>? emergencyContacts,
    Map<String, dynamic>? additionalInfo,
    String? position,
    List<String>? specializations,
    Map<String, dynamic>? sportStats,
    int? number,
    String? profileImageUrl,
  }) async {
    try {
      // 1. Crear el usuario básico (Firestore)
      final athlete = await createUser(
        name: name,
        role: UserRole.athlete,
        academyId: academyId,
        number: number,
        profileImageUrl: profileImageUrl,
      );
      
      // 2. Crear el perfil de atleta
      final profile = await _athleteRepository.createAthleteProfile(
        userId: athlete.id,
        academyId: academyId,
        birthDate: birthDate,
        height: height,
        weight: weight,
        groupIds: groupIds,
        parentIds: parentIds,
        medicalInfo: medicalInfo,
        emergencyContacts: emergencyContacts,
        additionalInfo: additionalInfo,
        position: position,
        specializations: specializations,
        sportStats: sportStats,
      );
      
      return {
        'success': true,
        'user': athlete,
        'profile': profile
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error al crear atleta: $e'
      };
    }
  }
  
  // Obtener un atleta con su perfil completo
  Future<Map<String, dynamic>> getAthleteWithProfile(String userId, String academyId) async {
    try {
      // Obtener datos básicos del usuario
      final athlete = await getUserById(userId);
      if (athlete == null) {
        throw Exception('Atleta no encontrado');
      }
      
      // Obtener perfil específico de atleta
      final profile = await _athleteRepository.getAthleteProfile(userId, academyId);
      
      return {
        'user': athlete,
        'profile': profile,
      };
    } catch (e) {
      throw Exception('Error al obtener atleta con perfil: $e');
    }
  }
  
  // Actualizar atleta y su perfil
  Future<void> updateAthlete({
    required User user,
    required AthleteProfile profile,
  }) async {
    try {
      // Actualizamos ambos en paralelo para eficiencia
      await Future.wait([
        updateUser(user),
        _athleteRepository.updateAthleteProfile(profile),
      ]);
    } catch (e) {
      throw Exception('Error al actualizar atleta: $e');
    }
  }
  
  // Eliminar un atleta por completo
  Future<void> deleteAthlete(String userId, String academyId) async {
    try {
      // 1. Eliminar el perfil de atleta de la academia
      await _athleteRepository.removeAthleteFromAcademy(userId, academyId);
      
      // 2. Verificar si el usuario pertenece a otras academias
      final user = await getUserById(userId);
      if (user == null) {
        return; // Ya no existe
      }
      
      // 3. Si no pertenece a otras academias, eliminar el usuario por completo
      if (user.academyIds.length <= 1) {
        await deleteUser(userId: userId, academyId: academyId, role: UserRole.athlete);
      } else {
        // 4. Si pertenece a otras academias, solo actualizar la lista de academias
        final updatedAcademyIds = user.academyIds.where((id) => id != academyId).toList();
        await updateUser(user.copyWith(academyIds: updatedAcademyIds));
      }
    } catch (e) {
      throw Exception('Error al eliminar atleta: $e');
    }
  }

  // MÉTODOS ESPECÍFICOS PARA COACHES

  // Crear un nuevo coach (sin email/password)
  Future<User> createCoach({
    required String name,
    required String academyId,
    String? profileImageUrl,
  }) async {
    try {
      final coach = await createUser(
        name: name,
        role: UserRole.coach,
        academyId: academyId,
        profileImageUrl: profileImageUrl,
      );
      
      // Actualizar la academia con el nuevo coach
      await _firestore.collection('academies').doc(academyId).update({
        'coachIds': FieldValue.arrayUnion([coach.id]),
      });
      
      return coach;
    } catch (e) {
      throw Exception('Error al crear coach: $e');
    }
  }
  
  // Eliminar coach
  Future<void> deleteCoach(String userId, String academyId) async {
    try {
      // Eliminar referencia del coach en la academia
      await _firestore.collection('academies').doc(academyId).update({
        'coachIds': FieldValue.arrayRemove([userId]),
      });
      
      // Eliminar coach de grupos
      final groupsQuery = await _firestore
          .collection('academies')
          .doc(academyId)
          .collection('groups')
          .where('coachId', isEqualTo: userId)
          .get();
      
      final batch = _firestore.batch();
      for (final groupDoc in groupsQuery.docs) {
        batch.update(groupDoc.reference, {'coachId': null});
      }
      await batch.commit();
      
      // Verificar si pertenece a otras academias
      final user = await getUserById(userId);
      if (user == null) return;
      
      if (user.academyIds.length <= 1) {
        await deleteUser(userId: userId, academyId: academyId, role: UserRole.coach);
      } else {
        final updatedAcademyIds = user.academyIds.where((id) => id != academyId).toList();
        await updateUser(user.copyWith(academyIds: updatedAcademyIds));
      }
    } catch (e) {
      throw Exception('Error al eliminar coach: $e');
    }
  }
  
  // MÉTODOS ESPECÍFICOS PARA MANAGERS

  // Crear un nuevo manager (sin email/password)
  Future<User> createManager({
    required String name,
    required String academyId,
    String? profileImageUrl,
  }) async {
    try {
      final manager = await createUser(
        name: name,
        role: UserRole.manager,
        academyId: academyId,
        profileImageUrl: profileImageUrl,
      );
      
      return manager;
    } catch (e) {
      throw Exception('Error al crear manager: $e');
    }
  }

  // Eliminar manager
  Future<void> deleteManager(String userId, String academyId) async {
    try {
      developer.log(
        '====== INICIANDO ELIMINACIÓN DE MANAGER [Método específico] ======',
        name: 'UserService-Manager',
      );
      
      developer.log(
        'Parámetros recibidos: userId=$userId, academyId=$academyId',
        name: 'UserService-Manager',
      );

      // Log adicional para depuración
      developer.log(
        '>> PASO 0: Verificación de inicio de eliminación de manager',
        name: 'UserDetails-Delete',
      );
      
      // 1. Verificar si el documento de academia existe
      developer.log(
        '>> PASO 1: Verificando existencia de academia...',
        name: 'UserService-Manager',
      );
      
      final academyRef = _firestore.collection('academies').doc(academyId);
      final academyDoc = await academyRef.get();
      
      developer.log(
        'Accediendo al documento de academia en Firestore',
        name: 'UserDetails-Delete',
      );
      
      if (!academyDoc.exists) {
        developer.log(
          'ERROR: Academia no encontrada con ID: $academyId',
          name: 'UserService-Manager',
        );
        developer.log(
          'ERROR: Academia no encontrada para eliminación de manager',
          name: 'UserDetails-Delete',
        );
        throw Exception('Academia no encontrada');
      }
      
      developer.log(
        'Academia encontrada: ${academyDoc.data()?['name']}',
        name: 'UserService-Manager',
      );
      
      // 2. Verificar si el usuario existe
      developer.log(
        '>> PASO 2: Verificando existencia de usuario manager...',
        name: 'UserService-Manager',
      );
      
      developer.log(
        'Buscando información del usuario manager',
        name: 'UserDetails-Delete',
      );
      
      final user = await getUserById(userId);
      
      developer.log(
        'Resultado de getUserById: ${user != null ? "Usuario encontrado" : "Usuario NO encontrado"}',
        name: 'UserDetails-Delete',
      );
      
      if (user == null) {
        developer.log(
          'ERROR: Manager no encontrado con ID: $userId',
          name: 'UserService-Manager',
        );
        developer.log(
          'ERROR: Usuario manager no encontrado en la base de datos',
          name: 'UserDetails-Delete',
        );
        throw Exception('Manager no encontrado');
      }
      
      developer.log(
        'Manager encontrado: ${user.name} (${user.id}), Rol: ${user.role}',
        name: 'UserService-Manager',
      );
      
      // 3. Eliminar referencia del manager en la academia
      developer.log(
        '>> PASO 3: Eliminando referencia de manager en academia...',
        name: 'UserService-Manager',
      );
      
      try {
        developer.log(
          'Verificando campo managerIds en documento de academia...',
          name: 'UserService-Manager',
        );
        
        // Verificar si el campo 'managerIds' existe en el documento
        final academyData = academyDoc.data();
        if (academyData == null) {
          developer.log(
            'ERROR: Datos de academia son nulos',
            name: 'UserService-Manager',
          );
          throw Exception('Datos de academia no disponibles');
        }
        
        // Registro de todos los campos existentes para diagnóstico
        developer.log(
          'Campos disponibles en documento de academia: ${academyData.keys.join(', ')}',
          name: 'UserService-Manager',
        );
        
        // Si no existe el campo managerIds, crearlo como lista vacía
        if (!academyData.containsKey('managerIds')) {
          developer.log(
            'ADVERTENCIA: Campo managerIds no existe en la academia, creando campo vacío',
            name: 'UserService-Manager',
          );
          await academyRef.update({
            'managerIds': [],
          });
          developer.log(
            'Campo managerIds creado exitosamente',
            name: 'UserService-Manager',
          );
        } else {
          // Si existe, mostrar los valores actuales
          final currentManagerIds = academyData['managerIds'];
          if (currentManagerIds is List) {
            developer.log(
              'Campo managerIds contiene: ${currentManagerIds.join(', ')}',
              name: 'UserService-Manager',
            );
          }
        }
        
        developer.log(
          'Actualizando academia: eliminando userId=$userId de managerIds y userIds',
          name: 'UserService-Manager',
        );
        
        // Ahora sí eliminar la referencia
        await academyRef.update({
          'managerIds': FieldValue.arrayRemove([userId]),
          'userIds': FieldValue.arrayRemove([userId]), // También eliminar de userIds general
        });
        
        developer.log(
          'Referencia de manager eliminada correctamente de la academia',
          name: 'UserService-Manager',
        );
      } catch (academyError) {
        developer.log(
          'ERROR al actualizar academia: $academyError',
          name: 'UserService-Manager',
          error: academyError,
        );
        developer.log(
          'Stack trace: ${StackTrace.current}',
          name: 'UserService-Manager',
        );
        // No lanzamos excepción, seguimos con el proceso
      }
      
      // 4. Verificar si pertenece a otras academias
      developer.log(
        '>> PASO 4: Verificando si el manager pertenece a otras academias...',
        name: 'UserService-Manager',
      );
      
      developer.log(
        'Academias actuales del manager: ${user.academyIds.length} - ${user.academyIds}',
        name: 'UserService-Manager',
      );
      
      if (user.academyIds.length <= 1) {
        developer.log(
          '>> PASO 5A: Manager solo pertenece a esta academia, eliminando por completo...',
          name: 'UserService-Manager',
        );
        
        // Si solo está en esta academia, eliminar completamente
        try {
          developer.log(
            'Llamando a método deleteUser para eliminación completa...',
            name: 'UserService-Manager',
          );
          
          await deleteUser(userId: userId, academyId: academyId, role: UserRole.manager);
          
          developer.log(
            'Manager eliminado completamente con éxito mediante deleteUser',
            name: 'UserService-Manager',
          );
        } catch (deleteError) {
          developer.log(
            'ERROR en deleteUser durante eliminación completa: $deleteError',
            name: 'UserService-Manager',
            error: deleteError,
          );
          rethrow;
        }
      } else {
        developer.log(
          '>> PASO 5B: Manager pertenece a múltiples academias, solo eliminando de la academia actual...',
          name: 'UserService-Manager',
        );
        
        // Si pertenece a otras academias, solo actualizar la lista de academias
        try {
          final updatedAcademyIds = user.academyIds.where((id) => id != academyId).toList();
          
          developer.log(
            'Actualizando lista de academias: ${updatedAcademyIds.length} - $updatedAcademyIds',
            name: 'UserService-Manager',
          );
          
          final updatedUser = user.copyWith(academyIds: updatedAcademyIds);
          await updateUser(updatedUser);
          
          developer.log(
            'Usuario manager actualizado exitosamente con nuevas academias',
            name: 'UserService-Manager',
          );
        } catch (updateError) {
          developer.log(
            'ERROR al actualizar manager con nuevas academias: $updateError',
            name: 'UserService-Manager',
            error: updateError,
          );
          rethrow;
        }
      }
      
      developer.log(
        '====== ELIMINACIÓN DE MANAGER COMPLETADA EXITOSAMENTE ======',
        name: 'UserService-Manager',
      );
    } catch (e) {
      developer.log(
        '====== ERROR FATAL EN PROCESO DE ELIMINACIÓN DE MANAGER: $e ======',
        name: 'UserService-Manager',
        error: e,
      );
      developer.log(
        'Stack trace: ${StackTrace.current}',
        name: 'UserService-Manager',
      );
      rethrow;
    }
  }

  // MÉTODOS ESPECÍFICOS PARA PADRES
  
  // Obtener un padre con sus datos adicionales
  Future<Map<String, dynamic>> getParentWithData(String userId, String academyId) async {
    try {
      // Obtener datos básicos del usuario
      final parent = await getUserById(userId);
      if (parent == null) {
        throw Exception('Padre/Madre no encontrado');
      }
      
      // Intentar obtener datos adicionales del documento del usuario
      Map<String, dynamic> parentData = {};
      
      try {
        final docSnap = await _usersCollection.doc(userId).get();
        if (docSnap.exists) {
          final data = docSnap.data() ?? {};
          
          // Extraer datos específicos de padres
          if (data.containsKey('parentData')) {
            parentData = data['parentData'] as Map<String, dynamic>;
          }
        }
      } catch (e) {
        debugPrint('Error al obtener datos adicionales del padre: $e');
      }
      
      return {
        'user': parent,
        'parentData': parentData,
      };
    } catch (e) {
      throw Exception('Error al obtener padre con datos: $e');
    }
  }
  
  // Crear un nuevo padre con sus datos adicionales
  Future<User> createParent({
    required String name,
    required String academyId,
    Map<String, dynamic>? parentData,
    String? profileImageUrl,
  }) async {
    try {
      // 1. Crear el usuario básico (Firestore)
      final parent = await createUser(
        name: name,
        role: UserRole.parent,
        academyId: academyId,
        profileImageUrl: profileImageUrl,
      );
      
      // 2. Guardar datos adicionales del padre si existen
      if (parentData != null && parentData.isNotEmpty) {
        await _usersCollection.doc(parent.id).update({
          'parentData': parentData,
        });
      }
      
      return parent;
    } catch (e) {
      throw Exception('Error al crear padre: $e');
    }
  }
  
  // Actualizar un padre existente
  Future<void> updateParent({
    required String userId,
    required String name,
    Map<String, dynamic>? parentData,
    String? profileImageUrl, required String email,
  }) async {
    try {
      // 1. Obtener el usuario actual
      final currentUser = await getUserById(userId);
      if (currentUser == null) {
        throw Exception('Usuario no encontrado');
      }
      
      // 2. Actualizar datos básicos del usuario (solo Firestore)
      // El email se mantiene como está en el objeto currentUser
      final updatedUser = currentUser.copyWith(
        name: name,
        profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
      );
      
      await updateUser(updatedUser); // updateUser ya no toca Auth
      
      // 3. Actualizar datos adicionales si existen
      if (parentData != null && parentData.isNotEmpty) {
        await _usersCollection.doc(userId).update({
          'parentData': parentData,
        });
      }
    } catch (e) {
      throw Exception('Error al actualizar padre: $e');
    }
  }
  
  // Eliminar un padre
  Future<void> deleteParent(String userId, String academyId) async {
    try {
      // Verificar si el usuario pertenece a otras academias
      final user = await getUserById(userId);
      if (user == null) {
        return; // Ya no existe
      }
      
      // Si no pertenece a otras academias, eliminar el usuario por completo
      if (user.academyIds.length <= 1) {
        await deleteUser(userId: userId, academyId: academyId, role: UserRole.parent);
      } else {
        // Si pertenece a otras academias, solo actualizar la lista de academias
        final updatedAcademyIds = user.academyIds.where((id) => id != academyId).toList();
        await updateUser(user.copyWith(academyIds: updatedAcademyIds));
      }
    } catch (e) {
      throw Exception('Error al eliminar padre: $e');
    }
  }

  // Obtener múltiples usuarios por sus IDs
  Future<List<User>> getUsersByIds(List<String> userIds) async {
    try {
      final result = <User>[];
      
      // Primero intentar obtener desde la base de datos local
      final localUsers = <User>[];
      final missingUserIds = <String>[];
      
      for (final userId in userIds) {
        final localUser = await _localUserRepository.getUserById(userId);
        if (localUser != null) {
          localUsers.add(localUser);
        } else {
          missingUserIds.add(userId);
        }
      }
      
      // Si tenemos todos los usuarios localmente, retornarlos
      if (missingUserIds.isEmpty) {
        debugPrint('Todos los usuarios obtenidos desde DB local: ${localUsers.length}');
        return localUsers;
      }
      
      // Si faltan algunos y no hay conectividad, retornar solo los que tenemos
      if (!await _connectivityService.hasConnectivity()) {
        debugPrint('Sin conectividad, retornando solo usuarios locales: ${localUsers.length}');
        return localUsers;
      }
      
      // Obtener los usuarios faltantes desde Firestore
      // Firebase no permite consultas 'in' con más de 10 valores, así que dividimos en chunks
      const int maxBatchSize = 10;
      
      for (int i = 0; i < missingUserIds.length; i += maxBatchSize) {
        final end = (i + maxBatchSize < missingUserIds.length) 
            ? i + maxBatchSize 
            : missingUserIds.length;
        final batch = missingUserIds.sublist(i, end);
        
        final querySnap = await _usersCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        final remoteUsers = querySnap.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return User.fromJson(data);
        }).toList();
        
        // Guardar usuarios remotos en la base de datos local
        for (final user in remoteUsers) {
          await _localUserRepository.saveUser(user);
        }
        
        result.addAll(remoteUsers);
      }
      
      // Combinar usuarios locales y remotos
      result.addAll(localUsers);
      
      // Eliminar duplicados (por si hubo alguna coincidencia entre locales y remotos)
      final uniqueUsers = <User>[];
      final seenIds = <String>{};
      
      for (final user in result) {
        if (!seenIds.contains(user.id)) {
          uniqueUsers.add(user);
          seenIds.add(user.id);
        }
      }
      
      return uniqueUsers;
    } catch (e) {
      debugPrint('Error al obtener usuarios por IDs: $e');
      throw Exception('Error al obtener usuarios por IDs: $e');
    }
  }

  // Obtener usuarios pendientes de activación por rol y academia
  Future<List<Map<String, dynamic>>> getPendingUsersByRole(UserRole role, String academyId) async {
    try {
      developer.log(
        'Buscando usuarios pendientes para rol: $role en academia: $academyId',
        name: 'UserService-Pending',
      );

      final pendingActivationsRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('pendingActivations');
          
      developer.log(
        'Consultando colección: ${pendingActivationsRef.path}',
        name: 'UserService-Pending',
      );
          
      final querySnap = await pendingActivationsRef
          .where('role', isEqualTo: role.toString().split('.').last)
          .get();
          
      developer.log(
        'Documentos encontrados: ${querySnap.docs.length}',
        name: 'UserService-Pending',
      );

      final results = querySnap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Usar el código de activación como ID
        data['isPending'] = true; // Marcar como pendiente
        
        developer.log(
          'Documento pendiente encontrado - ID: ${doc.id}, Nombre: ${data['name']}',
          name: 'UserService-Pending',
        );
        
        return data;
      }).toList();
      
      developer.log(
        'Total de usuarios pendientes encontrados: ${results.length}',
        name: 'UserService-Pending',
      );
      
      return results;
    } catch (e, stackTrace) {
      developer.log(
        'Error al obtener usuarios pendientes por rol: $e\n$stackTrace',
        name: 'UserService-Pending',
        error: e,
      );
      // En caso de error, retornamos lista vacía en lugar de propagar el error
      return [];
    }
  }

  // Obtener usuarios por rol incluyendo pendientes
  Future<List<dynamic>> getUsersByRoleWithPending(UserRole role, {String? academyId}) async {
    try {
      if (academyId == null) {
        throw Exception('Se requiere academyId para obtener usuarios con pendientes');
      }

      developer.log(
        'Obteniendo usuarios por rol con pendientes: $role, academyId: $academyId',
        name: 'UserService',
      );

      // 1. Obtener usuarios activos
      final activeUsers = await getUsersByRole(role, academyId: academyId);
      
      developer.log(
        'Usuarios activos encontrados: ${activeUsers.length}',
        name: 'UserService',
      );

      // 2. Obtener usuarios pendientes
      final pendingUsers = await getPendingUsersByRole(role, academyId);
      
      developer.log(
        'Usuarios pendientes encontrados: ${pendingUsers.length}',
        name: 'UserService',
      );
      
      // 3. Combinar ambas listas
      final combinedUsers = [
        ...activeUsers,
        ...pendingUsers.map((pending) {
          // Asegurarnos de que los campos requeridos existan y sean del tipo correcto
          final String id = pending['id']?.toString() ?? '';
          final String name = pending['name']?.toString() ?? '';
          final DateTime createdAt = (pending['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          
          return User(
            id: id,
            name: name,
            email: '', // Email vacío para pendientes
            role: role,
            permissions: Permissions.getDefaultPermissions(role),
            academyIds: [academyId],
            createdAt: createdAt,
            isPendingActivation: true, // Marcar como pendiente
          );
        }),
      ];
      
      developer.log(
        'Total de usuarios combinados: ${combinedUsers.length}',
        name: 'UserService',
      );
      
      return combinedUsers;
    } catch (e, stackTrace) {
      developer.log(
        'Error al obtener usuarios con pendientes: $e\n$stackTrace',
        name: 'UserService',
        error: e,
      );
      throw Exception('Error al obtener usuarios con pendientes: $e');
    }
  }

  /// Crear un usuario pendiente de activación
  Future<Map<String, dynamic>> createPendingUser({
    required String name,
    required UserRole role,
    required String academyId,
    String? profileImageUrl,
    File? profileImage,
  }) async {
    try {
      developer.log(
        'Iniciando creación de usuario pendiente: $name (${role.toString()})',
        name: 'UserService-PendingUser',
      );

      // Si hay imagen, subirla primero
      String? finalImageUrl = profileImageUrl;
      if (profileImage != null) {
        developer.log(
          'Subiendo imagen de perfil para usuario pendiente',
          name: 'UserService-PendingUser',
        );
        
        try {
          finalImageUrl = await _userImageService.uploadProfileImage(
            imagePath: profileImage.path,
            academyId: academyId,
          );
          
          developer.log(
            'Imagen subida exitosamente: $finalImageUrl',
            name: 'UserService-PendingUser',
          );
        } catch (imageError) {
          developer.log(
            'Error al subir imagen: $imageError',
            name: 'UserService-PendingUser',
            error: imageError,
          );
          // Continuamos sin imagen si hay error
        }
      }

      // Crear código de activación
      final activationCode = const Uuid().v4().substring(0, 6).toUpperCase();
      
      developer.log(
        'Generado código de activación: $activationCode',
        name: 'UserService-PendingUser',
      );

      // Crear documento en pendingActivations
      await _firestore
        .collection('academies')
        .doc(academyId)
        .collection('pendingActivations')
        .doc(activationCode)
        .set({
          'name': name,
          'role': role.toString().split('.').last,
          'createdAt': FieldValue.serverTimestamp(),
          'profileImageUrl': finalImageUrl,
          'academyId': academyId,
        });
        
      developer.log(
        'Usuario pendiente creado exitosamente',
        name: 'UserService-PendingUser',
      );

      return {
        'success': true,
        'activationCode': activationCode,
        'profileImageUrl': finalImageUrl,
      };
    } catch (e) {
      developer.log(
        'Error al crear usuario pendiente: $e',
        name: 'UserService-PendingUser',
        error: e,
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
} 