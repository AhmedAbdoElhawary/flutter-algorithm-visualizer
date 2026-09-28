import 'package:algorithm_visualizer/core/widgets/custom_widgets/tag_chip.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/challenge_tags.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';
import 'challenge_list_harness.dart';

void main() {
  testWidgets('one chip per tag, in order', (tester) async {
    await pumpListPiece(tester, const ChallengeTags(tags: ['Array', 'Hash Map']));

    expect(tester.widgetList<TagChip>(find.byType(TagChip)).map((chip) => chip.label), ['Array', 'Hash Map']);
  });

  testWidgets('no tags shows nothing', (tester) async {
    await pumpListPiece(tester, const ChallengeTags(tags: []));

    expect(find.byType(TagChip), findsNothing);
  });

  testWidgets('many long tags wrap on a small screen with large text', (tester) async {
    await pumpListPiece(
      tester,
      ChallengeTags(tags: [for (var i = 0; i < 10; i++) 'Dynamic Programming $i']),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
