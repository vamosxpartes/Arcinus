import 'package:arcinus/shared/models/athlete_profile.dart';
import 'package:arcinus/shared/models/user.dart';
import 'package:arcinus/ux/features/academy/athlete_repository.dart';
import 'package:arcinus/ux/features/auth/implementations/firebase_auth_repository.dart';
import 'package:arcinus/ux/features/auth/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final athleteRepository = ref.watch(athleteRepositoryProvider);
  return UserService(
    FirebaseFirestore.instance,
    FirebaseAuthRepository(),
    athleteRepository,
  );
});

class UserService {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final AthleteRepository _athleteRepository;

  UserService(this._firestore, this._authRepository, this._athleteRepository);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // MÉTODOS GENERALES PARA TODOS LOS USUARIOS

  // Obtener un usuario por ID
  Future<User?> getUserById(String userId) async {
    try {
      final docSnap = await _usersCollection.doc(userId).get();
      
      if (!docSnap.exists) {
        return null;
      }
      
      final data = docSnap.data()!;
      data['id'] = docSnap.id;
      
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // Obtener usuarios por rol
  Future<List<User>> getUsersByRole(UserRole role, {String? academyId}) async {
    try {
      Query<Map<String, dynamic>> query = _usersCollection
          .where('role', isEqualTo: role.toString().split('.').last);
      
      if (academyId != null) {
        query = query.where('academyIds', arrayContains: academyId);
      }
      
      final querySnap = await query.get();
      
      return querySnap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios por rol: $e');
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
      // Determinar qué método usar según si es registro directo o interno
      User user;
      
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
            // IMPORTANTE: Esto iniciará sesión como el nuevo usuario, lo que no es deseado
            // Sin embargo, necesitamos un fallback en caso de que la implementación cambie
          }
        } catch (e) {
          // En caso de error con la implementación específica, usamos el método estándar
          throw Exception('Error al crear usuario sin iniciar sesión: $e');
        }
      }
      
      // Si se proporciona un ID de academia, añadirlo a la lista
      if (academyId != null && !user.academyIds.contains(academyId)) {
        final updatedUser = user.copyWith(
          academyIds: [...user.academyIds, academyId],
        );
        
        await _authRepository.updateUser(updatedUser);
        return updatedUser;
      }
      
      return user;
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  // Actualizar un usuario existente
  Future<User> updateUser(User user) async {
    try {
      await _authRepository.updateUser(user);
      return user;
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }
  
  // Eliminar un usuario (desactivar o eliminar completamente)
  Future<void> deleteUser(String userId) async {
    try {
      // Primero obtener el usuario para verificar sus datos
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('Usuario no encontrado');
      }
      
      // Por ahora, solo eliminamos el documento de Firestore
      // NOTA: En una implementación completa, también se debería eliminar
      // la cuenta de autenticación y gestionar las referencias cruzadas
      await _usersCollection.doc(userId).delete();
    } catch (e) {
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
        isDirectRegistration: false,
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
        isDirectRegistration: false,
      );
      
      return manager;
    } catch (e) {
      throw Exception('Error al crear manager: $e');
    }
  }
} 