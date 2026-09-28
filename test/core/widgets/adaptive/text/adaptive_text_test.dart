import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_test_support.dart';

void main() {
  group('the weight widgets', () {
    testWidgets('cut long text with an ellipsis after two lines by default', (tester) async {
      final text = await textOnScreen(tester, const RegularText('A long label'));

      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('keep their tracking in English', (tester) async {
      final text = await textOnScreen(tester, const BoldText('AlgoDive', letterSpacing: -0.5));

      expect(text.style!.letterSpacing, -0.5);
    });

    testWidgets('drop tracking in Arabic, where it breaks the joined letters', (tester) async {
      final text = await textOnScreen(tester, const BoldText('AlgoDive', letterSpacing: -0.5), arabic: true);

      expect(text.style!.letterSpacing, 0);
    });

    testWidgets('an underline gets a thickness, plain text none', (tester) async {
      final underlined = await textOnScreen(
        tester,
        const RegularText('Terms', decoration: TextDecoration.underline),
      );
      expect(underlined.style!.decorationThickness, isNotNull);

      final plain = await textOnScreen(tester, const RegularText('Terms'));
      expect(plain.style!.decorationThickness, isNull);
    });

    testWidgets('content that is not ours is shown as is', (tester) async {
      const code = RegularText('def add(a, b):', translate: false);
      final text = await textOnScreen(tester, code, arabic: true);

      expect(text.data, 'def add(a, b):');
    });
  });

  group('AdaptiveText', () {
    testWidgets('with no style, regular at the base size', (tester) async {
      final text = await textOnScreen(tester, const AdaptiveText('Sorting'));

      expect(text.style!.fontWeight, FontWeight.w400);
      expect(text.style!.fontSize, 16);
      expect(text.maxLines, 2);
    });

    testWidgets('a given style keeps its look, sized for the screen', (tester) async {
      final text = await textOnScreen(
        tester,
        const AdaptiveText(
          'Sorting',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          maxLines: 1,
        ),
      );

      expect(text.style!.fontWeight, FontWeight.w700);
      expect(text.style!.fontSize, 20);
      expect(text.maxLines, 1);
    });

    testWidgets('a style with tracking keeps it in English and drops it in Arabic', (tester) async {
      const tracked = AdaptiveText('Sorting', style: TextStyle(letterSpacing: 1.2));

      expect((await textOnScreen(tester, tracked)).style!.letterSpacing, 1.2);
      expect((await textOnScreen(tester, tracked, arabic: true)).style!.letterSpacing, 0);
    });

    testWidgets('untranslated content is shown as is', (tester) async {
      final text = await textOnScreen(tester, const AdaptiveText('x = 1', translate: false), arabic: true);

      expect(text.data, 'x = 1');
    });
  });
}
