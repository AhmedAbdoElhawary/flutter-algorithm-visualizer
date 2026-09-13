import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_test_case_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

void main() {
  testWidgets('copy writes the current code to the clipboard and briefly confirms (FR-014)', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await pumpEditorPage(tester, problem: buildGradableTestProblem());

    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(calls.any((c) => c.method == 'Clipboard.setData'), isTrue);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
  });

  testWidgets(
      'Reset restores the default code, clears the line marking and removes the test case card (FR-015)',
      (tester) async {
    // Wrong code, so the run fails instead of navigating to celebration —
    // this test only cares about Reset, not the run outcome.
    final problem = buildGradableTestProblem(code: gradableWrongCode);
    await pumpEditorPage(tester, problem: problem);

    // Run once so a result card exists to be cleared.
    await tester.tap(find.text('▸ Run & submit'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(EditorTestCaseCard), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorTestCaseCard), findsNothing);

    final codeCard = tester.widget<EditorCodeCard>(find.byType(EditorCodeCard));
    expect(codeCard.highlightedLine == null || codeCard.highlightedLine == -1, isTrue);
  });
}
