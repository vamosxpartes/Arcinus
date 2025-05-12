import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/academies/data/models/academy_model.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:io';

/// Interfaz abstracta para el repositorio de academias.
/// Define los métodos necesarios para interactuar con los datos
/// de las academias.
abstract class AcademyRepository {
  /// Crea una nueva academia en la base de datos.
  ///
  /// Recibe el [academy] a crear (sin ID usualmente) y devuelve
  /// el [AcademyModel] creado (con ID y timestamps) en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AcademyModel>> createAcademy(AcademyModel academy);
  
  /// Crea una nueva academia incluyendo la carga del logo.
  ///
  /// Recibe el [academy] a crear y el [logoFile] para subir.
  /// Devuelve el [AcademyModel] creado con la URL del logo en caso de éxito,
  /// o un [Failure] en caso de error.
  Future<Either<Failure, AcademyModel>> createAcademyWithLogo(
    AcademyModel academy,
    File logoFile,
  );

  /// Obtiene los detalles de una academia específica por su ID.
  ///
  /// Devuelve el [AcademyModel] si se encuentra,
  /// o un [Failure] en caso de error o si no existe.
  Future<Either<Failure, AcademyModel>> getAcademyById(String id);

  /// Actualiza los datos de una academia existente.
  ///
  /// Recibe el [academy] con los datos actualizados (debe incluir el ID).
  /// Devuelve [void] en caso de éxito, o un [Failure] en caso de error.
  Future<Either<Failure, void>> updateAcademy(AcademyModel academy);

  // El método deleteAcademy no se incluye en el MVP.
  // Future<Either<Failure, void>> deleteAcademy(String academyId);
}
