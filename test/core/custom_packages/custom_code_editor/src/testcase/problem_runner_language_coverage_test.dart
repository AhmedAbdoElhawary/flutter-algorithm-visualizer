// The gate for offering Python and JavaScript on every problem that can take
// them. Same rule as the pilot set (`pilot_languages_test.dart`): starter code
// is only added to `assets/problems.json` for a problem proven solvable here,
// against the **stored** test cases and expected outputs.
//
// Solutions live in `coverage_solutions.dart` so this file stays a runner.

import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/custom_object.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'coverage_solutions.dart';
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

  coverageSolutions.forEach((id, byLanguage) {
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

  test('every problem offering a language has a verified solution in it', () {
    // The dataset must never promise a language nobody has solved the problem
    // in. Design problems (zero test cases) are the one exception: there is
    // nothing to grade, so the starter template is the whole deliverable.
    final verified = <int, Set<EditorLanguage>>{};
    for (final source in <Map<int, Map<EditorLanguage, String>>>[pilotSolutions, coverageSolutions]) {
      source.forEach((id, m) => verified.putIfAbsent(id, () => <EditorLanguage>{}).addAll(m.keys));
    }

    final unproven = <String>[];
    problems.forEach((id, dto) {
      final gradable = (dto.testCases?.isNotEmpty ?? false) || (dto.hiddenTestCases?.isNotEmpty ?? false);
      if (!gradable) return;
      for (final language in supportedLanguages) {
        if (language == EditorLanguage.dart) continue;
        final starter = dto.defaultCode?[language.datasetKey];
        final offered = starter != null && starter.trim().isNotEmpty;
        if (offered && !(verified[id]?.contains(language) ?? false)) {
          unproven.add('problem $id (${dto.name}) offers ${language.displayName} with no verified solution');
        }
      }
    });

    expect(unproven, isEmpty, reason: unproven.join('\n'));
  });
}
