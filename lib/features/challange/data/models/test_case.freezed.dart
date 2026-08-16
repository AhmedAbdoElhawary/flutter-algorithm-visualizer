// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TestCase _$TestCaseFromJson(Map<String, dynamic> json) {
  return _TestCase.fromJson(json);
}

/// @nodoc
mixin _$TestCase {
  String? get input => throw _privateConstructorUsedError;
  String? get expectedOutput => throw _privateConstructorUsedError;

  /// Serializes this TestCase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestCase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestCaseCopyWith<TestCase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestCaseCopyWith<$Res> {
  factory $TestCaseCopyWith(TestCase value, $Res Function(TestCase) then) =
      _$TestCaseCopyWithImpl<$Res, TestCase>;
  @useResult
  $Res call({String? input, String? expectedOutput});
}

/// @nodoc
class _$TestCaseCopyWithImpl<$Res, $Val extends TestCase>
    implements $TestCaseCopyWith<$Res> {
  _$TestCaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestCase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = freezed,
    Object? expectedOutput = freezed,
  }) {
    return _then(_value.copyWith(
      input: freezed == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestCaseImplCopyWith<$Res>
    implements $TestCaseCopyWith<$Res> {
  factory _$$TestCaseImplCopyWith(
          _$TestCaseImpl value, $Res Function(_$TestCaseImpl) then) =
      __$$TestCaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? input, String? expectedOutput});
}

/// @nodoc
class __$$TestCaseImplCopyWithImpl<$Res>
    extends _$TestCaseCopyWithImpl<$Res, _$TestCaseImpl>
    implements _$$TestCaseImplCopyWith<$Res> {
  __$$TestCaseImplCopyWithImpl(
      _$TestCaseImpl _value, $Res Function(_$TestCaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestCase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = freezed,
    Object? expectedOutput = freezed,
  }) {
    return _then(_$TestCaseImpl(
      input: freezed == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TestCaseImpl implements _TestCase {
  const _$TestCaseImpl({required this.input, required this.expectedOutput});

  factory _$TestCaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestCaseImplFromJson(json);

  @override
  final String? input;
  @override
  final String? expectedOutput;

  @override
  String toString() {
    return 'TestCase(input: $input, expectedOutput: $expectedOutput)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestCaseImpl &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.expectedOutput, expectedOutput) ||
                other.expectedOutput == expectedOutput));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, input, expectedOutput);

  /// Create a copy of TestCase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestCaseImplCopyWith<_$TestCaseImpl> get copyWith =>
      __$$TestCaseImplCopyWithImpl<_$TestCaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TestCaseImplToJson(
      this,
    );
  }
}

abstract class _TestCase implements TestCase {
  const factory _TestCase(
      {required final String? input,
      required final String? expectedOutput}) = _$TestCaseImpl;

  factory _TestCase.fromJson(Map<String, dynamic> json) =
      _$TestCaseImpl.fromJson;

  @override
  String? get input;
  @override
  String? get expectedOutput;

  /// Create a copy of TestCase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestCaseImplCopyWith<_$TestCaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TestCaseResult _$TestCaseResultFromJson(Map<String, dynamic> json) {
  return _SingleTestCaseResult.fromJson(json);
}

/// @nodoc
mixin _$TestCaseResult {
  /// The raw `input` string straight from the JSON, e.g. `nums=[2,7,11,15], target=9`.
  String? get input => throw _privateConstructorUsedError;
  String? get expectedOutput => throw _privateConstructorUsedError;
  String get actualOutput => throw _privateConstructorUsedError;
  bool get passed => throw _privateConstructorUsedError;

  /// Set when this single run failed to parse/execute (not when the output
  /// simply didn't match). Null on a clean run.
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this TestCaseResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TestCaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestCaseResultCopyWith<TestCaseResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestCaseResultCopyWith<$Res> {
  factory $TestCaseResultCopyWith(
          TestCaseResult value, $Res Function(TestCaseResult) then) =
      _$TestCaseResultCopyWithImpl<$Res, TestCaseResult>;
  @useResult
  $Res call(
      {String? input,
      String? expectedOutput,
      String actualOutput,
      bool passed,
      String? errorMessage});
}

/// @nodoc
class _$TestCaseResultCopyWithImpl<$Res, $Val extends TestCaseResult>
    implements $TestCaseResultCopyWith<$Res> {
  _$TestCaseResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestCaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = freezed,
    Object? expectedOutput = freezed,
    Object? actualOutput = null,
    Object? passed = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      input: freezed == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as String?,
      actualOutput: null == actualOutput
          ? _value.actualOutput
          : actualOutput // ignore: cast_nullable_to_non_nullable
              as String,
      passed: null == passed
          ? _value.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SingleTestCaseResultImplCopyWith<$Res>
    implements $TestCaseResultCopyWith<$Res> {
  factory _$$SingleTestCaseResultImplCopyWith(_$SingleTestCaseResultImpl value,
          $Res Function(_$SingleTestCaseResultImpl) then) =
      __$$SingleTestCaseResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? input,
      String? expectedOutput,
      String actualOutput,
      bool passed,
      String? errorMessage});
}

/// @nodoc
class __$$SingleTestCaseResultImplCopyWithImpl<$Res>
    extends _$TestCaseResultCopyWithImpl<$Res, _$SingleTestCaseResultImpl>
    implements _$$SingleTestCaseResultImplCopyWith<$Res> {
  __$$SingleTestCaseResultImplCopyWithImpl(_$SingleTestCaseResultImpl _value,
      $Res Function(_$SingleTestCaseResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestCaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = freezed,
    Object? expectedOutput = freezed,
    Object? actualOutput = null,
    Object? passed = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$SingleTestCaseResultImpl(
      input: freezed == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as String?,
      actualOutput: null == actualOutput
          ? _value.actualOutput
          : actualOutput // ignore: cast_nullable_to_non_nullable
              as String,
      passed: null == passed
          ? _value.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SingleTestCaseResultImpl implements _SingleTestCaseResult {
  const _$SingleTestCaseResultImpl(
      {required this.input,
      required this.expectedOutput,
      required this.actualOutput,
      required this.passed,
      this.errorMessage});

  factory _$SingleTestCaseResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SingleTestCaseResultImplFromJson(json);

  /// The raw `input` string straight from the JSON, e.g. `nums=[2,7,11,15], target=9`.
  @override
  final String? input;
  @override
  final String? expectedOutput;
  @override
  final String actualOutput;
  @override
  final bool passed;

  /// Set when this single run failed to parse/execute (not when the output
  /// simply didn't match). Null on a clean run.
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'TestCaseResult(input: $input, expectedOutput: $expectedOutput, actualOutput: $actualOutput, passed: $passed, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SingleTestCaseResultImpl &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.expectedOutput, expectedOutput) ||
                other.expectedOutput == expectedOutput) &&
            (identical(other.actualOutput, actualOutput) ||
                other.actualOutput == actualOutput) &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, input, expectedOutput, actualOutput, passed, errorMessage);

  /// Create a copy of TestCaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SingleTestCaseResultImplCopyWith<_$SingleTestCaseResultImpl>
      get copyWith =>
          __$$SingleTestCaseResultImplCopyWithImpl<_$SingleTestCaseResultImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SingleTestCaseResultImplToJson(
      this,
    );
  }
}

abstract class _SingleTestCaseResult implements TestCaseResult {
  const factory _SingleTestCaseResult(
      {required final String? input,
      required final String? expectedOutput,
      required final String actualOutput,
      required final bool passed,
      final String? errorMessage}) = _$SingleTestCaseResultImpl;

  factory _SingleTestCaseResult.fromJson(Map<String, dynamic> json) =
      _$SingleTestCaseResultImpl.fromJson;

  /// The raw `input` string straight from the JSON, e.g. `nums=[2,7,11,15], target=9`.
  @override
  String? get input;
  @override
  String? get expectedOutput;
  @override
  String get actualOutput;
  @override
  bool get passed;

  /// Set when this single run failed to parse/execute (not when the output
  /// simply didn't match). Null on a clean run.
  @override
  String? get errorMessage;

  /// Create a copy of TestCaseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SingleTestCaseResultImplCopyWith<_$SingleTestCaseResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
