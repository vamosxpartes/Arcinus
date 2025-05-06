import 'package:arcinus/core/models/user_model.dart';
import 'package:arcinus/features/memberships/data/models/membership_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_with_profile.freezed.dart';
part 'member_with_profile.g.dart';

/// Modelo que combina la información de membresía con los datos del perfil de usuario.
@freezed
class MemberWithProfile with _$MemberWithProfile {
  const factory MemberWithProfile({
    required MembershipModel membership,
    UserModel? userProfile,
  }) = _MemberWithProfile;

  factory MemberWithProfile.fromJson(Map<String, dynamic> json) =>
      _$MemberWithProfileFromJson(json);
} 