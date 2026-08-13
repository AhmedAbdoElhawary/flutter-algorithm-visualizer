// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hidden_test_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HiddenTestCase _$HiddenTestCaseFromJson(Map<String, dynamic> json) {
  return _HiddenTestCase.fromJson(json);
}

/// @nodoc
mixin _$HiddenTestCase {
  Map<String, dynamic> get input => throw _privateConstructorUsedError;
  dynamic get expectedOutput => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  /// Serializes this HiddenTestCase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HiddenTestCase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HiddenTestCaseCopyWith<HiddenTestCase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HiddenTestCaseCopyWith<$Res> {
  factory $HiddenTestCaseCopyWith(
          HiddenTestCase value, $Res Function(HiddenTestCase) then) =
      _$HiddenTestCaseCopyWithImpl<$Res, HiddenTestCase>;
  @useResult
  $Res call(
      {Map<String, dynamic> input, dynamic expectedOutput, String reason});
}

/// @nodoc
class _$HiddenTestCaseCopyWithImpl<$Res, $Val extends HiddenTestCase>
    implements $HiddenTestCaseCopyWith<$Res> {
  _$HiddenTestCaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HiddenTestCase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? expectedOutput = freezed,
    Object? reason = null,
  }) {
    return _then(_value.copyWith(
      input: null == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as dynamic,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HiddenTestCaseImplCopyWith<$Res>
    implements $HiddenTestCaseCopyWith<$Res> {
  factory _$$HiddenTestCaseImplCopyWith(_$HiddenTestCaseImpl value,
          $Res Function(_$HiddenTestCaseImpl) then) =
      __$$HiddenTestCaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, dynamic> input, dynamic expectedOutput, String reason});
}

/// @nodoc
class __$$HiddenTestCaseImplCopyWithImpl<$Res>
    extends _$HiddenTestCaseCopyWithImpl<$Res, _$HiddenTestCaseImpl>
    implements _$$HiddenTestCaseImplCopyWith<$Res> {
  __$$HiddenTestCaseImplCopyWithImpl(
      _$HiddenTestCaseImpl _value, $Res Function(_$HiddenTestCaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of HiddenTestCase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? expectedOutput = freezed,
    Object? reason = null,
  }) {
    return _then(_$HiddenTestCaseImpl(
      input: null == input
          ? _value._input
          : input // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as dynamic,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HiddenTestCaseImpl implements _HiddenTestCase {
  const _$HiddenTestCaseImpl(
      {required final Map<String, dynamic> input,
      required this.expectedOutput,
      required this.reason})
      : _input = input;

  factory _$HiddenTestCaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$HiddenTestCaseImplFromJson(json);

  final Map<String, dynamic> _input;
  @override
  Map<String, dynamic> get input {
    if (_input is EqualUnmodifiableMapView) return _input;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_input);
  }

  @override
  final dynamic expectedOutput;
  @override
  final String reason;

  @override
  String toString() {
    return 'HiddenTestCase(input: $input, expectedOutput: $expectedOutput, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HiddenTestCaseImpl &&
            const DeepCollectionEquality().equals(other._input, _input) &&
            const DeepCollectionEquality()
                .equals(other.expectedOutput, expectedOutput) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_input),
      const DeepCollectionEquality().hash(expectedOutput),
      reason);

  /// Create a copy of HiddenTestCase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HiddenTestCaseImplCopyWith<_$HiddenTestCaseImpl> get copyWith =>
      __$$HiddenTestCaseImplCopyWithImpl<_$HiddenTestCaseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HiddenTestCaseImplToJson(
      this,
    );
  }
}

abstract class _HiddenTestCase implements HiddenTestCase {
  const factory _HiddenTestCase(
      {required final Map<String, dynamic> input,
      required final dynamic expectedOutput,
      required final String reason}) = _$HiddenTestCaseImpl;

  factory _HiddenTestCase.fromJson(Map<String, dynamic> json) =
      _$HiddenTestCaseImpl.fromJson;

  @override
  Map<String, dynamic> get input;
  @override
  dynamic get expectedOutput;
  @override
  String get reason;

  /// Create a copy of HiddenTestCase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HiddenTestCaseImplCopyWith<_$HiddenTestCaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
