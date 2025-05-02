import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/providers/firebase_providers.dart'; // Para Firestore
import 'package:arcinus/features/auth/data/models/user_model.dart';
import 'package:arcinus/features/users/domain/repositories/user_repository.dart';
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
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado buscando usuario: $e'));
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
        // Podríamos tener un Failure.notFound específico
        return const Left(Failure.unexpectedError(error: 'Usuario no encontrado')); 
      }

      final user = UserModel.fromJson(docSnapshot.data()! as Map<String, dynamic>)
          .copyWith(id: docSnapshot.id);
      return Right(user);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado obteniendo usuario: $e'));
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
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado guardando usuario: $e'));
    }
  }
}

/// Provider para la implementación del repositorio de usuarios.
@riverpod
UserRepository userRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserRepositoryImpl(firestore);
} 