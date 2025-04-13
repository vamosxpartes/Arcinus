import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/shared/constants/permissions.dart';
import 'package:arcinus/shared/models/user.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import '../repositories/auth_repository.dart';

/// Implementación de Firebase para el repositorio de autenticación
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance {
    // Establecer persistencia para mantener la sesión activa entre reinicios
    _setPersistence();
  }
  
  // Configurar la persistencia de autenticación
  Future<void> _setPersistence() async {
    try {
      // La configuración de persistencia solo está disponible en web
      if (kIsWeb) {
        await _firebaseAuth.setPersistence(firebase_auth.Persistence.SESSION);
        developer.log('DEBUG: FirebaseAuthRepository - Persistencia establecida en SESSION (Web)');
      } else {
        // En dispositivos móviles la persistencia LOCAL es la predeterminada
        // No necesitamos configurarla explícitamente
        developer.log('DEBUG: FirebaseAuthRepository - Usando persistencia predeterminada en dispositivos móviles (LOCAL)');
      }
    } catch (e) {
      developer.log('ERROR: FirebaseAuthRepository - Error al configurar persistencia: $e');
    }
  }
  
  @override
  Future<app.User?> currentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    developer.log('DEBUG: FirebaseAuthRepository.currentUser - Usuario de Firebase: ${firebaseUser?.uid ?? "null"}');
    
    if (firebaseUser == null) {
      developer.log('DEBUG: FirebaseAuthRepository.currentUser - No hay usuario autenticado en Firebase');
      return null;
    }
    
    final userData = await _getUserData(firebaseUser.uid);
    developer.log('DEBUG: FirebaseAuthRepository.currentUser - Datos de usuario obtenidos: ${userData?.id ?? "null"}');
    return userData;
  }
  
  @override
  Future<app.User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) {
        throw Exception('Error al iniciar sesión: Usuario no encontrado');
      }
      
      final userData = await _getUserData(user.uid);
      if (userData == null) {
        throw Exception('Error al iniciar sesión: Datos de usuario no encontrados');
      }
      
      return userData;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  /// Crea un usuario en Firebase Auth sin iniciar sesión automáticamente
  /// Esta es una nueva función para ser usada internamente por la app cuando
  /// se crean usuarios desde un panel administrativo
  Future<app.User> createUserWithoutSignIn(
    String email,
    String password,
    String name,
    app.UserRole role,
  ) async {
    try {
      developer.log('DEBUG: Firebase - Creando usuario sin iniciar sesión: $email con rol: $role');
      
      // Guardar el usuario actual para restaurarlo después
      final currentUser = _firebaseAuth.currentUser;
      
      if (currentUser != null) {
        // No podemos obtener la contraseña actual, tendríamos que almacenarla de manera segura
        // Esto es una limitación de la implementación actual
        developer.log('DEBUG: Firebase - Usuario actual que se restaurará: ${currentUser.uid}');
      }
      
      // Crear usuario en Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      developer.log('DEBUG: Firebase - Usuario creado: $uid, estableciendo rol: $role');
      
      // Crear documento de usuario en Firestore en la colección apropiada
      final user = app.User(
        id: uid,
        email: email,
        name: name,
        role: role,
        permissions: Permissions.getDefaultPermissions(role),
        academyIds: [],
        createdAt: DateTime.now(),
      );
      
      // Determinar colección según el rol del usuario
      // Los superadmin y owners tienen sus propias colecciones
      if (role == app.UserRole.superAdmin) {
        await _firestore.collection('superadmins').doc(uid).set(_userToJson(user));
        developer.log('DEBUG: Firebase - Documento de superadmin creado en Firestore');
      } else if (role == app.UserRole.owner) {
        await _firestore.collection('owners').doc(uid).set(_userToJson(user));
        developer.log('DEBUG: Firebase - Documento de owner creado en Firestore');
      } else {
        // Para los otros roles, se guardarán en la subcolección de la academia correspondiente
        // Esto se manejará en el UserService al asignar la academia
        // Por ahora mantenemos la colección users para compatibilidad
        await _firestore.collection('users').doc(uid).set(_userToJson(user));
        developer.log('DEBUG: Firebase - Documento de usuario creado en Firestore (temporal, se moverá a la academia)');
      }
      
      // Cerrar sesión del usuario recién creado para no permanecer autenticado como él
      await _firebaseAuth.signOut();
      
      // Si había un usuario anterior, necesitaríamos volver a iniciar sesión con él
      // Pero esto requeriría conocer su contraseña, lo cual no tenemos
      // Por ahora, simplemente dejamos al usuario desconectado
      // y la UI debería redirigir al login
      
      return user;
    } catch (e) {
      developer.log('DEBUG: Firebase - Error al crear usuario: $e');
      throw _handleAuthException(firebase_auth.FirebaseAuthException(code: 'unknown', message: 'Error al crear usuario: $e'));
    }
  }
  
  @override
  Future<app.User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    app.UserRole role,
  ) async {
    try {
      developer.log('DEBUG: Firebase - Registrando usuario: $email con rol: $role');
      // Crear usuario en Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      
      // Usar el rol proporcionado directamente
      developer.log('DEBUG: Firebase - Usuario creado: $uid, estableciendo rol: $role');
      
      // Crear documento de usuario en Firestore
      final user = app.User(
        id: uid,
        email: email,
        name: name,
        role: role, // Usar el rol proporcionado sin modificar
        permissions: Permissions.getDefaultPermissions(role),
        academyIds: [],
        createdAt: DateTime.now(),
      );
      
      // Determinar colección según el rol del usuario
      if (role == app.UserRole.superAdmin) {
        await _firestore.collection('superadmins').doc(uid).set(_userToJson(user));
      } else if (role == app.UserRole.owner) {
        await _firestore.collection('owners').doc(uid).set(_userToJson(user));
      } else {
        // Para los otros roles, se guardarán en la subcolección de la academia correspondiente
        // Esto se manejará en el UserService al asignar la academia
        // Por ahora mantenemos la colección users para compatibilidad
        await _firestore.collection('users').doc(uid).set(_userToJson(user));
      }
      
      developer.log('DEBUG: Firebase - Documento de usuario creado en Firestore');
      return user;
    } catch (e) {
      developer.log('DEBUG: Firebase - Error al registrar usuario: $e');
      throw _handleAuthException(firebase_auth.FirebaseAuthException(code: 'unknown', message: 'Error al registrar usuario: $e'));
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  @override
  Stream<app.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      developer.log('DEBUG: FirebaseAuthRepository.authStateChanges - Cambio en estado de autenticación: ${firebaseUser?.uid ?? "null"}');
      
      if (firebaseUser == null) {
        developer.log('DEBUG: FirebaseAuthRepository.authStateChanges - Usuario Firebase null');
        return null;
      }
      
      final userData = await _getUserData(firebaseUser.uid);
      developer.log('DEBUG: FirebaseAuthRepository.authStateChanges - Datos de usuario obtenidos: ${userData?.id ?? "null"}');
      return userData;
    });
  }
  
  @override
  Future<app.User> updateUser(app.User user) async {
    try {
      // Determinar la colección correcta basada en el rol del usuario
      if (user.role == app.UserRole.superAdmin) {
        await _firestore.collection('superadmins').doc(user.id).update(_userToJson(user));
      } else if (user.role == app.UserRole.owner) {
        await _firestore.collection('owners').doc(user.id).update(_userToJson(user));
      } else if (user.academyIds.isNotEmpty) {
        // Usuario con academia asignada - actualizar en la subcolección de la academia
        for (final academyId in user.academyIds) {
          await _firestore.collection('academies').doc(academyId).collection('users').doc(user.id).update(_userToJson(user));
        }
      } else {
        // Para compatibilidad - actualizar en colección principal
        await _firestore.collection('users').doc(user.id).update(_userToJson(user));
      }
      
      return user;
    } catch (e) {
      debugPrint('Error al actualizar usuario: $e');
      rethrow;
    }
  }
  
  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Generar un nombre único para la imagen
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Referencia a donde se guardará la imagen
      final storageRef = _storage.ref().child('profile_images/$userId/$fileName');
      
      // Subir la imagen
      final uploadTask = storageRef.putFile(imageFile);
      
      // Esperar a que se complete la subida
      final snapshot = await uploadTask;
      
      // Obtener la URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Actualizar el documento del usuario con la URL de la imagen
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': downloadUrl,
      });
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir imagen de perfil: $e');
      rethrow;
    }
  }
  
  // Helpers
  
  /// Obtiene los datos de un usuario de Firestore
  Future<app.User?> _getUserData(String uid) async {
    try {
      developer.log('DEBUG: FirebaseAuthRepository._getUserData - Buscando usuario con ID: $uid');
      
      // Buscar primero en la colección de superadmins
      var doc = await _firestore.collection('superadmins').doc(uid).get();
      
      if (doc.exists) {
        developer.log('DEBUG: FirebaseAuthRepository._getUserData - Usuario encontrado en colección superadmins');
        return _userFromFirestore(doc);
      }
      
      // Buscar en la colección de owners
      doc = await _firestore.collection('owners').doc(uid).get();
      
      if (doc.exists) {
        developer.log('DEBUG: FirebaseAuthRepository._getUserData - Usuario encontrado en colección owners');
        return _userFromFirestore(doc);
      }
      
      // Buscar en la colección principal de users (para compatibilidad)
      doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        developer.log('DEBUG: FirebaseAuthRepository._getUserData - Usuario encontrado en colección users');
        return _userFromFirestore(doc);
      }
      
      // Si no se encuentra en las colecciones principales, buscar en las subcolecciones de academias
      // Primero necesitamos obtener todas las academias
      final academiesSnapshot = await _firestore.collection('academies').get();
      
      for (final academyDoc in academiesSnapshot.docs) {
        final academyId = academyDoc.id;
        // Buscar en la subcolección users de cada academia
        doc = await _firestore.collection('academies').doc(academyId).collection('users').doc(uid).get();
        
        if (doc.exists) {
          developer.log('DEBUG: FirebaseAuthRepository._getUserData - Usuario encontrado en subcolección users de academia: $academyId');
          return _userFromFirestore(doc);
        }
      }
      
      developer.log('DEBUG: FirebaseAuthRepository._getUserData - Documento no existe en ninguna colección de Firestore');
      return null;
    } catch (e) {
      developer.log('ERROR: FirebaseAuthRepository._getUserData - Error: $e');
      return null;
    }
  }
  
  /// Convierte un documento de Firestore a un objeto User
  app.User _userFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return app.User(
      id: doc.id,
      email: data['email'] as String,
      name: data['name'] as String,
      role: app.UserRole.values.firstWhere(
        (role) => role.toString() == data['role'],
        orElse: () => app.UserRole.guest,
      ),
      permissions: Map<String, bool>.from(data['permissions'] as Map<dynamic, dynamic>),
      academyIds: List<String>.from(data['academyIds'] as List<dynamic>? ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }
  
  /// Convierte un objeto User a un Map para Firestore
  Map<String, dynamic> _userToJson(app.User user) {
    final map = {
      'email': user.email,
      'name': user.name,
      'role': user.role.toString(),
      'permissions': user.permissions,
      'academyIds': user.academyIds,
      'createdAt': Timestamp.fromDate(user.createdAt),
    };
    
    if (user.profileImageUrl != null) {
      map['profileImageUrl'] = user.profileImageUrl!;
    }
    
    return map;
  }
  
  /// Maneja las excepciones de Firebase Auth
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Usuario no encontrado');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'invalid-credential':
        return Exception('Credenciales inválidas');
      case 'user-disabled':
        return Exception('Usuario deshabilitado');
      case 'email-already-in-use':
        return Exception('El email ya está en uso');
      case 'operation-not-allowed':
        return Exception('Operación no permitida');
      case 'weak-password':
        return Exception('Contraseña débil');
      default:
        return Exception('Error de autenticación: ${e.message}');
    }
  }
} 