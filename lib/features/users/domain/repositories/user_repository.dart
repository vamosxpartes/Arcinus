import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart'; // Importar UserModel
import 'package:arcinus/features/payments/data/models/client_user_model.dart';
import 'package:arcinus/features/payments/data/models/manager_user_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz abstracta para operaciones relacionadas con datos de usuarios
/// almacenados en la base de datos (ej. Firestore), no directamente
/// relacionadas con la autenticación.
abstract class UserRepository {

  /// Busca un usuario por su dirección de correo electrónico.
  ///
  /// Devuelve el [UserModel] si se encuentra un usuario con ese email,
  /// o `null` si no se encuentra ningún usuario.
  /// Devuelve un [Failure] en caso de error de comunicación.
  Future<Either<Failure, UserModel?>> getUserByEmail(String email);

  /// Obtiene los detalles de un usuario por su ID (Firebase UID).
  ///
  /// Devuelve el [UserModel] si se encuentra,
  /// o un [Failure] en caso de error o si no existe.
  Future<Either<Failure, UserModel>> getUserById(String userId);

  /// Crea o actualiza el documento de un usuario en Firestore.
  ///
  /// Útil después del registro o al completar/actualizar el perfil.
  /// Devuelve [void] en caso de éxito, o un [Failure] en caso de error.
  Future<Either<Failure, void>> upsertUser(UserModel user);

  /// Crea o actualiza un usuario manager (propietario o colaborador)
  Future<Either<Failure, ManagerUserModel>> createOrUpdateManagerUser(
    String userId, 
    String academyId, 
    AppRole managerType,
    {List<ManagerPermission>? permissions}
  );
  
  /// Crea o actualiza un usuario cliente (atleta o padre)
  Future<Either<Failure, ClientUserModel>> createOrUpdateClientUser(
    String userId, 
    String academyId, 
    AppRole clientType,
    {Map<String, dynamic>? additionalData}
  );

  // Otros métodos podrían incluir: updateUser, deleteUser, etc.
} 