import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_data.dart';
import 'challenge_list_harness.dart';

void main() {
  for (final bookmarked in [false, true]) {
    testWidgets(bookmarked ? 'a filled mark removes the bookmark' : 'an empty mark adds a bookmark', (tester) async {
      final problem = buildTestProblem(isBookmarked: bookmarked);
      final piece = await pumpListPiece(
        tester,
        BookmarkButton(isBookmarked: bookmarked, problem: problem),
        problems: [problem],
      );

      expect(find.byIcon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded), findsOneWidget);

      await tester.tap(find.byType(BookmarkButton));
      await tester.pumpAndSettle();

      expect(piece.repository.updated.single.getIsBookmarked, !bookmarked);
      expect(piece.container.read(problemsProvider).value!.single.getIsBookmarked, !bookmarked);
    });
  }
}
