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
      
      // Obtener desde Firestore
      final docSnap = await _usersCollection.doc(userId).get();
      
      if (!docSnap.exists) {
        return null;
      }
      
      final data = docSnap.data()!;
      data['id'] = docSnap.id;
      
      final user = User.fromJson(data);
      
      // Guardar en la base de datos local para futuros accesos
      await _localUserRepository.saveUser(user);
      
      return user;
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
      
      // Obtener desde Firestore
      Query<Map<String, dynamic>> query = _usersCollection
          .where('role', isEqualTo: role.toString().split('.').last);
      
      if (academyId != null) {
        query = query.where('academyIds', arrayContains: academyId);
      }
      
      final querySnap = await query.get();
      
      final users = querySnap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromJson(data);
      }).toList();
      
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
      
      // Obtener desde Firestore
      final querySnap = await _usersCollection
          .where('academyIds', arrayContains: academyId)
          .get();
      
      final users = querySnap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromJson(data);
      }).toList();
      
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
        } else {
          try {
            // Registro interno - no inicia sesión automáticamente
            if (_authRepository is FirebaseAuthRepository) {
              final authRepo = _authRepository;
              user = await authRepo.createUserWithoutSignIn(
                email,
                password,
                name,
                role,
              );
            } else {
              // Fallback si no es una instancia de FirebaseAuthRepository
              user = await _authRepository.signUpWithEmailAndPassword(
                email,
                password,
                name,
                role,
              );
            }
          } catch (e) {
            throw Exception('Error al crear usuario sin iniciar sesión: $e');
          }
        }
        
        // Si se proporciona un ID de academia, añadirlo a la lista
        if (academyId != null && !user.academyIds.contains(academyId)) {
          user = user.copyWith(
            academyIds: [...user.academyIds, academyId],
          );
          
          await _authRepository.updateUser(user);
        }
        
        // Guardar en la base de datos local
        await _localUserRepository.saveUser(user);
      } else {
        // No hay conectividad, crear usuario solo localmente
        // y encolar para sincronización posterior
        user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporal
          email: email,
          name: name,
          role: role,
          permissions: {}, // Se asignarán al sincronizar
          academyIds: academyId != null ? [academyId] : [],
          createdAt: DateTime.now(),
        );
        
        await _localUserRepository.saveUserWithSync(user);
        
        debugPrint('Usuario creado localmente y encolado para sincronización: ${user.id}');
      }
      
      return user;
    } catch (e) {
      debugPrint('Error al crear usuario: $e');
      throw Exception('Error al crear usuario: $e');
    }
  }

  // Crear un usuario sin iniciar sesión (usado para sincronización)
  Future<User> createUserOnly(User user) async {
    try {
      // Guardar en Firestore
      await _usersCollection.doc(user.id).set(
        {
          'email': user.email,
          'name': user.name,
          'role': user.role.toString(),
          'permissions': user.permissions,
          'academyIds': user.academyIds,
          'createdAt': Timestamp.fromDate(user.createdAt),
          if (user.profileImageUrl != null) 'profileImageUrl': user.profileImageUrl,
        },
      );
      
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
  Future<User> createAthlete({
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
  }) async {
    try {
      // 1. Crear el usuario básico
      final athlete = await createUser(
        email: email,
        password: password,
        name: name,
        role: UserRole.athlete,
        academyId: academyId,
      );
      
      // 2. Crear el perfil de atleta
      await _athleteRepository.createAthleteProfile(
        userId: athlete.id,
        academyId: academyId,
        birthDate: birthDate,
        height: height,
        weight: weight,
        groupIds: groupIds,
        parentIds: parentIds,
        medicalInfo: medicalInfo,
        emergencyContacts: emergencyContacts,
      );
      
      return athlete;
    } catch (e) {
      throw Exception('Error al crear atleta: $e');
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
} 