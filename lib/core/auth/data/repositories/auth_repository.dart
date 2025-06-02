import 'package:arcinus/core/auth/roles.dart'; // Importar roles
import 'package:arcinus/core/auth/user.dart';
import 'package:arcinus/core/utils/error/failures.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Alias para evitar conflictos
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'auth_repository.g.dart';

// Provider para la instancia de FirebaseAuth
@Riverpod(keepAlive: true)
/// Provider para la instancia de FirebaseAuth.
firebase_auth.FirebaseAuth firebaseAuthInstance(Ref ref) {
  return firebase_auth.FirebaseAuth.instance;
}

// Provider para la instancia de Firestore
@Riverpod(keepAlive: true)
/// Provider para la instancia de Firestore.
FirebaseFirestore firestoreInstance(Ref ref) {
  return FirebaseFirestore.instance;
}

// Provider para el repositorio
@Riverpod(keepAlive: true)
/// Provider para el repositorio de autenticación.
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository(
    ref.watch(firebaseAuthInstanceProvider),
    ref.watch(firestoreInstanceProvider),
  );
}

/// Modelo para la invitación de usuario
class UserInvitation {
  /// Crea una nueva instancia de [UserInvitation]
  UserInvitation({
    required this.email,
    required this.role,
    required this.academyId,
    this.initialPassword,
    this.permissions,
    this.name,
  });

  /// Email del usuario invitado
  final String email;

  /// Rol asignado al usuario
  final AppRole role;

  /// ID de la academia a la que se invita
  final String academyId;

  /// Contraseña inicial (opcional)
  final String? initialPassword;

  /// Permisos específicos (para rol colaborador)
  final List<String>? permissions;

  /// Nombre del usuario (opcional)
  final String? name;
}

// Interfaz del Repositorio de Autenticación
/// Define la interfaz para las operaciones de autenticación.
///
/// Esta clase abstracta establece el contrato
/// que deben seguir las implementaciones
/// concretas del repositorio de autenticación, como [FirebaseAuthRepository].
abstract class AuthRepository {
  /// Stream que emite el estado de autenticación.
  ///
  /// Emite un [User] cuando el usuario está autenticado,
  /// o `null` si no lo está.
  /// Escucha los cambios en tiempo real del estado de autenticación subyacente.
  Stream<User?> get authStateChanges;

  /// Inicia sesión con correo y contraseña.
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Cierra la sesión actual.
  Future<Either<Failure, void>> signOut();

  /// Obtiene el usuario actual.
  User? get currentUser;

  /// Crea un usuario por invitación.
  ///
  /// Esta operación debe ser realizada por un usuario con permisos adecuados
  /// (generalmente un Propietario o SuperAdmin).
  ///
  /// Normalmente, esto crea el usuario en Firebase Auth, establece un rol inicial
  /// y puede inicializar datos en Firestore.
  ///
  /// [invitation] contiene la información necesaria para crear el usuario.
  Future<Either<Failure, void>> createUserByInvitation(
    UserInvitation invitation,
  );

  /// Establece o actualiza el rol de un usuario mediante Custom Claims.
  ///
  /// Esta operación típicamente requiere privilegios administrativos y
  /// suele implementarse a través de una Cloud Function, ya que modificar
  /// Custom Claims requiere acceso al Admin SDK de Firebase.
  ///
  /// [userId] es el ID del usuario al que se le asignará el rol.
  /// [role] es el nuevo rol a asignar.
  Future<Either<Failure, void>> setUserRole(String userId, AppRole role);

  /// Crea un nuevo usuario con correo y contraseña.
  Future<Either<Failure, User>> createUserWithEmailAndPassword(
    String email,
    String password,
  );
}

// Implementación con [Firebase Auth]
/// Implementación concreta de [AuthRepository] que utiliza
/// Firebase Authentication.
///
/// Maneja las operaciones de autenticación interactuando
/// directamente con el servicio
/// de Firebase Auth.
class FirebaseAuthRepository implements AuthRepository {
  /// Crea una instancia de [FirebaseAuthRepository].
  FirebaseAuthRepository(this._firebaseAuth, this._firestore);

  /// Instancia de FirebaseAuth utilizada para las operaciones de autenticación.
  final firebase_auth.FirebaseAuth _firebaseAuth;

  /// Instancia de Firestore para operaciones de base de datos.
  final FirebaseFirestore _firestore;

  @override
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap(_mapFirebaseUser);

  @override
  User? get currentUser {
    // NOTA: Esta versión síncrona de currentUser
    //NO PUEDE obtener los Custom Claims
    // ya que no refresca el token automáticamente.
    //Usar con precaución o preferir
    // el stream authStateChanges o llamar a un método asíncrono.
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _mapFirebaseUserSync(firebaseUser);
  }

