// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'similar_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SimilarQuestion _$SimilarQuestionFromJson(Map<String, dynamic> json) {
  return _SimilarQuestion.fromJson(json);
}

/// @nodoc
mixin _$SimilarQuestion {
  int? get problemId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this SimilarQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimilarQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimilarQuestionCopyWith<SimilarQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimilarQuestionCopyWith<$Res> {
  factory $SimilarQuestionCopyWith(
          SimilarQuestion value, $Res Function(SimilarQuestion) then) =
      _$SimilarQuestionCopyWithImpl<$Res, SimilarQuestion>;
  @useResult
  $Res call({int? problemId, String? name, String? reason});
}

/// @nodoc
class _$SimilarQuestionCopyWithImpl<$Res, $Val extends SimilarQuestion>
    implements $SimilarQuestionCopyWith<$Res> {
  _$SimilarQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimilarQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemId = freezed,
    Object? name = freezed,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      problemId: freezed == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimilarQuestionImplCopyWith<$Res>
    implements $SimilarQuestionCopyWith<$Res> {
  factory _$$SimilarQuestionImplCopyWith(_$SimilarQuestionImpl value,
          $Res Function(_$SimilarQuestionImpl) then) =
      __$$SimilarQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? problemId, String? name, String? reason});
}

/// @nodoc
class __$$SimilarQuestionImplCopyWithImpl<$Res>
    extends _$SimilarQuestionCopyWithImpl<$Res, _$SimilarQuestionImpl>
    implements _$$SimilarQuestionImplCopyWith<$Res> {
  __$$SimilarQuestionImplCopyWithImpl(
      _$SimilarQuestionImpl _value, $Res Function(_$SimilarQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimilarQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemId = freezed,
    Object? name = freezed,
    Object? reason = freezed,
  }) {
    return _then(_$SimilarQuestionImpl(
      problemId: freezed == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimilarQuestionImpl implements _SimilarQuestion {
  const _$SimilarQuestionImpl(
      {required this.problemId, required this.name, required this.reason});

  factory _$SimilarQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimilarQuestionImplFromJson(json);

  @override
  final int? problemId;
  @override
  final String? name;
  @override
  final String? reason;

  @override
  String toString() {
    return 'SimilarQuestion(problemId: $problemId, name: $name, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimilarQuestionImpl &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, problemId, name, reason);

  /// Create a copy of SimilarQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimilarQuestionImplCopyWith<_$SimilarQuestionImpl> get copyWith =>
      __$$SimilarQuestionImplCopyWithImpl<_$SimilarQuestionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimilarQuestionImplToJson(
      this,
    );
  }
}

abstract class _SimilarQuestion implements SimilarQuestion {
  const factory _SimilarQuestion(
      {required final int? problemId,
      required final String? name,
      required final String? reason}) = _$SimilarQuestionImpl;

  factory _SimilarQuestion.fromJson(Map<String, dynamic> json) =
      _$SimilarQuestionImpl.fromJson;

  @override
  int? get problemId;
  @override
  String? get name;
  @override
  String? get reason;

  /// Create a copy of SimilarQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimilarQuestionImplCopyWith<_$SimilarQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
