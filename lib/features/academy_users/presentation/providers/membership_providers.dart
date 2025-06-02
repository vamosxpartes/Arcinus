import 'package:arcinus/core/auth/presentation/providers/user_profile_provider.dart';
import 'package:arcinus/core/auth/roles.dart'; // Importar AppRole
import 'package:arcinus/features/academy_users/data/models/member_with_profile.dart';
import 'package:arcinus/features/academy_users/data/models/membership_model.dart';
import 'package:arcinus/features/academy_users/data/repositories/membership_repository_impl.dart'; // Importar el provider del repo
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

/// Provider que obtiene membresías con perfiles de usuario correspondientes
///
/// Combina los datos de membresía con información de perfil del usuario
@riverpod
Future<List<MemberWithProfile>> membersWithProfiles(Ref ref, String academyId) async {
  final memberships = await ref.watch(academyMembersProvider(academyId).future);
  final result = <MemberWithProfile>[];

  for (final membership in memberships) {
    try {
      final userProfile = await ref.watch(userProfileProvider(membership.userId).future);
      result.add(MemberWithProfile(
        membership: membership,
        userProfile: userProfile,
      ));
    } catch (e) {
      // Si hay error al cargar el perfil, añadir solo la membresía
      result.add(MemberWithProfile(
        membership: membership,
        userProfile: null,
      ));
    }
  }

  return result;
}

/// Provider para filtrar miembros con perfiles
///
/// Permite filtrar los miembros con sus perfiles por rol
@riverpod
Future<List<MemberWithProfile>> filteredMembers(
  Ref ref, 
  FilteredMembersParams params
) async {
  final members = await ref.watch(membersWithProfilesProvider(params.academyId).future);
  
  // Si no hay filtro activo, devolvemos todos los miembros
  if (params.roleFilter == null) {
    return members;
  }
  
  // Filtramos por rol
  return members.where((member) => member.membership.role == params.roleFilter).toList();
}

/// Provider para filtrar miembros por rol.
///
/// Este provider permite obtener únicamente los miembros de un rol específico.
@riverpod
Future<List<MembershipModel>> filteredMembersByRole(
  Ref ref, 
  FilteredMembersParams params
) async {
  final memberships = await ref.watch(academyMembersProvider(params.academyId).future);
  
  // Si no hay filtro activo, devolvemos todos los miembros
  if (params.roleFilter == null) {
    return memberships;
  }
  
  // Filtramos por rol
  return memberships.where((member) => member.role == params.roleFilter).toList();
}

/// Parámetros para el provider de miembros filtrados
class FilteredMembersParams {
  final String academyId;
  final AppRole? roleFilter;
  
  const FilteredMembersParams({
    required this.academyId,
    this.roleFilter,
  });
} 