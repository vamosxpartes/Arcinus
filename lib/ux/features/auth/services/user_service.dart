import 'package:arcinus/shared/constants/permissions.dart';
import 'package:arcinus/shared/models/athlete_profile.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/academy/athlete_repository.dart';
import 'package:arcinus/ux/features/auth/implementations/firebase_auth_repository.dart';
import 'package:arcinus/ux/features/auth/repositories/auth_repository.dart';
import 'package:arcinus/ux/features/auth/repositories/local_user_repository.dart';
import 'package:arcinus/ux/shared/services/connectivity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final athleteRepository = ref.watch(athleteRepositoryProvider);
  final localUserRepository = ref.watch(localUserRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return UserService(
    FirebaseFirestore.instance,
    FirebaseAuthRepository(),
    athleteRepository,
    localUserRepository,
    connectivityService,
  );
});

class UserService {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final AthleteRepository _athleteRepository;
  final LocalUserRepository _localUserRepository;
  final ConnectivityService _connectivityService;

  UserService(
    this._firestore, 
    this._authRepository, 
    this._athleteRepository,
    this._localUserRepository,
    this._connectivityService,
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
      // Primero intentar obtener desde la base de datos local
      final localUser = await _localUserRepository.getUserById(userId);
      if (localUser != null) {
        debugPrint('Usuario obtenido desde DB local: $userId');
        return localUser;
      }
      
      // Si no está en local y no hay conectividad, retornar null
      if (!await _connectivityService.hasConnectivity()) {
        debugPrint('Sin conectividad, no se puede obtener usuario remoto');
        return null;
      }
      
      // Buscar en las diferentes colecciones
      // 1. Superadmins
      var docSnap = await _superadminsCollection.doc(userId).get();
      if (docSnap.exists) {
        final data = docSnap.data()!;
        data['id'] = docSnap.id;
        final user = User.fromJson(data);
        await _localUserRepository.saveUser(user);
        return user;
      }
      
      // 2. Owners
      docSnap = await _ownersCollection.doc(userId).get();
      if (docSnap.exists) {
        final data = docSnap.data()!;
        data['id'] = docSnap.id;
        final user = User.fromJson(data);
        await _localUserRepository.saveUser(user);
        return user;
      }
      
      // 3. Buscar en las academias
      final academiesSnap = await _firestore.collection('academies').get();
      for (final academyDoc in academiesSnap.docs) {
        final academyId = academyDoc.id;
        docSnap = await _academyUsersCollection(academyId).doc(userId).get();
        
        if (docSnap.exists) {
          final data = docSnap.data()!;
          data['id'] = docSnap.id;
          final user = User.fromJson(data);
          await _localUserRepository.saveUser(user);
          return user;
        }
      }
      
      // 4. Para compatibilidad - colección principal
      docSnap = await _usersCollection.doc(userId).get();
      if (docSnap.exists) {
        final data = docSnap.data()!;
        data['id'] = docSnap.id;
        final user = User.fromJson(data);
        await _localUserRepository.saveUser(user);
        return user;
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

  // Crear un nuevo usuario
  Future<User> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? academyId,
    bool isDirectRegistration = false,
    int? number,
  }) async {
    try {
      // Verificar conectividad
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      // Determinar qué método usar según si es registro directo o interno
      User user;
      
      if (hasConnectivity) {
        // Hay conectividad, crear usuario directamente en Firebase
        if (isDirectRegistration) {
          // Registro directo - inicia sesión automáticamente (usado solo en pantalla de registro)
          user = await _authRepository.signUpWithEmailAndPassword(
            email,
            password,
            name,
            role,
          );
          
          // Agregar academia si se proporciona
          if (academyId != null) {
            user = user.copyWith(
              academyIds: [academyId],
              number: number,
            );
          }
        } else {
          // Crear usuario sin iniciar sesión (para crear usuarios desde admin)
          final firebaseAuthRepo = _authRepository as FirebaseAuthRepository;
          final authUser = await firebaseAuthRepo.createUserWithoutSignIn(
            email,
            password,
            name,
            role,
          );
          
          user = User(
            id: authUser.id,
            name: name, 
            email: email,
            role: role,
            permissions: Permissions.getDefaultPermissions(role),
            academyIds: academyId != null ? [academyId] : [],
            number: number,
            createdAt: DateTime.now(),
          );
        }
        
        // Guardar usuario según su rol y academia
        final userData = user.toJson();
        userData.remove('id'); // No incluir ID en los datos a guardar
        
        if (role == UserRole.superAdmin) {
          // Superadmin va en su propia colección
          await _superadminsCollection.doc(user.id).set(userData);
        } else if (role == UserRole.owner) {
          // Owner va en su propia colección
          await _ownersCollection.doc(user.id).set(userData);
        } else if (academyId != null) {
          // Usuario regular asociado a una academia
          // Guardar en la subcolección de usuarios de la academia
          await _academyUsersCollection(academyId).doc(user.id).set(userData);
          
          // También actualizar la academia para añadir el ID de usuario según su rol
          await _firestore.collection('academies').doc(academyId).update({
            'userIds': FieldValue.arrayUnion([user.id]),
            // También podemos agregar a listas específicas según rol si es necesario
            '${role.toString().split('.').last}Ids': FieldValue.arrayUnion([user.id]),
          });
        } else {
          // Usuario sin academia (caso temporal o de migración)
          await _usersCollection.doc(user.id).set(userData);
        }
        
        // Guardar en DB local
        await _localUserRepository.saveUser(user);
        
        return user;
      } else {
        // Sin conectividad, implementar como proceso local y sincronizar después
        // (Implementación completa pendiente)
        throw Exception('No hay conectividad para crear usuario');
      }
    } catch (e) {
      debugPrint('Error al crear usuario: $e');
      throw Exception('Error al crear usuario: $e');
    }
  }

