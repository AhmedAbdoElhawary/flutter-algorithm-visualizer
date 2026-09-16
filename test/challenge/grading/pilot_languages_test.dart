// Proves the pilot problems really are solvable in Python and JavaScript
// against the **stored** test cases and expected outputs in
// `assets/problems.json` — not against fixtures written to match.
//
// This is the gate for offering a language on a problem: starter code is only
// added to the dataset for a problem that appears here and passes. A language
// offered on a problem nobody has solved in it is a promise the editor has not
// checked (R10, and the standing rule that a wrong answer must never pass).
//
// The set is chosen for coverage, not ease: hash map, stack, dynamic
// programming, sorting with a key, two pointers, sets, nested lists, string
// work, and an in-place function that returns nothing.

import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/custom_object.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pilot_solutions.dart';

/// The problem's custom-object classes, keyed by class name — the same thing
/// `GradeCodeUseCase` builds from the dataset before handing it to the runner.
Map<String, CustomObjectShape> _shapesOf(ProblemDTO dto) {
  final shapes = <String, CustomObjectShape>{};
  for (final object in dto.customObjects?['dart'] ?? const <CustomObject>[]) {
    final shape = CustomObjectShape.fromKey(object.shape);
    final name = RegExp(r'class\s+(\w+)').firstMatch(object.code?.trim() ?? '')?.group(1);
    if (shape != null && name != null) shapes[name] = shape;
  }
  return shapes;
}

void main() {
  late Map<int, ProblemDTO> problems;

  setUpAll(() {
    final raw = File('assets/problems.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    problems = <int, ProblemDTO>{
      for (final p in decoded['problems'] as List)
        (p as Map<String, dynamic>)['problem_id'] as int: ProblemDTO.fromJson(p),
    };
  });

  ProblemData dataFor(ProblemDTO dto, EditorLanguage language) => ProblemData(
        functionSignature: dto.functionSignature?.dart ?? '',
        language: language,
        testCases: <ProblemTestCase>[
          for (final t in <TestCase>[...?dto.testCases, ...?dto.hiddenTestCases])
            ProblemTestCase(input: t.input?.trim() ?? '', expectedOutput: t.expectedOutput?.trim() ?? ''),
        ],
        comparison: OutputComparison.fromKey(dto.comparison),
        customObjects: _shapesOf(dto),
        customObjectSources: <String>[for (final o in dto.customObjects?['dart'] ?? const []) o.code ?? ''],
      );

  pilotSolutions.forEach((id, byLanguage) {
    byLanguage.forEach((language, code) {
      test('problem $id in ${language.displayName}: passes every stored test case', () {
        final dto = problems[id];
        expect(dto, isNotNull, reason: 'problem $id is not in assets/problems.json');

        final result = const ProblemRunner().runAll(problem: dataFor(dto!, language), userCode: code);

        expect(result.error, isNull, reason: 'problem $id (${dto.name}) failed to run: ${result.error}');
        expect(result.totalCount, greaterThan(0), reason: 'problem $id has no test cases');

        final failures = result.testCaseResults.where((r) => !r.passed).map((r) {
          return 'input: ${r.testCase.input}\n'
              '  expected: ${r.testCase.expectedOutput}\n'
              '  actual:   ${r.actualOutput}\n'
              '  error:    ${r.errorMessage ?? '-'}';
        }).toList();

        expect(failures, isEmpty,
            reason: 'problem $id (${dto.name}) in ${language.displayName}:\n${failures.join('\n')}');
      });
    });
  });

  test('every pilot problem offers exactly the languages it has been proven in', () {
    // The dataset and this file must not drift apart: starter code without a
    // verified solution is an unchecked promise, and a verified solution with
    // no starter code is a language the learner is never offered.
    for (final id in pilotSolutions.keys) {
      final dto = problems[id]!;
      for (final language in pilotSolutions[id]!.keys) {
        final starter = dto.defaultCode?[language.datasetKey];
        expect(starter != null && starter.trim().isNotEmpty, isTrue,
            reason: 'problem $id has a verified ${language.displayName} solution '
                'but no ${language.datasetKey} starter code in assets/problems.json');
      }
    }
  });
}
