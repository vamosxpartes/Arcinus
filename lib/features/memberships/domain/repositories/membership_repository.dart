import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:fpdart/fpdart.dart';

/// Interfaz abstracta para el repositorio de membresías.
/// Define los métodos para gestionar la relación entre usuarios y academias.
abstract class MembershipRepository {

  /// Crea un nuevo registro de membresía.
  ///
  /// Útil para añadir un usuario a una academia con un rol específico.
  /// Devuelve [void] en caso de éxito, o un [Failure] en caso de error.
  Future<Either<Failure, void>> createMembership(MembershipModel membership);

  /// Obtiene la lista de miembros (MembershipModel) para una academia específica.
  ///
  /// Devuelve una lista de [MembershipModel] o un [Failure].
  Future<Either<Failure, List<MembershipModel>>> getMembershipsByAcademy(
    String academyId,
  );

  // --- Métodos Potenciales para el Futuro ---

  // Future<Either<Failure, MembershipModel?>> getMembership(
  //   String userId,
  //   String academyId,
  // );

  // Future<Either<Failure, List<MembershipModel>>> getMembershipsByUser(
  //   String userId,
  // );

  // Future<Either<Failure, void>> updateMembership(MembershipModel membership);

  // Future<Either<Failure, void>> deleteMembership(String membershipId);

} 