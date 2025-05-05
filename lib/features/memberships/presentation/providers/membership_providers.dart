import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/data/repositories/membership_repository_impl.dart'; // Importar el provider del repo
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_providers.g.dart';

/// Provider que obtiene la lista de miembros [MembershipModel] para una academia específica.
///
/// Retorna un [Future<List<MembershipModel>>]. Lanza una excepción si ocurre un error.
@riverpod
Future<List<MembershipModel>> academyMembers(Ref ref, String academyId) async {
  if (academyId.isEmpty) {
    // Retornar lista vacía o lanzar excepción si el ID es inválido.
    return []; 
  }

  final membershipRepository = ref.watch(membershipRepositoryProvider);
  final result = await membershipRepository.getMembershipsByAcademy(academyId);

  return result.fold(
    (failure) {
      // Mapear Failure a Exception
      throw Exception('Error obteniendo miembros: ${failure.message}');
    },
    (memberships) => memberships, // Devuelve la lista en caso de éxito
  );
}

/// Provider que obtiene una membresía específica por su ID.
///
/// Retorna un [Future<MembershipModel>]. Lanza una excepción si ocurre un error o no se encuentra.
@riverpod
Future<MembershipModel> membershipById(Ref ref, String membershipId) async {
  if (membershipId.isEmpty) {
    throw Exception('Membership ID inválido.');
  }

  final membershipRepository = ref.watch(membershipRepositoryProvider);
  final result = await membershipRepository.getMembershipById(membershipId);

  return result.fold(
    (failure) {
      // Mapear Failure a Exception
      throw Exception('Error obteniendo membresía por ID: ${failure.message}');
    },
    (membership) => membership, // Devuelve la membresía en caso de éxito
  );
} 