// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainingPlan _$TrainingPlanFromJson(Map<String, dynamic> json) {
  return _TrainingPlan.fromJson(json);
}

/// @nodoc
mixin _$TrainingPlan {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get academyId => throw _privateConstructorUsedError;
  List<String> get groupIds => throw _privateConstructorUsedError;
  List<String> get coachIds => throw _privateConstructorUsedError;
  int get durationInWeeks => throw _privateConstructorUsedError;
  String get sport => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  List<TrainingPlanPhase> get phases => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;

  /// Serializes this TrainingPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingPlanCopyWith<TrainingPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPlanCopyWith<$Res> {
  factory $TrainingPlanCopyWith(
          TrainingPlan value, $Res Function(TrainingPlan) then) =
      _$TrainingPlanCopyWithImpl<$Res, TrainingPlan>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String academyId,
      List<String> groupIds,
      List<String> coachIds,
      int durationInWeeks,
      String sport,
      String? difficulty,
      String? category,
      DateTime? startDate,
      DateTime? endDate,
      List<TrainingPlanPhase> phases,
      Map<String, dynamic> metadata,
      bool isActive,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class _$TrainingPlanCopyWithImpl<$Res, $Val extends TrainingPlan>
    implements $TrainingPlanCopyWith<$Res> {
  _$TrainingPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingPlan
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
    Object? durationInWeeks = null,
    Object? sport = null,
    Object? difficulty = freezed,
    Object? category = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? phases = null,
    Object? metadata = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
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
      durationInWeeks: null == durationInWeeks
          ? _value.durationInWeeks
          : durationInWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      phases: null == phases
          ? _value.phases
          : phases // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlanPhase>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingPlanImplCopyWith<$Res>
    implements $TrainingPlanCopyWith<$Res> {
  factory _$$TrainingPlanImplCopyWith(
          _$TrainingPlanImpl value, $Res Function(_$TrainingPlanImpl) then) =
      __$$TrainingPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String academyId,
      List<String> groupIds,
      List<String> coachIds,
      int durationInWeeks,
      String sport,
      String? difficulty,
      String? category,
      DateTime? startDate,
      DateTime? endDate,
      List<TrainingPlanPhase> phases,
      Map<String, dynamic> metadata,
      bool isActive,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy});
}

/// @nodoc
class __$$TrainingPlanImplCopyWithImpl<$Res>
    extends _$TrainingPlanCopyWithImpl<$Res, _$TrainingPlanImpl>
    implements _$$TrainingPlanImplCopyWith<$Res> {
  __$$TrainingPlanImplCopyWithImpl(
      _$TrainingPlanImpl _value, $Res Function(_$TrainingPlanImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrainingPlan
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
    Object? durationInWeeks = null,
    Object? sport = null,
    Object? difficulty = freezed,
    Object? category = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? phases = null,
    Object? metadata = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_$TrainingPlanImpl(
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
      durationInWeeks: null == durationInWeeks
          ? _value.durationInWeeks
          : durationInWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      phases: null == phases
          ? _value._phases
          : phases // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlanPhase>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingPlanImpl with DiagnosticableTreeMixin implements _TrainingPlan {
  const _$TrainingPlanImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.academyId,
      required final List<String> groupIds,
      required final List<String> coachIds,
      required this.durationInWeeks,
      required this.sport,
      this.difficulty,
      this.category,
      this.startDate,
      this.endDate,
      final List<TrainingPlanPhase> phases = const [],
      final Map<String, dynamic> metadata = const {},
      this.isActive = false,
      required this.createdAt,
      required this.createdBy,
      this.updatedAt,
      this.updatedBy})
      : _groupIds = groupIds,
        _coachIds = coachIds,
        _phases = phases,
        _metadata = metadata;

  factory _$TrainingPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingPlanImplFromJson(json);

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
  final int durationInWeeks;
  @override
  final String sport;
  @override
  final String? difficulty;
  @override
  final String? category;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  final List<TrainingPlanPhase> _phases;
  @override
  @JsonKey()
  List<TrainingPlanPhase> get phases {
    if (_phases is EqualUnmodifiableListView) return _phases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_phases);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final String createdBy;
  @override
  final DateTime? updatedAt;
  @override
  final String? updatedBy;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TrainingPlan(id: $id, name: $name, description: $description, academyId: $academyId, groupIds: $groupIds, coachIds: $coachIds, durationInWeeks: $durationInWeeks, sport: $sport, difficulty: $difficulty, category: $category, startDate: $startDate, endDate: $endDate, phases: $phases, metadata: $metadata, isActive: $isActive, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TrainingPlan'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('academyId', academyId))
      ..add(DiagnosticsProperty('groupIds', groupIds))
      ..add(DiagnosticsProperty('coachIds', coachIds))
      ..add(DiagnosticsProperty('durationInWeeks', durationInWeeks))
      ..add(DiagnosticsProperty('sport', sport))
      ..add(DiagnosticsProperty('difficulty', difficulty))
      ..add(DiagnosticsProperty('category', category))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('phases', phases))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('createdBy', createdBy))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('updatedBy', updatedBy));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.academyId, academyId) ||
                other.academyId == academyId) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            const DeepCollectionEquality().equals(other._coachIds, _coachIds) &&
            (identical(other.durationInWeeks, durationInWeeks) ||
                other.durationInWeeks == durationInWeeks) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other._phases, _phases) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
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
        durationInWeeks,
        sport,
        difficulty,
        category,
        startDate,
        endDate,
        const DeepCollectionEquality().hash(_phases),
        const DeepCollectionEquality().hash(_metadata),
        isActive,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy
      ]);

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPlanImplCopyWith<_$TrainingPlanImpl> get copyWith =>
      __$$TrainingPlanImplCopyWithImpl<_$TrainingPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingPlanImplToJson(
      this,
    );
  }
}

