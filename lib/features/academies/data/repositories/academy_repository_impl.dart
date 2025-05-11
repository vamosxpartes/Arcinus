import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:arcinus/features/academies/domain/repositories/academy_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:arcinus/core/utils/app_logger.dart';

/// Implementación de la interfaz [AcademyRepository] para interactuar
class AcademyRepositoryImpl implements AcademyRepository {
  static const String _className = 'AcademyRepositoryImpl';
  
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
      AppLogger.logInfo(
        'Iniciando creación de academia',
        className: _className,
        functionName: 'createAcademy',
        params: {'academy': '${academy.name}'},
      );
      
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
      
      AppLogger.logInfo(
        'Academia creada exitosamente',
        className: _className,
        functionName: 'createAcademy',
        params: {'academyId': docRef.id, 'academyName': createdAcademy.name},
      );
      
      return Right(createdAcademy);
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firestore al crear academia',
        error: e,
        className: _className,
        functionName: 'createAcademy',
        params: {'code': e.code, 'message': e.message},
      );
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado creando academia',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'createAcademy',
      );
      return Left(
        ServerFailure(message: 'Error inesperado creando academia: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AcademyModel>> getAcademyById(String id) async {
    if (id.isEmpty) {
      AppLogger.logWarning(
        'ID de academia vacío en getAcademyById',
        className: _className,
        functionName: 'getAcademyById',
      );
      return const Left(Failure.unexpectedError(error: 'Academy ID cannot be empty'));
    }
    try {
      AppLogger.logInfo(
        'Obteniendo academia por ID',
        className: _className,
        functionName: 'getAcademyById',
        params: {'academyId': id},
      );
      
      final docSnapshot = await _academiesCollection.doc(id).get();

      if (!docSnapshot.exists) {
        AppLogger.logWarning(
          'Academia no encontrada',
          className: _className,
          functionName: 'getAcademyById',
          params: {'academyId': id},
        );
        return const Left(Failure.unexpectedError(error: 'Academy not found'));
      }

      final academyData = docSnapshot.data()! as Map<String, dynamic>;
      final academy = AcademyModel.fromJson(academyData).copyWith(id: docSnapshot.id);
      
      AppLogger.logInfo(
        'Academia obtenida correctamente',
        className: _className,
        functionName: 'getAcademyById',
        params: {'academyId': id, 'academyName': academy.name},
      );
      
      return Right(academy);
    } on FirebaseException catch (e) {
      AppLogger.logError(
        message: 'Error de Firestore al obtener academia',
        error: e,
        className: _className,
        functionName: 'getAcademyById',
        params: {'academyId': id, 'code': e.code, 'message': e.message},
      );
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado obteniendo academia',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'getAcademyById',
        params: {'academyId': id},
      );
      return Left(
        ServerFailure(message: 'Error inesperado obteniendo academia: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateAcademy(AcademyModel academy) async {
    if (academy.id == null || academy.id!.isEmpty) {
      AppLogger.logWarning(
        'ID de academia requerido para actualización',
        className: _className,
        functionName: 'updateAcademy',
      );
      return const Left(Failure.validationError(message: 'Academy ID is required for update'));
    }
    try {
      AppLogger.logInfo(
        'Actualizando academia',
        className: _className,
        functionName: 'updateAcademy',
        params: {'academyId': academy.id, 'academyName': academy.name},
      );
      
      // Asegurar que updatedAt se actualice usando copyWith (ahora debería funcionar)
      final academyToUpdate = academy.copyWith(updatedAt: DateTime.now());
      final dataToUpdate = academyToUpdate.toJson();
      // Remover el ID del mapa, ya que se usa en .doc()
      dataToUpdate.remove('id'); 
      // Asegurarse de remover createdAt si existe en el JSON, para no sobreescribirlo
      dataToUpdate.remove('createdAt');

      await _academiesCollection.doc(academy.id!).update(dataToUpdate);
      
      AppLogger.logInfo(
        'Academia actualizada exitosamente',
        className: _className,
        functionName: 'updateAcademy',
        params: {'academyId': academy.id},
      );
      
      return const Right(null); // Indicar éxito (void)
    } on FirebaseException catch (e) {
      // Podrías mapear e.code a errores más específicos si es necesario
      AppLogger.logError(
        message: 'Error de Firestore al actualizar academia',
        error: e,
        className: _className,
        functionName: 'updateAcademy',
        params: {'academyId': academy.id, 'code': e.code, 'message': e.message},
      );
      return Left(
        ServerFailure(message: e.message ?? 'Error Firestore [${e.code}]'),
      );
    } catch (e, s) {
      AppLogger.logError(
        message: 'Error inesperado actualizando academia',
        error: e,
        stackTrace: s,
        className: _className,
        functionName: 'updateAcademy',
        params: {'academyId': academy.id},
      );
      return Left(
        ServerFailure(message: 'Error inesperado actualizando academia: $e'),
      );
    }
  }
}
