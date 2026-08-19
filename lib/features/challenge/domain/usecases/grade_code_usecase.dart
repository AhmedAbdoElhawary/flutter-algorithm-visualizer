import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show CustomObjectShape, ProblemData, ProblemRunner, ProblemTestCase;
import 'package:algorithm_visualizer/features/challenge/data/models/custom_object.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';

/// Aggregate result of grading user code against every test case
/// (visible `test_cases` + `hidden_test_cases`).
class CodeGradeResult {
  const CodeGradeResult({
    required this.allTestCaseResults,
    required this.totalCount,
    required this.code,
    this.error,
  });
  final List<TestCaseResult> allTestCaseResults;
  final int totalCount;
  final String code;

  /// A whole-program failure (e.g. the user code never compiles), which
  /// invalidates every test case at once. Null when each test ran.
  final String? error;

  int get passedCount => allTestCaseResults.where((r) => r.passed).length;

  int get failedCount => allTestCaseResults.where((r) => !r.passed).length;

  /// it just need to be simple not showing all test cases results
  List<TestCaseResult> get firstThreeTestCaseResults {
    if (allPassed) return allTestCaseResults.take(3).toList();

    final failedResults = allTestCaseResults.where((r) => !r.passed).take(3).toList();
    final passedResults = allTestCaseResults.where((r) => r.passed).take(3 - failedResults.length).toList();
    final failed = [...failedResults, ...passedResults];

    return failed;
  }

  /// True only when the code ran cleanly AND every test case passed.
  bool get allPassed => error == null && allTestCaseResults.isNotEmpty && passedCount == totalCount;
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
      return CodeGradeResult(allTestCaseResults: <TestCaseResult>[], totalCount: 0, code: userCode);
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
      code: userCode,
      allTestCaseResults: [
        for (final r in result.testCaseResults)
          TestCaseResult(
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
