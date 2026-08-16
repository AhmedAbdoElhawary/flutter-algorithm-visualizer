import '../execution/runner.dart';
import 'custom_object_shape.dart';
import 'function_signature.dart';
import 'object_builder.dart';
import 'object_serializer.dart';
import 'test_case.dart';
import 'test_value.dart';
import 'value_parser.dart';

export 'test_case.dart';

/// Everything the runner needs to know about a coding problem.
class ProblemData {
  const ProblemData({
    required this.functionSignature,
    required this.testCases,
    this.hiddenTestCases = const <ProblemTestCase>[],
    this.customObjects = const <String, CustomObjectShape>{},
    this.customObjectSources = const <String>[],
  });

  /// The `function_signature.dart` string, e.g.
  /// `List<int> twoSum(List<int> nums, int target)`.
  final String functionSignature;

  final List<ProblemTestCase> testCases;
  final List<ProblemTestCase> hiddenTestCases;

  /// Custom class name (e.g. `ListNode`, `TreeNode`) -> its shape.
  final Map<String, CustomObjectShape> customObjects;

  /// Raw `class` source (e.g. the `ListNode` definition) to prepend when the
  /// user's code doesn't already define the class.
  final List<String> customObjectSources;
}

/// Grades user-written Dart code against a problem's test cases using the
/// on-device interpreter.
///
/// For every test case it:
///  1. Parses the `input` string (`nums=[2,7,11,15], target=9`) into typed
///     values using the parsed function signature.
///  2. Builds a runnable program: custom-object class headers (if needed) +
///     the user's code + a generated `main()` that calls the target function
///     with those arguments and `print()`s the result.
///  3. Runs it and compares the canonical serialization of the printed value
///     (shape-aware for custom objects) against the expected output.
class ProblemRunner {
  const ProblemRunner({this.maxSteps = 2000000});

  final int maxSteps;

  ProblemRunResult runAll({
    required ProblemData problem,
    required String userCode,
  }) {
    final all = <ProblemTestCase>[
      ...problem.testCases,
      ...problem.hiddenTestCases,
    ];
    if (all.isEmpty) {
      return const ProblemRunResult(
        testCaseResults: <SingleTestCaseResult>[],
        allPassed: false,
        passedCount: 0,
        totalCount: 0,
      );
    }

    ParsedFunctionSignature sig;
    try {
      sig = parseFunctionSignature(problem.functionSignature);
    } catch (e) {
      return ProblemRunResult(
        testCaseResults: const <SingleTestCaseResult>[],
        allPassed: false,
        passedCount: 0,
        totalCount: all.length,
        error: 'Invalid function signature: $e',
      );
    }

    final runner = DartInterpreterRunner(maxSteps: maxSteps);
    final results = <SingleTestCaseResult>[];
    String? firstError;

    for (final testCase in all) {
      final input = testCase.input.trim();
      final expected = testCase.expectedOutput.trim();

      final argValues = parseTestCaseInput(input);
      final program = _buildProgram(problem, sig, userCode, argValues);
      final run = runner.run(program);

      if (run.error != null) {
        results.add(SingleTestCaseResult(
          testCase: testCase,
          passed: false,
          actualOutput: run.stdout.isEmpty ? '' : run.stdout.join('\n'),
          errorMessage: run.error.toString(),
        ));
        firstError ??= run.error.toString();
        continue;
      }

      final raw = run.rawOutput.isEmpty ? null : run.rawOutput.last;
      // For in-place (`void`) functions the printed value is the mutated
      // first argument, so its shape comes from the first parameter's type.
      final shape = sig.isVoid && sig.params.isNotEmpty
          ? _shapeForType(problem, sig.params.first.type)
          : _shapeForType(problem, sig.returnType);
      final actual = _serialize(raw, shape);
      final expectedCanonical = canonicalString(testValueToRaw(parseValue(expected)));

      results.add(SingleTestCaseResult(
        testCase: testCase,
        passed: actual == expectedCanonical,
        actualOutput: actual,
      ));
    }

    return ProblemRunResult(
      testCaseResults: results,
      allPassed: firstError == null && results.isNotEmpty && results.every((r) => r.passed),
      passedCount: results.where((r) => r.passed).length,
      totalCount: all.length,
      error: firstError,
    );
  }

  // ---------------------------------------------------------------------
  // Program construction
  // ---------------------------------------------------------------------

  String _buildProgram(
    ProblemData problem,
    ParsedFunctionSignature sig,
    String userCode,
    Map<String, TestValue> argValues,
  ) {
    final code = _stripSolutionWrapper(userCode).trim();

    final headers = _customObjectHeaders(problem, code);

    // The user provided their own main(): run it as-is (whatever it prints
    // last is treated as the result).
    if (RegExp(r'\bvoid\s+main\s*\(').hasMatch(code)) {
      return headers.isEmpty ? code : '${headers.join('\n\n')}\n\n$code';
    }

    final argDecls = <String>[];
    for (final param in sig.params) {
      final source = _argSource(problem, param.type, argValues[param.name]);
      argDecls.add('  final ${param.name} = $source;');
    }

    final callArgs = sig.params.map((p) => p.name).join(', ');
    final buf = StringBuffer()
      ..writeln('void main() {')
      ..writeln(argDecls.join('\n'));
    if (sig.isVoid) {
      buf
        ..writeln('  ${sig.name}($callArgs);')
        ..writeln('  print(${sig.params.isEmpty ? 'null' : sig.params.first.name});');
    } else {
      buf
        ..writeln('  final result = ${sig.name}($callArgs);')
        ..writeln('  print(result);');
    }
    buf.writeln('}');

    if (headers.isEmpty) {
      return '$code\n\n${buf.toString()}';
    }
    return '${headers.join('\n\n')}\n\n$code\n\n${buf.toString()}';
  }

