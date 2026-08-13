// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dataset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Dataset _$DatasetFromJson(Map<String, dynamic> json) {
  return _Dataset.fromJson(json);
}

/// @nodoc
mixin _$Dataset {
  String get name => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  int get totalProblems => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<ProblemDTO> get problems => throw _privateConstructorUsedError;

  /// Serializes this Dataset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DatasetCopyWith<Dataset> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DatasetCopyWith<$Res> {
  factory $DatasetCopyWith(Dataset value, $Res Function(Dataset) then) =
      _$DatasetCopyWithImpl<$Res, Dataset>;
  @useResult
  $Res call(
      {String name,
      String version,
      int totalProblems,
      String source,
      String description,
      List<ProblemDTO> problems});
}

/// @nodoc
class _$DatasetCopyWithImpl<$Res, $Val extends Dataset>
    implements $DatasetCopyWith<$Res> {
  _$DatasetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? version = null,
    Object? totalProblems = null,
    Object? source = null,
    Object? description = null,
    Object? problems = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      totalProblems: null == totalProblems
          ? _value.totalProblems
          : totalProblems // ignore: cast_nullable_to_non_nullable
              as int,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      problems: null == problems
          ? _value.problems
          : problems // ignore: cast_nullable_to_non_nullable
              as List<ProblemDTO>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DatasetImplCopyWith<$Res> implements $DatasetCopyWith<$Res> {
  factory _$$DatasetImplCopyWith(
          _$DatasetImpl value, $Res Function(_$DatasetImpl) then) =
      __$$DatasetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String version,
      int totalProblems,
      String source,
      String description,
      List<ProblemDTO> problems});
}

/// @nodoc
class __$$DatasetImplCopyWithImpl<$Res>
    extends _$DatasetCopyWithImpl<$Res, _$DatasetImpl>
    implements _$$DatasetImplCopyWith<$Res> {
  __$$DatasetImplCopyWithImpl(
      _$DatasetImpl _value, $Res Function(_$DatasetImpl) _then)
      : super(_value, _then);

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? version = null,
    Object? totalProblems = null,
    Object? source = null,
    Object? description = null,
    Object? problems = null,
  }) {
    return _then(_$DatasetImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      totalProblems: null == totalProblems
          ? _value.totalProblems
          : totalProblems // ignore: cast_nullable_to_non_nullable
              as int,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      problems: null == problems
          ? _value._problems
          : problems // ignore: cast_nullable_to_non_nullable
              as List<ProblemDTO>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DatasetImpl implements _Dataset {
  const _$DatasetImpl(
      {required this.name,
      required this.version,
      required this.totalProblems,
      required this.source,
      required this.description,
      required final List<ProblemDTO> problems})
      : _problems = problems;

  factory _$DatasetImpl.fromJson(Map<String, dynamic> json) =>
      _$$DatasetImplFromJson(json);

  @override
  final String name;
  @override
  final String version;
  @override
  final int totalProblems;
  @override
  final String source;
  @override
  final String description;
  final List<ProblemDTO> _problems;
  @override
  List<ProblemDTO> get problems {
    if (_problems is EqualUnmodifiableListView) return _problems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_problems);
  }

  @override
  String toString() {
    return 'Dataset(name: $name, version: $version, totalProblems: $totalProblems, source: $source, description: $description, problems: $problems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DatasetImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.totalProblems, totalProblems) ||
                other.totalProblems == totalProblems) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._problems, _problems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, version, totalProblems,
      source, description, const DeepCollectionEquality().hash(_problems));

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DatasetImplCopyWith<_$DatasetImpl> get copyWith =>
      __$$DatasetImplCopyWithImpl<_$DatasetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DatasetImplToJson(
      this,
    );
  }
}

abstract class _Dataset implements Dataset {
  const factory _Dataset(
      {required final String name,
      required final String version,
      required final int totalProblems,
      required final String source,
      required final String description,
      required final List<ProblemDTO> problems}) = _$DatasetImpl;

  factory _Dataset.fromJson(Map<String, dynamic> json) = _$DatasetImpl.fromJson;

  @override
  String get name;
  @override
  String get version;
  @override
  int get totalProblems;
  @override
  String get source;
  @override
  String get description;
  @override
  List<ProblemDTO> get problems;

  /// Create a copy of Dataset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DatasetImplCopyWith<_$DatasetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
