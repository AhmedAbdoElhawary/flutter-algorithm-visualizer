// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'function_signature.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FunctionSignature _$FunctionSignatureFromJson(Map<String, dynamic> json) {
  return _FunctionSignature.fromJson(json);
}

/// @nodoc
mixin _$FunctionSignature {
  String get generic => throw _privateConstructorUsedError;
  String get dart => throw _privateConstructorUsedError;

  /// Serializes this FunctionSignature to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FunctionSignature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FunctionSignatureCopyWith<FunctionSignature> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FunctionSignatureCopyWith<$Res> {
  factory $FunctionSignatureCopyWith(
          FunctionSignature value, $Res Function(FunctionSignature) then) =
      _$FunctionSignatureCopyWithImpl<$Res, FunctionSignature>;
  @useResult
  $Res call({String generic, String dart});
}

/// @nodoc
class _$FunctionSignatureCopyWithImpl<$Res, $Val extends FunctionSignature>
    implements $FunctionSignatureCopyWith<$Res> {
  _$FunctionSignatureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FunctionSignature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generic = null,
    Object? dart = null,
  }) {
    return _then(_value.copyWith(
      generic: null == generic
          ? _value.generic
          : generic // ignore: cast_nullable_to_non_nullable
              as String,
      dart: null == dart
          ? _value.dart
          : dart // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FunctionSignatureImplCopyWith<$Res>
    implements $FunctionSignatureCopyWith<$Res> {
  factory _$$FunctionSignatureImplCopyWith(_$FunctionSignatureImpl value,
          $Res Function(_$FunctionSignatureImpl) then) =
      __$$FunctionSignatureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String generic, String dart});
}

/// @nodoc
class __$$FunctionSignatureImplCopyWithImpl<$Res>
    extends _$FunctionSignatureCopyWithImpl<$Res, _$FunctionSignatureImpl>
    implements _$$FunctionSignatureImplCopyWith<$Res> {
  __$$FunctionSignatureImplCopyWithImpl(_$FunctionSignatureImpl _value,
      $Res Function(_$FunctionSignatureImpl) _then)
      : super(_value, _then);

  /// Create a copy of FunctionSignature
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? generic = null,
    Object? dart = null,
  }) {
    return _then(_$FunctionSignatureImpl(
      generic: null == generic
          ? _value.generic
          : generic // ignore: cast_nullable_to_non_nullable
              as String,
      dart: null == dart
          ? _value.dart
          : dart // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FunctionSignatureImpl implements _FunctionSignature {
  const _$FunctionSignatureImpl({required this.generic, required this.dart});

  factory _$FunctionSignatureImpl.fromJson(Map<String, dynamic> json) =>
      _$$FunctionSignatureImplFromJson(json);

  @override
  final String generic;
  @override
  final String dart;

  @override
  String toString() {
    return 'FunctionSignature(generic: $generic, dart: $dart)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FunctionSignatureImpl &&
            (identical(other.generic, generic) || other.generic == generic) &&
            (identical(other.dart, dart) || other.dart == dart));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, generic, dart);

  /// Create a copy of FunctionSignature
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FunctionSignatureImplCopyWith<_$FunctionSignatureImpl> get copyWith =>
      __$$FunctionSignatureImplCopyWithImpl<_$FunctionSignatureImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FunctionSignatureImplToJson(
      this,
    );
  }
}

abstract class _FunctionSignature implements FunctionSignature {
  const factory _FunctionSignature(
      {required final String generic,
      required final String dart}) = _$FunctionSignatureImpl;

  factory _FunctionSignature.fromJson(Map<String, dynamic> json) =
      _$FunctionSignatureImpl.fromJson;

  @override
  String get generic;
  @override
  String get dart;

  /// Create a copy of FunctionSignature
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FunctionSignatureImplCopyWith<_$FunctionSignatureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
