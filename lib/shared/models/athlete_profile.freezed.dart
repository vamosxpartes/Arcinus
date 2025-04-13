// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athlete_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AthleteProfile _$AthleteProfileFromJson(Map<String, dynamic> json) {
  return _AthleteProfile.fromJson(json);
}

/// @nodoc
mixin _$AthleteProfile {
  String get userId => throw _privateConstructorUsedError;
  String get academyId => throw _privateConstructorUsedError;
  DateTime? get birthDate => throw _privateConstructorUsedError;
  double? get height => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  List<String>? get groupIds => throw _privateConstructorUsedError;
  List<String>? get parentIds => throw _privateConstructorUsedError;
  Map<String, dynamic>? get medicalInfo => throw _privateConstructorUsedError;
  Map<String, dynamic>? get emergencyContacts =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalInfo =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get sportStats => throw _privateConstructorUsedError;
  List<String>? get specializations => throw _privateConstructorUsedError;
  String? get position => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AthleteProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AthleteProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AthleteProfileCopyWith<AthleteProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AthleteProfileCopyWith<$Res> {
  factory $AthleteProfileCopyWith(
          AthleteProfile value, $Res Function(AthleteProfile) then) =
      _$AthleteProfileCopyWithImpl<$Res, AthleteProfile>;
  @useResult
  $Res call(
      {String userId,
      String academyId,
      DateTime? birthDate,
      double? height,
      double? weight,
      List<String>? groupIds,
      List<String>? parentIds,
      Map<String, dynamic>? medicalInfo,
      Map<String, dynamic>? emergencyContacts,
      Map<String, dynamic>? additionalInfo,
      Map<String, dynamic>? sportStats,
      List<String>? specializations,
      String? position,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      DateTime createdAt});
}

/// @nodoc
class _$AthleteProfileCopyWithImpl<$Res, $Val extends AthleteProfile>
    implements $AthleteProfileCopyWith<$Res> {
  _$AthleteProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AthleteProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? academyId = null,
    Object? birthDate = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? groupIds = freezed,
    Object? parentIds = freezed,
    Object? medicalInfo = freezed,
    Object? emergencyContacts = freezed,
    Object? additionalInfo = freezed,
    Object? sportStats = freezed,
    Object? specializations = freezed,
    Object? position = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      academyId: null == academyId
          ? _value.academyId
          : academyId // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      groupIds: freezed == groupIds
          ? _value.groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      parentIds: freezed == parentIds
          ? _value.parentIds
          : parentIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      medicalInfo: freezed == medicalInfo
          ? _value.medicalInfo
          : medicalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      emergencyContacts: freezed == emergencyContacts
          ? _value.emergencyContacts
          : emergencyContacts // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      additionalInfo: freezed == additionalInfo
          ? _value.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sportStats: freezed == sportStats
          ? _value.sportStats
          : sportStats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      specializations: freezed == specializations
          ? _value.specializations
          : specializations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AthleteProfileImplCopyWith<$Res>
    implements $AthleteProfileCopyWith<$Res> {
  factory _$$AthleteProfileImplCopyWith(_$AthleteProfileImpl value,
          $Res Function(_$AthleteProfileImpl) then) =
      __$$AthleteProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String academyId,
      DateTime? birthDate,
      double? height,
      double? weight,
      List<String>? groupIds,
      List<String>? parentIds,
      Map<String, dynamic>? medicalInfo,
      Map<String, dynamic>? emergencyContacts,
      Map<String, dynamic>? additionalInfo,
      Map<String, dynamic>? sportStats,
      List<String>? specializations,
      String? position,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      DateTime createdAt});
}

