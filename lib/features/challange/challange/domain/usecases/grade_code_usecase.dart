import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show CustomObjectShape, ProblemData, ProblemRunner, ProblemTestCase;
import 'package:algorithm_visualizer/features/challange/data/models/custom_object.dart';
import 'package:algorithm_visualizer/features/challange/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';

/// Result of grading the user's code against a single test case.
class SingleTestCaseResult {
  const SingleTestCaseResult({
    required this.input,
    required this.expectedOutput,
    required this.actualOutput,
    required this.passed,
    this.errorMessage,
  });

  /// The raw `input` string straight from the JSON, e.g. `nums=[2,7,11,15], target=9`.
  final String input;
  final String expectedOutput;
  final String actualOutput;
  final bool passed;

  /// Set when this single run failed to parse/execute (not when the output
  /// simply didn't match). Null on a clean run.
  final String? errorMessage;
}

/// Aggregate result of grading user code against every test case
/// (visible `test_cases` + `hidden_test_cases`).
class CodeGradeResult {
  const CodeGradeResult({
    required this.testCaseResults,
    required this.totalCount,
    this.error,
  });

  final List<SingleTestCaseResult> testCaseResults;
  final int totalCount;

  /// A whole-program failure (e.g. the user code never compiles), which
  /// invalidates every test case at once. Null when each test ran.
  final String? error;

  int get passedCount => testCaseResults.where((r) => r.passed).length;

  /// True only when the code ran cleanly AND every test case passed.
  bool get allPassed => error == null && testCaseResults.isNotEmpty && passedCount == totalCount;
}

/// Grades user-written Dart code against a coding problem using the on-device
/// interpreter from `custom_code_editor`.
///
/// This is a thin adapter: it builds a package-level [ProblemData] from the
/// problem entity (signature, test cases, custom-object sources/shapes) and
/// delegates the heavy lifting to [ProblemRunner].
class GradeCodeUseCase {
  const GradeCodeUseCase();

  /// Grades [userCode] against [problem]'s test cases (visible + hidden) and
  /// returns a detailed [CodeGradeResult].
  CodeGradeResult grade({
    required CodingProblem problem,
    required String userCode,
  }) {
    final allCases = <TestCase>[...problem.getTestCases, ...problem.getHiddenTestCases];
    if (allCases.isEmpty) {
      return const CodeGradeResult(testCaseResults: <SingleTestCaseResult>[], totalCount: 0);
    }

    final problemData = ProblemData(
      functionSignature: problem.functionSignature?.dart ?? '',
      testCases: allCases
          .map((t) => ProblemTestCase(
                input: t.input?.trim() ?? '',
                expectedOutput: t.expectedOutput?.trim() ?? '',
              ))
          .toList(growable: false),
      customObjects: _buildCustomShapes(problem.getCustomObjects),
      customObjectSources: _buildCustomSources(problem.getCustomObjects),
    );

    final result = const ProblemRunner().runAll(problem: problemData, userCode: userCode);

    return CodeGradeResult(
      testCaseResults: [
        for (final r in result.testCaseResults)
          SingleTestCaseResult(
            input: r.testCase.input,
            expectedOutput: r.testCase.expectedOutput,
            actualOutput: r.actualOutput,
            passed: r.passed,
            errorMessage: r.errorMessage,
          ),
      ],
      totalCount: result.totalCount,
      error: result.error,
    );
  }

  /// Custom class name -> shape, from each entry's `shape` metadata.
  Map<String, CustomObjectShape> _buildCustomShapes(List<CustomObject> objects) {
    final shapes = <String, CustomObjectShape>{};
    for (final object in objects) {
      final shape = CustomObjectShape.fromKey(object.getShape);
      if (shape == null) continue;
      final name = _classNameOf(object.getCode);
      if (name != null) shapes[name] = shape;
    }
    return shapes;
  }

  /// The raw `class` source strings to prepend when the user code doesn't
  /// define them itself.
  List<String> _buildCustomSources(List<CustomObject> objects) {
    return [for (final object in objects) object.getCode];
  }

  String? _classNameOf(String source) {
    return RegExp(r'class\s+(\w+)').firstMatch(source.trim())?.group(1);
  }
}
