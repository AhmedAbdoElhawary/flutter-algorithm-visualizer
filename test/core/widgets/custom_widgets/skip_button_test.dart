import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/skip_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('skips when tapped, with a finger-sized target', (tester) async {
    var skipped = 0;
    await pumpApp(tester, Material(child: SkipButton(onSkip: () => skipped++)));

    await tester.tap(find.text(StringsManager.onboardingSkip));

    expect(skipped, 1);
    expect(tester.getSize(find.byType(InkResponse)), const Size(44, 44));
  });
}
