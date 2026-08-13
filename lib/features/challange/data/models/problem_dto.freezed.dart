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
  int get problemId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  int? get sourceProblemNumber => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get patterns => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get constraints => throw _privateConstructorUsedError;
  FunctionSignature get functionSignature => throw _privateConstructorUsedError;
  List<Example> get examples => throw _privateConstructorUsedError;
  List<String> get edgeCases => throw _privateConstructorUsedError;
  List<TestCase> get testCases => throw _privateConstructorUsedError;
  List<HiddenTestCase> get hiddenTestCases =>
      throw _privateConstructorUsedError;
  List<String> get hints => throw _privateConstructorUsedError;
  SolutionApproach get solutionApproach => throw _privateConstructorUsedError;
  String get expectedTimeComplexity => throw _privateConstructorUsedError;
  String get expectedSpaceComplexity => throw _privateConstructorUsedError;
  String get whatYouLearn => throw _privateConstructorUsedError;
  String get keyPattern => throw _privateConstructorUsedError;
  List<String> get prerequisites => throw _privateConstructorUsedError;
  List<String> get followUpConcepts => throw _privateConstructorUsedError;
  List<String> get commonMistakes => throw _privateConstructorUsedError;
  List<SimilarQuestion> get similarQuestions =>
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
      {int problemId,
      String name,
      String source,
      int? sourceProblemNumber,
      String difficulty,
      String category,
      List<String> tags,
      List<String> patterns,
      String description,
      List<String> constraints,
      FunctionSignature functionSignature,
      List<Example> examples,
      List<String> edgeCases,
      List<TestCase> testCases,
      List<HiddenTestCase> hiddenTestCases,
      List<String> hints,
      SolutionApproach solutionApproach,
      String expectedTimeComplexity,
      String expectedSpaceComplexity,
      String whatYouLearn,
      String keyPattern,
      List<String> prerequisites,
      List<String> followUpConcepts,
      List<String> commonMistakes,
      List<SimilarQuestion> similarQuestions});

  $FunctionSignatureCopyWith<$Res> get functionSignature;
  $SolutionApproachCopyWith<$Res> get solutionApproach;
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
    Object? problemId = null,
    Object? name = null,
    Object? source = null,
    Object? sourceProblemNumber = freezed,
    Object? difficulty = null,
    Object? category = null,
    Object? tags = null,
    Object? patterns = null,
    Object? description = null,
    Object? constraints = null,
    Object? functionSignature = null,
    Object? examples = null,
    Object? edgeCases = null,
    Object? testCases = null,
    Object? hiddenTestCases = null,
    Object? hints = null,
    Object? solutionApproach = null,
    Object? expectedTimeComplexity = null,
    Object? expectedSpaceComplexity = null,
    Object? whatYouLearn = null,
    Object? keyPattern = null,
    Object? prerequisites = null,
    Object? followUpConcepts = null,
    Object? commonMistakes = null,
    Object? similarQuestions = null,
  }) {
    return _then(_value.copyWith(
      problemId: null == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      sourceProblemNumber: freezed == sourceProblemNumber
          ? _value.sourceProblemNumber
          : sourceProblemNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      patterns: null == patterns
          ? _value.patterns
          : patterns // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      constraints: null == constraints
          ? _value.constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      functionSignature: null == functionSignature
          ? _value.functionSignature
          : functionSignature // ignore: cast_nullable_to_non_nullable
              as FunctionSignature,
      examples: null == examples
          ? _value.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<Example>,
      edgeCases: null == edgeCases
          ? _value.edgeCases
          : edgeCases // ignore: cast_nullable_to_non_nullable
              as List<String>,
      testCases: null == testCases
          ? _value.testCases
          : testCases // ignore: cast_nullable_to_non_nullable
              as List<TestCase>,
      hiddenTestCases: null == hiddenTestCases
          ? _value.hiddenTestCases
          : hiddenTestCases // ignore: cast_nullable_to_non_nullable
              as List<HiddenTestCase>,
      hints: null == hints
          ? _value.hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      solutionApproach: null == solutionApproach
          ? _value.solutionApproach
          : solutionApproach // ignore: cast_nullable_to_non_nullable
              as SolutionApproach,
      expectedTimeComplexity: null == expectedTimeComplexity
          ? _value.expectedTimeComplexity
          : expectedTimeComplexity // ignore: cast_nullable_to_non_nullable
              as String,
      expectedSpaceComplexity: null == expectedSpaceComplexity
          ? _value.expectedSpaceComplexity
          : expectedSpaceComplexity // ignore: cast_nullable_to_non_nullable
              as String,
      whatYouLearn: null == whatYouLearn
          ? _value.whatYouLearn
          : whatYouLearn // ignore: cast_nullable_to_non_nullable
              as String,
      keyPattern: null == keyPattern
          ? _value.keyPattern
          : keyPattern // ignore: cast_nullable_to_non_nullable
              as String,
      prerequisites: null == prerequisites
          ? _value.prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followUpConcepts: null == followUpConcepts
          ? _value.followUpConcepts
          : followUpConcepts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      commonMistakes: null == commonMistakes
          ? _value.commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      similarQuestions: null == similarQuestions
          ? _value.similarQuestions
          : similarQuestions // ignore: cast_nullable_to_non_nullable
              as List<SimilarQuestion>,
    ) as $Val);
  }

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FunctionSignatureCopyWith<$Res> get functionSignature {
    return $FunctionSignatureCopyWith<$Res>(_value.functionSignature, (value) {
      return _then(_value.copyWith(functionSignature: value) as $Val);
    });
  }

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SolutionApproachCopyWith<$Res> get solutionApproach {
    return $SolutionApproachCopyWith<$Res>(_value.solutionApproach, (value) {
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
      {int problemId,
      String name,
      String source,
      int? sourceProblemNumber,
      String difficulty,
      String category,
      List<String> tags,
      List<String> patterns,
      String description,
      List<String> constraints,
      FunctionSignature functionSignature,
      List<Example> examples,
      List<String> edgeCases,
      List<TestCase> testCases,
      List<HiddenTestCase> hiddenTestCases,
      List<String> hints,
      SolutionApproach solutionApproach,
      String expectedTimeComplexity,
      String expectedSpaceComplexity,
      String whatYouLearn,
      String keyPattern,
      List<String> prerequisites,
      List<String> followUpConcepts,
      List<String> commonMistakes,
      List<SimilarQuestion> similarQuestions});

  @override
  $FunctionSignatureCopyWith<$Res> get functionSignature;
  @override
  $SolutionApproachCopyWith<$Res> get solutionApproach;
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
    Object? problemId = null,
    Object? name = null,
    Object? source = null,
    Object? sourceProblemNumber = freezed,
    Object? difficulty = null,
    Object? category = null,
    Object? tags = null,
    Object? patterns = null,
    Object? description = null,
    Object? constraints = null,
    Object? functionSignature = null,
    Object? examples = null,
    Object? edgeCases = null,
    Object? testCases = null,
    Object? hiddenTestCases = null,
    Object? hints = null,
    Object? solutionApproach = null,
    Object? expectedTimeComplexity = null,
    Object? expectedSpaceComplexity = null,
    Object? whatYouLearn = null,
    Object? keyPattern = null,
    Object? prerequisites = null,
    Object? followUpConcepts = null,
    Object? commonMistakes = null,
    Object? similarQuestions = null,
  }) {
    return _then(_$ProblemDTOImpl(
      problemId: null == problemId
          ? _value.problemId
          : problemId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      sourceProblemNumber: freezed == sourceProblemNumber
          ? _value.sourceProblemNumber
          : sourceProblemNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      patterns: null == patterns
          ? _value._patterns
          : patterns // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      constraints: null == constraints
          ? _value._constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      functionSignature: null == functionSignature
          ? _value.functionSignature
          : functionSignature // ignore: cast_nullable_to_non_nullable
              as FunctionSignature,
      examples: null == examples
          ? _value._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<Example>,
      edgeCases: null == edgeCases
          ? _value._edgeCases
          : edgeCases // ignore: cast_nullable_to_non_nullable
              as List<String>,
      testCases: null == testCases
          ? _value._testCases
          : testCases // ignore: cast_nullable_to_non_nullable
              as List<TestCase>,
      hiddenTestCases: null == hiddenTestCases
          ? _value._hiddenTestCases
          : hiddenTestCases // ignore: cast_nullable_to_non_nullable
              as List<HiddenTestCase>,
      hints: null == hints
          ? _value._hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      solutionApproach: null == solutionApproach
          ? _value.solutionApproach
          : solutionApproach // ignore: cast_nullable_to_non_nullable
              as SolutionApproach,
      expectedTimeComplexity: null == expectedTimeComplexity
          ? _value.expectedTimeComplexity
          : expectedTimeComplexity // ignore: cast_nullable_to_non_nullable
              as String,
      expectedSpaceComplexity: null == expectedSpaceComplexity
          ? _value.expectedSpaceComplexity
          : expectedSpaceComplexity // ignore: cast_nullable_to_non_nullable
              as String,
      whatYouLearn: null == whatYouLearn
          ? _value.whatYouLearn
          : whatYouLearn // ignore: cast_nullable_to_non_nullable
              as String,
      keyPattern: null == keyPattern
          ? _value.keyPattern
          : keyPattern // ignore: cast_nullable_to_non_nullable
              as String,
      prerequisites: null == prerequisites
          ? _value._prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followUpConcepts: null == followUpConcepts
          ? _value._followUpConcepts
          : followUpConcepts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      commonMistakes: null == commonMistakes
          ? _value._commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      similarQuestions: null == similarQuestions
          ? _value._similarQuestions
          : similarQuestions // ignore: cast_nullable_to_non_nullable
              as List<SimilarQuestion>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProblemDTOImpl implements _ProblemDTO {
  const _$ProblemDTOImpl(
      {required this.problemId,
      required this.name,
      required this.source,
      this.sourceProblemNumber,
      required this.difficulty,
      required this.category,
      required final List<String> tags,
      required final List<String> patterns,
      required this.description,
      required final List<String> constraints,
      required this.functionSignature,
      required final List<Example> examples,
      required final List<String> edgeCases,
      required final List<TestCase> testCases,
      required final List<HiddenTestCase> hiddenTestCases,
      required final List<String> hints,
      required this.solutionApproach,
      required this.expectedTimeComplexity,
      required this.expectedSpaceComplexity,
      required this.whatYouLearn,
      required this.keyPattern,
      required final List<String> prerequisites,
      required final List<String> followUpConcepts,
      required final List<String> commonMistakes,
      required final List<SimilarQuestion> similarQuestions})
      : _tags = tags,
        _patterns = patterns,
        _constraints = constraints,
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
  final int problemId;
  @override
  final String name;
  @override
  final String source;
  @override
  final int? sourceProblemNumber;
  @override
  final String difficulty;
  @override
  final String category;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _patterns;
  @override
  List<String> get patterns {
    if (_patterns is EqualUnmodifiableListView) return _patterns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_patterns);
  }

  @override
  final String description;
  final List<String> _constraints;
  @override
  List<String> get constraints {
    if (_constraints is EqualUnmodifiableListView) return _constraints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_constraints);
  }

  @override
  final FunctionSignature functionSignature;
  final List<Example> _examples;
  @override
  List<Example> get examples {
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_examples);
  }

  final List<String> _edgeCases;
  @override
  List<String> get edgeCases {
    if (_edgeCases is EqualUnmodifiableListView) return _edgeCases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_edgeCases);
  }

  final List<TestCase> _testCases;
  @override
  List<TestCase> get testCases {
    if (_testCases is EqualUnmodifiableListView) return _testCases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_testCases);
  }

  final List<HiddenTestCase> _hiddenTestCases;
  @override
  List<HiddenTestCase> get hiddenTestCases {
    if (_hiddenTestCases is EqualUnmodifiableListView) return _hiddenTestCases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hiddenTestCases);
  }

  final List<String> _hints;
  @override
  List<String> get hints {
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hints);
  }

  @override
  final SolutionApproach solutionApproach;
  @override
  final String expectedTimeComplexity;
  @override
  final String expectedSpaceComplexity;
  @override
  final String whatYouLearn;
  @override
  final String keyPattern;
  final List<String> _prerequisites;
  @override
  List<String> get prerequisites {
    if (_prerequisites is EqualUnmodifiableListView) return _prerequisites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prerequisites);
  }

  final List<String> _followUpConcepts;
  @override
  List<String> get followUpConcepts {
    if (_followUpConcepts is EqualUnmodifiableListView)
      return _followUpConcepts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followUpConcepts);
  }

  final List<String> _commonMistakes;
  @override
  List<String> get commonMistakes {
    if (_commonMistakes is EqualUnmodifiableListView) return _commonMistakes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commonMistakes);
  }

  final List<SimilarQuestion> _similarQuestions;
  @override
  List<SimilarQuestion> get similarQuestions {
    if (_similarQuestions is EqualUnmodifiableListView)
      return _similarQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_similarQuestions);
  }

  @override
  String toString() {
    return 'ProblemDTO(problemId: $problemId, name: $name, source: $source, sourceProblemNumber: $sourceProblemNumber, difficulty: $difficulty, category: $category, tags: $tags, patterns: $patterns, description: $description, constraints: $constraints, functionSignature: $functionSignature, examples: $examples, edgeCases: $edgeCases, testCases: $testCases, hiddenTestCases: $hiddenTestCases, hints: $hints, solutionApproach: $solutionApproach, expectedTimeComplexity: $expectedTimeComplexity, expectedSpaceComplexity: $expectedSpaceComplexity, whatYouLearn: $whatYouLearn, keyPattern: $keyPattern, prerequisites: $prerequisites, followUpConcepts: $followUpConcepts, commonMistakes: $commonMistakes, similarQuestions: $similarQuestions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProblemDTOImpl &&
            (identical(other.problemId, problemId) ||
                other.problemId == problemId) &&
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
          {required final int problemId,
          required final String name,
          required final String source,
          final int? sourceProblemNumber,
          required final String difficulty,
          required final String category,
          required final List<String> tags,
          required final List<String> patterns,
          required final String description,
          required final List<String> constraints,
          required final FunctionSignature functionSignature,
          required final List<Example> examples,
          required final List<String> edgeCases,
          required final List<TestCase> testCases,
          required final List<HiddenTestCase> hiddenTestCases,
          required final List<String> hints,
          required final SolutionApproach solutionApproach,
          required final String expectedTimeComplexity,
          required final String expectedSpaceComplexity,
          required final String whatYouLearn,
          required final String keyPattern,
          required final List<String> prerequisites,
          required final List<String> followUpConcepts,
          required final List<String> commonMistakes,
          required final List<SimilarQuestion> similarQuestions}) =
      _$ProblemDTOImpl;

  factory _ProblemDTO.fromJson(Map<String, dynamic> json) =
      _$ProblemDTOImpl.fromJson;

  @override
  int get problemId;
  @override
  String get name;
  @override
  String get source;
  @override
  int? get sourceProblemNumber;
  @override
  String get difficulty;
  @override
  String get category;
  @override
  List<String> get tags;
  @override
  List<String> get patterns;
  @override
  String get description;
  @override
  List<String> get constraints;
  @override
  FunctionSignature get functionSignature;
  @override
  List<Example> get examples;
  @override
  List<String> get edgeCases;
  @override
  List<TestCase> get testCases;
  @override
  List<HiddenTestCase> get hiddenTestCases;
  @override
  List<String> get hints;
  @override
  SolutionApproach get solutionApproach;
  @override
  String get expectedTimeComplexity;
  @override
  String get expectedSpaceComplexity;
  @override
  String get whatYouLearn;
  @override
  String get keyPattern;
  @override
  List<String> get prerequisites;
  @override
  List<String> get followUpConcepts;
  @override
  List<String> get commonMistakes;
  @override
  List<SimilarQuestion> get similarQuestions;

  /// Create a copy of ProblemDTO
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProblemDTOImplCopyWith<_$ProblemDTOImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
