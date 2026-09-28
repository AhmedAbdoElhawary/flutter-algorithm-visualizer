import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fakes/fake_problem_repository.dart';
import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_data.dart';

/// The bookmarks list the way the bookmarks page builds it.
class _Bookmarks extends ConsumerWidget {
  const _Bookmarks({required this.onTap});

  final void Function(CodingProblem) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref.watch(problemsProvider).value!.where((problem) => problem.getIsBookmarked).toList();
    return ListView(
      children: [for (final problem in bookmarked) BookmarkRow(problem: problem, onTap: () => onTap(problem))],
    );
  }
}

void main() {
  final problems = [
    buildTestProblem(problemId: 1, name: 'Two Sum', isBookmarked: true, problemStatus: ProblemStatus.solved),
    buildTestProblem(problemId: 2, name: 'Three Sum', isBookmarked: true, tags: const ['Array', 'Two Pointers', 'Sorting']),
  ];

  late FakeProblemRepository repository;
  final tapped = <int>[];

  Future<void> pumpBookmarks(WidgetTester tester, {ScreenSize screen = ScreenSize.phone, double textScale = 1}) async {
    repository = FakeProblemRepository();
    tapped.clear();
    await pumpApp(
      tester,
      Scaffold(body: _Bookmarks(onTap: (problem) => tapped.add(problem.getProblemId))),
      overrides: [
        problemRepositoryProvider.overrideWithValue(repository),
        problemsProvider.overrideWithBuild((ref, notifier) => AsyncValue.data(problems)),
      ],
      screen: screen,
      textScale: textScale,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the name and at most two tags', (tester) async {
    await pumpBookmarks(tester);

    expect(find.text('Three Sum'), findsOneWidget);
    expect(find.text('Array'), findsNWidgets(2));
    expect(find.text('Two Pointers'), findsOneWidget);
    expect(find.text('Sorting'), findsNothing);
  });

  testWidgets('tapping the row opens it', (tester) async {
    await pumpBookmarks(tester);

    await tester.tap(find.text('Two Sum'));

    expect(tapped, [1]);
  });

  testWidgets('tapping the bookmark removes it', (tester) async {
    await pumpBookmarks(tester);

    await tester.tap(find.byIcon(Icons.bookmark_rounded).first);
    await tester.pumpAndSettle();

    expect(repository.updated.single.getIsBookmarked, isFalse);
    expect(find.byType(BookmarkRow), findsOneWidget);
  });

  testWidgets('swiping removes it cleanly', (tester) async {
    await pumpBookmarks(tester);

    await tester.fling(find.text('Two Sum'), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(repository.updated.single.getProblemId, 1);
    expect(find.text('Two Sum'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpBookmarks(tester, screen: ScreenSize.smallPhone, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
