import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage, EditorLanguageX;
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_language_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_data.dart';
import 'editor_test_harness.dart';

void main() {
  final allThree = buildTestProblem().copyWith(defaultCode: {'dart': 'd', 'python': 'p', 'javascript': 'j'});

  testWidgets('shows the current language', (tester) async {
    await pumpEditorPiece(tester, const EditorLanguageMenu(problemId: 1), allThree);

    expect(find.text(EditorLanguage.dart.displayName), findsOneWidget);
  });

  testWidgets('opens to every language the problem offers, and picking one switches to it', (tester) async {
    final container = await pumpEditorPiece(tester, const EditorLanguageMenu(problemId: 1), allThree);

    await tester.tap(find.byType(EditorLanguageMenu));
    await tester.pumpAndSettle();
    expect(find.text(EditorLanguage.python.displayName), findsOneWidget);
    expect(find.text(EditorLanguage.javascript.displayName), findsOneWidget);

    await tester.tap(find.text(EditorLanguage.python.displayName));
    await tester.pumpAndSettle();

    expect(container.read(codeEditorControllerProvider(1)).language, EditorLanguage.python);
    expect(find.text(EditorLanguage.javascript.displayName), findsNothing, reason: 'the menu closed');
  });

  testWidgets('a problem in Dart only greys the others out, and tapping one does nothing', (tester) async {
    final container = await pumpEditorPiece(tester, const EditorLanguageMenu(problemId: 1), buildTestProblem());

    await tester.tap(find.byType(EditorLanguageMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(EditorLanguage.python.displayName));
    await tester.pumpAndSettle();

    expect(container.read(codeEditorControllerProvider(1)).language, EditorLanguage.dart);
    expect(find.text(EditorLanguage.python.displayName), findsOneWidget, reason: 'the menu stays open');
  });

  testWidgets('tapping outside closes it without switching', (tester) async {
    final container = await pumpEditorPiece(tester, const EditorLanguageMenu(problemId: 1), allThree);

    await tester.tap(find.byType(EditorLanguageMenu));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 700));
    await tester.pumpAndSettle();

    expect(find.text(EditorLanguage.python.displayName), findsNothing);
    expect(container.read(codeEditorControllerProvider(1)).language, EditorLanguage.dart);
  });

  testWidgets('closing the page with the menu open cleans it up', (tester) async {
    await pumpEditorPiece(tester, const EditorLanguageMenu(problemId: 1), allThree);
    await tester.tap(find.byType(EditorLanguageMenu));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());

    expect(find.text(EditorLanguage.python.displayName), findsNothing);
  });
}

