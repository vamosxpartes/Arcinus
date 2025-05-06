import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

/// Implementación de la interfaz [AcademyRepository] para interactuar
class AcademyRepositoryImpl implements AcademyRepository {
  /// Constructor de la clase.
  AcademyRepositoryImpl(this._firestore) {
    /// Inicializamos la colección de academias.
    _academiesCollection = _firestore.collection('academies');
  }
  final FirebaseFirestore _firestore;
  late final CollectionReference _academiesCollection;

  @override
  Future<Either<Failure, AcademyModel>> createAcademy(
    AcademyModel academy,
  ) async {
    try {
      final now = DateTime.now();
      // Aseguramos que createdAt y updatedAt estén en el modelo como DateTime
      final academyToProcess = academy.copyWith(
        createdAt: academy.createdAt ?? now, // Usar existente o 'now'
        updatedAt: now, // Siempre 'now' al crear/actualizar
      );

      final dataToAdd = academyToProcess.toJson();

      // Forzar que los campos de fecha sean Timestamps para Firestore.
      // toJson() por defecto convierte DateTime a String ISO8601.
      if (academyToProcess.createdAt != null) {
        dataToAdd['createdAt'] = Timestamp.fromDate(academyToProcess.createdAt!);
      }
      if (academyToProcess.updatedAt != null) {
        dataToAdd['updatedAt'] = Timestamp.fromDate(academyToProcess.updatedAt!);
      }

      // Asegurar que 'phone' se guarde como String si está presente.
      // Idealmente, academy.phone ya es String? en el modelo de entrada.
      // Esto es una salvaguarda por si llegara como int desde una fuente no controlada.
      if (dataToAdd.containsKey('phone') && dataToAdd['phone'] != null) {
        if (dataToAdd['phone'] is int) {
          dataToAdd['phone'] = (dataToAdd['phone'] as int).toString();
        } else if (dataToAdd['phone'] is! String) {
          // Si no es int ni String pero no es null, convertir a String
          // Podría ser útil si viene como double, por ejemplo.
          dataToAdd['phone'] = dataToAdd['phone'].toString();
        }
        // Si ya es String, no se hace nada. Si es null, se queda null.
      }

      final docRef = await _academiesCollection.add(dataToAdd);

      // Devolvemos el modelo con el ID asignado por Firestore
      // y los timestamps del modelo que usamos para la data (que son DateTime).
      final createdAcademy = academyToProcess.copyWith(id: docRef.id);
      return Right(createdAcademy);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error inesperado creando academia: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AcademyModel>> getAcademyById(String id) async {
    if (id.isEmpty) {
      return const Left(Failure.unexpectedError(error: 'Academy ID cannot be empty'));
    }
    try {
      final docSnapshot = await _academiesCollection.doc(id).get();

      if (!docSnapshot.exists) {
        return const Left(Failure.unexpectedError(error: 'Academy not found'));
      }

      final academyData = docSnapshot.data()! as Map<String, dynamic>;
      final academy = AcademyModel.fromJson(academyData).copyWith(id: docSnapshot.id);
      return Right(academy);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error inesperado obteniendo academia: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateAcademy(AcademyModel academy) async {
    if (academy.id == null || academy.id!.isEmpty) {
      return const Left(Failure.validationError(message: 'Academy ID is required for update'));
    }
    try {
      // Asegurar que updatedAt se actualice usando copyWith (ahora debería funcionar)
      final academyToUpdate = academy.copyWith(updatedAt: DateTime.now());
      final dataToUpdate = academyToUpdate.toJson();
      // Remover el ID del mapa, ya que se usa en .doc()
      dataToUpdate.remove('id'); 
      // Asegurarse de remover createdAt si existe en el JSON, para no sobreescribirlo
      dataToUpdate.remove('createdAt');

      await _academiesCollection.doc(academy.id!).update(dataToUpdate);
      return const Right(null); // Indicar éxito (void)
    } on FirebaseException catch (e) {
      // Podrías mapear e.code a errores más específicos si es necesario
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error inesperado actualizando academia: $e'),
      );
    }
  }
}