abstract class _TrainingPlan implements TrainingPlan {
  const factory _TrainingPlan(
      {required final String id,
      required final String name,
      required final String description,
      required final String academyId,
      required final List<String> groupIds,
      required final List<String> coachIds,
      required final int durationInWeeks,
      required final String sport,
      final String? difficulty,
      final String? category,
      final DateTime? startDate,
      final DateTime? endDate,
      final List<TrainingPlanPhase> phases,
      final Map<String, dynamic> metadata,
      final bool isActive,
      required final DateTime createdAt,
      required final String createdBy,
      final DateTime? updatedAt,
      final String? updatedBy}) = _$TrainingPlanImpl;

  factory _TrainingPlan.fromJson(Map<String, dynamic> json) =
      _$TrainingPlanImpl.fromJson;

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
  int get durationInWeeks;
  @override
  String get sport;
  @override
  String? get difficulty;
  @override
  String? get category;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  List<TrainingPlanPhase> get phases;
  @override
  Map<String, dynamic> get metadata;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  String get createdBy;
  @override
  DateTime? get updatedAt;
  @override
  String? get updatedBy;

  /// Create a copy of TrainingPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingPlanImplCopyWith<_$TrainingPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrainingPlanPhase _$TrainingPlanPhaseFromJson(Map<String, dynamic> json) {
  return _TrainingPlanPhase.fromJson(json);
}

/// @nodoc
mixin _$TrainingPlanPhase {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  int get durationInDays => throw _privateConstructorUsedError;
  List<TrainingPlanSession> get plannedSessions =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> get objectives => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Serializes this TrainingPlanPhase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingPlanPhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingPlanPhaseCopyWith<TrainingPlanPhase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPlanPhaseCopyWith<$Res> {
  factory $TrainingPlanPhaseCopyWith(
          TrainingPlanPhase value, $Res Function(TrainingPlanPhase) then) =
      _$TrainingPlanPhaseCopyWithImpl<$Res, TrainingPlanPhase>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      int order,
      int durationInDays,
      List<TrainingPlanSession> plannedSessions,
      Map<String, dynamic> objectives,
      DateTime? startDate,
      DateTime? endDate});
}

