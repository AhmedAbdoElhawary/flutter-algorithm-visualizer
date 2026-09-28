import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_test_support.dart';

void main() {
  testWidgets('draws in its own weight, in the title ink by default', (tester) async {
    final text = await textOnScreen(tester, const SemiBoldText('Sorting'));

    expect(text.data, 'Sorting');
    expect(text.style!.fontWeight, FontWeightManager.semiBold);
    expect(text.style!.color, tester.element(find.byType(Text)).getColor(ThemeEnum.inkTitle));
  });

  testWidgets('the colour follows the theme', (tester) async {
    final text = await textOnScreen(tester, const SemiBoldText('Sorting'), theme: ThemeMode.dark);

    expect(text.style!.color, tester.element(find.byType(Text)).getColor(ThemeEnum.inkTitle));
  });
}
