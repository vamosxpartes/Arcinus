// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return _Exercise.fromJson(json);
}

/// @nodoc
mixin _$Exercise {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get academyId => throw _privateConstructorUsedError;
  String get sport =>
      throw _privateConstructorUsedError; // Deporte al que pertenece
  String get category =>
      throw _privateConstructorUsedError; // Categoría: cardio, fuerza, flexibilidad, etc.
  String get difficulty =>
      throw _privateConstructorUsedError; // Dificultad: principiante, intermedio, avanzado
  List<String> get muscleGroups =>
      throw _privateConstructorUsedError; // Grupos musculares trabajados
  List<String> get equipment =>
      throw _privateConstructorUsedError; // Equipamiento necesario
  Map<String, dynamic> get instructions =>
      throw _privateConstructorUsedError; // Instrucciones detalladas (pasos)
  String? get videoUrl =>
      throw _privateConstructorUsedError; // URL de video demostrativo
  List<String> get imageUrls =>
      throw _privateConstructorUsedError; // URLs de imágenes demostrativas
  Map<String, dynamic> get metrics =>
      throw _privateConstructorUsedError; // Métricas que se pueden registrar (tiempo, repeticiones, peso, etc.)
  Map<String, dynamic> get variations =>
      throw _privateConstructorUsedError; // Variaciones del ejercicio
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String academyId,
      String sport,
      String category,
      String difficulty,
      List<String> muscleGroups,
      List<String> equipment,
      Map<String, dynamic> instructions,
      String? videoUrl,
      List<String> imageUrls,
      Map<String, dynamic> metrics,
      Map<String, dynamic> variations,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? academyId = null,
    Object? sport = null,
    Object? category = null,
    Object? difficulty = null,
    Object? muscleGroups = null,
    Object? equipment = null,
    Object? instructions = null,
    Object? videoUrl = freezed,
    Object? imageUrls = null,
    Object? metrics = null,
    Object? variations = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? metadata = null,
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
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      muscleGroups: null == muscleGroups
          ? _value.muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      metrics: null == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      variations: null == variations
          ? _value.variations
          : variations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
          _$ExerciseImpl value, $Res Function(_$ExerciseImpl) then) =
      __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String academyId,
      String sport,
      String category,
      String difficulty,
      List<String> muscleGroups,
      List<String> equipment,
      Map<String, dynamic> instructions,
      String? videoUrl,
      List<String> imageUrls,
      Map<String, dynamic> metrics,
      Map<String, dynamic> variations,
      DateTime createdAt,
      String createdBy,
      DateTime? updatedAt,
      String? updatedBy,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
      _$ExerciseImpl _value, $Res Function(_$ExerciseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? academyId = null,
    Object? sport = null,
    Object? category = null,
    Object? difficulty = null,
    Object? muscleGroups = null,
    Object? equipment = null,
    Object? instructions = null,
    Object? videoUrl = freezed,
    Object? imageUrls = null,
    Object? metrics = null,
    Object? variations = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? updatedAt = freezed,
    Object? updatedBy = freezed,
    Object? metadata = null,
  }) {
    return _then(_$ExerciseImpl(
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
      sport: null == sport
          ? _value.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      muscleGroups: null == muscleGroups
          ? _value._muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instructions: null == instructions
          ? _value._instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      metrics: null == metrics
          ? _value._metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      variations: null == variations
          ? _value._variations
          : variations // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseImpl with DiagnosticableTreeMixin implements _Exercise {
  const _$ExerciseImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.academyId,
      required this.sport,
      required this.category,
      required this.difficulty,
      final List<String> muscleGroups = const [],
      final List<String> equipment = const [],
      final Map<String, dynamic> instructions = const {},
      this.videoUrl,
      final List<String> imageUrls = const [],
      final Map<String, dynamic> metrics = const {},
      final Map<String, dynamic> variations = const {},
      required this.createdAt,
      required this.createdBy,
      this.updatedAt,
      this.updatedBy,
      final Map<String, dynamic> metadata = const {}})
      : _muscleGroups = muscleGroups,
        _equipment = equipment,
        _instructions = instructions,
        _imageUrls = imageUrls,
        _metrics = metrics,
        _variations = variations,
        _metadata = metadata;

  factory _$ExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String academyId;
  @override
  final String sport;
// Deporte al que pertenece
  @override
  final String category;
// Categoría: cardio, fuerza, flexibilidad, etc.
  @override
  final String difficulty;
// Dificultad: principiante, intermedio, avanzado
  final List<String> _muscleGroups;
// Dificultad: principiante, intermedio, avanzado
  @override
  @JsonKey()
  List<String> get muscleGroups {
    if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscleGroups);
  }

// Grupos musculares trabajados
  final List<String> _equipment;
// Grupos musculares trabajados
  @override
  @JsonKey()
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

// Equipamiento necesario
  final Map<String, dynamic> _instructions;
