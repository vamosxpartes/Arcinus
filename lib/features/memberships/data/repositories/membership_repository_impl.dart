import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/core/providers/firebase_providers.dart'; // Para Firestore
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/domain/repositories/membership_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_repository_impl.g.dart';

/// Implementación de [MembershipRepository] usando Firestore.
class MembershipRepositoryImpl implements MembershipRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference _membershipsCollection;

  MembershipRepositoryImpl(this._firestore) {
    _membershipsCollection = _firestore.collection('memberships');
  }

  @override
  Future<Either<Failure, void>> createMembership(MembershipModel membership) async {
    try {
      // Asegurar que addedAt esté seteado (podría hacerse en el Notifier también)
      // final membershipToCreate = membership.copyWith(addedAt: DateTime.now());
      // El modelo ya requiere addedAt, así que asumimos que viene seteado.
      final dataToAdd = membership.toJson();
      // Remover id si existe, Firestore lo genera
      dataToAdd.remove('id'); 

      // Podríamos verificar si ya existe una membresía para ese usuario/academia
      // antes de crearla, para evitar duplicados.
      // Query q = _membershipsCollection
      //    .where('userId', isEqualTo: membership.userId)
      //    .where('academyId', isEqualTo: membership.academyId);
      // ... (si q.get().docs.isNotEmpty, retornar error o actualizar)

      await _membershipsCollection.add(dataToAdd);
      return const Right(null); // Éxito (void)
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado creando membresía: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MembershipModel>>> getMembershipsByAcademy(
    String academyId,
  ) async {
    if (academyId.isEmpty) {
      return const Left(Failure.validationError(message: 'Academy ID no puede estar vacío'));
    }
    try {
      final querySnapshot = await _membershipsCollection
          .where('academyId', isEqualTo: academyId)
          // Opcional: ordenar por rol o fecha de adición
          // .orderBy('role') 
          // .orderBy('addedAt', descending: true)
          .get();

      final memberships = querySnapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        // Añadir el ID del documento al modelo
        return MembershipModel.fromJson(data).copyWith(id: doc.id);
      }).toList();

      return Right(memberships);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado obteniendo membresías: $e'));
    }
  }

  @override
  Future<Either<Failure, MembershipModel>> getMembershipById(String membershipId) async {
    if (membershipId.isEmpty) {
      return const Left(Failure.validationError(message: 'Membership ID no puede estar vacío'));
    }
    try {
      final docSnapshot = await _membershipsCollection.doc(membershipId).get();

      if (!docSnapshot.exists) {
        return const Left(ServerFailure(message: 'Membresía no encontrada'));
      }

      final data = docSnapshot.data()! as Map<String, dynamic>;
      // Añadir el ID del documento al modelo
      final membership = MembershipModel.fromJson(data).copyWith(id: docSnapshot.id);
      return Right(membership);

    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado obteniendo membresía por ID: $e'));
    }
  }
}

/// Provider para la implementación del repositorio de membresías.
@riverpod
MembershipRepository membershipRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return MembershipRepositoryImpl(firestore);
} 