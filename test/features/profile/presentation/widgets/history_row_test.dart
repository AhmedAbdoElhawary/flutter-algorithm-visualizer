import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bar_chart_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_problem_card.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/practice_history_entry.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/recent_submission.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/history_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../profile_test_data.dart';

void main() {
  RecentSubmission submission(DateTime at, {bool passed = true, String name = 'Two Sum'}) => RecentSubmission(
        problemId: 1,
        problemName: name,
        difficulty: ProblemDifficulty.easy,
        isCorrect: passed,
        submittedAt: at,
      );

  /// [attempts] newest first, as the calculator hands them over.
  PracticeHistoryEntry entry(List<RecentSubmission> attempts) => PracticeHistoryEntry(
        problemId: 1,
        problemName: attempts.first.problemName,
        difficulty: ProblemDifficulty.easy,
        lastResult: attempts.first.isCorrect,
        lastSubmittedAt: attempts.first.submittedAt,
        attempts: attempts,
      );

  bool shownSolved(WidgetTester tester) =>
      tester.widget<SecondaryProblemCard>(find.byType(SecondaryProblemCard)).isSolved;

  testWidgets('shows the name, the attempt count, a bar per attempt, and solved once any passed', (tester) async {
    final now = DateTime.now();
    await pumpProfileWidget(
      tester,
      HistoryRow(entry: entry([submission(now, passed: false), submission(now, passed: true)])),
    );

    expect(find.text('Two Sum'), findsOneWidget);
    expect(find.textContaining('2 submissions'), findsOneWidget);
    expect(find.byType(QuietBar), findsNWidgets(2));
    expect(shownSolved(tester), isTrue);
  });

  testWidgets('never passed shows as not solved', (tester) async {
    await pumpProfileWidget(tester, HistoryRow(entry: entry([submission(DateTime.now(), passed: false)])));

    expect(find.textContaining('1 submission '), findsOneWidget);
    expect(shownSolved(tester), isFalse);
  });

  testWidgets('without the attempt bars when asked', (tester) async {
    await pumpProfileWidget(
      tester,
      HistoryRow(entry: entry([submission(DateTime.now())]), addAttemptsCharts: false),
    );

    expect(find.byType(QuietBar), findsNothing);
  });

  group('the last attempt reads as time ago', () {
    for (final (ago, text) in [
      (const Duration(seconds: 20), StringsManager.justNow),
      (const Duration(minutes: 5), '5${StringsManager.mAgo}'),
      (const Duration(hours: 3), '3${StringsManager.hAgo}'),
      (const Duration(hours: 30), '1 ${StringsManager.dayAgo}'),
      (const Duration(days: 4, hours: 1), '4 ${StringsManager.daysAgo}'),
    ]) {
      testWidgets(text, (tester) async {
        await pumpProfileWidget(tester, HistoryRow(entry: entry([submission(DateTime.now().subtract(ago))])));

        expect(find.textContaining(text), findsOneWidget);
      });
    }
  });

  testWidgets('tapping opens the table of attempts with their dates, tapping again closes it', (tester) async {
    await pumpProfileWidget(
      tester,
      HistoryRow(
        entry: entry([submission(DateTime(2026, 9, 1, 14, 5)), submission(DateTime(2026, 8, 31, 9, 30), passed: false)]),
      ),
    );

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();

    expect(find.text('Sep 1, 2026  14:05'), findsOneWidget);
    expect(find.text('Aug 31, 2026  09:30'), findsOneWidget);
    expect(find.text(StringsManager.passed), findsOneWidget);
    expect(find.text(StringsManager.failed), findsOneWidget);

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.passed), findsNothing);
  });

  testWidgets('the dates follow the app language', (tester) async {
    await pumpProfileWidget(
      tester,
      Builder(
        builder: (context) => Localizations.override(
          context: context,
          locale: const Locale('ar'),
          delegates: const [GlobalMaterialLocalizations.delegate],
          child: HistoryRow(entry: entry([submission(DateTime(2026, 9, 1, 14, 5))])),
        ),
      ),
    );

    await tester.tap(find.text('Two Sum'));
    await tester.pumpAndSettle();

    expect(find.textContaining('سبتمبر'), findsOneWidget);
    expect(find.textContaining('Sep'), findsNothing);
  });

  testWidgets('a long name with many attempts fits a small screen with large text', (tester) async {
    final now = DateTime.now();
    await pumpProfileWidget(
      tester,
      HistoryRow(
        entry: entry([for (var i = 0; i < 12; i++) submission(now, passed: i.isEven, name: longProblemName)]),
      ),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    await tester.tap(find.text(longProblemName));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