/// @nodoc
class _$TrainingPlanPhaseCopyWithImpl<$Res, $Val extends TrainingPlanPhase>
    implements $TrainingPlanPhaseCopyWith<$Res> {
  _$TrainingPlanPhaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingPlanPhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? order = null,
    Object? durationInDays = null,
    Object? plannedSessions = null,
    Object? objectives = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
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
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      durationInDays: null == durationInDays
          ? _value.durationInDays
          : durationInDays // ignore: cast_nullable_to_non_nullable
              as int,
      plannedSessions: null == plannedSessions
          ? _value.plannedSessions
          : plannedSessions // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlanSession>,
      objectives: null == objectives
          ? _value.objectives
          : objectives // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingPlanPhaseImplCopyWith<$Res>
    implements $TrainingPlanPhaseCopyWith<$Res> {
  factory _$$TrainingPlanPhaseImplCopyWith(_$TrainingPlanPhaseImpl value,
          $Res Function(_$TrainingPlanPhaseImpl) then) =
      __$$TrainingPlanPhaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      int order,
      int durationInDays,
      List<TrainingPlanSession> plannedSessions,
      Map<String, dynamic> objectives,
      DateTime? startDate,
      DateTime? endDate});
}

/// @nodoc
class __$$TrainingPlanPhaseImplCopyWithImpl<$Res>
    extends _$TrainingPlanPhaseCopyWithImpl<$Res, _$TrainingPlanPhaseImpl>
    implements _$$TrainingPlanPhaseImplCopyWith<$Res> {
  __$$TrainingPlanPhaseImplCopyWithImpl(_$TrainingPlanPhaseImpl _value,
      $Res Function(_$TrainingPlanPhaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrainingPlanPhase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? order = null,
    Object? durationInDays = null,
    Object? plannedSessions = null,
    Object? objectives = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_$TrainingPlanPhaseImpl(
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
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      durationInDays: null == durationInDays
          ? _value.durationInDays
          : durationInDays // ignore: cast_nullable_to_non_nullable
              as int,
      plannedSessions: null == plannedSessions
          ? _value._plannedSessions
          : plannedSessions // ignore: cast_nullable_to_non_nullable
              as List<TrainingPlanSession>,
      objectives: null == objectives
          ? _value._objectives
          : objectives // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingPlanPhaseImpl
    with DiagnosticableTreeMixin
    implements _TrainingPlanPhase {
  const _$TrainingPlanPhaseImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.order,
      required this.durationInDays,
      final List<TrainingPlanSession> plannedSessions = const [],
      final Map<String, dynamic> objectives = const {},
      this.startDate,
      this.endDate})
      : _plannedSessions = plannedSessions,
        _objectives = objectives;

  factory _$TrainingPlanPhaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingPlanPhaseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final int order;
  @override
  final int durationInDays;
  final List<TrainingPlanSession> _plannedSessions;
  @override
  @JsonKey()
  List<TrainingPlanSession> get plannedSessions {
    if (_plannedSessions is EqualUnmodifiableListView) return _plannedSessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plannedSessions);
  }

  final Map<String, dynamic> _objectives;
  @override
  @JsonKey()
  Map<String, dynamic> get objectives {
    if (_objectives is EqualUnmodifiableMapView) return _objectives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_objectives);
  }

  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TrainingPlanPhase(id: $id, name: $name, description: $description, order: $order, durationInDays: $durationInDays, plannedSessions: $plannedSessions, objectives: $objectives, startDate: $startDate, endDate: $endDate)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TrainingPlanPhase'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('order', order))
      ..add(DiagnosticsProperty('durationInDays', durationInDays))
      ..add(DiagnosticsProperty('plannedSessions', plannedSessions))
      ..add(DiagnosticsProperty('objectives', objectives))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPlanPhaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.durationInDays, durationInDays) ||
                other.durationInDays == durationInDays) &&
            const DeepCollectionEquality()
                .equals(other._plannedSessions, _plannedSessions) &&
            const DeepCollectionEquality()
                .equals(other._objectives, _objectives) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      order,
      durationInDays,
      const DeepCollectionEquality().hash(_plannedSessions),
      const DeepCollectionEquality().hash(_objectives),
      startDate,
      endDate);

  /// Create a copy of TrainingPlanPhase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPlanPhaseImplCopyWith<_$TrainingPlanPhaseImpl> get copyWith =>
      __$$TrainingPlanPhaseImplCopyWithImpl<_$TrainingPlanPhaseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingPlanPhaseImplToJson(
      this,
    );
  }
}

