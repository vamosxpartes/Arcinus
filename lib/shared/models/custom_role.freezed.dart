// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomRole _$CustomRoleFromJson(Map<String, dynamic> json) {
  return _CustomRole.fromJson(json);
}

/// @nodoc
mixin _$CustomRole {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get academyId => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  Map<String, bool> get permissions => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String> get assignedUserIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CustomRole to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomRoleCopyWith<CustomRole> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomRoleCopyWith<$Res> {
  factory $CustomRoleCopyWith(
          CustomRole value, $Res Function(CustomRole) then) =
      _$CustomRoleCopyWithImpl<$Res, CustomRole>;
  @useResult
  $Res call(
      {String id,
      String name,
      String academyId,
      String createdBy,
      Map<String, bool> permissions,
      String? description,
      List<String> assignedUserIds,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$CustomRoleCopyWithImpl<$Res, $Val extends CustomRole>
    implements $CustomRoleCopyWith<$Res> {
  _$CustomRoleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? academyId = null,
    Object? createdBy = null,
    Object? permissions = null,
    Object? description = freezed,
    Object? assignedUserIds = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      academyId: null == academyId
          ? _value.academyId
          : academyId // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      permissions: null == permissions
          ? _value.permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedUserIds: null == assignedUserIds
          ? _value.assignedUserIds
          : assignedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomRoleImplCopyWith<$Res>
    implements $CustomRoleCopyWith<$Res> {
  factory _$$CustomRoleImplCopyWith(
          _$CustomRoleImpl value, $Res Function(_$CustomRoleImpl) then) =
      __$$CustomRoleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String academyId,
      String createdBy,
      Map<String, bool> permissions,
      String? description,
      List<String> assignedUserIds,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$CustomRoleImplCopyWithImpl<$Res>
    extends _$CustomRoleCopyWithImpl<$Res, _$CustomRoleImpl>
    implements _$$CustomRoleImplCopyWith<$Res> {
  __$$CustomRoleImplCopyWithImpl(
      _$CustomRoleImpl _value, $Res Function(_$CustomRoleImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? academyId = null,
    Object? createdBy = null,
    Object? permissions = null,
    Object? description = freezed,
    Object? assignedUserIds = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$CustomRoleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      academyId: null == academyId
          ? _value.academyId
          : academyId // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      permissions: null == permissions
          ? _value._permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedUserIds: null == assignedUserIds
          ? _value._assignedUserIds
          : assignedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomRoleImpl implements _CustomRole {
  const _$CustomRoleImpl(
      {required this.id,
      required this.name,
      required this.academyId,
      required this.createdBy,
      required final Map<String, bool> permissions,
      this.description,
      final List<String> assignedUserIds = const [],
      required this.createdAt,
      this.updatedAt})
      : _permissions = permissions,
        _assignedUserIds = assignedUserIds;

  factory _$CustomRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomRoleImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String academyId;
  @override
  final String createdBy;
  final Map<String, bool> _permissions;
  @override
  Map<String, bool> get permissions {
    if (_permissions is EqualUnmodifiableMapView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_permissions);
  }

  @override
  final String? description;
  final List<String> _assignedUserIds;
  @override
  @JsonKey()
  List<String> get assignedUserIds {
    if (_assignedUserIds is EqualUnmodifiableListView) return _assignedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedUserIds);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CustomRole(id: $id, name: $name, academyId: $academyId, createdBy: $createdBy, permissions: $permissions, description: $description, assignedUserIds: $assignedUserIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomRoleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.academyId, academyId) ||
                other.academyId == academyId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality()
                .equals(other._permissions, _permissions) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._assignedUserIds, _assignedUserIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      academyId,
      createdBy,
      const DeepCollectionEquality().hash(_permissions),
      description,
      const DeepCollectionEquality().hash(_assignedUserIds),
      createdAt,
      updatedAt);

  /// Create a copy of CustomRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomRoleImplCopyWith<_$CustomRoleImpl> get copyWith =>
      __$$CustomRoleImplCopyWithImpl<_$CustomRoleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomRoleImplToJson(
      this,
    );
  }
}

abstract class _CustomRole implements CustomRole {
  const factory _CustomRole(
      {required final String id,
      required final String name,
      required final String academyId,
      required final String createdBy,
      required final Map<String, bool> permissions,
      final String? description,
      final List<String> assignedUserIds,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$CustomRoleImpl;

  factory _CustomRole.fromJson(Map<String, dynamic> json) =
      _$CustomRoleImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get academyId;
  @override
  String get createdBy;
  @override
  Map<String, bool> get permissions;
  @override
  String? get description;
  @override
  List<String> get assignedUserIds;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of CustomRole
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomRoleImplCopyWith<_$CustomRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
