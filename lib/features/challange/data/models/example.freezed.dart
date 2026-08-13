// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'example.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Example _$ExampleFromJson(Map<String, dynamic> json) {
  return _Example.fromJson(json);
}

/// @nodoc
mixin _$Example {
  Map<String, dynamic> get input => throw _privateConstructorUsedError;
  dynamic get output => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;

  /// Serializes this Example to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Example
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExampleCopyWith<Example> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExampleCopyWith<$Res> {
  factory $ExampleCopyWith(Example value, $Res Function(Example) then) =
      _$ExampleCopyWithImpl<$Res, Example>;
  @useResult
  $Res call({Map<String, dynamic> input, dynamic output, String explanation});
}

/// @nodoc
class _$ExampleCopyWithImpl<$Res, $Val extends Example>
    implements $ExampleCopyWith<$Res> {
  _$ExampleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Example
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? output = freezed,
    Object? explanation = null,
  }) {
    return _then(_value.copyWith(
      input: null == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      output: freezed == output
          ? _value.output
          : output // ignore: cast_nullable_to_non_nullable
              as dynamic,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExampleImplCopyWith<$Res> implements $ExampleCopyWith<$Res> {
  factory _$$ExampleImplCopyWith(
          _$ExampleImpl value, $Res Function(_$ExampleImpl) then) =
      __$$ExampleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, dynamic> input, dynamic output, String explanation});
}

/// @nodoc
class __$$ExampleImplCopyWithImpl<$Res>
    extends _$ExampleCopyWithImpl<$Res, _$ExampleImpl>
    implements _$$ExampleImplCopyWith<$Res> {
  __$$ExampleImplCopyWithImpl(
      _$ExampleImpl _value, $Res Function(_$ExampleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Example
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? output = freezed,
    Object? explanation = null,
  }) {
    return _then(_$ExampleImpl(
      input: null == input
          ? _value._input
          : input // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      output: freezed == output
          ? _value.output
          : output // ignore: cast_nullable_to_non_nullable
              as dynamic,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExampleImpl implements _Example {
  const _$ExampleImpl(
      {required final Map<String, dynamic> input,
      required this.output,
      required this.explanation})
      : _input = input;

  factory _$ExampleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExampleImplFromJson(json);

  final Map<String, dynamic> _input;
  @override
  Map<String, dynamic> get input {
    if (_input is EqualUnmodifiableMapView) return _input;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_input);
  }

  @override
  final dynamic output;
  @override
  final String explanation;

  @override
  String toString() {
    return 'Example(input: $input, output: $output, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExampleImpl &&
            const DeepCollectionEquality().equals(other._input, _input) &&
            const DeepCollectionEquality().equals(other.output, output) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_input),
      const DeepCollectionEquality().hash(output),
      explanation);

  /// Create a copy of Example
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExampleImplCopyWith<_$ExampleImpl> get copyWith =>
      __$$ExampleImplCopyWithImpl<_$ExampleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExampleImplToJson(
      this,
    );
  }
}

abstract class _Example implements Example {
  const factory _Example(
      {required final Map<String, dynamic> input,
      required final dynamic output,
      required final String explanation}) = _$ExampleImpl;

  factory _Example.fromJson(Map<String, dynamic> json) = _$ExampleImpl.fromJson;

  @override
  Map<String, dynamic> get input;
  @override
  dynamic get output;
  @override
  String get explanation;

  /// Create a copy of Example
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExampleImplCopyWith<_$ExampleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
