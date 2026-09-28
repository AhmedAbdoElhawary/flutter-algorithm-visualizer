import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_test_case_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  TestCaseResult result(String input, {required bool passed}) => TestCaseResult(
        input: input,
        expectedOutput: '[0,1]',
        actualOutput: passed ? '[0,1]' : '[]',
        passed: passed,
      );

  Future<void> pumpCard(WidgetTester tester, CodeGradeResult grade, {double textScale = 1}) => pumpApp(
        tester,
        Scaffold(body: SingleChildScrollView(child: EditorTestCaseCard(grade: grade))),
        screen: textScale > 1 ? ScreenSize.smallPhone : ScreenSize.phone,
        textScale: textScale,
      );

  testWidgets('shows how many passed, and up to three cases with failures first', (tester) async {
    await pumpCard(
      tester,
      CodeGradeResult(
        allTestCaseResults: [
          result('case-one', passed: true),
          result('case-two', passed: false),
          result('case-three', passed: true),
          result('case-four', passed: true),
        ],
        totalCount: 4,
        code: '',
      ),
    );

    expect(find.text(StringsManager.testCases), findsOneWidget);
    expect(find.textContaining('3'), findsWidgets);
    expect(find.textContaining('${StringsManager.gotPrefix}[]'), findsOneWidget);
    expect(find.text('case-two'), findsOneWidget);
    expect(find.text('case-four'), findsNothing, reason: 'only three rows');
    final rows = ['case-two', 'case-one', 'case-three'].map((input) => tester.getTopLeft(find.text(input)).dy).toList();
    expect(rows, orderedEquals([...rows]..sort()), reason: 'the failure comes first');
  });

  testWidgets('a program that never ran shows its error instead of rows', (tester) async {
    await pumpCard(
      tester,
      const CodeGradeResult(allTestCaseResults: [], totalCount: 4, code: '', error: 'Expected a ) on line 1'),
    );

    expect(find.text('Expected a ) on line 1'), findsOneWidget);
    expect(find.textContaining(StringsManager.gotPrefix), findsNothing);
  });

  testWidgets('long outputs fit a small screen with large text', (tester) async {
    await pumpCard(
      tester,
      CodeGradeResult(
        allTestCaseResults: [
          TestCaseResult(
            input: 'nums = [${List.filled(60, 7).join(',')}]',
            expectedOutput: '[${List.filled(40, 1).join(',')}]',
            actualOutput: '[${List.filled(40, 2).join(',')}]',
            passed: false,
          ),
        ],
        totalCount: 1,
        code: '',
      ),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