/// @nodoc
class __$$AthleteProfileImplCopyWithImpl<$Res>
    extends _$AthleteProfileCopyWithImpl<$Res, _$AthleteProfileImpl>
    implements _$$AthleteProfileImplCopyWith<$Res> {
  __$$AthleteProfileImplCopyWithImpl(
      _$AthleteProfileImpl _value, $Res Function(_$AthleteProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of AthleteProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? academyId = null,
    Object? birthDate = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? groupIds = freezed,
    Object? parentIds = freezed,
    Object? medicalInfo = freezed,
    Object? emergencyContacts = freezed,
    Object? additionalInfo = freezed,
    Object? sportStats = freezed,
    Object? specializations = freezed,
    Object? position = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AthleteProfileImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      academyId: null == academyId
          ? _value.academyId
          : academyId // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      groupIds: freezed == groupIds
          ? _value._groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      parentIds: freezed == parentIds
          ? _value._parentIds
          : parentIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      medicalInfo: freezed == medicalInfo
          ? _value._medicalInfo
          : medicalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      emergencyContacts: freezed == emergencyContacts
          ? _value._emergencyContacts
          : emergencyContacts // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      additionalInfo: freezed == additionalInfo
          ? _value._additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      sportStats: freezed == sportStats
          ? _value._sportStats
          : sportStats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      specializations: freezed == specializations
          ? _value._specializations
          : specializations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AthleteProfileImpl extends _AthleteProfile {
  const _$AthleteProfileImpl(
      {required this.userId,
      required this.academyId,
      this.birthDate,
      this.height,
      this.weight,
      final List<String>? groupIds,
      final List<String>? parentIds,
      final Map<String, dynamic>? medicalInfo,
      final Map<String, dynamic>? emergencyContacts,
      final Map<String, dynamic>? additionalInfo,
      final Map<String, dynamic>? sportStats,
      final List<String>? specializations,
      this.position,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      required this.createdAt})
      : _groupIds = groupIds,
        _parentIds = parentIds,
        _medicalInfo = medicalInfo,
        _emergencyContacts = emergencyContacts,
        _additionalInfo = additionalInfo,
        _sportStats = sportStats,
        _specializations = specializations,
        super._();

  factory _$AthleteProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$AthleteProfileImplFromJson(json);

  @override
  final String userId;
  @override
  final String academyId;
  @override
  final DateTime? birthDate;
  @override
  final double? height;
  @override
  final double? weight;
  final List<String>? _groupIds;
  @override
  List<String>? get groupIds {
    final value = _groupIds;
    if (value == null) return null;
    if (_groupIds is EqualUnmodifiableListView) return _groupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _parentIds;
  @override
  List<String>? get parentIds {
    final value = _parentIds;
    if (value == null) return null;
    if (_parentIds is EqualUnmodifiableListView) return _parentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _medicalInfo;
  @override
  Map<String, dynamic>? get medicalInfo {
    final value = _medicalInfo;
    if (value == null) return null;
    if (_medicalInfo is EqualUnmodifiableMapView) return _medicalInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _emergencyContacts;
  @override
  Map<String, dynamic>? get emergencyContacts {
    final value = _emergencyContacts;
    if (value == null) return null;
    if (_emergencyContacts is EqualUnmodifiableMapView)
      return _emergencyContacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _additionalInfo;
  @override
  Map<String, dynamic>? get additionalInfo {
    final value = _additionalInfo;
    if (value == null) return null;
    if (_additionalInfo is EqualUnmodifiableMapView) return _additionalInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _sportStats;
  @override
  Map<String, dynamic>? get sportStats {
    final value = _sportStats;
    if (value == null) return null;
    if (_sportStats is EqualUnmodifiableMapView) return _sportStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _specializations;
  @override
  List<String>? get specializations {
    final value = _specializations;
    if (value == null) return null;
    if (_specializations is EqualUnmodifiableListView) return _specializations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? position;
  @override
  @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
  final DateTime createdAt;

  @override
  String toString() {
    return 'AthleteProfile(userId: $userId, academyId: $academyId, birthDate: $birthDate, height: $height, weight: $weight, groupIds: $groupIds, parentIds: $parentIds, medicalInfo: $medicalInfo, emergencyContacts: $emergencyContacts, additionalInfo: $additionalInfo, sportStats: $sportStats, specializations: $specializations, position: $position, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AthleteProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.academyId, academyId) ||
                other.academyId == academyId) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            const DeepCollectionEquality()
                .equals(other._parentIds, _parentIds) &&
            const DeepCollectionEquality()
                .equals(other._medicalInfo, _medicalInfo) &&
            const DeepCollectionEquality()
                .equals(other._emergencyContacts, _emergencyContacts) &&
            const DeepCollectionEquality()
                .equals(other._additionalInfo, _additionalInfo) &&
            const DeepCollectionEquality()
                .equals(other._sportStats, _sportStats) &&
            const DeepCollectionEquality()
                .equals(other._specializations, _specializations) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      academyId,
      birthDate,
      height,
      weight,
      const DeepCollectionEquality().hash(_groupIds),
      const DeepCollectionEquality().hash(_parentIds),
      const DeepCollectionEquality().hash(_medicalInfo),
      const DeepCollectionEquality().hash(_emergencyContacts),
      const DeepCollectionEquality().hash(_additionalInfo),
      const DeepCollectionEquality().hash(_sportStats),
      const DeepCollectionEquality().hash(_specializations),
      position,
      createdAt);

  /// Create a copy of AthleteProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AthleteProfileImplCopyWith<_$AthleteProfileImpl> get copyWith =>
      __$$AthleteProfileImplCopyWithImpl<_$AthleteProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AthleteProfileImplToJson(
      this,
    );
  }
}

abstract class _AthleteProfile extends AthleteProfile {
  const factory _AthleteProfile(
      {required final String userId,
      required final String academyId,
      final DateTime? birthDate,
      final double? height,
      final double? weight,
      final List<String>? groupIds,
      final List<String>? parentIds,
      final Map<String, dynamic>? medicalInfo,
      final Map<String, dynamic>? emergencyContacts,
      final Map<String, dynamic>? additionalInfo,
      final Map<String, dynamic>? sportStats,
      final List<String>? specializations,
      final String? position,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      required final DateTime createdAt}) = _$AthleteProfileImpl;
  const _AthleteProfile._() : super._();

  factory _AthleteProfile.fromJson(Map<String, dynamic> json) =
      _$AthleteProfileImpl.fromJson;

  @override
  String get userId;
  @override
  String get academyId;
  @override
  DateTime? get birthDate;
  @override
  double? get height;
  @override
  double? get weight;
  @override
  List<String>? get groupIds;
  @override
  List<String>? get parentIds;
  @override
  Map<String, dynamic>? get medicalInfo;
  @override
  Map<String, dynamic>? get emergencyContacts;
  @override
  Map<String, dynamic>? get additionalInfo;
  @override
  Map<String, dynamic>? get sportStats;
  @override
  List<String>? get specializations;
  @override
  String? get position;
  @override
  @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
  DateTime get createdAt;

  /// Create a copy of AthleteProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AthleteProfileImplCopyWith<_$AthleteProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
