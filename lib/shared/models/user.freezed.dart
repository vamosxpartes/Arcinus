// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  Map<String, bool> get permissions => throw _privateConstructorUsedError;
  List<String> get academyIds => throw _privateConstructorUsedError;
  List<String> get customRoleIds =>
      throw _privateConstructorUsedError; // IDs de roles personalizados asignados
  int? get number =>
      throw _privateConstructorUsedError; // Número del jugador/atleta (para deportes de equipo)
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      UserRole role,
      Map<String, bool> permissions,
      List<String> academyIds,
      List<String> customRoleIds,
      int? number,
      DateTime createdAt,
      String? profileImageUrl});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? role = null,
    Object? permissions = null,
    Object? academyIds = null,
    Object? customRoleIds = null,
    Object? number = freezed,
    Object? createdAt = null,
    Object? profileImageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      permissions: null == permissions
          ? _value.permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      academyIds: null == academyIds
          ? _value.academyIds
          : academyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customRoleIds: null == customRoleIds
          ? _value.customRoleIds
          : customRoleIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      UserRole role,
      Map<String, bool> permissions,
      List<String> academyIds,
      List<String> customRoleIds,
      int? number,
      DateTime createdAt,
      String? profileImageUrl});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? role = null,
    Object? permissions = null,
    Object? academyIds = null,
    Object? customRoleIds = null,
    Object? number = freezed,
    Object? createdAt = null,
    Object? profileImageUrl = freezed,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      permissions: null == permissions
          ? _value._permissions
          : permissions // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      academyIds: null == academyIds
          ? _value._academyIds
          : academyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      customRoleIds: null == customRoleIds
          ? _value._customRoleIds
          : customRoleIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.email,
      required this.name,
      required this.role,
      required final Map<String, bool> permissions,
      final List<String> academyIds = const [],
      final List<String> customRoleIds = const [],
      this.number,
      required this.createdAt,
      this.profileImageUrl})
      : _permissions = permissions,
        _academyIds = academyIds,
        _customRoleIds = customRoleIds;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final UserRole role;
  final Map<String, bool> _permissions;
  @override
  Map<String, bool> get permissions {
    if (_permissions is EqualUnmodifiableMapView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_permissions);
  }

  final List<String> _academyIds;
  @override
  @JsonKey()
  List<String> get academyIds {
    if (_academyIds is EqualUnmodifiableListView) return _academyIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_academyIds);
  }

  final List<String> _customRoleIds;
  @override
  @JsonKey()
  List<String> get customRoleIds {
    if (_customRoleIds is EqualUnmodifiableListView) return _customRoleIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customRoleIds);
  }

// IDs de roles personalizados asignados
  @override
  final int? number;
// Número del jugador/atleta (para deportes de equipo)
  @override
  final DateTime createdAt;
  @override
  final String? profileImageUrl;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, permissions: $permissions, academyIds: $academyIds, customRoleIds: $customRoleIds, number: $number, createdAt: $createdAt, profileImageUrl: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality()
                .equals(other._permissions, _permissions) &&
            const DeepCollectionEquality()
                .equals(other._academyIds, _academyIds) &&
            const DeepCollectionEquality()
                .equals(other._customRoleIds, _customRoleIds) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      name,
      role,
      const DeepCollectionEquality().hash(_permissions),
      const DeepCollectionEquality().hash(_academyIds),
      const DeepCollectionEquality().hash(_customRoleIds),
      number,
      createdAt,
      profileImageUrl);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      required final String email,
      required final String name,
      required final UserRole role,
      required final Map<String, bool> permissions,
      final List<String> academyIds,
      final List<String> customRoleIds,
      final int? number,
      required final DateTime createdAt,
      final String? profileImageUrl}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  UserRole get role;
  @override
  Map<String, bool> get permissions;
  @override
  List<String> get academyIds;
  @override
  List<String> get customRoleIds; // IDs de roles personalizados asignados
  @override
  int? get number; // Número del jugador/atleta (para deportes de equipo)
  @override
  DateTime get createdAt;
  @override
  String? get profileImageUrl;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
