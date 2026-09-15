import 'package:algorithm_visualizer/core/resources/strings_manager.dart';

import '../execution/compile/compiler.dart';
import '../execution/errors/failure.dart';
import '../execution/frontend/language_registry.dart';
import '../execution/legacy/object_instance.dart';
import '../execution/values/value.dart' as engine;
import '../execution/vm/budget.dart';
import '../execution/vm/vm.dart';
import 'custom_object_shape.dart';
import 'function_signature.dart';
import 'object_builder.dart';
import 'object_serializer.dart';
import 'output_comparison.dart';
import 'test_case.dart';
import 'test_value.dart';
import 'value_parser.dart';

export 'output_comparison.dart';
export 'test_case.dart';

/// Everything the runner needs to know about a coding problem.
class ProblemData {
  const ProblemData({
    required this.functionSignature,
    required this.testCases,
    this.hiddenTestCases = const <ProblemTestCase>[],
    this.customObjects = const <String, CustomObjectShape>{},
    this.customObjectSources = const <String>[],
    this.comparison = OutputComparison.exact,
    this.language = EditorLanguage.dart,
  });

  /// The language the learner wrote their solution in. The test cases and
  /// the expected output are the same whichever it is — that is the whole
  /// point of grading on canonical values (SC-013).
  final EditorLanguage language;

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

  /// How the result is matched against the expected output. Problems whose
  /// answer has no required ordering relax this so a correct solution isn't
  /// failed for the order it returned.
  final OutputComparison comparison;
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

    if (problem.language != EditorLanguage.dart && problem.customObjects.isNotEmpty) {
      // Linked lists and trees are still built as Dart source text
      // (`object_builder.dart`), so a problem that needs them can only be
      // graded in Dart for now. Say so rather than failing every test case
      // with something that reads like the learner's fault.
      return ProblemRunResult(
        testCaseResults: const <SingleTestCaseResult>[],
        allPassed: false,
        passedCount: 0,
        totalCount: all.length,
        error:
            StringsManager.executionFailureMessage('customObjectsInThisLanguage', const <String, Object?>{}),
      );
    }

    final frontend = frontendFor(problem.language);
    final results = <SingleTestCaseResult>[];
    String? firstError;