  /// Custom-object class sources that the user code doesn't already define.
  List<String> _customObjectHeaders(ProblemData problem, String code) {
    final headers = <String>[];
    for (final src in problem.customObjectSources) {
      final nameMatch = RegExp(r'class\s+(\w+)').firstMatch(src.trim());
      final name = nameMatch?.group(1);
      if (name != null && _definesClass(code, name)) continue;
      headers.add(src.trim());
    }
    return headers;
  }

  bool _definesClass(String code, String name) {
    return RegExp(r'\bclass\s+' + RegExp.escape(name) + r'\b').hasMatch(code);
  }

  String _argSource(ProblemData problem, String paramType, TestValue? value) {
    final effective = value ?? const NullTestValue();
    if (effective is NullTestValue) return 'null';

    final shape = _shapeForType(problem, paramType);
    if (shape != null) {
      if (effective is ListTestValue) {
        return buildObjectSource(
          value: effective,
          className: _baseTypeName(paramType),
          shape: shape,
        );
      }
      return testValueToSource(effective);
    }

    // `List<CustomType>` params, e.g. `mergeKLists(List<ListNode?> lists)`.
    final elementShape = _elementShapeForListType(problem, paramType);
    if (elementShape != null && effective is ListTestValue) {
      final elementName = _elementTypeName(paramType);
      final parts = effective.items.map((item) {
        if (item is NullTestValue) return 'null';
        return buildObjectSource(value: item, className: elementName, shape: elementShape);
      }).join(', ');
      return '[$parts]';
    }

    return testValueToSource(effective);
  }

  // ---------------------------------------------------------------------
  // Serialization / comparison
  // ---------------------------------------------------------------------

  String _serialize(dynamic raw, CustomObjectShape? shape) {
    if (raw == null && (shape == CustomObjectShape.linkedList || shape == CustomObjectShape.binaryTree)) {
      // LeetCode's Dart templates return null for empty lists/trees; the
      // dataset stores those as `[]`.
      return '[]';
    }
    return canonicalString(raw, shape: shape);
  }

  // ---------------------------------------------------------------------
  // Type helpers
  // ---------------------------------------------------------------------

  CustomObjectShape? _shapeForType(ProblemData problem, String type) {
    final base = _baseTypeName(type);
    return problem.customObjects[base];
  }

  CustomObjectShape? _elementShapeForListType(ProblemData problem, String type) {
    final compact = type.replaceAll(RegExp(r'\s+'), '');
    final match = RegExp(r'^List<(.+)>$').firstMatch(compact);
    if (match == null) return null;
    return _shapeForType(problem, match.group(1)!);
  }

  String _elementTypeName(String type) {
    final compact = type.replaceAll(RegExp(r'\s+'), '');
    final match = RegExp(r'^List<(.+)>$').firstMatch(compact);
    return _baseTypeName(match == null ? type : match.group(1)!);
  }

  String _baseTypeName(String type) {
    return type
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'<.*>'), '')
        .replaceAll('?', '');
  }

  /// The `default_code` in the JSON wraps the function in `class Solution`
  /// (LeetCode style), sometimes preceded by a `/** ... */` doc comment.
  /// Peel that wrapper off, keeping only its body.
  ///
  /// Only a class named exactly `Solution` is treated as the wrapper:
  /// class-based problems (`MinStack`, `LRUCache`, ...) define the solution
  /// class itself and must be left intact.
  ///
  /// Comments are stripped first (the interpreter ignores them anyway) so the
  /// wrapper detection isn't fooled by a leading doc comment and the class
  /// check in [ProblemRunner._definesClass] can't match class names that only
  /// appear inside comments.
  String _stripSolutionWrapper(String code) {
    final commentFree = _stripComments(code).trim();
    final match = RegExp(r'^class\s+Solution\s*\{').firstMatch(commentFree);
    if (match == null) return commentFree;

    final open = commentFree.indexOf('{', match.start);
    var depth = 0;
    for (var i = open; i < commentFree.length; i++) {
      final c = commentFree[i];
      if (c == '{') {
        depth++;
      } else if (c == '}') {
        depth--;
        if (depth == 0) return commentFree.substring(open + 1, i).trim();
      }
    }
    return commentFree;
  }

  /// Removes `//` line comments and (nested) `/* ... */` block comments,
  /// leaving string literals untouched. Mirrors the lexer's comment rules so
  /// the surrounding code is unchanged.
  String _stripComments(String source) {
    final buf = StringBuffer();
    var i = 0;
    while (i < source.length) {
      final ch = source[i];

      if (ch == '/' && i + 1 < source.length && source[i + 1] == '/') {
        while (i < source.length && source[i] != '\n') {
          i++;
        }
        continue;
      }

      if (ch == '/' && i + 1 < source.length && source[i + 1] == '*') {
        var depth = 1;
        i += 2;
        while (i < source.length && depth > 0) {
          if (i + 1 < source.length && source[i] == '/' && source[i + 1] == '*') {
            depth++;
            i += 2;
            continue;
          }
          if (i + 1 < source.length && source[i] == '*' && source[i + 1] == '/') {
            depth--;
            i += 2;
            continue;
          }
          i++;
        }
        continue;
      }

      if (ch == '"' || ch == "'") {
        final quote = ch;
        buf.write(ch);
        i++;
        while (i < source.length && source[i] != quote) {
          buf.write(source[i]);
          if (source[i] == '\\' && i + 1 < source.length) {
            buf.write(source[i + 1]);
            i += 2;
            continue;
          }
          i++;
        }
        if (i < source.length) buf.write(source[i]);
        i++;
        continue;
      }

      buf.write(ch);
      i++;
    }
    return buf.toString();
  }
}
