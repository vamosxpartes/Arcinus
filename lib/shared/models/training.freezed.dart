// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Training _$TrainingFromJson(Map<String, dynamic> json) {
  return _Training.fromJson(json);
}

/// @nodoc
mixin _$Training {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get academyId => throw _privateConstructorUsedError;
  List<String> get groupIds => throw _privateConstructorUsedError;
  List<String> get coachIds => throw _privateConstructorUsedError;
  bool get isTemplate => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get recurrencePattern =>
      throw _privateConstructorUsedError; // Patrón de recurrencia: "daily", "weekly", "monthly"
  List<String>? get recurrenceDays =>
      throw _privateConstructorUsedError; // Días de la semana para recurrencia semanal
  int? get recurrenceInterval =>
      throw _privateConstructorUsedError; // Intervalo de recurrencia
  List<String>? get sessionIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  Map<String, dynamic> get content => throw _privateConstructorUsedError;

  /// Serializes this Training to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Training
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingCopyWith<Training> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingCopyWith<$Res> {
  factory $TrainingCopyWith(Training value, $Res Function(Training) then) =
      _$TrainingCopyWithImpl<$Res, Training>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String academyId,
      List<String> groupIds,
      List<String> coachIds,
      bool isTemplate,
      bool isRecurring,
      DateTime? startDate,
      DateTime? endDate,
      String? recurrencePattern,
      List<String>? recurrenceDays,
      int? recurrenceInterval,
      List<String>? sessionIds,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy,
      Map<String, dynamic>? metadata,
      Map<String, dynamic> content});
}

/// @nodoc
class _$TrainingCopyWithImpl<$Res, $Val extends Training>
    implements $TrainingCopyWith<$Res> {
  _$TrainingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Training
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? academyId = null,
    Object? groupIds = null,
    Object? coachIds = null,
    Object? isTemplate = null,
    Object? isRecurring = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? recurrencePattern = freezed,
    Object? recurrenceDays = freezed,
    Object? recurrenceInterval = freezed,
    Object? sessionIds = freezed,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? metadata = freezed,
    Object? content = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      academyId: null == academyId
          ? _value.academyId
          : academyId // ignore: cast_nullable_to_non_nullable
              as String,
      groupIds: null == groupIds
          ? _value.groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      coachIds: null == coachIds
          ? _value.coachIds
          : coachIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isTemplate: null == isTemplate
          ? _value.isTemplate
          : isTemplate // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      recurrencePattern: freezed == recurrencePattern
          ? _value.recurrencePattern
          : recurrencePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceDays: freezed == recurrenceDays
          ? _value.recurrenceDays
          : recurrenceDays // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      recurrenceInterval: freezed == recurrenceInterval
          ? _value.recurrenceInterval
          : recurrenceInterval // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionIds: freezed == sessionIds
          ? _value.sessionIds
          : sessionIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingImplCopyWith<$Res>
    implements $TrainingCopyWith<$Res> {
  factory _$$TrainingImplCopyWith(
          _$TrainingImpl value, $Res Function(_$TrainingImpl) then) =
      __$$TrainingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String academyId,
      List<String> groupIds,
      List<String> coachIds,
      bool isTemplate,
      bool isRecurring,
      DateTime? startDate,
      DateTime? endDate,
      String? recurrencePattern,
      List<String>? recurrenceDays,
      int? recurrenceInterval,
      List<String>? sessionIds,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy,
      Map<String, dynamic>? metadata,
      Map<String, dynamic> content});
}

/// @nodoc
class __$$TrainingImplCopyWithImpl<$Res>
    extends _$TrainingCopyWithImpl<$Res, _$TrainingImpl>
    implements _$$TrainingImplCopyWith<$Res> {
  __$$TrainingImplCopyWithImpl(
      _$TrainingImpl _value, $Res Function(_$TrainingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Training
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? academyId = null,
    Object? groupIds = null,
    Object? coachIds = null,
    Object? isTemplate = null,
    Object? isRecurring = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? recurrencePattern = freezed,
    Object? recurrenceDays = freezed,
    Object? recurrenceInterval = freezed,
    Object? sessionIds = freezed,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? metadata = freezed,
    Object? content = null,
  }) {
    return _then(_$TrainingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      academyId: null == academyId
          ? _value.academyId
          : academyId // ignore: cast_nullable_to_non_nullable
              as String,
      groupIds: null == groupIds
          ? _value._groupIds
          : groupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      coachIds: null == coachIds
          ? _value._coachIds
          : coachIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isTemplate: null == isTemplate
          ? _value.isTemplate
          : isTemplate // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      recurrencePattern: freezed == recurrencePattern
          ? _value.recurrencePattern
          : recurrencePattern // ignore: cast_nullable_to_non_nullable
              as String?,
      recurrenceDays: freezed == recurrenceDays
          ? _value._recurrenceDays
          : recurrenceDays // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      recurrenceInterval: freezed == recurrenceInterval
          ? _value.recurrenceInterval
          : recurrenceInterval // ignore: cast_nullable_to_non_nullable
              as int?,
      sessionIds: freezed == sessionIds
          ? _value._sessionIds
          : sessionIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      content: null == content
          ? _value._content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingImpl with DiagnosticableTreeMixin implements _Training {
  const _$TrainingImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.academyId,
      required final List<String> groupIds,
      required final List<String> coachIds,
      required this.isTemplate,
      this.isRecurring = false,
      this.startDate,
      this.endDate,
      this.recurrencePattern,
      final List<String>? recurrenceDays,
      this.recurrenceInterval,
      final List<String>? sessionIds,
      required this.createdAt,
      required this.createdBy,
      this.updatedAt,
      this.updatedBy,
      final Map<String, dynamic>? metadata,
      final Map<String, dynamic> content = const {}})
      : _groupIds = groupIds,
        _coachIds = coachIds,
        _recurrenceDays = recurrenceDays,
        _sessionIds = sessionIds,
        _metadata = metadata,
        _content = content;

  factory _$TrainingImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String academyId;
  final List<String> _groupIds;
  @override
  List<String> get groupIds {
    if (_groupIds is EqualUnmodifiableListView) return _groupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groupIds);
  }

  final List<String> _coachIds;
  @override
  List<String> get coachIds {
    if (_coachIds is EqualUnmodifiableListView) return _coachIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coachIds);
  }

  @override
  final bool isTemplate;
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final String? recurrencePattern;
// Patrón de recurrencia: "daily", "weekly", "monthly"
  final List<String>? _recurrenceDays;
