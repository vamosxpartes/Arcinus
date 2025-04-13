// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'academy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Academy _$AcademyFromJson(Map<String, dynamic> json) {
  return _Academy.fromJson(json);
}

/// @nodoc
mixin _$Academy {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;
  String get sport => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get taxId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  SportCharacteristics? get sportConfig => throw _privateConstructorUsedError;
  List<String>? get groupIds => throw _privateConstructorUsedError;
  List<String>? get coachIds => throw _privateConstructorUsedError;
  List<String>? get athleteIds => throw _privateConstructorUsedError;
  Map<String, dynamic>? get settings => throw _privateConstructorUsedError;
  String get subscription => throw _privateConstructorUsedError;
  @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Academy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Academy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcademyCopyWith<Academy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcademyCopyWith<$Res> {
  factory $AcademyCopyWith(Academy value, $Res Function(Academy) then) =
      _$AcademyCopyWithImpl<$Res, Academy>;
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerId,
      String? logo,
      String sport,
      String? location,
      String? taxId,
      String? description,
      SportCharacteristics? sportConfig,
      List<String>? groupIds,
      List<String>? coachIds,
      List<String>? athleteIds,
      Map<String, dynamic>? settings,
      String subscription,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      DateTime createdAt});

  $SportCharacteristicsCopyWith<$Res>? get sportConfig;
}

