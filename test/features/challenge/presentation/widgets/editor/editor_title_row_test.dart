import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/editor/code_controller.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_language_menu.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_title_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_data.dart';
import 'editor_test_harness.dart';

void main() {
  // The back button needs a router to build.
  Widget inRouter(Widget child) => MaterialApp.router(
        routerConfig: GoRouter(routes: [GoRoute(path: '/', builder: (context, state) => child)]),
      );

  testWidgets('shows the name, the language menu and a copy button', (tester) async {
    await pumpEditorPiece(
      tester,
      inRouter(const EditorTitleRow(problemName: 'Two Sum', problemId: 1)),
      buildTestProblem(),
    );

    expect(find.text('Two Sum'), findsOneWidget);
    expect(find.byType(EditorLanguageMenu), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });

  testWidgets('copy does nothing until an editor is attached', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final container = await pumpEditorPiece(
      tester,
      inRouter(const EditorTitleRow(problemName: 'Two Sum', problemId: 1)),
      buildTestProblem(),
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    expect(container.read(codeEditorControllerProvider(1)).copied, isFalse);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('copy turns into a tick for a second', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final container = await pumpEditorPiece(
      tester,
      inRouter(const EditorTitleRow(problemName: 'Two Sum', problemId: 1)),
      buildTestProblem(),
    );
    final editor = CodeController(text: 'code');
    addTearDown(editor.dispose);
    container.read(codeEditorControllerProvider(1).notifier).attachCodeController(editor);

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });

  testWidgets('a long name stays on one line on a small screen with large text', (tester) async {
    const name = 'Find the Minimum Number of Operations to Make Every Element of the Array Equal';
    await pumpEditorPiece(
      tester,
      inRouter(const EditorTitleRow(problemName: name, problemId: 1)),
      buildTestProblem(),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(find.text(name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