    for (final testCase in all) {
      final input = testCase.input.trim();
      final expected = testCase.expectedOutput.trim();

      final argValues = parseTestCaseInput(input);
      final built = problem.language == EditorLanguage.dart
          ? _buildProgram(problem, sig, userCode, argValues)
          : (program: userCode, lineOffset: 0);

      // Built once, so that an in-place function's mutations are visible on
      // the very objects handed to it — that mutated argument *is* the answer
      // for a `void` signature.
      final engineArgs = problem.language == EditorLanguage.dart
          ? const <engine.Value>[]
          : <engine.Value>[for (final param in sig.params) _toEngineValue(argValues[param.name])];

      Failure? failure;
      VmResult? run;
      engine.Value? answer;
      try {
        final userProgram = frontend.parse(built.program);
        // Dart still runs through a generated `main()` built as source text,
        // which the grading suite is pinned against. Every other language
        // goes through the frontend contract's own harness, so no per-language
        // source templates exist anywhere (FR-017).
        final program = problem.language == EditorLanguage.dart
            ? userProgram
            : frontend.buildHarness(
                userProgram: userProgram,
                functionName: sig.name,
                arguments: engineArgs,
                preludeSources: const <String>[],
              );
        final script = Compiler().compileProgram(program);
        final vm =
            Vm(dialect: frontend.dialect, budget: const ExecutionBudget(instructionsPerBudgetCheck: 2000));
        frontend.globals.forEach(vm.defineGlobal);
        run = vm.run(script, timeout: const Duration(seconds: 2));
        failure = run.failure;
        answer = run.returned;
      } on FrontendFailure catch (e) {
        failure = e.toFailure();
      }

      if (failure != null) {
        // Rebase the reported line so it points at the user's original code
        // (e.g. the function's signature inside `class Solution { ... }`)
        // instead of the generated program.
        final line = failure.line + built.lineOffset;
        final message =
            '${failure.kind.name} error (line $line): ${StringsManager.executionFailureMessage(failure.code, failure.data)}';
        results.add(SingleTestCaseResult(
          testCase: testCase,
          passed: false,
          actualOutput: (run?.stdout ?? const <String>[]).isEmpty ? '' : run!.stdout.join('\n'),
          errorMessage: message,
        ));
        firstError ??= message;
        continue;
      }

      // Dart's generated `main()` prints the answer; every other language
      // returns it from the harness. An in-place (`void`) function has
      // mutated its first argument instead, and that argument is the answer.
      final engine.Value? resultValue = problem.language == EditorLanguage.dart
          ? (run!.rawOutput.isEmpty ? null : run.rawOutput.last)
          : (sig.isVoid && engineArgs.isNotEmpty ? engineArgs.first : answer);
      final raw = resultValue == null ? null : _unwrapValue(resultValue);
      // For in-place (`void`) functions the printed value is the mutated
      // first argument, so its shape comes from the first parameter's type.
      final shape = sig.isVoid && sig.params.isNotEmpty
          ? _shapeForType(problem, sig.params.first.type)
          : _shapeForType(problem, sig.returnType);
      final actual = _serialize(raw, shape);
      final expectedCanonical = canonicalString(testValueToRaw(parseValue(expected)));

      results.add(SingleTestCaseResult(
        testCase: testCase,
        passed: normalizeForComparison(actual, problem.comparison) ==
            normalizeForComparison(expectedCanonical, problem.comparison),
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

  ({String program, int lineOffset}) _buildProgram(
    ProblemData problem,
    ParsedFunctionSignature sig,
    String userCode,
    Map<String, TestValue> argValues,
  ) {
    final (code, strippedLines) = _stripSolutionWrapper(userCode);

    final headers = _customObjectHeaders(problem, code);

    // The user provided their own main(): run it as-is (whatever it prints
    // last is treated as the result).
    if (RegExp(r'\bvoid\s+main\s*\(').hasMatch(code)) {
      final program = headers.isEmpty ? code : '${headers.join('\n\n')}\n\n$code';
      return (
        program: program,
        lineOffset: _offsetToOriginal(program, code, strippedLines),
      );
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

    final program = headers.isEmpty
        ? '$code\n\n${buf.toString()}'
        : '${headers.join('\n\n')}\n\n$code\n\n${buf.toString()}';
    return (
      program: program,
      lineOffset: _offsetToOriginal(program, code, strippedLines),
    );
  }

  /// Maps a line in the generated [program] back to the user's original code.
  ///
  /// The stripped user code starts at some program line; its first line was at
  /// `strippedLines + 1` in the original source. Adding the returned offset to
  /// any error line reported against [program] rebases it onto that source.
  int _offsetToOriginal(String program, String code, int strippedLines) {
    if (code.isEmpty) return 0;
    final idx = program.indexOf(code);
    final linesBeforeCode = '\n'.allMatches(program.substring(0, idx)).length;
    return strippedLines - linesBeforeCode;
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
  // Bridging the new engine's Value model to the raw shape
  // object_serializer.dart still expects
  // ---------------------------------------------------------------------

  /// `object_serializer.dart`'s `canonicalString` (and its shape-aware
  /// linked-list/tree serializers, including their cycle guards) still
  /// operate on plain Dart primitives and the legacy `ObjectInstance` —
  /// rewiring them onto the new engine's canonical-value model directly is
  /// Phase 6 (US6, T059-T061) work. Until then, this recursively unwraps a
  /// [engine.Value] into that same raw shape, preserving node identity (via
  /// [seen]) so a cyclic structure still round-trips through the existing
  /// cycle guard correctly.
  /// A parsed test-case argument as a runtime [engine.Value], for the
  /// languages that pass their arguments through `buildHarness` rather than
  /// through generated source text. Collections are built mutable, so an
  /// in-place solution really does modify what it was given.
  engine.Value _toEngineValue(TestValue? value) => _rawToEngineValue(
        value == null ? null : testValueToRaw(value),
      );

  engine.Value _rawToEngineValue(dynamic raw) {
    if (raw == null) return engine.NullValue.instance;
    if (raw is bool) return engine.BoolValue(raw);
    if (raw is int) return engine.IntValue(raw);
    if (raw is double) return engine.NumValue(raw);
    if (raw is String) return engine.StrValue(raw);
    if (raw is List) {
      return engine.ListValue(<engine.Value>[for (final item in raw) _rawToEngineValue(item)]);
    }
    if (raw is Map) {
      final map = engine.MapValue();
      raw.forEach((key, dynamic v) {
        map.entries[_rawToEngineValue(key)] = _rawToEngineValue(v);
      });
      return map;
    }
    throw ArgumentError('$raw has no engine representation');
  }

  dynamic _unwrapValue(engine.Value value, [Map<engine.InstanceValue, ObjectInstance>? seen]) {
    final visited = seen ?? <engine.InstanceValue, ObjectInstance>{};
    switch (value) {
      case engine.IntValue(:final value):
        return value;
      case engine.NumValue(:final value):
        return value;
      case engine.BoolValue(:final value):
        return value;
      case engine.StrValue(:final value):
        return value;
      case engine.NullValue():
      case engine.UndefinedValue():
        return null;
      case engine.ListValue(:final items):
        return items.map((e) => _unwrapValue(e, visited)).toList();
      case engine.TupleValue(:final items):
        return items.map((e) => _unwrapValue(e, visited)).toList();
      case engine.SetValue(:final items):
        return items.map((e) => _unwrapValue(e, visited)).toList();
      case engine.MapValue(:final entries):
        return <dynamic, dynamic>{
          for (final e in entries.entries) _unwrapValue(e.key, visited): _unwrapValue(e.value, visited)
        };
      case engine.InstanceValue():
        final existing = visited[value];
        if (existing != null) return existing;
        final instance = ObjectInstance(value.klass.name, <String, dynamic>{});
        visited[value] = instance;
        value.fields.forEach((key, v) => instance.fields[key] = _unwrapValue(v, visited));
        return instance;
      case engine.FunctionValue():
      case engine.ClassValue():
      case engine.ErrorValue():
      case engine.NativeFunctionValue():
      case engine.IntrinsicMethod():
      case engine.NamespaceValue():
        throw ArgumentError('$value has no raw representation for grading');
    }
  }

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
    return type.trim().replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'<.*>'), '').replaceAll('?', '');
  }

  /// The `default_code` in the JSON wraps the function in `class Solution`
  /// (LeetCode style), sometimes preceded by a `/** ... */` doc comment.
  /// Peel that wrapper off, keeping only its body (which becomes a set of
  /// top-level functions the interpreter can run — it can't parse class
  /// methods).
  ///
  /// Returns the body and how many source lines it started after (so error
  /// lines reported against the body can be rebased onto the original code).
  ///
  /// Only a class named exactly `Solution` is treated as the wrapper:
  /// class-based problems (`MinStack`, `LRUCache`, ...) define the solution
  /// class itself and must be left intact.
  ///
  /// Comments are stripped first (the interpreter ignores them anyway) so the
  /// wrapper detection isn't fooled by a leading doc comment and the class
  /// check in [ProblemRunner._definesClass] can't match class names that only
  /// appear inside comments.
  (String, int) _stripSolutionWrapper(String code) {
    final commentFree = _stripComments(code);
    final match = RegExp(r'^[ \t]*class\s+Solution\s*\{', multiLine: true).firstMatch(commentFree);
    if (match == null) return _trimmed(commentFree);

    final open = commentFree.indexOf('{', match.start);
    final close = _matchingBrace(commentFree, open);
    if (close == -1) return _trimmed(commentFree);
    return _trimmed(commentFree, from: open + 1, to: close);
  }

  /// Returns the index of the `}` that closes the `{` at [open], skipping
  /// braces that appear inside string literals (e.g. `char == '{'`).
  /// Returns -1 when the braces don't balance.
  int _matchingBrace(String source, int open) {
    var depth = 0;
    var i = open;
    while (i < source.length) {
      final ch = source[i];
      if (ch == '"' || ch == "'") {
        final quote = ch;
        i++;
        while (i < source.length && source[i] != quote) {
          if (source[i] == '\\' && i + 1 < source.length) i++;
          i++;
        }
        i++;
        continue;
      }
      if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) return i;
      }
      i++;
    }
    return -1;
  }

  /// Trims [source] (optionally the slice `[from, to)`) and returns the trimmed
  /// string plus the number of newlines before it in the original [source],
  /// i.e. how many lines were consumed before the kept text.
  (String, int) _trimmed(String source, {int? from, int? to}) {
    final kept = source.substring(from ?? 0, to ?? source.length).trim();
    final start = source.indexOf(kept, from ?? 0);
    return (
      kept,
      '\n'.allMatches(source.substring(0, start)).length,
    );
  }

  /// Removes `//` line comments and (nested) `/* ... */` block comments,
  /// leaving string literals untouched. Mirrors the lexer's comment rules so
  /// the surrounding code is unchanged.
  ///
  /// Newlines inside block comments are preserved so line numbers in the
  /// stripped code still match the original source.
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
          if (source[i] == '\n') buf.write('\n');
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
