import 'package:arcinus/core/utils/error/failures.dart';
import 'package:arcinus/core/providers/firebase_providers.dart'; // Para Firestore
import 'package:arcinus/features/academy_users/data/models/membership_model.dart';
import 'package:arcinus/features/academy_users/domain/repositories/membership_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:arcinus/core/utils/app_logger.dart';

part 'membership_repository_impl.g.dart';

/// Implementación de [MembershipRepository] usando Firestore.
class MembershipRepositoryImpl implements MembershipRepository {
  static const String _className = 'MembershipRepositoryImpl';
  
  final FirebaseFirestore _firestore;
  late final CollectionReference _membershipsCollection;

  MembershipRepositoryImpl(this._firestore) {
    _membershipsCollection = _firestore.collection('memberships');
    AppLogger.logInfo(
      'Inicializado MembershipRepositoryImpl',
      className: _className,
      functionName: 'constructor',
    );
  }

  @override
  Future<Either<Failure, void>> createMembership(MembershipModel membership) async {
    try {
      AppLogger.logInfo(
        'Creando membresía',
        className: _className,
        functionName: 'createMembership',
        params: {
          'userId': membership.userId,
          'academyId': membership.academyId,
        },
      );
      
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
      
      AppLogger.logInfo(
        'Membresía creada exitosamente',
        className: _className,
        functionName: 'createMembership',
        params: {
          'userId': membership.userId,
          'academyId': membership.academyId,
        },
      );
      
      return const Right(null); // Éxito (void)
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firestore al crear membresía',
        error: e,
        className: _className,
        functionName: 'createMembership',
        params: {
          'code': e.code,
          'message': e.message,
          'userId': membership.userId,
          'academyId': membership.academyId,
        },
      );
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado creando membresía',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createMembership',
        params: {
          'userId': membership.userId,
          'academyId': membership.academyId,
        },
      );
      return Left(ServerFailure(message: 'Error inesperado creando membresía: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MembershipModel>>> getMembershipsByAcademy(
    String academyId,
  ) async {
    if (academyId.isEmpty) {
      AppLogger.logWarning(
        'ID de academia vacío en getMembershipsByAcademy',
        className: _className,
        functionName: 'getMembershipsByAcademy',
      );
      return const Left(Failure.validationError(message: 'Academy ID no puede estar vacío'));
    }
    try {
      AppLogger.logInfo(
        'Obteniendo membresías por academia',
        className: _className,
        functionName: 'getMembershipsByAcademy',
        params: {'academyId': academyId},
      );
      
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

      AppLogger.logInfo(
        'Membresías obtenidas exitosamente',
        className: _className,
        functionName: 'getMembershipsByAcademy',
        params: {'academyId': academyId, 'count': memberships.length},
      );
      
      return Right(memberships);
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener membresías',
        error: e,
        className: _className,
        functionName: 'getMembershipsByAcademy',
        params: {'academyId': academyId, 'code': e.code, 'message': e.message},
      );
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado obteniendo membresías',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getMembershipsByAcademy',
        params: {'academyId': academyId},
      );
      return Left(ServerFailure(message: 'Error inesperado obteniendo membresías: $e'));
    }
  }

  @override
  Future<Either<Failure, MembershipModel>> getMembershipById(String membershipId) async {
    if (membershipId.isEmpty) {
      AppLogger.logWarning(
        'ID de membresía vacío en getMembershipById',
        className: _className,
        functionName: 'getMembershipById',
      );
      return const Left(Failure.validationError(message: 'Membership ID no puede estar vacío'));
    }
    try {
      AppLogger.logInfo(
        'Obteniendo membresía por ID',
        className: _className,
        functionName: 'getMembershipById',
        params: {'membershipId': membershipId},
      );
      
      final docSnapshot = await _membershipsCollection.doc(membershipId).get();

      if (!docSnapshot.exists) {
        AppLogger.logWarning(
          'Membresía no encontrada',
          className: _className,
          functionName: 'getMembershipById',
          params: {'membershipId': membershipId},
        );
        return const Left(ServerFailure(message: 'Membresía no encontrada'));
      }

      final data = docSnapshot.data()! as Map<String, dynamic>;
      // Añadir el ID del documento al modelo
      final membership = MembershipModel.fromJson(data).copyWith(id: docSnapshot.id);
      
      AppLogger.logInfo(
        'Membresía obtenida exitosamente',
        className: _className,
        functionName: 'getMembershipById',
        params: {'membershipId': membershipId},
      );
      
      return Right(membership);

    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener membresía por ID',
        error: e,
        className: _className,
        functionName: 'getMembershipById',
        params: {'membershipId': membershipId, 'code': e.code, 'message': e.message},
      );
      return Left(ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'));
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado obteniendo membresía por ID',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getMembershipById',
        params: {'membershipId': membershipId},
      );
      return Left(ServerFailure(message: 'Error inesperado obteniendo membresía por ID: $e'));
    }
  }
}

/// Provider para la implementación del repositorio de membresías.
@riverpod
MembershipRepository membershipRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  AppLogger.logInfo(
    'Creando instancia de MembershipRepository',
    className: 'membership_repository',
    functionName: 'membershipRepository',
  );
  return MembershipRepositoryImpl(firestore);
} 