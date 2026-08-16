// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem_storage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProblemStorageDTO _$ProblemStorageDTOFromJson(Map<String, dynamic> json) {
  return _ProblemStorageDTO.fromJson(json);
}

/// @nodoc
mixin _$ProblemStorageDTO {
  int? get problemId => throw _privateConstructorUsedError;
  ProblemStatus? get problemStatus => throw _privateConstructorUsedError;
  bool? get isBookmarked => throw _privateConstructorUsedError;
  List<ProblemSolutionStatusDTO>? get solutionsStatus =>
      throw _privateConstructorUsedError;

  /// Serializes this ProblemStorageDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProblemStorageDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProblemStorageDTOCopyWith<ProblemStorageDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProblemStorageDTOCopyWith<$Res> {
  factory $ProblemStorageDTOCopyWith(
          ProblemStorageDTO value, $Res Function(ProblemStorageDTO) then) =
      _$ProblemStorageDTOCopyWithImpl<$Res, ProblemStorageDTO>;
  @useResult
  $Res call(
      {int? problemId,
      ProblemStatus? problemStatus,
      bool? isBookmarked,
      List<ProblemSolutionStatusDTO>? solutionsStatus});
}

/// @nodoc
class _$ProblemStorageDTOCopyWithImpl<$Res, $Val extends ProblemStorageDTO>
    implements $ProblemStorageDTOCopyWith<$Res> {
  _$ProblemStorageDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProblemStorageDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemId = freezed,
    Object? problemStatus = freezed,
    Object? isBookmarked = freezed,
    Object? solutionsStatus = freezed,
  }) {
    return _then(_value.copyWith(
      problemId: freezed == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int?,
      problemStatus: freezed == problemStatus
          ? _value.problemStatus
          : problemStatus // ignore: cast_nullable_to_non_nullable
              as ProblemStatus?,
      isBookmarked: freezed == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool?,
      solutionsStatus: freezed == solutionsStatus
          ? _value.solutionsStatus
          : solutionsStatus // ignore: cast_nullable_to_non_nullable
              as List<ProblemSolutionStatusDTO>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProblemStorageDTOImplCopyWith<$Res>
    implements $ProblemStorageDTOCopyWith<$Res> {
  factory _$$ProblemStorageDTOImplCopyWith(_$ProblemStorageDTOImpl value,
          $Res Function(_$ProblemStorageDTOImpl) then) =
      __$$ProblemStorageDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? problemId,
      ProblemStatus? problemStatus,
      bool? isBookmarked,
      List<ProblemSolutionStatusDTO>? solutionsStatus});
}

/// @nodoc
class __$$ProblemStorageDTOImplCopyWithImpl<$Res>
    extends _$ProblemStorageDTOCopyWithImpl<$Res, _$ProblemStorageDTOImpl>
    implements _$$ProblemStorageDTOImplCopyWith<$Res> {
  __$$ProblemStorageDTOImplCopyWithImpl(_$ProblemStorageDTOImpl _value,
      $Res Function(_$ProblemStorageDTOImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProblemStorageDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemId = freezed,
    Object? problemStatus = freezed,
    Object? isBookmarked = freezed,
    Object? solutionsStatus = freezed,
  }) {
    return _then(_$ProblemStorageDTOImpl(
      problemId: freezed == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int?,
      problemStatus: freezed == problemStatus
          ? _value.problemStatus
          : problemStatus // ignore: cast_nullable_to_non_nullable
              as ProblemStatus?,
      isBookmarked: freezed == isBookmarked
          ? _value.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool?,
      solutionsStatus: freezed == solutionsStatus
          ? _value._solutionsStatus
          : solutionsStatus // ignore: cast_nullable_to_non_nullable
              as List<ProblemSolutionStatusDTO>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProblemStorageDTOImpl implements _ProblemStorageDTO {
  const _$ProblemStorageDTOImpl(
      {required this.problemId,
      required this.problemStatus,
      required this.isBookmarked,
      required final List<ProblemSolutionStatusDTO>? solutionsStatus})
      : _solutionsStatus = solutionsStatus;

  factory _$ProblemStorageDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProblemStorageDTOImplFromJson(json);

  @override
  final int? problemId;
  @override
  final ProblemStatus? problemStatus;
  @override
  final bool? isBookmarked;
  final List<ProblemSolutionStatusDTO>? _solutionsStatus;
  @override
  List<ProblemSolutionStatusDTO>? get solutionsStatus {
    final value = _solutionsStatus;
    if (value == null) return null;
    if (_solutionsStatus is EqualUnmodifiableListView) return _solutionsStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ProblemStorageDTO(problemId: $problemId, problemStatus: $problemStatus, isBookmarked: $isBookmarked, solutionsStatus: $solutionsStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProblemStorageDTOImpl &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId) &&
            (identical(other.problemStatus, problemStatus) ||
                other.problemStatus == problemStatus) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            const DeepCollectionEquality()
                .equals(other._solutionsStatus, _solutionsStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, problemId, problemStatus,
      isBookmarked, const DeepCollectionEquality().hash(_solutionsStatus));

  /// Create a copy of ProblemStorageDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProblemStorageDTOImplCopyWith<_$ProblemStorageDTOImpl> get copyWith =>
      __$$ProblemStorageDTOImplCopyWithImpl<_$ProblemStorageDTOImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProblemStorageDTOImplToJson(
      this,
    );
  }
}

abstract class _ProblemStorageDTO implements ProblemStorageDTO {
  const factory _ProblemStorageDTO(
          {required final int? problemId,
          required final ProblemStatus? problemStatus,
          required final bool? isBookmarked,
          required final List<ProblemSolutionStatusDTO>? solutionsStatus}) =
      _$ProblemStorageDTOImpl;

  factory _ProblemStorageDTO.fromJson(Map<String, dynamic> json) =
      _$ProblemStorageDTOImpl.fromJson;

  @override
  int? get problemId;
  @override
  ProblemStatus? get problemStatus;
  @override
  bool? get isBookmarked;
  @override
  List<ProblemSolutionStatusDTO>? get solutionsStatus;

  /// Create a copy of ProblemStorageDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProblemStorageDTOImplCopyWith<_$ProblemStorageDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProblemSolutionStatusDTO _$ProblemSolutionStatusDTOFromJson(
    Map<String, dynamic> json) {
  return _ProblemSolutionStatusDTO.fromJson(json);
}

/// @nodoc
mixin _$ProblemSolutionStatusDTO {
  String? get code => throw _privateConstructorUsedError;
  List<TestCaseResult>? get allTestCaseResults =>
      throw _privateConstructorUsedError;
  bool? get isCorrect => throw _privateConstructorUsedError;

  /// Serializes this ProblemSolutionStatusDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProblemSolutionStatusDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProblemSolutionStatusDTOCopyWith<ProblemSolutionStatusDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProblemSolutionStatusDTOCopyWith<$Res> {
  factory $ProblemSolutionStatusDTOCopyWith(ProblemSolutionStatusDTO value,
          $Res Function(ProblemSolutionStatusDTO) then) =
      _$ProblemSolutionStatusDTOCopyWithImpl<$Res, ProblemSolutionStatusDTO>;
  @useResult
  $Res call(
      {String? code,
      List<TestCaseResult>? allTestCaseResults,
      bool? isCorrect});
}

/// @nodoc
class _$ProblemSolutionStatusDTOCopyWithImpl<$Res,
        $Val extends ProblemSolutionStatusDTO>
    implements $ProblemSolutionStatusDTOCopyWith<$Res> {
  _$ProblemSolutionStatusDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProblemSolutionStatusDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? allTestCaseResults = freezed,
    Object? isCorrect = freezed,
  }) {
    return _then(_value.copyWith(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      allTestCaseResults: freezed == allTestCaseResults
          ? _value.allTestCaseResults
          : allTestCaseResults // ignore: cast_nullable_to_non_nullable
              as List<TestCaseResult>?,
      isCorrect: freezed == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProblemSolutionStatusDTOImplCopyWith<$Res>
    implements $ProblemSolutionStatusDTOCopyWith<$Res> {
  factory _$$ProblemSolutionStatusDTOImplCopyWith(
          _$ProblemSolutionStatusDTOImpl value,
          $Res Function(_$ProblemSolutionStatusDTOImpl) then) =
      __$$ProblemSolutionStatusDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? code,
      List<TestCaseResult>? allTestCaseResults,
      bool? isCorrect});
}

/// @nodoc
class __$$ProblemSolutionStatusDTOImplCopyWithImpl<$Res>
    extends _$ProblemSolutionStatusDTOCopyWithImpl<$Res,
        _$ProblemSolutionStatusDTOImpl>
    implements _$$ProblemSolutionStatusDTOImplCopyWith<$Res> {
  __$$ProblemSolutionStatusDTOImplCopyWithImpl(
      _$ProblemSolutionStatusDTOImpl _value,
      $Res Function(_$ProblemSolutionStatusDTOImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProblemSolutionStatusDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = freezed,
    Object? allTestCaseResults = freezed,
    Object? isCorrect = freezed,
  }) {
    return _then(_$ProblemSolutionStatusDTOImpl(
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      allTestCaseResults: freezed == allTestCaseResults
          ? _value._allTestCaseResults
          : allTestCaseResults // ignore: cast_nullable_to_non_nullable
              as List<TestCaseResult>?,
      isCorrect: freezed == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProblemSolutionStatusDTOImpl implements _ProblemSolutionStatusDTO {
  const _$ProblemSolutionStatusDTOImpl(
      {required this.code,
      required final List<TestCaseResult>? allTestCaseResults,
      required this.isCorrect})
      : _allTestCaseResults = allTestCaseResults;

  factory _$ProblemSolutionStatusDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProblemSolutionStatusDTOImplFromJson(json);

  @override
  final String? code;
  final List<TestCaseResult>? _allTestCaseResults;
  @override
  List<TestCaseResult>? get allTestCaseResults {
    final value = _allTestCaseResults;
    if (value == null) return null;
    if (_allTestCaseResults is EqualUnmodifiableListView)
      return _allTestCaseResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isCorrect;

  @override
  String toString() {
    return 'ProblemSolutionStatusDTO(code: $code, allTestCaseResults: $allTestCaseResults, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProblemSolutionStatusDTOImpl &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality()
                .equals(other._allTestCaseResults, _allTestCaseResults) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code,
      const DeepCollectionEquality().hash(_allTestCaseResults), isCorrect);

  /// Create a copy of ProblemSolutionStatusDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProblemSolutionStatusDTOImplCopyWith<_$ProblemSolutionStatusDTOImpl>
      get copyWith => __$$ProblemSolutionStatusDTOImplCopyWithImpl<
          _$ProblemSolutionStatusDTOImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProblemSolutionStatusDTOImplToJson(
      this,
    );
  }
}

abstract class _ProblemSolutionStatusDTO implements ProblemSolutionStatusDTO {
  const factory _ProblemSolutionStatusDTO(
      {required final String? code,
      required final List<TestCaseResult>? allTestCaseResults,
      required final bool? isCorrect}) = _$ProblemSolutionStatusDTOImpl;

  factory _ProblemSolutionStatusDTO.fromJson(Map<String, dynamic> json) =
      _$ProblemSolutionStatusDTOImpl.fromJson;

  @override
  String? get code;
  @override
  List<TestCaseResult>? get allTestCaseResults;
  @override
  bool? get isCorrect;

  /// Create a copy of ProblemSolutionStatusDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProblemSolutionStatusDTOImplCopyWith<_$ProblemSolutionStatusDTOImpl>
      get copyWith => throw _privateConstructorUsedError;
}
