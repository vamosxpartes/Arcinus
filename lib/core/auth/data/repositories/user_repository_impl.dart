import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/utils/providers/firebase_providers.dart'; // Para Firestore
import 'package:arcinus/core/auth/data/models/user_model.dart';
import 'package:arcinus/features/academy_users/data/models/manager/academy_manager_permission.dart';
import 'package:arcinus/core/auth/domain/repositories/user_repository.dart';
import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/features/academy_users/data/models/manager/academy_manager_model.dart';
import 'package:arcinus/features/academy_users/data/models/member/academy_member_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_repository_impl.g.dart';

/// Implementación de [UserRepository] usando Firestore.
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _usersCollection;

  UserRepositoryImpl(this._firestore) {
    _usersCollection = _firestore.collection('users');
  }

  @override
  Future<Either<Failure, UserModel?>> getUserByEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      return const Left(Failure.validationError(message: 'Email inválido'));
    }
    try {
      final querySnapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Right(null); // No encontrado
      }

      final doc = querySnapshot.docs.first;
      final user = UserModel.fromJson(doc.data()! as Map<String, dynamic>)
          .copyWith(id: doc.id); // Asegurar que el ID esté presente
      return Right(user);
    } on FirebaseException catch (e) {
      return Left(Failure.serverError(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.serverError(message: 'Error inesperado buscando usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserById(String userId) async {
     if (userId.isEmpty) {
      return const Left(Failure.validationError(message: 'User ID inválido'));
    }
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();

      if (!docSnapshot.exists) {
        return Left(Failure.notFound(message: 'Usuario no encontrado')); 
      }

      final user = UserModel.fromJson(docSnapshot.data()! as Map<String, dynamic>)
          .copyWith(id: docSnapshot.id);
      return Right(user);
    } on FirebaseException catch (e) {
      return Left(Failure.serverError(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.serverError(message: 'Error inesperado obteniendo usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> upsertUser(UserModel user) async {
     if (user.id.isEmpty) {
      return const Left(Failure.validationError(message: 'User ID es requerido para upsert'));
    }
    try {
      // Usamos set con merge: true para crear si no existe o actualizar si existe.
      await _usersCollection.doc(user.id).set(
        user.toJson(), 
        SetOptions(merge: true), // Merge para no sobreescribir campos no incluidos
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(Failure.serverError(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.serverError(message: 'Error inesperado guardando usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, ManagerUserModel>> createOrUpdateManagerUser(
    String userId, 
    String academyId, 
    AppRole managerType,
    {List<ManagerPermission>? permissions}
  ) async {
    try {
      // 1. Primero verificamos si el usuario existe
      final userResult = await getUserById(userId);
      
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // 2. Verificar que el tipo de usuario es correcto (propietario o colaborador)
          if (managerType != AppRole.propietario && managerType != AppRole.colaborador) {
            return Left(Failure.validationError(
              message: 'Tipo de manager inválido. Debe ser PROPIETARIO o COLABORADOR'
            ));
          }
          
          // 3. Asignar permisos según el tipo
          final defaultPermissions = managerType == AppRole.propietario
              ? [ManagerPermission.fullAccess]
              : permissions ?? [
                  ManagerPermission.manageUsers,
                  ManagerPermission.managePayments
                ];
          
          // 4. Crear modelo de manager
          final now = DateTime.now();
          final managerUser = ManagerUserModel(
            userId: userId,
            academyId: academyId.isEmpty ? 'pending_academy' : academyId, // Valor temporal si no hay academyId
            managerType: managerType,
            permissions: defaultPermissions,
            createdAt: now,
            updatedAt: now,
          );
          
          // 5. Guardar en Firestore solo si hay academyId válido
          if (academyId.isNotEmpty) {
            final managerData = managerUser.toJson();
            
            await _firestore
                .collection('academies')
                .doc(academyId)
                .collection('managers')
                .doc(userId)
                .set(managerData, SetOptions(merge: true));
          } else {
            // Si no hay academyId, guardar en una colección temporal de managers pendientes
            await _firestore
                .collection('pending_managers')
                .doc(userId)
                .set(managerUser.toJson(), SetOptions(merge: true));
          }
          
          // 6. Si es propietario, actualizar el campo role en users
          if (managerType == AppRole.propietario && user.appRole != AppRole.propietario) {
            await _usersCollection.doc(userId).update({
              'role': managerType.name,
            });
          }
          
          return Right(managerUser.copyWith(id: userId));
        },
      );
    } on FirebaseException catch (e) {
      return Left(Failure.serverError(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.serverError(message: 'Error inesperado creando manager: $e'));
    }
  }

  @override
  Future<Either<Failure, AcademyMemberUserModel>> createOrUpdateClientUser(
    String userId, 
    String academyId, 
    AppRole clientType,
    {Map<String, dynamic>? additionalData}
  ) async {
    try {
      // 1. Primero verificamos si el usuario existe
      final userResult = await getUserById(userId);
      
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // 2. Verificar que el tipo de usuario es correcto (atleta o padre)
          if (clientType != AppRole.atleta && clientType != AppRole.padre) {
            return Left(Failure.validationError(
              message: 'Tipo de cliente inválido. Debe ser ATLETA o PADRE'
            ));
          }
          
          // 3. Crear modelo de cliente
          final clientUser = AcademyMemberUserModel(
            userId: userId,
            academyId: academyId,
            clientType: clientType,
            // Añadimos datos adicionales si existen
            metadata: additionalData ?? {},
          );
          
          // 4. Guardar en Firestore
          final clientData = clientUser.toJson();
          
          await _firestore
              .collection('academies')
              .doc(academyId)
              .collection('clients')
              .doc(userId)
              .set(clientData, SetOptions(merge: true));
          
          // 5. Actualizar el campo role en users si es necesario
          if (user.appRole != clientType) {
            await _usersCollection.doc(userId).update({
              'role': clientType.name,
            });
          }
          
          return Right(clientUser.copyWith(id: userId));
        },
      );
    } on FirebaseException catch (e) {
      return Left(Failure.serverError(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(Failure.serverError(message: 'Error inesperado creando cliente: $e'));
    }
  }
}

/// Provider para la implementación del repositorio de usuarios.
@riverpod
UserRepository userRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserRepositoryImpl(firestore);
}

/// Provider para el repositorio de usuarios generales
@riverpod
UserRepository userRepositoryGeneral(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserRepositoryImpl(firestore);
} 