  @override
  Future<Either<Failure, User>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Crear documento en Firestore para el nuevo usuario con rol de Propietario por defecto
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': AppRole.propietario.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      final user = await _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return left(
          const Failure.authError(
            code: 'unknown',
            message: 'No se pudo crear el usuario.',
          ),
        );
      }
      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e, s) {
      AppLogger.logError(
        message: 'Error creando usuario',
        error: e,
        stackTrace: s
      );
      return left(_handleAuthError(e));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado creando usuario',
        error: e,
        stackTrace: s
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  // Mapeo ASÍNCRONO: Puede refrescar token para obtener Claims
  Future<User?> _mapFirebaseUser(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }
    try {
      // Intentar obtener rol desde Custom Claims primero
      final idTokenResult = await firebaseUser.getIdTokenResult(true);
      String? roleString = idTokenResult.claims?['role'] as String?;
      AppRole? role;
      
      // Si no hay rol en claims, intentar obtenerlo desde Firestore
      if (roleString == null) {
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          roleString = userDoc.data()?['role'] as String?;
        }
      }
      
      role = AppRole.fromString(roleString);

      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        role: role,
        // El UserProfileProvider se encargará de obtener estos detalles.
      );
    } catch (e) {
      // Si hay error al obtener token/claims, devolver usuario básico
      AppLogger.logWarning(
        'Error al obtener claims de usuario o datos de Firestore: $e',
        error: e
      );
      return _mapFirebaseUserSync(firebaseUser);
    }
  }

  // Mapeo SÍNCRONO: Solo usa la información disponible en firebaseUser
  User _mapFirebaseUserSync(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      role: AppRole.desconocido, // Valor por defecto
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return right(null);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error durante signOut',
        error: e,
        stackTrace: s
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> createUserByInvitation(
    UserInvitation invitation,
  ) async {
    try {
      // Verificar si el usuario actual tiene permisos para invitar
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return left(
          const Failure.authError(
            code: 'no-user',
            message: 'Debes iniciar sesión para invitar usuarios.',
          ),
        );
      }

      // En una app real, verificaríamos los permisos del usuario actual
      // usando sus claims o roles en Firestore

      // 1. Crear usuario en Firebase Auth
      final password = invitation.initialPassword ?? _generateRandomPassword();
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: invitation.email,
        password: password,
      );

      if (userCredential.user == null) {
        return left(
          const Failure.authError(
            code: 'user-creation-failed',
            message: 'No se pudo crear el usuario.',
          ),
        );
      }

      final newUserId = userCredential.user!.uid;

      // 2. Almacenar datos iniciales en Firestore
      await _firestore.collection('users').doc(newUserId).set({
        'email': invitation.email,
        'name': invitation.name,
        'role': invitation.role.name,
        'academyId': invitation.academyId,
        'permissions': invitation.permissions ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'status': 'pendingProfileCompletion',
      });

      // 3. Llamar a la Cloud Function para establecer el rol (Custom Claim)
      // En un entorno real, esto enviaría una solicitud a una API o Cloud Function
      final Either<Failure, void> roleResult = await setUserRole(newUserId, invitation.role);

      if (roleResult.isLeft()) {
        // Si falla establecer el rol, continuamos pero registramos el error
        AppLogger.logWarning('Error estableciendo rol para usuario invitado: $newUserId');
      }

      // 4. En una implementación real, enviaríamos un email al usuario
      // con instrucciones para completar su registro o establecer contraseña

      return right(null);
    } on firebase_auth.FirebaseAuthException catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear usuario por invitación (FirebaseAuthException)',
        error: e,
        stackTrace: s
      );
      return left(_handleAuthError(e));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al crear usuario por invitación (Inesperado)',
        error: e,
        stackTrace: s
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  @override
  Future<Either<Failure, void>> setUserRole(String userId, AppRole role) async {
    try {
      // En una implementación real, esto llamaría a una Cloud Function
      // específica para establecer Custom Claims, ya que no se puede hacer
      // directamente desde el cliente por seguridad.

      // Ejemplo de cómo sería la llamada a una Cloud Function:
      /*
      final callable = FirebaseFunctions.instance.httpsCallable('setUserRole');
      final result = await callable.call({
        'userId': userId,
        'role': role.name,
      });
      
      if (result.data['success'] != true) {
        return left(Failure.serverError(
          message: result.data['message'] ?? 'Error al establecer el rol del usuario',
        ));
      }
      */

      // Para este ejemplo, simulamos que la operación fue exitosa
      AppLogger.logInfo('Estableciendo rol $role para usuario $userId');
      AppLogger.logWarning('setUserRole: NOTA: Esta función debe implementarse con Cloud Functions');

      return right(null);
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error al establecer rol de usuario',
        error: e,
        stackTrace: s
      );
      return left(Failure.unexpectedError(error: e));
    }
  }

  /// Genera una contraseña aleatoria para invitaciones
  String _generateRandomPassword() {
    // En una implementación real, generaríamos una contraseña segura
    // utilizando alguna biblioteca de generación de contraseñas aleatorias
    return 'Temp${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Mapea una excepción de Firebase Auth a un objeto Failure.
  Failure _handleAuthError(firebase_auth.FirebaseAuthException e) {
    AppLogger.logWarning('FirebaseAuthException: Código=${e.code}, Mensaje=${e.message}');
    // Considera mapear códigos específicos a mensajes amigables si es necesario
    // ej. 'user-not-found', 'wrong-password', 'invalid-email'
    return Failure.authError(code: e.code, message: e.message ?? e.code);
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return left(
          const Failure.authError(
            code: 'unknown',
            message: 'Fallo al mapear usuario autenticado.',
          ),
        );
      }
      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.logWarning(
        'Error durante inicio de sesión (FirebaseAuthException)',
        error: e
      );
      return left(_handleAuthError(e));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error durante inicio de sesión (Inesperado)',
        error: e,
        stackTrace: s
      );
      return left(Failure.unexpectedError(error: e));
    }
  }
}
