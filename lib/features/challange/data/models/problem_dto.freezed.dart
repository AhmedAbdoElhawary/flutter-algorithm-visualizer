// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'problem_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProblemDTO _$ProblemDTOFromJson(Map<String, dynamic> json) {
  return _ProblemDTO.fromJson(json);
}

/// @nodoc
mixin _$ProblemDTO {
  int? get problemId => throw _privateConstructorUsedError;
  int? get number => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  int? get sourceProblemNumber => throw _privateConstructorUsedError;
  ProblemDifficulty? get difficulty => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  List<String>? get patterns => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String>? get constraints => throw _privateConstructorUsedError;
  FunctionSignature? get functionSignature =>
      throw _privateConstructorUsedError;
  Map<String, String>? get defaultCode => throw _privateConstructorUsedError;
  Map<String, List<CustomObject>>? get customObjects =>
      throw _privateConstructorUsedError;
  List<Example>? get examples => throw _privateConstructorUsedError;
  List<String>? get edgeCases => throw _privateConstructorUsedError;
  List<TestCase>? get testCases => throw _privateConstructorUsedError;
  List<TestCase>? get hiddenTestCases => throw _privateConstructorUsedError;
  List<String>? get hints => throw _privateConstructorUsedError;
  SolutionApproach? get solutionApproach => throw _privateConstructorUsedError;
  String? get expectedTimeComplexity => throw _privateConstructorUsedError;
  String? get expectedSpaceComplexity => throw _privateConstructorUsedError;
  String? get whatYouLearn => throw _privateConstructorUsedError;
  String? get keyPattern => throw _privateConstructorUsedError;
  List<String>? get prerequisites => throw _privateConstructorUsedError;
  List<String>? get followUpConcepts => throw _privateConstructorUsedError;
  List<String>? get commonMistakes => throw _privateConstructorUsedError;
  List<SimilarQuestion>? get similarQuestions =>
      throw _privateConstructorUsedError;

  /// Serializes this ProblemDTO to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProblemDTOCopyWith<ProblemDTO> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProblemDTOCopyWith<$Res> {
  factory $ProblemDTOCopyWith(
          ProblemDTO value, $Res Function(ProblemDTO) then) =
      _$ProblemDTOCopyWithImpl<$Res, ProblemDTO>;
  @useResult
  $Res call(
      {int? problemId,
      int? number,
      String? name,
      String? source,
      int? sourceProblemNumber,
      ProblemDifficulty? difficulty,
      String? category,
      List<String>? tags,
      List<String>? patterns,
      String? description,
      List<String>? constraints,
      FunctionSignature? functionSignature,
      Map<String, String>? defaultCode,
      Map<String, List<CustomObject>>? customObjects,
      List<Example>? examples,
      List<String>? edgeCases,
      List<TestCase>? testCases,
      List<TestCase>? hiddenTestCases,
      List<String>? hints,
      SolutionApproach? solutionApproach,
      String? expectedTimeComplexity,
      String? expectedSpaceComplexity,
      String? whatYouLearn,
      String? keyPattern,
      List<String>? prerequisites,
      List<String>? followUpConcepts,
      List<String>? commonMistakes,
      List<SimilarQuestion>? similarQuestions});

  $FunctionSignatureCopyWith<$Res>? get functionSignature;
  $SolutionApproachCopyWith<$Res>? get solutionApproach;
}

