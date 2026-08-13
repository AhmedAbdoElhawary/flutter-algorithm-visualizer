// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'solution_approach.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SolutionApproach _$SolutionApproachFromJson(Map<String, dynamic> json) {
  return _SolutionApproach.fromJson(json);
}

/// @nodoc
mixin _$SolutionApproach {
  String get keyObservation => throw _privateConstructorUsedError;
  String get algorithm => throw _privateConstructorUsedError;
  String get whyItWorks => throw _privateConstructorUsedError;
  String get implementationNotes => throw _privateConstructorUsedError;

  /// Serializes this SolutionApproach to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SolutionApproach
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SolutionApproachCopyWith<SolutionApproach> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SolutionApproachCopyWith<$Res> {
  factory $SolutionApproachCopyWith(
          SolutionApproach value, $Res Function(SolutionApproach) then) =
      _$SolutionApproachCopyWithImpl<$Res, SolutionApproach>;
  @useResult
  $Res call(
      {String keyObservation,
      String algorithm,
      String whyItWorks,
      String implementationNotes});
}

/// @nodoc
class _$SolutionApproachCopyWithImpl<$Res, $Val extends SolutionApproach>
    implements $SolutionApproachCopyWith<$Res> {
  _$SolutionApproachCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SolutionApproach
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyObservation = null,
    Object? algorithm = null,
    Object? whyItWorks = null,
    Object? implementationNotes = null,
  }) {
    return _then(_value.copyWith(
      keyObservation: null == keyObservation
          ? _value.keyObservation
          : keyObservation // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      whyItWorks: null == whyItWorks
          ? _value.whyItWorks
          : whyItWorks // ignore: cast_nullable_to_non_nullable
              as String,
      implementationNotes: null == implementationNotes
          ? _value.implementationNotes
          : implementationNotes // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SolutionApproachImplCopyWith<$Res>
    implements $SolutionApproachCopyWith<$Res> {
  factory _$$SolutionApproachImplCopyWith(_$SolutionApproachImpl value,
          $Res Function(_$SolutionApproachImpl) then) =
      __$$SolutionApproachImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String keyObservation,
      String algorithm,
      String whyItWorks,
      String implementationNotes});
}

/// @nodoc
class __$$SolutionApproachImplCopyWithImpl<$Res>
    extends _$SolutionApproachCopyWithImpl<$Res, _$SolutionApproachImpl>
    implements _$$SolutionApproachImplCopyWith<$Res> {
  __$$SolutionApproachImplCopyWithImpl(_$SolutionApproachImpl _value,
      $Res Function(_$SolutionApproachImpl) _then)
      : super(_value, _then);

  /// Create a copy of SolutionApproach
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyObservation = null,
    Object? algorithm = null,
    Object? whyItWorks = null,
    Object? implementationNotes = null,
  }) {
    return _then(_$SolutionApproachImpl(
      keyObservation: null == keyObservation
          ? _value.keyObservation
          : keyObservation // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      whyItWorks: null == whyItWorks
          ? _value.whyItWorks
          : whyItWorks // ignore: cast_nullable_to_non_nullable
              as String,
      implementationNotes: null == implementationNotes
          ? _value.implementationNotes
          : implementationNotes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SolutionApproachImpl implements _SolutionApproach {
  const _$SolutionApproachImpl(
      {required this.keyObservation,
      required this.algorithm,
      required this.whyItWorks,
      required this.implementationNotes});

  factory _$SolutionApproachImpl.fromJson(Map<String, dynamic> json) =>
      _$$SolutionApproachImplFromJson(json);

  @override
  final String keyObservation;
  @override
  final String algorithm;
  @override
  final String whyItWorks;
  @override
  final String implementationNotes;

  @override
  String toString() {
    return 'SolutionApproach(keyObservation: $keyObservation, algorithm: $algorithm, whyItWorks: $whyItWorks, implementationNotes: $implementationNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SolutionApproachImpl &&
            (identical(other.keyObservation, keyObservation) ||
                other.keyObservation == keyObservation) &&
            (identical(other.algorithm, algorithm) ||
                other.algorithm == algorithm) &&
            (identical(other.whyItWorks, whyItWorks) ||
                other.whyItWorks == whyItWorks) &&
            (identical(other.implementationNotes, implementationNotes) ||
                other.implementationNotes == implementationNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, keyObservation, algorithm, whyItWorks, implementationNotes);

  /// Create a copy of SolutionApproach
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SolutionApproachImplCopyWith<_$SolutionApproachImpl> get copyWith =>
      __$$SolutionApproachImplCopyWithImpl<_$SolutionApproachImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SolutionApproachImplToJson(
      this,
    );
  }
}

abstract class _SolutionApproach implements SolutionApproach {
  const factory _SolutionApproach(
      {required final String keyObservation,
      required final String algorithm,
      required final String whyItWorks,
      required final String implementationNotes}) = _$SolutionApproachImpl;

  factory _SolutionApproach.fromJson(Map<String, dynamic> json) =
      _$SolutionApproachImpl.fromJson;

  @override
  String get keyObservation;
  @override
  String get algorithm;
  @override
  String get whyItWorks;
  @override
  String get implementationNotes;

  /// Create a copy of SolutionApproach
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SolutionApproachImplCopyWith<_$SolutionApproachImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