// Patrón de recurrencia: "daily", "weekly", "monthly"
  @override
  List<String>? get recurrenceDays {
    final value = _recurrenceDays;
    if (value == null) return null;
    if (_recurrenceDays is EqualUnmodifiableListView) return _recurrenceDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Días de la semana para recurrencia semanal
  @override
  final int? recurrenceInterval;
// Intervalo de recurrencia
  final List<String>? _sessionIds;
// Intervalo de recurrencia
  @override
  List<String>? get sessionIds {
    final value = _sessionIds;
    if (value == null) return null;
    if (_sessionIds is EqualUnmodifiableListView) return _sessionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final String createdBy;
  @override
  final DateTime? updatedAt;
  @override
  final String? updatedBy;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic> _content;
  @override
  @JsonKey()
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Training(id: $id, name: $name, description: $description, academyId: $academyId, groupIds: $groupIds, coachIds: $coachIds, isTemplate: $isTemplate, isRecurring: $isRecurring, startDate: $startDate, endDate: $endDate, recurrencePattern: $recurrencePattern, recurrenceDays: $recurrenceDays, recurrenceInterval: $recurrenceInterval, sessionIds: $sessionIds, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy, metadata: $metadata, content: $content)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Training'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('academyId', academyId))
      ..add(DiagnosticsProperty('groupIds', groupIds))
      ..add(DiagnosticsProperty('coachIds', coachIds))
      ..add(DiagnosticsProperty('isTemplate', isTemplate))
      ..add(DiagnosticsProperty('isRecurring', isRecurring))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('recurrencePattern', recurrencePattern))
      ..add(DiagnosticsProperty('recurrenceDays', recurrenceDays))
      ..add(DiagnosticsProperty('recurrenceInterval', recurrenceInterval))
      ..add(DiagnosticsProperty('sessionIds', sessionIds))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('createdBy', createdBy))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('updatedBy', updatedBy))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('content', content));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.academyId, academyId) ||
                other.academyId == academyId) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            const DeepCollectionEquality().equals(other._coachIds, _coachIds) &&
            (identical(other.isTemplate, isTemplate) ||
                other.isTemplate == isTemplate) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.recurrencePattern, recurrencePattern) ||
                other.recurrencePattern == recurrencePattern) &&
            const DeepCollectionEquality()
                .equals(other._recurrenceDays, _recurrenceDays) &&
            (identical(other.recurrenceInterval, recurrenceInterval) ||
                other.recurrenceInterval == recurrenceInterval) &&
            const DeepCollectionEquality()
                .equals(other._sessionIds, _sessionIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._content, _content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        academyId,
        const DeepCollectionEquality().hash(_groupIds),
        const DeepCollectionEquality().hash(_coachIds),
        isTemplate,
        isRecurring,
        startDate,
        endDate,
        recurrencePattern,
        const DeepCollectionEquality().hash(_recurrenceDays),
        recurrenceInterval,
        const DeepCollectionEquality().hash(_sessionIds),
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        const DeepCollectionEquality().hash(_metadata),
        const DeepCollectionEquality().hash(_content)
      ]);

  /// Create a copy of Training
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingImplCopyWith<_$TrainingImpl> get copyWith =>
      __$$TrainingImplCopyWithImpl<_$TrainingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingImplToJson(
      this,
    );
  }
}

abstract class _Training implements Training {
  const factory _Training(
      {required final String id,
      required final String name,
      required final String description,
      required final String academyId,
      required final List<String> groupIds,
      required final List<String> coachIds,
      required final bool isTemplate,
      final bool isRecurring,
      final DateTime? startDate,
      final DateTime? endDate,
      final String? recurrencePattern,
      final List<String>? recurrenceDays,
      final int? recurrenceInterval,
      final List<String>? sessionIds,
      required final DateTime createdAt,
      required final String createdBy,
      final DateTime? updatedAt,
      final String? updatedBy,
      final Map<String, dynamic>? metadata,
      final Map<String, dynamic> content}) = _$TrainingImpl;

  factory _Training.fromJson(Map<String, dynamic> json) =
      _$TrainingImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get academyId;
  @override
  List<String> get groupIds;
  @override
  List<String> get coachIds;
  @override
  bool get isTemplate;
  @override
  bool get isRecurring;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String?
      get recurrencePattern; // Patrón de recurrencia: "daily", "weekly", "monthly"
  @override
  List<String>?
      get recurrenceDays; // Días de la semana para recurrencia semanal
  @override
  int? get recurrenceInterval; // Intervalo de recurrencia
  @override
  List<String>? get sessionIds;
  @override
  DateTime get createdAt;
  @override
  String get createdBy;
  @override
  DateTime? get updatedAt;
  @override
  String? get updatedBy;
  @override
  Map<String, dynamic>? get metadata;
  @override
  Map<String, dynamic> get content;

  /// Create a copy of Training
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingImplCopyWith<_$TrainingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
