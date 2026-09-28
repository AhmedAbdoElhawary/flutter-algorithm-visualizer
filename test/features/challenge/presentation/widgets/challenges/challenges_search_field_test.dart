import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/challenges_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'challenge_list_harness.dart';

void main() {
  testWidgets('empty, it shows the hint and no clear button', (tester) async {
    await pumpListPiece(tester, const ChallengesSearchField());

    expect(find.text(StringsManager.searchProblem), findsOneWidget);
    expect(find.text('×'), findsNothing);
  });

  testWidgets('typing searches, and × clears both the text and the search', (tester) async {
    final piece = await pumpListPiece(tester, const ChallengesSearchField());

    await tester.enterText(find.byType(TextField), 'two');
    await tester.pump();
    expect(piece.container.read(challengesProvider).search, 'two');

    await tester.tap(find.text('×'));
    await tester.pump();

    expect(piece.container.read(challengesProvider).search, '');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    expect(find.text('×'), findsNothing);
  });
}
