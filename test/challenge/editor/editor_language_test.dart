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
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_language_menu.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_title_row.dart';
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

  group('the language menu in the editor', () {
    /// Opens the drop-down.
    Future<void> openMenu(WidgetTester tester) async {
      await tester.tap(find.byType(EditorLanguageMenu));
      await tester.pumpAndSettle();
    }

    /// One row of the open menu. Matched by its file-extension label, which
    /// only the menu rows carry — the trigger shows the name alone.
    Finder entry(String extension) => find.text(extension);

    Future<void> choose(WidgetTester tester, String extension) async {
      await openMenu(tester);
      await tester.tap(entry(extension));
      await tester.pumpAndSettle();
    }

    testWidgets('sits in the title row, showing the current language', (tester) async {
      await pumpEditorPage(tester, problem: buildGradableTestProblem());

      expect(
        find.descendant(of: find.byType(EditorTitleRow), matching: find.byType(EditorLanguageMenu)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(EditorLanguageMenu), matching: find.text('Dart')),
        findsOneWidget,
      );
    });

    testWidgets('lists every language even when the problem offers only one', (tester) async {
      // A Dart-only problem still lists all three, so the choice looks the
      // same everywhere. The other two are marked, not missing.
      await pumpEditorPage(tester, problem: buildGradableTestProblem());
      await openMenu(tester);

      expect(find.text('Python'), findsOneWidget);
      expect(find.text('JavaScript'), findsOneWidget);
      // Dart twice: once on the trigger, once on its row.
      expect(find.text('Dart'), findsNWidgets(2));
    });

    testWidgets('a language the problem does not offer says so and does nothing', (tester) async {
      await pumpEditorPage(tester, problem: buildGradableTestProblem());
      await openMenu(tester);

      // The reason is on the row for a screen reader, where there is room
      // for a sentence; on screen it is the dimmed dash.
      expect(
        tester.getSemantics(find.text('Python')).getSemanticsData().hint,
        contains(StringsManager.dartOnlyProblem),
      );

      await tester.tap(find.text('Python'));
      await tester.pumpAndSettle();

      expect(tester.widget<EditorCodeCard>(find.byType(EditorCodeCard)).language, EditorLanguage.dart);
    });

    testWidgets('choosing a language closes the menu', (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem().copyWith(
          defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
        ),
      );
      await choose(tester, '.py');

      expect(find.text('.py'), findsNothing, reason: 'the menu should have closed behind the choice');
    });

    testWidgets('tapping away closes the menu without changing anything', (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem().copyWith(
          defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
        ),
      );
      await openMenu(tester);
      expect(find.text('.py'), findsOneWidget);

      await tester.tapAt(const Offset(10, 400));
      await tester.pumpAndSettle();

      expect(find.text('.py'), findsNothing);
      expect(tester.widget<EditorCodeCard>(find.byType(EditorCodeCard)).language, EditorLanguage.dart);
    });

    testWidgets('switching language changes the editor language with no prompt', (tester) async {
      await pumpEditorPage(
        tester,
        problem: buildGradableTestProblem().copyWith(
          defaultCode: <String, String>{'dart': gradableCorrectCode, 'python': pythonAdd},
        ),
      );

      expect(tester.widget<EditorCodeCard>(find.byType(EditorCodeCard)).language, EditorLanguage.dart);

      await choose(tester, '.py');

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

      await choose(tester, '.py');
      expect(editorText(), contains('def add'));

      await choose(tester, '.dart');
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
