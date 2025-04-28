import 'package:arcinus/core/auth/roles.dart';
import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:arcinus/features/memberships/data/repositories/membership_repository_impl.dart'; // Provider Repo Membresías
import 'package:arcinus/features/memberships/domain/repositories/membership_repository.dart';
import 'package:arcinus/features/memberships/presentation/providers/state/invite_member_state.dart';
import 'package:arcinus/features/users/data/repositories/user_repository_impl.dart'; // Provider Repo Usuarios
import 'package:arcinus/features/users/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart'; // Para TextEditingController
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el Notifier de invitación de miembros.
///
/// Necesita el [academyId] al que se añadirá el miembro.
final inviteMemberProvider = StateNotifierProvider.autoDispose
    .family<InviteMemberNotifier, InviteMemberState, String>((ref, academyId) {
  final userRepository = ref.watch(userRepositoryProvider);
  final membershipRepository = ref.watch(membershipRepositoryProvider);
  return InviteMemberNotifier(userRepository, membershipRepository, academyId);
});

class InviteMemberNotifier extends StateNotifier<InviteMemberState> {
  final UserRepository _userRepository;
  final MembershipRepository _membershipRepository;
  final String _academyId;

  final emailController = TextEditingController();
  AppRole? selectedRole;
  UserModel? _foundUser; // Para guardar el usuario encontrado

  InviteMemberNotifier(
      this._userRepository, this._membershipRepository, this._academyId)
      : super(const InviteMemberState.initial());

  /// Busca un usuario por el email introducido.
  Future<void> searchUserByEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      state = const InviteMemberState.error(Failure.validationError(message: 'Introduce un email válido'));
      _clearErrorAfterDelay();
      return;
    }

    state = const InviteMemberState.searching();
    _foundUser = null; // Limpiar usuario anterior
    selectedRole = null; // Limpiar rol anterior

    final result = await _userRepository.getUserByEmail(email);

    result.fold(
      (failure) {
        state = InviteMemberState.error(failure);
         _clearErrorAfterDelay();
      },
      (user) {
        if (user == null) {
          state = const InviteMemberState.userNotFound();
        } else {
          _foundUser = user;
          state = InviteMemberState.userFound(user);
        }
      },
    );
  }

  /// Selecciona el rol para el usuario a invitar.
  void selectRole(AppRole? role) {
    selectedRole = role;
    // Podríamos actualizar el estado si fuera necesario reflejarlo en la UI inmediatamente
  }

  /// Crea la membresía para el usuario encontrado con el rol seleccionado.
  Future<void> createMembershipForFoundUser() async {
    if (_foundUser == null) {
      state = const InviteMemberState.error(Failure.validationError(message: 'No se ha encontrado un usuario para invitar'));
      _clearErrorAfterDelay();
      return;
    }
    if (selectedRole == null || selectedRole == AppRole.desconocido || selectedRole == AppRole.propietario || selectedRole == AppRole.superAdmin) {
      // Evitar asignar roles no permitidos directamente aquí
      state = const InviteMemberState.error(Failure.validationError(message: 'Selecciona un rol válido para el miembro (Colaborador, Atleta, Padre)'));
      _clearErrorAfterDelay();
      return;
    }

    state = const InviteMemberState.creatingMembership();

    final newMembership = MembershipModel(
      userId: _foundUser!.id,
      academyId: _academyId,
      role: selectedRole!, 
      addedAt: DateTime.now(),
      // permissions se podrían gestionar en otro flujo para colaboradores
    );

    final result = await _membershipRepository.createMembership(newMembership);

    result.fold(
      (failure) {
        state = InviteMemberState.error(failure);
        _clearErrorAfterDelay();
      },
      (_) {
        state = const InviteMemberState.success();
        // Limpiar campos después de éxito
        emailController.clear();
        _foundUser = null;
        selectedRole = null;
        // Podríamos resetear a initial después de un delay
        _resetStateAfterDelay(); 
      },
    );
  }

  /// Resetea el estado a initial después de un tiempo.
  void _resetStateAfterDelay() {
     Future.delayed(const Duration(seconds: 3), () {
       // Solo resetear si sigue en estado de éxito
       if (state.maybeWhen(success: () => true, orElse: () => false)) {
         state = const InviteMemberState.initial();
       }
     });
  }

  /// Limpia el estado de error después de un tiempo.
  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
        state = const InviteMemberState.initial();
      }
    });
  }

   @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
} 