abstract class _TrainingPlanPhase implements TrainingPlanPhase {
  const factory _TrainingPlanPhase(
      {required final String id,
      required final String name,
      required final String description,
      required final int order,
      required final int durationInDays,
      final List<TrainingPlanSession> plannedSessions,
      final Map<String, dynamic> objectives,
      final DateTime? startDate,
      final DateTime? endDate}) = _$TrainingPlanPhaseImpl;

  factory _TrainingPlanPhase.fromJson(Map<String, dynamic> json) =
      _$TrainingPlanPhaseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  int get order;
  @override
  int get durationInDays;
  @override
  List<TrainingPlanSession> get plannedSessions;
  @override
  Map<String, dynamic> get objectives;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;

  /// Create a copy of TrainingPlanPhase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingPlanPhaseImplCopyWith<_$TrainingPlanPhaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrainingPlanSession _$TrainingPlanSessionFromJson(Map<String, dynamic> json) {
  return _TrainingPlanSession.fromJson(json);
}

/// @nodoc
mixin _$TrainingPlanSession {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get dayOffset =>
      throw _privateConstructorUsedError; // Días desde el inicio de la fase
  String? get trainingTemplateId =>
      throw _privateConstructorUsedError; // Template que se usará como base
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get content =>
      throw _privateConstructorUsedError; // Contenido específico si no hay template
  int get duration => throw _privateConstructorUsedError; // Duración en minutos
  String get intensity =>
      throw _privateConstructorUsedError; // baja, normal, alta
  String? get generatedSessionId => throw _privateConstructorUsedError;

  /// Serializes this TrainingPlanSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingPlanSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingPlanSessionCopyWith<TrainingPlanSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPlanSessionCopyWith<$Res> {
  factory $TrainingPlanSessionCopyWith(
          TrainingPlanSession value, $Res Function(TrainingPlanSession) then) =
      _$TrainingPlanSessionCopyWithImpl<$Res, TrainingPlanSession>;
  @useResult
  $Res call(
      {String id,
      String name,
      int dayOffset,
      String? trainingTemplateId,
      String? description,
      Map<String, dynamic> content,
      int duration,
      String intensity,
      String? generatedSessionId});
}

/// @nodoc
class _$TrainingPlanSessionCopyWithImpl<$Res, $Val extends TrainingPlanSession>
    implements $TrainingPlanSessionCopyWith<$Res> {
  _$TrainingPlanSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingPlanSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dayOffset = null,
    Object? trainingTemplateId = freezed,
    Object? description = freezed,
    Object? content = null,
    Object? duration = null,
    Object? intensity = null,
    Object? generatedSessionId = freezed,
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
      dayOffset: null == dayOffset
          ? _value.dayOffset
          : dayOffset // ignore: cast_nullable_to_non_nullable
              as int,
      trainingTemplateId: freezed == trainingTemplateId
          ? _value.trainingTemplateId
          : trainingTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as String,
      generatedSessionId: freezed == generatedSessionId
          ? _value.generatedSessionId
          : generatedSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingPlanSessionImplCopyWith<$Res>
    implements $TrainingPlanSessionCopyWith<$Res> {
  factory _$$TrainingPlanSessionImplCopyWith(_$TrainingPlanSessionImpl value,
          $Res Function(_$TrainingPlanSessionImpl) then) =
      __$$TrainingPlanSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int dayOffset,
      String? trainingTemplateId,
      String? description,
      Map<String, dynamic> content,
      int duration,
      String intensity,
      String? generatedSessionId});
}

