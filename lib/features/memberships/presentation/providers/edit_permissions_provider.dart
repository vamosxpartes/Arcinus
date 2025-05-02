import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estados posibles durante la edición de permisos
enum EditPermissionsStatus {
  initial,
  loading,
  success,
  error,
}

/// Provider notifier para editar permisos de un miembro.
class EditPermissionsNotifier extends StateNotifier<({
  EditPermissionsStatus status,
  MembershipModel? membership,
  Failure? error,
  List<String> selectedPermissions,
})> {
  final String membershipId;
  final String academyId;
  final Ref ref;

  EditPermissionsNotifier(
    this.ref, {
    required this.membershipId,
    required this.academyId,
    required MembershipModel initialMembership,
  }) : super((
          status: EditPermissionsStatus.initial,
          membership: initialMembership,
          error: null,
          selectedPermissions: initialMembership.permissions,
        ));

  /// Actualiza los permisos seleccionados en el estado local
  void togglePermission(String permission) {
    final currentPermissions = state.selectedPermissions;
    
    if (currentPermissions.contains(permission)) {
      // Quitar el permiso si ya está seleccionado
      state = (
        status: state.status,
        membership: state.membership,
        error: state.error,
        selectedPermissions: currentPermissions
            .where((p) => p != permission)
            .toList(),
      );
    } else {
      // Añadir el permiso si no está seleccionado
      state = (
        status: state.status,
        membership: state.membership,
        error: state.error,
        selectedPermissions: [...currentPermissions, permission],
      );
    }
  }

  /// Guarda los cambios de permisos en Firestore
  Future<void> savePermissions() async {
    if (state.membership == null) {
      state = (
        status: EditPermissionsStatus.error,
        membership: state.membership,
        error: const Failure.validationError(
          message: 'No se ha cargado ninguna membresía para editar',
        ),
        selectedPermissions: state.selectedPermissions,
      );
      return;
    }

    // Actualizar estado a cargando
    state = (
      status: EditPermissionsStatus.loading,
      membership: state.membership,
      error: null,
      selectedPermissions: state.selectedPermissions,
    );

    try {
      // Crear una nueva membresía con los permisos actualizados
      final updatedMembership = state.membership!.copyWith(
        permissions: state.selectedPermissions,
      );

      // Obtener el repositorio
      // final MembershipRepository memberhipRepository = ref.read(membershipRepositoryProvider);

      // Guardar en Firestore
      // TODO: Implementar el método updateMembership en el repositorio
      // Actualmente no existe, así que esto fallará
      // final result = await membershipRepository.updateMembership(updatedMembership);

      // Por ahora, simular éxito para el MVP
      // En producción, usar el resultado del repositorio
      // result.fold(
      //   (failure) {
      //     state = (
      //       status: EditPermissionsStatus.error,
      //       membership: state.membership,
      //       error: failure,
      //       selectedPermissions: state.selectedPermissions,
      //     );
      //   },
      //   (_) {
          state = (
            status: EditPermissionsStatus.success,
            membership: updatedMembership,
            error: null,
            selectedPermissions: state.selectedPermissions,
          );
      //   },
      // );
    } catch (e) {
      state = (
        status: EditPermissionsStatus.error,
        membership: state.membership,
        error: Failure.serverError(message: 'Error: $e'),
        selectedPermissions: state.selectedPermissions,
      );
    }
  }

  /// Resetea el estado después de un error o éxito
  void resetStatus() {
    state = (
      status: EditPermissionsStatus.initial,
      membership: state.membership,
      error: null,
      selectedPermissions: state.selectedPermissions,
    );
  }
}

/// Provider para editar permisos de un miembro
final editPermissionsProvider = StateNotifierProvider.family<
    EditPermissionsNotifier,
    ({
      EditPermissionsStatus status,
      MembershipModel? membership,
      Failure? error,
      List<String> selectedPermissions,
    }),
    ({String membershipId, String academyId, MembershipModel initialMembership})>(
  (ref, params) => EditPermissionsNotifier(
    ref,
    membershipId: params.membershipId,
    academyId: params.academyId,
    initialMembership: params.initialMembership,
  ),
); 