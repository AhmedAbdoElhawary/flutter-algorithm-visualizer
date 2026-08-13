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
  String get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get input => throw _privateConstructorUsedError;
  dynamic get expectedOutput => throw _privateConstructorUsedError;

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
  $Res call({String type, Map<String, dynamic> input, dynamic expectedOutput});
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
    Object? type = null,
    Object? input = null,
    Object? expectedOutput = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      input: null == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as dynamic,
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
  $Res call({String type, Map<String, dynamic> input, dynamic expectedOutput});
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
    Object? type = null,
    Object? input = null,
    Object? expectedOutput = freezed,
  }) {
    return _then(_$TestCaseImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      input: null == input
          ? _value._input
          : input // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      expectedOutput: freezed == expectedOutput
          ? _value.expectedOutput
          : expectedOutput // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TestCaseImpl implements _TestCase {
  const _$TestCaseImpl(
      {required this.type,
      required final Map<String, dynamic> input,
      required this.expectedOutput})
      : _input = input;

  factory _$TestCaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TestCaseImplFromJson(json);

  @override
  final String type;
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
  String toString() {
    return 'TestCase(type: $type, input: $input, expectedOutput: $expectedOutput)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestCaseImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._input, _input) &&
            const DeepCollectionEquality()
                .equals(other.expectedOutput, expectedOutput));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      const DeepCollectionEquality().hash(_input),
      const DeepCollectionEquality().hash(expectedOutput));

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
      {required final String type,
      required final Map<String, dynamic> input,
      required final dynamic expectedOutput}) = _$TestCaseImpl;

  factory _TestCase.fromJson(Map<String, dynamic> json) =
      _$TestCaseImpl.fromJson;

  @override
  String get type;
  @override
  Map<String, dynamic> get input;
  @override
  dynamic get expectedOutput;

  /// Create a copy of TestCase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestCaseImplCopyWith<_$TestCaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
