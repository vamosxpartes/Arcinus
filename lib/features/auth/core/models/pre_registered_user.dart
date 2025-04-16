import 'package:arcinus/features/app/users/user/core/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pre_registered_user.freezed.dart';
part 'pre_registered_user.g.dart';

@freezed
class PreRegisteredUser with _$PreRegisteredUser {
  const factory PreRegisteredUser({
    required String id,
    String? email,
    required String name,
    required UserRole role,
    required String activationCode,
    required DateTime expiresAt,
    required DateTime createdAt,
    @Default(false) bool isUsed,
    String? createdBy, // ID del administrador que creó el pre-registro
  }) = _PreRegisteredUser;
  
  factory PreRegisteredUser.fromJson(Map<String, dynamic> json) => 
      _$PreRegisteredUserFromJson(json);
} 