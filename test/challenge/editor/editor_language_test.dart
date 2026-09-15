// The language picker and the per-language drafts behind it.
//
// The promise being tested is a narrow one but the whole point of offering a
// choice: switching language never costs the learner work, and never asks
// them to confirm anything (SC-018). A language is offered if and only if the
// problem has starter code for it (FR-027a).

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show CodeEditor, EditorLanguage, EditorLanguageX;
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_language_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

const pythonAdd = 'def add(a, b):\n    return a + b\n';
const javascriptAdd = 'function add(a, b) {\n  return a + b\n}\n';

void main() {
  group('which languages are offered', () {
    test('a problem with only Dart starter code offers only Dart', () {
      final problem = buildGradableTestProblem();
      expect(problem.languagesAvailable, <EditorLanguage>[EditorLanguage.dart]);
    });

    test('adding starter code for a language is all it takes to offer it', () {
      final problem = buildGradableTestProblem().copyWith(
        defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
      );
      expect(problem.languagesAvailable, <EditorLanguage>[EditorLanguage.dart, EditorLanguage.python]);
    });

    test('empty or whitespace-only starter code does not count as offering a language', () {
      final problem = buildGradableTestProblem().copyWith(
        defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': '   \n'},
      );
      expect(problem.languagesAvailable, <EditorLanguage>[EditorLanguage.dart]);
    });

    test('Dart is always offered, even with no starter code, because it has a signature stub', () {
      final problem = buildGradableTestProblem().copyWith(defaultCode: <String, String>{});
      expect(problem.languagesAvailable, contains(EditorLanguage.dart));
    });

    test('the starter code for each language is the one the dataset gives', () {
      final problem = buildGradableTestProblem().copyWith(
        defaultCode: <String, String>{
          'dart': gradableCorrectCode,
          'python': pythonAdd,
          'javascript': javascriptAdd,
        },
      );
      expect(problem.getDefaultCodeFor(EditorLanguage.python), pythonAdd);
      expect(problem.getDefaultCodeFor(EditorLanguage.javascript), javascriptAdd);
      expect(problem.getDefaultCodeFor(EditorLanguage.dart), gradableCorrectCode);
    });

    test('a saved draft is preferred over the starter code, per language', () {
      final problem = buildGradableTestProblem(
        solutionsStatus: <ProblemSolutionStatusDTO>[
          const ProblemSolutionStatusDTO(code: 'my python draft', isCorrect: false, language: 'python'),
        ],
      ).copyWith(
        defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
      );
      expect(problem.getCodeFor(EditorLanguage.python), 'my python draft');
      expect(problem.getCodeFor(EditorLanguage.dart), gradableCorrectCode);
    });

    test('a solution saved before languages existed reads as Dart', () {
      const saved = ProblemSolutionStatusDTO(code: 'old dart draft', isCorrect: true);
      expect(saved.languageKey, 'dart');

      final problem = buildGradableTestProblem(
        solutionsStatus: const <ProblemSolutionStatusDTO>[saved],
      );
      expect(problem.getCodeFor(EditorLanguage.dart), 'old dart draft');
    });
  });

  group('the picker in the editor', () {
    /// Scoped to the picker, because the card header also prints the file
    /// name — which ends in the language too.
    Finder chip(String label) =>
        find.descendant(of: find.byType(EditorLanguagePicker), matching: find.text(label));

    testWidgets('is absent when there is nothing to choose between', (tester) async {
      await pumpEditorPage(tester, problem: buildGradableTestProblem());

      expect(find.byType(EditorLanguagePicker), findsOneWidget);
      // Rendered, but deliberately empty: one language is not a choice.
      expect(chip('Dart'), findsNothing);
    });

    testWidgets('lists exactly the languages the problem offers', (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem().copyWith(
          defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
        ),
      );

      expect(chip('Dart'), findsOneWidget);
      expect(chip('Python'), findsOneWidget);
      expect(chip('JavaScript'), findsNothing);
    });

    testWidgets('switching language changes the editor language with no prompt', (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem().copyWith(
          defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
        ),
      );

      expect(tester.widget<EditorCodeCard>(find.byType(EditorCodeCard)).language, EditorLanguage.dart);

      await tester.tap(chip('Python'));
      await tester.pumpAndSettle();

      expect(tester.widget<EditorCodeCard>(find.byType(EditorCodeCard)).language, EditorLanguage.python);
      // No confirmation of any kind stood between the two.
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('switching shows that language starter code, and switching back keeps the edit',
        (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem().copyWith(
          defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
        ),
      );

      // The code area paints its text rather than using Text widgets, so the
      // controller is what to read.
      String editorText() => tester.widget<CodeEditor>(find.byType(CodeEditor)).controller.text;

      expect(editorText(), contains('int add'));

      // Edit the Dart draft, then leave it.
      tester.widget<CodeEditor>(find.byType(CodeEditor)).controller.text =
          'int add(int a, int b) { return 99; }';
      await tester.pumpAndSettle();

      await tester.tap(chip('Python'));
      await tester.pumpAndSettle();
      expect(editorText(), contains('def add'));

      await tester.tap(chip('Dart'));
      await tester.pumpAndSettle();
      expect(editorText(), contains('99'), reason: 'the Dart draft should have survived the round trip');
    });

    testWidgets('the editor opens in the language of the most recent saved draft', (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem(
          solutionsStatus: <ProblemSolutionStatusDTO>[
            ProblemSolutionStatusDTO(
              code: pythonAdd,
              isCorrect: true,
              language: 'python',
              submittedAt: DateTime(2026, 1, 2),
            ),
            ProblemSolutionStatusDTO(
              code: gradableCorrectCode,
              isCorrect: true,
              language: 'dart',
              submittedAt: DateTime(2026),
            ),
          ],
        ).copyWith(
          defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
        ),
      );

      expect(tester.widget<EditorCodeCard>(find.byType(EditorCodeCard)).language, EditorLanguage.python);
    });
  });

  group('the language names the picker shows', () {
    test('read the way a learner writes them', () {
      expect(EditorLanguage.dart.displayName, 'Dart');
      expect(EditorLanguage.python.displayName, 'Python');
      expect(EditorLanguage.javascript.displayName, 'JavaScript');
    });

    test('map to the keys the dataset uses', () {
      expect(EditorLanguage.dart.datasetKey, 'dart');
      expect(EditorLanguage.python.datasetKey, 'python');
      expect(EditorLanguage.javascript.datasetKey, 'javascript');
    });
  });
}