/// @nodoc
class _$ProblemDTOCopyWithImpl<$Res, $Val extends ProblemDTO>
    implements $ProblemDTOCopyWith<$Res> {
  _$ProblemDTOCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemId = freezed,
    Object? number = freezed,
    Object? name = freezed,
    Object? source = freezed,
    Object? sourceProblemNumber = freezed,
    Object? difficulty = freezed,
    Object? category = freezed,
    Object? tags = freezed,
    Object? patterns = freezed,
    Object? description = freezed,
    Object? constraints = freezed,
    Object? functionSignature = freezed,
    Object? defaultCode = freezed,
    Object? customObjects = freezed,
    Object? examples = freezed,
    Object? edgeCases = freezed,
    Object? testCases = freezed,
    Object? hiddenTestCases = freezed,
    Object? hints = freezed,
    Object? solutionApproach = freezed,
    Object? expectedTimeComplexity = freezed,
    Object? expectedSpaceComplexity = freezed,
    Object? whatYouLearn = freezed,
    Object? keyPattern = freezed,
    Object? prerequisites = freezed,
    Object? followUpConcepts = freezed,
    Object? commonMistakes = freezed,
    Object? similarQuestions = freezed,
  }) {
    return _then(_value.copyWith(
      problemId: freezed == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int?,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceProblemNumber: freezed == sourceProblemNumber
          ? _value.sourceProblemNumber
          : sourceProblemNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ProblemDifficulty?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      patterns: freezed == patterns
          ? _value.patterns
          : patterns // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      constraints: freezed == constraints
          ? _value.constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      functionSignature: freezed == functionSignature
          ? _value.functionSignature
          : functionSignature // ignore: cast_nullable_to_non_nullable
              as FunctionSignature?,
      defaultCode: freezed == defaultCode
          ? _value.defaultCode
          : defaultCode // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      customObjects: freezed == customObjects
          ? _value.customObjects
          : customObjects // ignore: cast_nullable_to_non_nullable
              as Map<String, List<CustomObject>>?,
      examples: freezed == examples
          ? _value.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<Example>?,
      edgeCases: freezed == edgeCases
          ? _value.edgeCases
          : edgeCases // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      testCases: freezed == testCases
          ? _value.testCases
          : testCases // ignore: cast_nullable_to_non_nullable
              as List<TestCase>?,
      hiddenTestCases: freezed == hiddenTestCases
          ? _value.hiddenTestCases
          : hiddenTestCases // ignore: cast_nullable_to_non_nullable
              as List<TestCase>?,
      hints: freezed == hints
          ? _value.hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      solutionApproach: freezed == solutionApproach
          ? _value.solutionApproach
          : solutionApproach // ignore: cast_nullable_to_non_nullable
              as SolutionApproach?,
      expectedTimeComplexity: freezed == expectedTimeComplexity
          ? _value.expectedTimeComplexity
          : expectedTimeComplexity // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedSpaceComplexity: freezed == expectedSpaceComplexity
          ? _value.expectedSpaceComplexity
          : expectedSpaceComplexity // ignore: cast_nullable_to_non_nullable
              as String?,
      whatYouLearn: freezed == whatYouLearn
          ? _value.whatYouLearn
          : whatYouLearn // ignore: cast_nullable_to_non_nullable
              as String?,
      keyPattern: freezed == keyPattern
          ? _value.keyPattern
          : keyPattern // ignore: cast_nullable_to_non_nullable
              as String?,
      prerequisites: freezed == prerequisites
          ? _value.prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      followUpConcepts: freezed == followUpConcepts
          ? _value.followUpConcepts
          : followUpConcepts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      commonMistakes: freezed == commonMistakes
          ? _value.commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      similarQuestions: freezed == similarQuestions
          ? _value.similarQuestions
          : similarQuestions // ignore: cast_nullable_to_non_nullable
              as List<SimilarQuestion>?,
    ) as $Val);
  }

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FunctionSignatureCopyWith<$Res>? get functionSignature {
    if (_value.functionSignature == null) {
      return null;
    }

    return $FunctionSignatureCopyWith<$Res>(_value.functionSignature!, (value) {
      return _then(_value.copyWith(functionSignature: value) as $Val);
    });
  }

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SolutionApproachCopyWith<$Res>? get solutionApproach {
    if (_value.solutionApproach == null) {
      return null;
    }

    return $SolutionApproachCopyWith<$Res>(_value.solutionApproach!, (value) {
      return _then(_value.copyWith(solutionApproach: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProblemDTOImplCopyWith<$Res>
    implements $ProblemDTOCopyWith<$Res> {
  factory _$$ProblemDTOImplCopyWith(
          _$ProblemDTOImpl value, $Res Function(_$ProblemDTOImpl) then) =
      __$$ProblemDTOImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? problemId,
      int? number,
      String? name,
      String? source,
      int? sourceProblemNumber,
      ProblemDifficulty? difficulty,
      String? category,
      List<String>? tags,
      List<String>? patterns,
      String? description,
      List<String>? constraints,
      FunctionSignature? functionSignature,
      Map<String, String>? defaultCode,
      Map<String, List<CustomObject>>? customObjects,
      List<Example>? examples,
      List<String>? edgeCases,
      List<TestCase>? testCases,
      List<TestCase>? hiddenTestCases,
      List<String>? hints,
      SolutionApproach? solutionApproach,
      String? expectedTimeComplexity,
      String? expectedSpaceComplexity,
      String? whatYouLearn,
      String? keyPattern,
      List<String>? prerequisites,
      List<String>? followUpConcepts,
      List<String>? commonMistakes,
      List<SimilarQuestion>? similarQuestions});

  @override
  $FunctionSignatureCopyWith<$Res>? get functionSignature;
  @override
  $SolutionApproachCopyWith<$Res>? get solutionApproach;
}

/// @nodoc
class __$$ProblemDTOImplCopyWithImpl<$Res>
    extends _$ProblemDTOCopyWithImpl<$Res, _$ProblemDTOImpl>
    implements _$$ProblemDTOImplCopyWith<$Res> {
  __$$ProblemDTOImplCopyWithImpl(
      _$ProblemDTOImpl _value, $Res Function(_$ProblemDTOImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemId = freezed,
    Object? number = freezed,
    Object? name = freezed,
    Object? source = freezed,
    Object? sourceProblemNumber = freezed,
    Object? difficulty = freezed,
    Object? category = freezed,
    Object? tags = freezed,
    Object? patterns = freezed,
    Object? description = freezed,
    Object? constraints = freezed,
    Object? functionSignature = freezed,
    Object? defaultCode = freezed,
    Object? customObjects = freezed,
    Object? examples = freezed,
    Object? edgeCases = freezed,
    Object? testCases = freezed,
    Object? hiddenTestCases = freezed,
    Object? hints = freezed,
    Object? solutionApproach = freezed,
    Object? expectedTimeComplexity = freezed,
    Object? expectedSpaceComplexity = freezed,
    Object? whatYouLearn = freezed,
    Object? keyPattern = freezed,
    Object? prerequisites = freezed,
    Object? followUpConcepts = freezed,
    Object? commonMistakes = freezed,
    Object? similarQuestions = freezed,
  }) {
    return _then(_$ProblemDTOImpl(
      problemId: freezed == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int?,
      number: freezed == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceProblemNumber: freezed == sourceProblemNumber
          ? _value.sourceProblemNumber
          : sourceProblemNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as ProblemDifficulty?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      patterns: freezed == patterns
          ? _value._patterns
          : patterns // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      constraints: freezed == constraints
          ? _value._constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      functionSignature: freezed == functionSignature
          ? _value.functionSignature
          : functionSignature // ignore: cast_nullable_to_non_nullable
              as FunctionSignature?,
      defaultCode: freezed == defaultCode
          ? _value._defaultCode
          : defaultCode // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      customObjects: freezed == customObjects
          ? _value._customObjects
          : customObjects // ignore: cast_nullable_to_non_nullable
              as Map<String, List<CustomObject>>?,
      examples: freezed == examples
          ? _value._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<Example>?,
      edgeCases: freezed == edgeCases
          ? _value._edgeCases
          : edgeCases // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      testCases: freezed == testCases
          ? _value._testCases
          : testCases // ignore: cast_nullable_to_non_nullable
              as List<TestCase>?,
      hiddenTestCases: freezed == hiddenTestCases
          ? _value._hiddenTestCases
          : hiddenTestCases // ignore: cast_nullable_to_non_nullable
              as List<TestCase>?,
      hints: freezed == hints
          ? _value._hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      solutionApproach: freezed == solutionApproach
          ? _value.solutionApproach
          : solutionApproach // ignore: cast_nullable_to_non_nullable
              as SolutionApproach?,
      expectedTimeComplexity: freezed == expectedTimeComplexity
          ? _value.expectedTimeComplexity
          : expectedTimeComplexity // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedSpaceComplexity: freezed == expectedSpaceComplexity
          ? _value.expectedSpaceComplexity
          : expectedSpaceComplexity // ignore: cast_nullable_to_non_nullable
              as String?,
      whatYouLearn: freezed == whatYouLearn
          ? _value.whatYouLearn
          : whatYouLearn // ignore: cast_nullable_to_non_nullable
              as String?,
      keyPattern: freezed == keyPattern
          ? _value.keyPattern
          : keyPattern // ignore: cast_nullable_to_non_nullable
              as String?,
      prerequisites: freezed == prerequisites
          ? _value._prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      followUpConcepts: freezed == followUpConcepts
          ? _value._followUpConcepts
          : followUpConcepts // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      commonMistakes: freezed == commonMistakes
          ? _value._commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      similarQuestions: freezed == similarQuestions
          ? _value._similarQuestions
          : similarQuestions // ignore: cast_nullable_to_non_nullable
              as List<SimilarQuestion>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProblemDTOImpl implements _ProblemDTO {
  const _$ProblemDTOImpl(
      {required this.problemId,
      required this.number,
      required this.name,
      required this.source,
      this.sourceProblemNumber,
      required this.difficulty,
      required this.category,
      required final List<String>? tags,
      required final List<String>? patterns,
      required this.description,
      required final List<String>? constraints,
      required this.functionSignature,
      final Map<String, String>? defaultCode,
      final Map<String, List<CustomObject>>? customObjects,
      required final List<Example>? examples,
      required final List<String>? edgeCases,
      required final List<TestCase>? testCases,
      required final List<TestCase>? hiddenTestCases,
      required final List<String>? hints,
      required this.solutionApproach,
      required this.expectedTimeComplexity,
      required this.expectedSpaceComplexity,
      required this.whatYouLearn,
      required this.keyPattern,
      required final List<String>? prerequisites,
      required final List<String>? followUpConcepts,
      required final List<String>? commonMistakes,
      required final List<SimilarQuestion>? similarQuestions})
      : _tags = tags,
        _patterns = patterns,
        _constraints = constraints,
        _defaultCode = defaultCode,
        _customObjects = customObjects,
        _examples = examples,
        _edgeCases = edgeCases,
        _testCases = testCases,
        _hiddenTestCases = hiddenTestCases,
        _hints = hints,
        _prerequisites = prerequisites,
        _followUpConcepts = followUpConcepts,
        _commonMistakes = commonMistakes,
        _similarQuestions = similarQuestions;

  factory _$ProblemDTOImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProblemDTOImplFromJson(json);

  @override
  final int? problemId;
  @override
  final int? number;
  @override
  final String? name;
  @override
  final String? source;
  @override
  final int? sourceProblemNumber;
  @override
  final ProblemDifficulty? difficulty;
  @override
  final String? category;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _patterns;
  @override
  List<String>? get patterns {
    final value = _patterns;
    if (value == null) return null;
    if (_patterns is EqualUnmodifiableListView) return _patterns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? description;
  final List<String>? _constraints;
  @override
  List<String>? get constraints {
    final value = _constraints;
    if (value == null) return null;
    if (_constraints is EqualUnmodifiableListView) return _constraints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final FunctionSignature? functionSignature;
  final Map<String, String>? _defaultCode;
  @override
  Map<String, String>? get defaultCode {
    final value = _defaultCode;
    if (value == null) return null;
    if (_defaultCode is EqualUnmodifiableMapView) return _defaultCode;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, List<CustomObject>>? _customObjects;
  @override
  Map<String, List<CustomObject>>? get customObjects {
    final value = _customObjects;
    if (value == null) return null;
    if (_customObjects is EqualUnmodifiableMapView) return _customObjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<Example>? _examples;
  @override
  List<Example>? get examples {
    final value = _examples;
    if (value == null) return null;
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _edgeCases;
  @override
  List<String>? get edgeCases {
    final value = _edgeCases;
    if (value == null) return null;
    if (_edgeCases is EqualUnmodifiableListView) return _edgeCases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<TestCase>? _testCases;
  @override
  List<TestCase>? get testCases {
    final value = _testCases;
    if (value == null) return null;
    if (_testCases is EqualUnmodifiableListView) return _testCases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<TestCase>? _hiddenTestCases;
  @override
  List<TestCase>? get hiddenTestCases {
    final value = _hiddenTestCases;
    if (value == null) return null;
    if (_hiddenTestCases is EqualUnmodifiableListView) return _hiddenTestCases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _hints;
  @override
  List<String>? get hints {
    final value = _hints;
    if (value == null) return null;
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final SolutionApproach? solutionApproach;
  @override
  final String? expectedTimeComplexity;
  @override
  final String? expectedSpaceComplexity;
  @override
  final String? whatYouLearn;
  @override
  final String? keyPattern;
  final List<String>? _prerequisites;
  @override
  List<String>? get prerequisites {
    final value = _prerequisites;
    if (value == null) return null;
    if (_prerequisites is EqualUnmodifiableListView) return _prerequisites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _followUpConcepts;
  @override
  List<String>? get followUpConcepts {
    final value = _followUpConcepts;
    if (value == null) return null;
    if (_followUpConcepts is EqualUnmodifiableListView)
      return _followUpConcepts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _commonMistakes;
  @override
  List<String>? get commonMistakes {
    final value = _commonMistakes;
    if (value == null) return null;
    if (_commonMistakes is EqualUnmodifiableListView) return _commonMistakes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SimilarQuestion>? _similarQuestions;
  @override
  List<SimilarQuestion>? get similarQuestions {
    final value = _similarQuestions;
    if (value == null) return null;
    if (_similarQuestions is EqualUnmodifiableListView)
      return _similarQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ProblemDTO(problemId: $problemId, number: $number, name: $name, source: $source, sourceProblemNumber: $sourceProblemNumber, difficulty: $difficulty, category: $category, tags: $tags, patterns: $patterns, description: $description, constraints: $constraints, functionSignature: $functionSignature, defaultCode: $defaultCode, customObjects: $customObjects, examples: $examples, edgeCases: $edgeCases, testCases: $testCases, hiddenTestCases: $hiddenTestCases, hints: $hints, solutionApproach: $solutionApproach, expectedTimeComplexity: $expectedTimeComplexity, expectedSpaceComplexity: $expectedSpaceComplexity, whatYouLearn: $whatYouLearn, keyPattern: $keyPattern, prerequisites: $prerequisites, followUpConcepts: $followUpConcepts, commonMistakes: $commonMistakes, similarQuestions: $similarQuestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProblemDTOImpl &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.sourceProblemNumber, sourceProblemNumber) ||
                other.sourceProblemNumber == sourceProblemNumber) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._patterns, _patterns) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._constraints, _constraints) &&
            (identical(other.functionSignature, functionSignature) ||
                other.functionSignature == functionSignature) &&
            const DeepCollectionEquality()
                .equals(other._defaultCode, _defaultCode) &&
            const DeepCollectionEquality()
                .equals(other._customObjects, _customObjects) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            const DeepCollectionEquality()
                .equals(other._edgeCases, _edgeCases) &&
            const DeepCollectionEquality()
                .equals(other._testCases, _testCases) &&
            const DeepCollectionEquality()
                .equals(other._hiddenTestCases, _hiddenTestCases) &&
            const DeepCollectionEquality().equals(other._hints, _hints) &&
            (identical(other.solutionApproach, solutionApproach) ||
                other.solutionApproach == solutionApproach) &&
            (identical(other.expectedTimeComplexity, expectedTimeComplexity) ||
                other.expectedTimeComplexity == expectedTimeComplexity) &&
            (identical(
                    other.expectedSpaceComplexity, expectedSpaceComplexity) ||
                other.expectedSpaceComplexity == expectedSpaceComplexity) &&
            (identical(other.whatYouLearn, whatYouLearn) ||
                other.whatYouLearn == whatYouLearn) &&
            (identical(other.keyPattern, keyPattern) ||
                other.keyPattern == keyPattern) &&
            const DeepCollectionEquality()
                .equals(other._prerequisites, _prerequisites) &&
            const DeepCollectionEquality()
                .equals(other._followUpConcepts, _followUpConcepts) &&
            const DeepCollectionEquality()
                .equals(other._commonMistakes, _commonMistakes) &&
            const DeepCollectionEquality()
                .equals(other._similarQuestions, _similarQuestions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        problemId,
        number,
        name,
        source,
        sourceProblemNumber,
        difficulty,
        category,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_patterns),
        description,
        const DeepCollectionEquality().hash(_constraints),
        functionSignature,
        const DeepCollectionEquality().hash(_defaultCode),
        const DeepCollectionEquality().hash(_customObjects),
        const DeepCollectionEquality().hash(_examples),
        const DeepCollectionEquality().hash(_edgeCases),
        const DeepCollectionEquality().hash(_testCases),
        const DeepCollectionEquality().hash(_hiddenTestCases),
        const DeepCollectionEquality().hash(_hints),
        solutionApproach,
        expectedTimeComplexity,
        expectedSpaceComplexity,
        whatYouLearn,
        keyPattern,
        const DeepCollectionEquality().hash(_prerequisites),
        const DeepCollectionEquality().hash(_followUpConcepts),
        const DeepCollectionEquality().hash(_commonMistakes),
        const DeepCollectionEquality().hash(_similarQuestions)
      ]);

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProblemDTOImplCopyWith<_$ProblemDTOImpl> get copyWith =>
      __$$ProblemDTOImplCopyWithImpl<_$ProblemDTOImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProblemDTOImplToJson(
      this,
    );
  }
}

abstract class _ProblemDTO implements ProblemDTO {
  const factory _ProblemDTO(
          {required final int? problemId,
          required final int? number,
          required final String? name,
          required final String? source,
          final int? sourceProblemNumber,
          required final ProblemDifficulty? difficulty,
          required final String? category,
          required final List<String>? tags,
          required final List<String>? patterns,
          required final String? description,
          required final List<String>? constraints,
          required final FunctionSignature? functionSignature,
          final Map<String, String>? defaultCode,
          final Map<String, List<CustomObject>>? customObjects,
          required final List<Example>? examples,
          required final List<String>? edgeCases,
          required final List<TestCase>? testCases,
          required final List<TestCase>? hiddenTestCases,
          required final List<String>? hints,
          required final SolutionApproach? solutionApproach,
          required final String? expectedTimeComplexity,
          required final String? expectedSpaceComplexity,
          required final String? whatYouLearn,
          required final String? keyPattern,
          required final List<String>? prerequisites,
          required final List<String>? followUpConcepts,
          required final List<String>? commonMistakes,
          required final List<SimilarQuestion>? similarQuestions}) =
      _$ProblemDTOImpl;

  factory _ProblemDTO.fromJson(Map<String, dynamic> json) =
      _$ProblemDTOImpl.fromJson;

  @override
  int? get problemId;
  @override
  int? get number;
  @override
  String? get name;
  @override
  String? get source;
  @override
  int? get sourceProblemNumber;
  @override
  ProblemDifficulty? get difficulty;
  @override
  String? get category;
  @override
  List<String>? get tags;
  @override
  List<String>? get patterns;
  @override
  String? get description;
  @override
  List<String>? get constraints;
  @override
  FunctionSignature? get functionSignature;
  @override
  Map<String, String>? get defaultCode;
  @override
  Map<String, List<CustomObject>>? get customObjects;
  @override
  List<Example>? get examples;
  @override
  List<String>? get edgeCases;
  @override
  List<TestCase>? get testCases;
  @override
  List<TestCase>? get hiddenTestCases;
  @override
  List<String>? get hints;
  @override
  SolutionApproach? get solutionApproach;
  @override
  String? get expectedTimeComplexity;
  @override
  String? get expectedSpaceComplexity;
  @override
  String? get whatYouLearn;
  @override
  String? get keyPattern;
  @override
  List<String>? get prerequisites;
  @override
  List<String>? get followUpConcepts;
  @override
  List<String>? get commonMistakes;
  @override
  List<SimilarQuestion>? get similarQuestions;

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProblemDTOImplCopyWith<_$ProblemDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
