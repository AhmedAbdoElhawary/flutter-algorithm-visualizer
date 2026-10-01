import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart' show EditorLanguage;
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/editor/code_controller.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_controller.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_container.dart';
import '../../../dataset_problem.dart';

const _twoSum = '''
List<int> twoSum(List<int> nums, int target) {
  for (var i = 0; i < nums.length; i++) {
    for (var j = i + 1; j < nums.length; j++) {
      if (nums[i] + nums[j] == target) return [i, j];
    }
  }
  return [];
}''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CodingProblem twoSum;

  setUpAll(() async => twoSum = await datasetProblem(1));

  /// A container holding [problem], with its controller kept alive and an editor attached.
  ({ProviderContainer container, CodeEditorController notifier, CodeController editor}) open(
    CodingProblem? problem, {
    bool attach = true,
  }) {
    final container = createTestContainer(
      overrides: [
        problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([if (problem != null) problem])),
      ],
    );
    final provider = codeEditorControllerProvider(problem?.getProblemId ?? 1);
    container.listen(provider, (previous, next) {});
    final notifier = container.read(provider.notifier);
    final editor = CodeController(text: notifier.initialCode);
    addTearDown(editor.dispose);
    if (attach) notifier.attachCodeController(editor);
    return (container: container, notifier: notifier, editor: editor);
  }

  ProblemSolutionStatusDTO draft(String code, String language, {int day = 1}) =>
      ProblemSolutionStatusDTO(code: code, isCorrect: false, submittedAt: DateTime(2026, 9, day), language: language);

  group('opening', () {
    test('with nothing saved, in Dart with the starter code', () {
      final editor = open(twoSum);

      expect(editor.notifier.initialLanguage, EditorLanguage.dart);
      expect(editor.notifier.initialCode, twoSum.getDefaultCodeFor(EditorLanguage.dart));
    });

    test('in the language of the newest saved draft, with that draft', () {
      final saved = twoSum.copyWith(solutionsStatus: [draft('py code', 'python', day: 2), draft('dart code', 'dart')]);

      final editor = open(saved);

      expect(editor.notifier.initialLanguage, EditorLanguage.python);
      expect(editor.notifier.initialCode, 'py code');
    });

    test('skips a saved language the problem no longer offers', () {
      final dartOnly = twoSum.copyWith(
        defaultCode: {'dart': twoSum.getDefaultCodeFor(EditorLanguage.dart)},
        solutionsStatus: [draft('py code', 'python', day: 2), draft('dart code', 'dart')],
      );

      expect(open(dartOnly).notifier.initialLanguage, EditorLanguage.dart);
    });

    test('a problem that is not loaded opens empty in Dart', () {
      final editor = open(null);

      expect(editor.notifier.initialLanguage, EditorLanguage.dart);
      expect(editor.notifier.initialCode, '');
      expect(editor.notifier.languagesAvailable, [EditorLanguage.dart]);
    });
  });

  group('languages', () {
    test('switching keeps each language draft, so switching back loses nothing', () {
      final editor = open(twoSum);
      editor.editor.text = 'my dart';

      editor.notifier.setLanguage(EditorLanguage.python);
      expect(editor.editor.text, twoSum.getDefaultCodeFor(EditorLanguage.python));
      editor.editor.text = 'my python';

      editor.notifier.setLanguage(EditorLanguage.dart);
      expect(editor.editor.text, 'my dart');
      expect(editor.notifier.draftFor(EditorLanguage.python), 'my python');
      expect(editor.container.read(codeEditorControllerProvider(1)).language, EditorLanguage.dart);
    });

    test('a language the problem does not offer is ignored', () {
      final dartOnly = twoSum.copyWith(defaultCode: {'dart': 'x'});
      final editor = open(dartOnly);

      editor.notifier.setLanguage(EditorLanguage.javascript);

      expect(editor.container.read(codeEditorControllerProvider(1)).language, EditorLanguage.dart);
    });
  });

  group('reset and copy', () {
    test('reset puts back the starter code of this language only', () {
      final editor = open(twoSum);
      editor.editor.text = 'my dart';
      editor.notifier.setLanguage(EditorLanguage.python);
      editor.editor.text = 'my python';

      editor.notifier.resetCode();

      expect(editor.editor.text, twoSum.getDefaultCodeFor(EditorLanguage.python));
      expect(editor.notifier.draftFor(EditorLanguage.dart), 'my dart');
    });

    test('with no editor attached, reset and copy do nothing', () async {
      final editor = open(twoSum, attach: false);

      editor.notifier.resetCode();
      await editor.notifier.copyCode();

      expect(editor.container.read(codeEditorControllerProvider(1)).copied, isFalse);
    });

    testWidgets('copying puts the code on the clipboard and shows "copied" for a second', (tester) async {
      final copied = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text']);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      final editor = open(twoSum);

      await editor.notifier.copyCode();
      expect(editor.container.read(codeEditorControllerProvider(1)).copied, isTrue);
      expect(copied, [editor.editor.text]);

      await tester.pump(const Duration(seconds: 1));
      expect(editor.container.read(codeEditorControllerProvider(1)).copied, isFalse);
    });

    test('attaching the same text twice keeps the first editor', () {
      final editor = open(twoSum);
      final twin = CodeController(text: editor.editor.text);
      addTearDown(twin.dispose);

      editor.notifier.attachCodeController(twin);
      editor.editor.text = 'typed in the first';
      editor.notifier.setLanguage(EditorLanguage.python);

      expect(editor.notifier.draftFor(EditorLanguage.dart), 'typed in the first');
    });
  });

  group('running', () {
    testWidgets('grades straight away, walks the lines, then shows the grade', (tester) async {
      final editor = open(twoSum);
      editor.editor.text = _twoSum;
      CodeGradeResult? graded;

      final run = editor.notifier.runCode((result) => graded = result);
      await tester.pump();
      final state = editor.container.read(codeEditorControllerProvider(1));
      expect(state.isRunning, isTrue);
      expect(graded?.allPassed, isTrue);

      await tester.pump(const Duration(milliseconds: 100));
      expect(editor.container.read(codeEditorControllerProvider(1)).highlightedLine, 1);

      await tester.pump(Duration(milliseconds: 100 * (_twoSum.split('\n').length + 1)));
      await run;
      final done = editor.container.read(codeEditorControllerProvider(1));
      expect(done.isRunning, isFalse);
      expect(done.highlightedLine, -1);
      expect(done.grade, same(graded));
    });

    testWidgets('empty code runs and fails, it is not skipped', (tester) async {
      final editor = open(twoSum);
      editor.editor.text = '';
      CodeGradeResult? graded;

      final run = editor.notifier.runCode((result) => graded = result);
      await tester.pump(const Duration(seconds: 1));
      await run;

      expect(graded, isNotNull);
      expect(graded!.allPassed, isFalse);
    });

    testWidgets('code that never ends is stopped and fails', (tester) async {
      // One case, so the test waits out a single time limit rather than one per case.
      final oneCase = twoSum.copyWith(testCases: [twoSum.getTestCases.first], hiddenTestCases: []);
      final editor = open(oneCase);
      editor.editor.text = 'List<int> twoSum(List<int> nums, int target) { while (true) {} }';
      CodeGradeResult? graded;

      final run = editor.notifier.runCode((result) => graded = result);
      await tester.pump(const Duration(seconds: 1));
      await run;

      expect(graded!.allPassed, isFalse);
      expect(graded!.error ?? graded!.firstThreeTestCaseResults.first.errorMessage, isNotNull);
    });

    testWidgets('a second run while one is going is turned away', (tester) async {
      final editor = open(twoSum);
      editor.editor.text = _twoSum;
      final results = <CodeGradeResult?>[];

      final first = editor.notifier.runCode(results.add);
      await editor.notifier.runCode(results.add);

      expect(results, [isNotNull, isNull]);
      await tester.pump(const Duration(seconds: 2));
      await first;
    });

    testWidgets('switching language mid-run is ignored', (tester) async {
      final editor = open(twoSum);
      editor.editor.text = _twoSum;

      final run = editor.notifier.runCode((result) {});
      editor.notifier.setLanguage(EditorLanguage.python);

      expect(editor.container.read(codeEditorControllerProvider(1)).language, EditorLanguage.dart);
      await tester.pump(const Duration(seconds: 2));
      await run;
    });

    test('with no editor attached it is turned away, and never left running', () async {
      final editor = open(twoSum, attach: false);
      CodeGradeResult? graded = const CodeGradeResult(allTestCaseResults: [], totalCount: 0, code: 'unset');

      await editor.notifier.runCode((result) => graded = result);

      expect(graded, isNull);
      expect(editor.container.read(codeEditorControllerProvider(1)).isRunning, isFalse);
    });

    test('a problem that is not loaded is turned away', () async {
      final editor = open(null);
      CodeGradeResult? graded = const CodeGradeResult(allTestCaseResults: [], totalCount: 0, code: 'unset');

      await editor.notifier.runCode((result) => graded = result);

      expect(graded, isNull);
    });

    testWidgets('leaving mid-run ends the run and writes nothing after', (tester) async {
      final editor = open(twoSum);
      editor.editor.text = _twoSum;

      final run = editor.notifier.runCode((result) {});
      await tester.pump(const Duration(milliseconds: 250));
      editor.container.dispose();

      await expectLater(run, completes);
      await tester.pump(const Duration(seconds: 2));
    });
  });

  test('each problem gets its own controller', () {
    final container = createTestContainer(
      overrides: [problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data([twoSum]))],
    );
    container.listen(codeEditorControllerProvider(1), (previous, next) {});
    container.listen(codeEditorControllerProvider(2), (previous, next) {});

    expect(
      container.read(codeEditorControllerProvider(1).notifier),
      isNot(same(container.read(codeEditorControllerProvider(2).notifier))),
    );
    expect(container.read(codeEditorControllerProvider(1).notifier).problemId, 1);
  });
}
