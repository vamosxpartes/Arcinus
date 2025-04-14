import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_role.freezed.dart';
part 'custom_role.g.dart';

@freezed
class CustomRole with _$CustomRole {
  /// Modelo para roles personalizados
  const factory CustomRole({
    required String id,
    required String name,
    required String academyId,
    required String createdBy,
    required Map<String, bool> permissions,
    String? description,
    @Default([]) List<String> assignedUserIds,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _CustomRole;
  
  factory CustomRole.fromJson(Map<String, dynamic> json) => _$CustomRoleFromJson(json);
  
  factory CustomRole.empty() => CustomRole(
    id: '',
    name: '',
    academyId: '',
    createdBy: '',
    permissions: {},
    assignedUserIds: [],
    createdAt: DateTime.now(),
  );
} 