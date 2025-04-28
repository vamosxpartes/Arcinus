import 'package:arcinus/core/error/failures.dart';
import 'package:arcinus/features/auth/data/models/user_model.dart'; // Asumiendo que tienes UserModel
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_member_state.freezed.dart';

@freezed
sealed class InviteMemberState with _$InviteMemberState {
  /// Estado inicial o cuando no hay búsqueda activa.
  const factory InviteMemberState.initial() = _Initial;

  /// Estado mientras se busca un usuario por email.
  const factory InviteMemberState.searching() = _Searching;

  /// Estado cuando se encuentra un usuario.
  const factory InviteMemberState.userFound(UserModel user) = _UserFound;

  /// Estado cuando no se encuentra un usuario con ese email.
  const factory InviteMemberState.userNotFound() = _UserNotFound;

  /// Estado mientras se crea la membresía.
  const factory InviteMemberState.creatingMembership() = _CreatingMembership;

  /// Estado cuando la membresía se crea con éxito.
  const factory InviteMemberState.success() = _Success;

  /// Estado cuando ocurre un error (búsqueda o creación).
  const factory InviteMemberState.error(Failure failure) = _Error;
} 