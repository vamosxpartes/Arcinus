import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:arcinus/features/app/users/user/core/models/user.dart' as app;
// Eliminar UserService y Riverpod si ya no se usan directamente aquí
// import 'package:arcinus/features/app/users/user/core/services/user_service.dart';
import 'package:arcinus/features/permissions/core/models/permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

import 'auth_repository.dart';

// Eliminar el provider placeholder si ya no se necesita
/*
final userServiceProvider = Provider<UserService>((ref) {
  throw UnimplementedError('Define el provider real para UserService');
});
*/

/// Implementación de Firebase para el repositorio de autenticación
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  // Eliminar Ref
  // final Ref ref;

  FirebaseAuthRepository({
    // Eliminar ref del constructor
    // required this.ref,
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance {
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
    developer.log('WARN: createUserWithoutSignIn - Revisar implementación para multi-academia');
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
        developer.log('DEBUG: Firebase - Documento de superadmin creado en Firestore (revisar)');
      } else if (role == app.UserRole.owner) {
        await _firestore.collection('owners').doc(uid).set(_userToJson(user));
        developer.log('DEBUG: Firebase - Documento de owner creado en Firestore (revisar)');
      } else {
        // Para los otros roles, se guardarán en la subcolección de la academia correspondiente
        // Esto se manejará en el UserService al asignar la academia
        // Por ahora mantenemos la colección users para compatibilidad
        await _firestore.collection('users').doc(uid).set(_userToJson(user));
        developer.log('WARN: Firebase - Documento de usuario creado en /users (debe usar UserService con academyId)');
      }
      
      // Cerrar sesión del usuario recién creado para no permanecer autenticado como él
      await _firebaseAuth.signOut();
      
      // Si había un usuario anterior, necesitaríamos volver a iniciar sesión con él
      // Pero esto requeriría conocer su contraseña, lo cual no tenemos
      // Por ahora, simplemente dejamos al usuario desconectado
      // y la UI debería redirigir al login
      
      return user;
    } catch (e) {
      developer.log('ERROR: Firebase - Error al crear usuario sin sign-in: $e');
      // Simplificamos el manejo de excepciones aquí
       if (e is firebase_auth.FirebaseAuthException) {
         throw _handleAuthException(e);
       } else {
         throw Exception('Error desconocido al crear usuario: $e');
       }
    }
  }
  
  @override
  Future<app.User> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    app.UserRole role,
  ) async {
    developer.log('WARN: signUpWithEmailAndPassword - Método de registro directo llamado. Revisar si debe estar activo y su lógica de academia.');
    try {
      developer.log('DEBUG: Firebase - Registrando usuario directo: $email con rol: $role');
      // Crear usuario en Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      
      developer.log('DEBUG: Firebase - Usuario Auth creado: $uid, rol: $role');
      
      // Crear el objeto User
       final user = app.User(
         id: uid,
         email: email,
         name: name,
         role: role,
         permissions: Permissions.getDefaultPermissions(role),
         academyIds: [], // No se asigna academia aquí
         createdAt: DateTime.now(),
       );

      // **Problema:** Al igual que en createUserWithoutSignIn, la escritura
      // directa en colecciones raíz o en 'users' no es ideal para multi-academia.
      // Debería usarse UserService.
      if (role == app.UserRole.superAdmin) {
        await _firestore.collection('superadmins').doc(uid).set(_userToJson(user));
      } else if (role == app.UserRole.owner) {
        await _firestore.collection('owners').doc(uid).set(_userToJson(user));
      } else {
         // ¡No escribir en /users! El usuario necesita una academia.
        developer.log('WARN: Firebase - signUpWithEmailAndPassword para rol regular no crea documento en Firestore (necesita academia vía UserService)');
      }

      // Devuelve el objeto User, pero ten en cuenta que su documento en Firestore
      // puede no existir o estar en el lugar equivocado si no es admin/owner.
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
       developer.log('ERROR: Firebase - Error en signUpWithEmailAndPassword: $e');
      throw _handleAuthException(e);
     } catch (e) {
       developer.log('ERROR: Firebase - Error desconocido en signUpWithEmailAndPassword: $e');
       throw Exception('Error desconocido al registrar usuario: $e');
     }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      developer.log('DEBUG: FirebaseAuthRepository - Sesión cerrada');
    } catch (e) {
      developer.log('ERROR: FirebaseAuthRepository - Error al cerrar sesión: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      developer.log('DEBUG: FirebaseAuthRepository - Correo de restablecimiento enviado a: $email');
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
      
      // Intentar obtener datos del usuario. Puede fallar si el usuario acaba de
      // registrarse/activarse y el documento aún no está listo o si hay un error.
      try {
         final userData = await _getUserData(firebaseUser.uid);
         developer.log('DEBUG: FirebaseAuthRepository.authStateChanges - Datos de usuario obtenidos: ${userData?.id ?? "null"}');
         return userData;
       } catch (e) {
         developer.log('ERROR: FirebaseAuthRepository.authStateChanges - Error obteniendo datos de usuario (${firebaseUser.uid}): $e. Devolviendo null.');
         // Podríamos intentar manejar esto de forma más granular, pero por ahora devolvemos null
         // si no se pueden obtener los datos del usuario asociado al UID autenticado.
         return null;
       }
    });
  }
  
  @override
  Future<app.User> updateUser(app.User user) async {
    developer.log('DEBUG: FirebaseAuthRepository.updateUser - Actualizando usuario: ${user.id}');
    try {
      final userRef = await _getUserDocRef(user.id);
      if (userRef == null) {
        developer.log('ERROR: FirebaseAuthRepository.updateUser - No se encontró la referencia del documento para el usuario: ${user.id}');
        throw Exception('Usuario no encontrado para actualizar');
      }
      await userRef.update(_userToJson(user));
      developer.log('DEBUG: FirebaseAuthRepository.updateUser - Usuario actualizado exitosamente: ${user.id}');
      // Devuelve el mismo objeto user ya que la actualización fue exitosa.
      // Podríamos re-leer desde Firestore si quisiéramos confirmar.
      return user;
    } on FirebaseException catch (e) {
       developer.log('ERROR: FirebaseAuthRepository.updateUser - Error de Firestore al actualizar usuario ${user.id}: $e');
       throw Exception('Error de base de datos al actualizar usuario: ${e.message}');
    } catch (e) {
       developer.log('ERROR: FirebaseAuthRepository.updateUser - Error desconocido al actualizar usuario ${user.id}: $e');
      throw Exception('Error desconocido al actualizar usuario: $e');
    }
  }
  
  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    developer.log('DEBUG: FirebaseAuthRepository.uploadProfileImage - Subiendo imagen para usuario: $userId');
    try {
      final fileName = path.basename(imageFile.path);
      final destination = 'profileImages/$userId/$fileName';
      final ref = _storage.ref(destination);

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(await imageFile.readAsBytes());
      } else {
        uploadTask = ref.putFile(imageFile);
      }

      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      developer.log('DEBUG: FirebaseAuthRepository.uploadProfileImage - Imagen subida, URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      developer.log('ERROR: FirebaseAuthRepository.uploadProfileImage - Error de Firebase Storage: $e');
      throw Exception('Error al subir la imagen de perfil: ${e.message}');
    } catch (e) {
       developer.log('ERROR: FirebaseAuthRepository.uploadProfileImage - Error desconocido: $e');
      throw Exception('Error desconocido al subir la imagen de perfil: $e');
    }
  }
  
  // Helpers
  
  /// Obtiene los datos de un usuario desde Firestore buscando en las posibles ubicaciones.
  Future<app.User?> _getUserData(String uid) async {
    developer.log('DEBUG: _getUserData - Buscando datos para UID: $uid');
    
    // 1. Buscar en colecciones raíz (superadmins, owners)
    final superAdminDoc = await _firestore.collection('superadmins').doc(uid).get();
    if (superAdminDoc.exists) {
       developer.log('DEBUG: _getUserData - Encontrado en superadmins');
      return _userFromFirestore(superAdminDoc);
    }

    final ownerDoc = await _firestore.collection('owners').doc(uid).get();
    if (ownerDoc.exists) {
       developer.log('DEBUG: _getUserData - Encontrado en owners');
      return _userFromFirestore(ownerDoc);
    }

    // 2. Buscar en la subcolección 'users' de TODAS las academias
    //    ¡Esto puede ser ineficiente si hay muchas academias!
    //    Una mejor aproximación sería si supiéramos a qué academia(s) pertenece el usuario.
    //    Si el modelo User tiene un campo `academyIds`, podríamos usarlo si lo tuviéramos.
    //    Por ahora, hacemos una query de colección de grupo.
    developer.log('DEBUG: _getUserData - Buscando en subcolecciones de academias (users)');
    final querySnapshot = await _firestore.collectionGroup('users').where(FieldPath.documentId, isEqualTo: uid).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
       developer.log('DEBUG: _getUserData - Encontrado en la subcolección users de una academia.');
       final userDoc = querySnapshot.docs.first;
       // Obtener academyId de la referencia del documento
       final academyId = userDoc.reference.parent.parent?.id;
       final userData = _userFromFirestore(userDoc);
       // Asegurarse de que academyId esté en la lista (aunque debería ser así si se encontró aquí)
       if (academyId != null && !userData.academyIds.contains(academyId)) {
         userData.academyIds.add(academyId); // Añadir por si acaso no estaba
         developer.log('DEBUG: _getUserData - Añadido academyId $academyId a la lista del usuario.');
       }
      return userData;
    }

    // 3. Buscar en la colección 'users' raíz (como fallback o para usuarios sin academia?)
    //    Esto depende de tu lógica de negocio. Si todos los usuarios DEBEN estar en una academia,
    //    esta búsqueda podría eliminarse.
    // final userDoc = await _firestore.collection('users').doc(uid).get();
    // if (userDoc.exists) {
    //   developer.log('DEBUG: _getUserData - Encontrado en la colección raíz /users (revisar si es correcto)');
    //   return _userFromFirestore(userDoc);
    // }

     developer.log('WARN: _getUserData - No se encontraron datos para el usuario con UID: $uid en ninguna ubicación conocida.');
    return null;
  }
  
  /// Obtiene la referencia a un documento de usuario buscando en las posibles ubicaciones.
  Future<DocumentReference?> _getUserDocRef(String uid) async {
    developer.log('DEBUG: _getUserDocRef - Buscando referencia para UID: $uid');
    // Similar a _getUserData, pero devuelve la referencia
    final superAdminRef = _firestore.collection('superadmins').doc(uid);
    if ((await superAdminRef.get()).exists) return superAdminRef;

    final ownerRef = _firestore.collection('owners').doc(uid);
    if ((await ownerRef.get()).exists) return ownerRef;

    final querySnapshot = await _firestore.collectionGroup('users').where(FieldPath.documentId, isEqualTo: uid).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) return querySnapshot.docs.first.reference;

    // final userRef = _firestore.collection('users').doc(uid);
    // if ((await userRef.get()).exists) return userRef; // Considerar eliminar si /users no se usa

    developer.log('WARN: _getUserDocRef - No se encontró referencia para UID: $uid');
    return null;
  }
  
  /// Convierte un documento de Firestore a un objeto User
  app.User _userFromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Datos de usuario nulos en Firestore para ID: ${snapshot.id}');
    }

    // Convertir 'role' (String) a UserRole enum
    final roleString = data['role'] as String?;
    final role = app.UserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () {
        developer.log('WARN: _userFromFirestore - Rol "$roleString" inválido o ausente para usuario ${snapshot.id}. Usando guest.');
        return app.UserRole.guest; // Rol por defecto si falta o es inválido
      },
    );

    // Convertir Timestamps
    Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
    DateTime createdAt = createdAtTimestamp?.toDate() ?? DateTime.now(); // Usar now() si falta

    // Convertir lista de academyIds (asegurándose de que sea List<String>)
    List<String> academyIds = [];
    if (data['academyIds'] is List) {
       try {
         academyIds = (data['academyIds'] as List).map((item) => item.toString()).toList();
       } catch (e) {
          developer.log('WARN: _userFromFirestore - Error convirtiendo academyIds para usuario ${snapshot.id}. Usando lista vacía. Error: $e');
          academyIds = [];
       }
    }

     // Convertir lista de customRoleIds
     List<String> customRoleIds = [];
     if (data['customRoleIds'] is List) {
        try {
          customRoleIds = (data['customRoleIds'] as List).map((item) => item.toString()).toList();
        } catch (e) {
           developer.log('WARN: _userFromFirestore - Error convirtiendo customRoleIds para usuario ${snapshot.id}. Usando lista vacía. Error: $e');
           customRoleIds = [];
        }
     }

    // Convertir permissions (Map<String, dynamic> a Map<String, bool>)
    Map<String, bool> permissions = {};
    if (data['permissions'] is Map) {
      try {
          final permissionsData = data['permissions'] as Map<dynamic, dynamic>;
           permissions = permissionsData.map((key, value) => MapEntry(key.toString(), value as bool? ?? false));
      } catch (e) {
         developer.log('WARN: _userFromFirestore - Error convirtiendo permissions para usuario ${snapshot.id}. Usando defaults para rol ${role.name}. Error: $e');
         permissions = Permissions.getDefaultPermissions(role);
      }
    } else {
       developer.log('WARN: _userFromFirestore - Campo permissions ausente o no es un mapa para usuario ${snapshot.id}. Usando defaults para rol ${role.name}.');
      permissions = Permissions.getDefaultPermissions(role);
    }


    return app.User(
      id: snapshot.id,
      email: data['email'] as String? ?? '', // Manejar posible nulidad
      name: data['name'] as String? ?? '', // Manejar posible nulidad
      role: role,
      permissions: permissions,
      academyIds: academyIds,
      customRoleIds: customRoleIds,
      number: data['number'] as int?,
      createdAt: createdAt,
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }
  
  /// Convierte un objeto User a un mapa JSON para Firestore
  Map<String, dynamic> _userToJson(app.User user) {
    return {
      'email': user.email,
      'name': user.name,
      'role': user.role.name, // Guardar el nombre del enum
      'permissions': user.permissions, // Guardar el mapa directamente
      'academyIds': user.academyIds,
      'customRoleIds': user.customRoleIds,
      'number': user.number,
      // ignore: unnecessary_null_comparison
      'createdAt': user.createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(user.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'profileImageUrl': user.profileImageUrl,
    };
  }
  
  /// Maneja las excepciones de Firebase Auth
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    developer.log('ERROR: FirebaseAuthException - Código: ${e.code}, Mensaje: ${e.message}');
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'La contraseña proporcionada es demasiado débil.';
        break;
      case 'email-already-in-use':
        message = 'Ya existe una cuenta con este correo electrónico.';
        break;
      case 'user-not-found':
        message = 'No se encontró ningún usuario con ese correo electrónico.';
        break;
      case 'wrong-password':
        message = 'Contraseña incorrecta.';
        break;
      case 'invalid-email':
         message = 'El formato del correo electrónico no es válido.';
         break;
      case 'user-disabled':
         message = 'Este usuario ha sido deshabilitado.';
         break;
      case 'too-many-requests':
          message = 'Demasiados intentos. Inténtalo de nuevo más tarde.';
          break;
      case 'operation-not-allowed':
           message = 'La operación de inicio de sesión por correo/contraseña no está habilitada.';
           break;
      // Añadir más casos según sea necesario
      default:
        message = 'Ocurrió un error de autenticación inesperado.';
    }
    return Exception(message);
  }
  
  // Implementación de los Nuevos Métodos
  
  @override
  Future<String> createPendingActivation({
    required String academyId,
    required String name,
    required app.UserRole role,
    required String createdBy,
  }) async {
    developer.log('DEBUG: createPendingActivation - Creando para academyId: $academyId, name: $name, role: ${role.name}');
    try {
      // Generar código de activación único (ejemplo simple)
      final activationCode = _generateActivationCode();
      final pendingActivationRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('pendingActivations')
          .doc(activationCode);

      final data = {
        'name': name,
        'role': role.name, // Guardar el nombre del enum
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await pendingActivationRef.set(data);
      developer.log('DEBUG: createPendingActivation - Registro pendiente creado con código: $activationCode');
      return activationCode;
    } on FirebaseException catch (e) {
       developer.log('ERROR: createPendingActivation - Error de Firestore: $e');
       throw Exception('Error al crear el registro de activación pendiente: ${e.message}');
    } catch (e) {
      developer.log('ERROR: createPendingActivation - Error desconocido: $e');
      throw Exception('Error desconocido al crear la activación pendiente: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>?> verifyPendingActivation({
    required String academyId,
    required String activationCode,
  }) async {
    developer.log('DEBUG: verifyPendingActivation - Verificando código: $activationCode para academyId: $academyId');
    try {
      final pendingActivationRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('pendingActivations')
          .doc(activationCode);

      final snapshot = await pendingActivationRef.get();

      if (snapshot.exists) {
        developer.log('DEBUG: verifyPendingActivation - Código válido encontrado.');
        return snapshot.data();
      } else {
        developer.log('DEBUG: verifyPendingActivation - Código inválido o ya usado.');
        return null;
      }
    } on FirebaseException catch (e) {
       developer.log('ERROR: verifyPendingActivation - Error de Firestore: $e');
       // Podríamos querer diferenciar entre "no encontrado" y otros errores.
       // Por ahora, tratamos cualquier error de Firestore como código inválido/inaccesible.
       return null;
    } catch (e) {
       developer.log('ERROR: verifyPendingActivation - Error desconocido: $e');
       return null; // Tratar error desconocido como código inválido
    }
  }
  
  @override
  Future<app.User> completeActivationWithCode({
    required String academyId,
    required String activationCode,
    required String email,
    required String password,
  }) async {
     developer.log('DEBUG: completeActivationWithCode - Iniciando para código: $activationCode, email: $email, academyId: $academyId');
    // 1. Verificar el código de activación
    final pendingData = await verifyPendingActivation(
      academyId: academyId,
      activationCode: activationCode,
    );

    if (pendingData == null) {
       developer.log('ERROR: completeActivationWithCode - Código de activación inválido o no encontrado.');
      throw Exception('Código de activación inválido o expirado.');
    }

    final name = pendingData['name'] as String?;
    final roleString = pendingData['role'] as String?;

    if (name == null || roleString == null) {
       developer.log('ERROR: completeActivationWithCode - Datos incompletos en el registro pendiente.');
      throw Exception('Datos de pre-registro incompletos.');
    }

    final role = app.UserRole.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () {
         developer.log('ERROR: completeActivationWithCode - Rol inválido "$roleString" en el registro pendiente.');
        throw Exception('Rol de usuario inválido en el pre-registro.');
      },
    );

     developer.log('DEBUG: completeActivationWithCode - Código verificado. Name: $name, Role: $role. Procediendo a crear cuenta Auth.');

    try {
      // 2. Crear cuenta en Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
         developer.log('ERROR: completeActivationWithCode - Falló la creación del usuario en Firebase Auth.');
        throw Exception('No se pudo crear la cuenta de autenticación.');
      }
      final uid = firebaseUser.uid;
      developer.log('DEBUG: completeActivationWithCode - Cuenta Auth creada con UID: $uid. Procediendo a crear usuario en Firestore.');

      // 3. Crear registro de usuario DIRECTAMENTE en Firestore
      final newUser = app.User(
        id: uid,
        email: email,
        name: name,
        role: role,
        permissions: Permissions.getDefaultPermissions(role),
        academyIds: [academyId],
        customRoleIds: [], // Inicialmente vacío
        createdAt: DateTime.now(), // Establecer aquí, será convertido a Timestamp al guardar
      );

      // Obtener referencia al documento del nuevo usuario en la subcolección de la academia
      final userDocRef = _firestore
          .collection('academies')
          .doc(academyId)
          .collection('users')
          .doc(uid);

      // Escribir el documento usando _userToJson para la conversión correcta
      await userDocRef.set(_userToJson(newUser));

      developer.log('DEBUG: completeActivationWithCode - Usuario creado directamente en Firestore en academies/$academyId/users/$uid. Procediendo a eliminar registro pendiente.');

      // 4. Eliminar el documento de activación pendiente
      try {
         final pendingActivationRef = _firestore
             .collection('academies')
             .doc(academyId)
             .collection('pendingActivations')
             .doc(activationCode);
         await pendingActivationRef.delete();
         developer.log('DEBUG: completeActivationWithCode - Registro pendiente eliminado exitosamente.');
       } catch (deleteError) {
         developer.log('ERROR: completeActivationWithCode - Falló la eliminación del registro pendiente ($activationCode): $deleteError. El usuario ya está creado.');
       }

       // 5. Devolver el usuario recién creado (leyéndolo para asegurar consistencia)
       final finalUserData = await _getUserData(uid);
        if (finalUserData == null) {
          developer.log('ERROR: completeActivationWithCode - No se pudieron obtener los datos del usuario recién creado ($uid) después de la creación.');
          // Devolver el objeto `newUser` como fallback si _getUserData falla inesperadamente
          return newUser;
        }
         developer.log('DEBUG: completeActivationWithCode - Proceso completado exitosamente para UID: $uid.');
        return finalUserData;

     } on firebase_auth.FirebaseAuthException catch (e) {
       developer.log('ERROR: completeActivationWithCode - Error de Firebase Auth durante la creación: $e');
       // Podríamos intentar eliminar el usuario Auth si falló la escritura en Firestore, pero es complejo
       throw _handleAuthException(e);
     } on FirebaseException catch (e) {
       developer.log('ERROR: completeActivationWithCode - Error de Firestore durante la creación del usuario final: $e');
       // Si falla la escritura en Firestore, la cuenta Auth ya existe. Limpieza necesaria?
       throw Exception('Error de base de datos al crear el usuario final: ${e.message}');
     } catch (e) {
       developer.log('ERROR: completeActivationWithCode - Error desconocido: $e');
       throw Exception('Error desconocido durante la activación: $e');
     }
  }
  
  // --- Métodos Privados Auxiliares ---
  
  /// Genera un código de activación simple (ejemplo)
  String _generateActivationCode() {
    // Lógica más robusta podría ser necesaria (criptográficamente seguro, etc.)
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
} 