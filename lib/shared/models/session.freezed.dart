// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Session _$SessionFromJson(Map<String, dynamic> json) {
  return _Session.fromJson(json);
}

/// @nodoc
mixin _$Session {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get trainingId => throw _privateConstructorUsedError;
  String get academyId => throw _privateConstructorUsedError;
  List<String> get groupIds => throw _privateConstructorUsedError;
  List<String> get coachIds => throw _privateConstructorUsedError;
  DateTime get scheduledDate => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  Map<String, bool> get attendance =>
      throw _privateConstructorUsedError; // ID del atleta -> asistencia
  Map<String, dynamic> get performanceData =>
      throw _privateConstructorUsedError; // ID del atleta -> datos de rendimiento
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  Map<String, dynamic> get content => throw _privateConstructorUsedError;

  /// Serializes this Session to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionCopyWith<Session> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionCopyWith<$Res> {
  factory $SessionCopyWith(Session value, $Res Function(Session) then) =
      _$SessionCopyWithImpl<$Res, Session>;
  @useResult
  $Res call(
      {String id,
      String name,
      String trainingId,
      String academyId,
      List<String> groupIds,
      List<String> coachIds,
      DateTime scheduledDate,
      DateTime? startTime,
      DateTime? endTime,
      bool isCompleted,
      Map<String, bool> attendance,
      Map<String, dynamic> performanceData,
      String? notes,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy,
      Map<String, dynamic> content});
}

/// @nodoc
class _$SessionCopyWithImpl<$Res, $Val extends Session>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? trainingId = null,
    Object? academyId = null,
    Object? groupIds = null,
    Object? coachIds = null,
    Object? scheduledDate = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? isCompleted = null,
    Object? attendance = null,
    Object? performanceData = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
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
      trainingId: null == trainingId
          ? _value.trainingId
          : trainingId // ignore: cast_nullable_to_non_nullable
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
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      attendance: null == attendance
          ? _value.attendance
          : attendance // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      performanceData: null == performanceData
          ? _value.performanceData
          : performanceData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionImplCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$$SessionImplCopyWith(
          _$SessionImpl value, $Res Function(_$SessionImpl) then) =
      __$$SessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String trainingId,
      String academyId,
      List<String> groupIds,
      List<String> coachIds,
      DateTime scheduledDate,
      DateTime? startTime,
      DateTime? endTime,
      bool isCompleted,
      Map<String, bool> attendance,
      Map<String, dynamic> performanceData,
      String? notes,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy,
      Map<String, dynamic> content});
}