// Equipamiento necesario
  @override
  @JsonKey()
  Map<String, dynamic> get instructions {
    if (_instructions is EqualUnmodifiableMapView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_instructions);
  }

// Instrucciones detalladas (pasos)
  @override
  final String? videoUrl;
// URL de video demostrativo
  final List<String> _imageUrls;
// URL de video demostrativo
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

// URLs de imágenes demostrativas
  final Map<String, dynamic> _metrics;
// URLs de imágenes demostrativas
  @override
  @JsonKey()
  Map<String, dynamic> get metrics {
    if (_metrics is EqualUnmodifiableMapView) return _metrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metrics);
  }

// Métricas que se pueden registrar (tiempo, repeticiones, peso, etc.)
  final Map<String, dynamic> _variations;
// Métricas que se pueden registrar (tiempo, repeticiones, peso, etc.)
  @override
  @JsonKey()
  Map<String, dynamic> get variations {
    if (_variations is EqualUnmodifiableMapView) return _variations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_variations);
  }

// Variaciones del ejercicio
  @override
  final DateTime createdAt;
  @override
  final String createdBy;
  @override
  final DateTime? updatedAt;
  @override
  final String? updatedBy;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Exercise(id: $id, name: $name, description: $description, academyId: $academyId, sport: $sport, category: $category, difficulty: $difficulty, muscleGroups: $muscleGroups, equipment: $equipment, instructions: $instructions, videoUrl: $videoUrl, imageUrls: $imageUrls, metrics: $metrics, variations: $variations, createdAt: $createdAt, createdBy: $createdBy, updatedAt: $updatedAt, updatedBy: $updatedBy, metadata: $metadata)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Exercise'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('academyId', academyId))
      ..add(DiagnosticsProperty('sport', sport))
      ..add(DiagnosticsProperty('category', category))
      ..add(DiagnosticsProperty('difficulty', difficulty))
      ..add(DiagnosticsProperty('muscleGroups', muscleGroups))
      ..add(DiagnosticsProperty('equipment', equipment))
      ..add(DiagnosticsProperty('instructions', instructions))
      ..add(DiagnosticsProperty('videoUrl', videoUrl))
      ..add(DiagnosticsProperty('imageUrls', imageUrls))
      ..add(DiagnosticsProperty('metrics', metrics))
      ..add(DiagnosticsProperty('variations', variations))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('createdBy', createdBy))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('updatedBy', updatedBy))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.academyId, academyId) ||
                other.academyId == academyId) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality()
                .equals(other._muscleGroups, _muscleGroups) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality()
                .equals(other._instructions, _instructions) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            const DeepCollectionEquality().equals(other._metrics, _metrics) &&
            const DeepCollectionEquality()
                .equals(other._variations, _variations) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        academyId,
        sport,
        category,
        difficulty,
        const DeepCollectionEquality().hash(_muscleGroups),
        const DeepCollectionEquality().hash(_equipment),
        const DeepCollectionEquality().hash(_instructions),
        videoUrl,
        const DeepCollectionEquality().hash(_imageUrls),
        const DeepCollectionEquality().hash(_metrics),
        const DeepCollectionEquality().hash(_variations),
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
        const DeepCollectionEquality().hash(_metadata)
      ]);

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseImplToJson(
      this,
    );
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise(
      {required final String id,
      required final String name,
      required final String description,
      required final String academyId,
      required final String sport,
      required final String category,
      required final String difficulty,
      final List<String> muscleGroups,
      final List<String> equipment,
      final Map<String, dynamic> instructions,
      final String? videoUrl,
      final List<String> imageUrls,
      final Map<String, dynamic> metrics,
      final Map<String, dynamic> variations,
      required final DateTime createdAt,
      required final String createdBy,
      final DateTime? updatedAt,
      final String? updatedBy,
      final Map<String, dynamic> metadata}) = _$ExerciseImpl;

  factory _Exercise.fromJson(Map<String, dynamic> json) =
      _$ExerciseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get academyId;
  @override
  String get sport; // Deporte al que pertenece
  @override
  String get category; // Categoría: cardio, fuerza, flexibilidad, etc.
  @override
  String get difficulty; // Dificultad: principiante, intermedio, avanzado
  @override
  List<String> get muscleGroups; // Grupos musculares trabajados
  @override
  List<String> get equipment; // Equipamiento necesario
  @override
  Map<String, dynamic> get instructions; // Instrucciones detalladas (pasos)
  @override
  String? get videoUrl; // URL de video demostrativo
  @override
  List<String> get imageUrls; // URLs de imágenes demostrativas
  @override
  Map<String, dynamic>
      get metrics; // Métricas que se pueden registrar (tiempo, repeticiones, peso, etc.)
  @override
  Map<String, dynamic> get variations; // Variaciones del ejercicio
  @override
  DateTime get createdAt;
  @override
  String get createdBy;
  @override
  DateTime? get updatedAt;
  @override
  String? get updatedBy;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