  // Crear un usuario sin iniciar sesión (usado para sincronización)
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
        // Caso de compatibilidad/migración
        await _usersCollection.doc(user.id).set(userData);
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
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (hasConnectivity) {
        // Actualizar en Firebase
        await _authRepository.updateUser(user);
        
        // Actualizar también en local
        await _localUserRepository.updateUser(user);
      } else {
        // Solo actualizar en local y encolar para sincronización
        await _localUserRepository.updateUserWithSync(user);
        debugPrint('Usuario actualizado localmente y encolado para sincronización: ${user.id}');
      }
      
      return user;
    } catch (e) {
      debugPrint('Error al actualizar usuario: $e');
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  // Eliminar un usuario (desactivar o eliminar completamente)
  Future<void> deleteUser(String userId) async {
    try {
      final hasConnectivity = await _connectivityService.hasConnectivity();
      
      if (hasConnectivity) {
        // Primero obtener el usuario para verificar sus datos
        final user = await getUserById(userId);
        if (user == null) {
          throw Exception('Usuario no encontrado');
        }
        
        // Eliminar de Firestore
        await _usersCollection.doc(userId).delete();
        
        // Eliminar también de local
        await _localUserRepository.deleteUser(userId);
      } else {
        // Solo eliminar en local y encolar para sincronización
        await _localUserRepository.deleteUserWithSync(userId);
        debugPrint('Usuario eliminado localmente y encolado para sincronización: $userId');
      }
    } catch (e) {
      debugPrint('Error al eliminar usuario: $e');
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  // MÉTODOS ESPECÍFICOS PARA ATLETAS

  // Crear un nuevo atleta con su perfil
  Future<Map<String, dynamic>> createAthlete({
    required String email,
    required String password,
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
  }) async {
    try {
      // 1. Crear el usuario básico
      final athlete = await createUser(
        email: email,
        password: password,
        name: name,
        role: UserRole.athlete,
        academyId: academyId,
        number: number,
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
        await deleteUser(userId);
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

  // Crear un nuevo coach
  Future<User> createCoach({
    required String email,
    required String password,
    required String name,
    required String academyId,
  }) async {
    try {
      final coach = await createUser(
        email: email,
        password: password,
        name: name,
        role: UserRole.coach,
        academyId: academyId,
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
        await deleteUser(userId);
      } else {
        final updatedAcademyIds = user.academyIds.where((id) => id != academyId).toList();
        await updateUser(user.copyWith(academyIds: updatedAcademyIds));
      }
    } catch (e) {
      throw Exception('Error al eliminar coach: $e');
    }
  }
  
  // MÉTODOS ESPECÍFICOS PARA MANAGERS

  // Crear un nuevo manager
  Future<User> createManager({
    required String email,
    required String password,
    required String name,
    required String academyId,
  }) async {
    try {
      final manager = await createUser(
        email: email,
        password: password,
        name: name,
        role: UserRole.manager,
        academyId: academyId,
      );
      
      return manager;
    } catch (e) {
      throw Exception('Error al crear manager: $e');
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
    required String email,
    required String password,
    required String name,
    required String academyId,
    Map<String, dynamic>? parentData,
  }) async {
    try {
      // 1. Crear el usuario básico
      final parent = await createUser(
        email: email,
        password: password,
        name: name,
        role: UserRole.parent,
        academyId: academyId,
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
    required String email,
    Map<String, dynamic>? parentData,
  }) async {
    try {
      // 1. Obtener el usuario actual
      final currentUser = await getUserById(userId);
      if (currentUser == null) {
        throw Exception('Usuario no encontrado');
      }
      
      // 2. Actualizar datos básicos del usuario
      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
      );
      
      await updateUser(updatedUser);
      
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
        await deleteUser(userId);
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

  // Método para migrar los usuarios existentes a la nueva estructura
  Future<Map<String, dynamic>> migrateUsersToNewStructure() async {
    try {
      final stats = {
        'total': 0,
        'superadmins': 0,
        'owners': 0,
        'academyUsers': 0,
        'errors': 0,
      };
      
      // Verificar conectividad
      if (!await _connectivityService.hasConnectivity()) {
        throw Exception('No hay conectividad para realizar la migración');
      }
      
      // Obtener todos los usuarios de la colección antigua
      final usersSnapshot = await _usersCollection.get();
      stats['total'] = usersSnapshot.docs.length;
      
      // Procesar cada usuario
      for (final userDoc in usersSnapshot.docs) {
        try {
          final userId = userDoc.id;
          final userData = userDoc.data();
          userData['id'] = userId;
          
          final user = User.fromJson(userData);
          
          // Migrar según el rol
          if (user.role == UserRole.superAdmin) {
            // Migrar a colección de superadmins
            await _superadminsCollection.doc(userId).set(userData);
            stats['superadmins'] = (stats['superadmins'] as int) + 1;
          } else if (user.role == UserRole.owner) {
            // Migrar a colección de owners
            await _ownersCollection.doc(userId).set(userData);
            stats['owners'] = (stats['owners'] as int) + 1;
          } else if (user.academyIds.isNotEmpty) {
            // Migrar a las subcolecciones de las academias
            for (final academyId in user.academyIds) {
              await _academyUsersCollection(academyId).doc(userId).set(userData);
              
              // Actualizar la academia para añadir referencia al usuario
              await _firestore.collection('academies').doc(academyId).update({
                'userIds': FieldValue.arrayUnion([userId]),
                '${user.role.toString().split('.').last}Ids': FieldValue.arrayUnion([userId]),
              });
            }
            stats['academyUsers'] = (stats['academyUsers'] as int) + 1;
          }
          
          // No eliminamos el usuario original inmediatamente para mantener compatibilidad
          // Se puede implementar un proceso de limpieza después
          
        } catch (e) {
          debugPrint('Error al migrar usuario ${userDoc.id}: $e');
          stats['errors'] = (stats['errors'] as int) + 1;
        }
      }
      
      return {
        'success': true,
        'stats': stats,
        'message': 'Migración completada. Total: ${stats['total']}, ' 'SuperAdmins: ${stats['superadmins']}, ' +
                  'Owners: ${stats['owners']}, ' +
                  'AcademyUsers: ${stats['academyUsers']}, ' +
                  'Errores: ${stats['errors']}',
      };
    } catch (e) {
      debugPrint('Error en proceso de migración: $e');
      return {
        'success': false,
        'message': 'Error en la migración: $e',
      };
    }
  }
} 