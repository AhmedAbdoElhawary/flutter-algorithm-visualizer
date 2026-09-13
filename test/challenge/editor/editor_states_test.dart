import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/empty_state_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/loading_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/error_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_title_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/problem_page_test_support.dart';

void main() {
  group('EditorPage — the four getProblemProvider(problemId) outcomes (FR-024)', () {
    testWidgets('loading renders the loading state', (tester) async {
      await pumpEditorPage(
        tester,
        problemId: 1,
        problemsAsync: const AsyncValue.loading(),
      );

      expect(find.byType(ChallengesLoadingState), findsOneWidget);
      expect(find.byType(EditorTitleRow), findsNothing);
    });

    testWidgets('error renders the standard error state', (tester) async {
      await pumpEditorPage(
        tester,
        problemId: 1,
        problemsAsync: AsyncValue.error(Exception('boom'), StackTrace.empty),
      );

      expect(find.byType(ChallengesErrorState), findsOneWidget);
      expect(find.byType(EditorTitleRow), findsNothing);
    });

    testWidgets('data(null) renders the empty state reading "no challenge selected"', (tester) async {
      await pumpEditorPage(
        tester,
        problemId: 999,
        problemsAsync: const AsyncValue.data([]),
      );

      expect(find.byType(EmptyStateQuiet), findsOneWidget);
      expect(find.text(StringsManager.noChallengeSelected), findsOneWidget);
      expect(find.byType(EditorTitleRow), findsNothing);
    });

    testWidgets('data(problem) renders the editor', (tester) async {
      final problem = buildTestProblem(problemId: 1, name: 'Two Sum');

      await pumpEditorPage(tester, problem: problem);

      expect(find.byType(EditorTitleRow), findsOneWidget);
      expect(find.byType(EditorCodeCard), findsOneWidget);
      expect(find.text('Two Sum'), findsOneWidget);
    });
  });
}