/// @nodoc
class __$$SessionImplCopyWithImpl<$Res>
    extends _$SessionCopyWithImpl<$Res, _$SessionImpl>
    implements _$$SessionImplCopyWith<$Res> {
  __$$SessionImplCopyWithImpl(
      _$SessionImpl _value, $Res Function(_$SessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? trainingId = null,
    Object? academyId = null,
    Object? groupIds = null,
    Object? coachIds = null,
    Object? scheduledDate = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? isCompleted = null,
    Object? attendance = null,
    Object? performanceData = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? content = null,
  }) {
    return _then(_$SessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      trainingId: null == trainingId
          ? _value.trainingId
          : trainingId // ignore: cast_nullable_to_non_nullable
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
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      attendance: null == attendance
          ? _value._attendance
          : attendance // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      performanceData: null == performanceData
          ? _value._performanceData
          : performanceData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
      content: null == content
          ? _value._content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionImpl with DiagnosticableTreeMixin implements _Session {
  const _$SessionImpl(
      {required this.id,
      required this.name,
      required this.trainingId,
      required this.academyId,
      required final List<String> groupIds,
      required final List<String> coachIds,
      required this.scheduledDate,
      this.startTime,
      this.endTime,
      this.isCompleted = false,
      final Map<String, bool> attendance = const {},
      final Map<String, dynamic> performanceData = const {},
      this.notes,
      required this.createdAt,
      required this.createdBy,
      this.updatedAt,
      this.updatedBy,
      final Map<String, dynamic> content = const {}})
      : _groupIds = groupIds,
        _coachIds = coachIds,
        _attendance = attendance,
        _performanceData = performanceData,
        _content = content;

  factory _$SessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String trainingId;
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
  final DateTime scheduledDate;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  @JsonKey()
  final bool isCompleted;
  final Map<String, bool> _attendance;
  @override
  @JsonKey()
  Map<String, bool> get attendance {
    if (_attendance is EqualUnmodifiableMapView) return _attendance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attendance);
  }

// ID del atleta -> asistencia
  final Map<String, dynamic> _performanceData;
// ID del atleta -> asistencia
  @override
  @JsonKey()
  Map<String, dynamic> get performanceData {
    if (_performanceData is EqualUnmodifiableMapView) return _performanceData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_performanceData);
  }

// ID del atleta -> datos de rendimiento
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final String createdBy;
  @override
  final DateTime? updatedAt;
  @override
  final String? updatedBy;
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
    return 'Session(id: $id, name: $name, trainingId: $trainingId, academyId: $academyId, groupIds: $groupIds, coachIds: $coachIds, scheduledDate: $scheduledDate, startTime: $startTime, endTime: $endTime, isCompleted: $isCompleted, attendance: $attendance, performanceData: $performanceData, notes: $notes, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy, content: $content)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Session'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('trainingId', trainingId))
      ..add(DiagnosticsProperty('academyId', academyId))
      ..add(DiagnosticsProperty('groupIds', groupIds))
      ..add(DiagnosticsProperty('coachIds', coachIds))
      ..add(DiagnosticsProperty('scheduledDate', scheduledDate))
      ..add(DiagnosticsProperty('startTime', startTime))
      ..add(DiagnosticsProperty('endTime', endTime))
      ..add(DiagnosticsProperty('isCompleted', isCompleted))
      ..add(DiagnosticsProperty('attendance', attendance))
      ..add(DiagnosticsProperty('performanceData', performanceData))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('createdBy', createdBy))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('updatedBy', updatedBy))
      ..add(DiagnosticsProperty('content', content));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.trainingId, trainingId) ||
                other.trainingId == trainingId) &&
            (identical(other.academyId, academyId) ||
                other.academyId == academyId) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            const DeepCollectionEquality().equals(other._coachIds, _coachIds) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            const DeepCollectionEquality()
                .equals(other._attendance, _attendance) &&
            const DeepCollectionEquality()
                .equals(other._performanceData, _performanceData) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            const DeepCollectionEquality().equals(other._content, _content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      trainingId,
      academyId,
      const DeepCollectionEquality().hash(_groupIds),
      const DeepCollectionEquality().hash(_coachIds),
      scheduledDate,
      startTime,
      endTime,
      isCompleted,
      const DeepCollectionEquality().hash(_attendance),
      const DeepCollectionEquality().hash(_performanceData),
      notes,
      createdAt,
      createdBy,
      updatedAt,
      updatedBy,
      const DeepCollectionEquality().hash(_content));

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionImplCopyWith<_$SessionImpl> get copyWith =>
      __$$SessionImplCopyWithImpl<_$SessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionImplToJson(
      this,
    );
  }
}

abstract class _Session implements Session {
  const factory _Session(
      {required final String id,
      required final String name,
      required final String trainingId,
      required final String academyId,
      required final List<String> groupIds,
      required final List<String> coachIds,
      required final DateTime scheduledDate,
      final DateTime? startTime,
      final DateTime? endTime,
      final bool isCompleted,
      final Map<String, bool> attendance,
      final Map<String, dynamic> performanceData,
      final String? notes,
      required final DateTime createdAt,
      required final String createdBy,
      final DateTime? updatedAt,
      final String? updatedBy,
      final Map<String, dynamic> content}) = _$SessionImpl;

  factory _Session.fromJson(Map<String, dynamic> json) = _$SessionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get trainingId;
  @override
  String get academyId;
  @override
  List<String> get groupIds;
  @override
  List<String> get coachIds;
  @override
  DateTime get scheduledDate;
  @override
  DateTime? get startTime;
  @override
  DateTime? get endTime;
  @override
  bool get isCompleted;
  @override
  Map<String, bool> get attendance; // ID del atleta -> asistencia
  @override
  Map<String, dynamic>
      get performanceData; // ID del atleta -> datos de rendimiento
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  String get createdBy;
  @override
  DateTime? get updatedAt;
  @override
  String? get updatedBy;
  @override
  Map<String, dynamic> get content;

  /// Create a copy of Session
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionImplCopyWith<_$SessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