/// @nodoc
class __$$TrainingPlanSessionImplCopyWithImpl<$Res>
    extends _$TrainingPlanSessionCopyWithImpl<$Res, _$TrainingPlanSessionImpl>
    implements _$$TrainingPlanSessionImplCopyWith<$Res> {
  __$$TrainingPlanSessionImplCopyWithImpl(_$TrainingPlanSessionImpl _value,
      $Res Function(_$TrainingPlanSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrainingPlanSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dayOffset = null,
    Object? trainingTemplateId = freezed,
    Object? description = freezed,
    Object? content = null,
    Object? duration = null,
    Object? intensity = null,
    Object? generatedSessionId = freezed,
  }) {
    return _then(_$TrainingPlanSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dayOffset: null == dayOffset
          ? _value.dayOffset
          : dayOffset // ignore: cast_nullable_to_non_nullable
              as int,
      trainingTemplateId: freezed == trainingTemplateId
          ? _value.trainingTemplateId
          : trainingTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value._content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as String,
      generatedSessionId: freezed == generatedSessionId
          ? _value.generatedSessionId
          : generatedSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingPlanSessionImpl
    with DiagnosticableTreeMixin
    implements _TrainingPlanSession {
  const _$TrainingPlanSessionImpl(
      {required this.id,
      required this.name,
      required this.dayOffset,
      this.trainingTemplateId,
      this.description,
      final Map<String, dynamic> content = const {},
      this.duration = 0,
      this.intensity = 'normal',
      this.generatedSessionId})
      : _content = content;

  factory _$TrainingPlanSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingPlanSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int dayOffset;
// Días desde el inicio de la fase
  @override
  final String? trainingTemplateId;
// Template que se usará como base
  @override
  final String? description;
  final Map<String, dynamic> _content;
  @override
  @JsonKey()
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

// Contenido específico si no hay template
  @override
  @JsonKey()
  final int duration;
// Duración en minutos
  @override
  @JsonKey()
  final String intensity;
// baja, normal, alta
  @override
  final String? generatedSessionId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TrainingPlanSession(id: $id, name: $name, dayOffset: $dayOffset, trainingTemplateId: $trainingTemplateId, description: $description, content: $content, duration: $duration, intensity: $intensity, generatedSessionId: $generatedSessionId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TrainingPlanSession'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('dayOffset', dayOffset))
      ..add(DiagnosticsProperty('trainingTemplateId', trainingTemplateId))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('intensity', intensity))
      ..add(DiagnosticsProperty('generatedSessionId', generatedSessionId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPlanSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dayOffset, dayOffset) ||
                other.dayOffset == dayOffset) &&
            (identical(other.trainingTemplateId, trainingTemplateId) ||
                other.trainingTemplateId == trainingTemplateId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            (identical(other.generatedSessionId, generatedSessionId) ||
                other.generatedSessionId == generatedSessionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      dayOffset,
      trainingTemplateId,
      description,
      const DeepCollectionEquality().hash(_content),
      duration,
      intensity,
      generatedSessionId);

  /// Create a copy of TrainingPlanSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPlanSessionImplCopyWith<_$TrainingPlanSessionImpl> get copyWith =>
      __$$TrainingPlanSessionImplCopyWithImpl<_$TrainingPlanSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingPlanSessionImplToJson(
      this,
    );
  }
}

abstract class _TrainingPlanSession implements TrainingPlanSession {
  const factory _TrainingPlanSession(
      {required final String id,
      required final String name,
      required final int dayOffset,
      final String? trainingTemplateId,
      final String? description,
      final Map<String, dynamic> content,
      final int duration,
      final String intensity,
      final String? generatedSessionId}) = _$TrainingPlanSessionImpl;

  factory _TrainingPlanSession.fromJson(Map<String, dynamic> json) =
      _$TrainingPlanSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get dayOffset; // Días desde el inicio de la fase
  @override
  String? get trainingTemplateId; // Template que se usará como base
  @override
  String? get description;
  @override
  Map<String, dynamic> get content; // Contenido específico si no hay template
  @override
  int get duration; // Duración en minutos
  @override
  String get intensity; // baja, normal, alta
  @override
  String? get generatedSessionId;

  /// Create a copy of TrainingPlanSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingPlanSessionImplCopyWith<_$TrainingPlanSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