/// @nodoc
class _$AcademyCopyWithImpl<$Res, $Val extends Academy>
    implements $AcademyCopyWith<$Res> {
  _$AcademyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Academy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? logo = freezed,
    Object? sport = null,
    Object? location = freezed,
    Object? taxId = freezed,
    Object? description = freezed,
    Object? sportConfig = freezed,
    Object? groupIds = freezed,
    Object? coachIds = freezed,
    Object? athleteIds = freezed,
    Object? settings = freezed,
    Object? subscription = null,
    Object? createdAt = null,
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
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      taxId: freezed == taxId
          ? _value.taxId
          : taxId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sportConfig: freezed == sportConfig
          ? _value.sportConfig
          : sportConfig // ignore: cast_nullable_to_non_nullable
              as SportCharacteristics?,
      groupIds: freezed == groupIds
          ? _value.groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      coachIds: freezed == coachIds
          ? _value.coachIds
          : coachIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      athleteIds: freezed == athleteIds
          ? _value.athleteIds
          : athleteIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      settings: freezed == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      subscription: null == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Academy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SportCharacteristicsCopyWith<$Res>? get sportConfig {
    if (_value.sportConfig == null) {
      return null;
    }

    return $SportCharacteristicsCopyWith<$Res>(_value.sportConfig!, (value) {
      return _then(_value.copyWith(sportConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AcademyImplCopyWith<$Res> implements $AcademyCopyWith<$Res> {
  factory _$$AcademyImplCopyWith(
          _$AcademyImpl value, $Res Function(_$AcademyImpl) then) =
      __$$AcademyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerId,
      String? logo,
      String sport,
      String? location,
      String? taxId,
      String? description,
      SportCharacteristics? sportConfig,
      List<String>? groupIds,
      List<String>? coachIds,
      List<String>? athleteIds,
      Map<String, dynamic>? settings,
      String subscription,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      DateTime createdAt});

  @override
  $SportCharacteristicsCopyWith<$Res>? get sportConfig;
}

/// @nodoc
class __$$AcademyImplCopyWithImpl<$Res>
    extends _$AcademyCopyWithImpl<$Res, _$AcademyImpl>
    implements _$$AcademyImplCopyWith<$Res> {
  __$$AcademyImplCopyWithImpl(
      _$AcademyImpl _value, $Res Function(_$AcademyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Academy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? logo = freezed,
    Object? sport = null,
    Object? location = freezed,
    Object? taxId = freezed,
    Object? description = freezed,
    Object? sportConfig = freezed,
    Object? groupIds = freezed,
    Object? coachIds = freezed,
    Object? athleteIds = freezed,
    Object? settings = freezed,
    Object? subscription = null,
    Object? createdAt = null,
  }) {
    return _then(_$AcademyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as String?,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      taxId: freezed == taxId
          ? _value.taxId
          : taxId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      sportConfig: freezed == sportConfig
          ? _value.sportConfig
          : sportConfig // ignore: cast_nullable_to_non_nullable
              as SportCharacteristics?,
      groupIds: freezed == groupIds
          ? _value._groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      coachIds: freezed == coachIds
          ? _value._coachIds
          : coachIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      athleteIds: freezed == athleteIds
          ? _value._athleteIds
          : athleteIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      settings: freezed == settings
          ? _value._settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      subscription: null == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AcademyImpl implements _Academy {
  const _$AcademyImpl(
      {required this.id,
      required this.name,
      required this.ownerId,
      this.logo,
      required this.sport,
      this.location,
      this.taxId,
      this.description,
      this.sportConfig,
      final List<String>? groupIds,
      final List<String>? coachIds,
      final List<String>? athleteIds,
      final Map<String, dynamic>? settings,
      required this.subscription,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      required this.createdAt})
      : _groupIds = groupIds,
        _coachIds = coachIds,
        _athleteIds = athleteIds,
        _settings = settings;

  factory _$AcademyImpl.fromJson(Map<String, dynamic> json) =>
      _$$AcademyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String ownerId;
  @override
  final String? logo;
  @override
  final String sport;
  @override
  final String? location;
  @override
  final String? taxId;
  @override
  final String? description;
  @override
  final SportCharacteristics? sportConfig;
  final List<String>? _groupIds;
  @override
  List<String>? get groupIds {
    final value = _groupIds;
    if (value == null) return null;
    if (_groupIds is EqualUnmodifiableListView) return _groupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _coachIds;
  @override
  List<String>? get coachIds {
    final value = _coachIds;
    if (value == null) return null;
    if (_coachIds is EqualUnmodifiableListView) return _coachIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _athleteIds;
  @override
  List<String>? get athleteIds {
    final value = _athleteIds;
    if (value == null) return null;
    if (_athleteIds is EqualUnmodifiableListView) return _athleteIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _settings;
  @override
  Map<String, dynamic>? get settings {
    final value = _settings;
    if (value == null) return null;
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String subscription;
  @override
  @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
  final DateTime createdAt;

  @override
  String toString() {
    return 'Academy(id: $id, name: $name, ownerId: $ownerId, logo: $logo, sport: $sport, location: $location, taxId: $taxId, description: $description, sportConfig: $sportConfig, groupIds: $groupIds, coachIds: $coachIds, athleteIds: $athleteIds, settings: $settings, subscription: $subscription, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcademyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.taxId, taxId) || other.taxId == taxId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sportConfig, sportConfig) ||
                other.sportConfig == sportConfig) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            const DeepCollectionEquality().equals(other._coachIds, _coachIds) &&
            const DeepCollectionEquality()
                .equals(other._athleteIds, _athleteIds) &&
            const DeepCollectionEquality().equals(other._settings, _settings) &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      ownerId,
      logo,
      sport,
      location,
      taxId,
      description,
      sportConfig,
      const DeepCollectionEquality().hash(_groupIds),
      const DeepCollectionEquality().hash(_coachIds),
      const DeepCollectionEquality().hash(_athleteIds),
      const DeepCollectionEquality().hash(_settings),
      subscription,
      createdAt);

  /// Create a copy of Academy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcademyImplCopyWith<_$AcademyImpl> get copyWith =>
      __$$AcademyImplCopyWithImpl<_$AcademyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AcademyImplToJson(
      this,
    );
  }
}

abstract class _Academy implements Academy {
  const factory _Academy(
      {required final String id,
      required final String name,
      required final String ownerId,
      final String? logo,
      required final String sport,
      final String? location,
      final String? taxId,
      final String? description,
      final SportCharacteristics? sportConfig,
      final List<String>? groupIds,
      final List<String>? coachIds,
      final List<String>? athleteIds,
      final Map<String, dynamic>? settings,
      required final String subscription,
      @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
      required final DateTime createdAt}) = _$AcademyImpl;

  factory _Academy.fromJson(Map<String, dynamic> json) = _$AcademyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ownerId;
  @override
  String? get logo;
  @override
  String get sport;
  @override
  String? get location;
  @override
  String? get taxId;
  @override
  String? get description;
  @override
  SportCharacteristics? get sportConfig;
  @override
  List<String>? get groupIds;
  @override
  List<String>? get coachIds;
  @override
  List<String>? get athleteIds;
  @override
  Map<String, dynamic>? get settings;
  @override
  String get subscription;
  @override
  @JsonKey(fromJson: dateTimeFromString, toJson: dateTimeToString)
  DateTime get createdAt;

  /// Create a copy of Academy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcademyImplCopyWith<_$AcademyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
