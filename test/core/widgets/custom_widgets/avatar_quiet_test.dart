import 'package:algorithm_visualizer/core/widgets/custom_widgets/avatar_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the initial in a square of the given size', (tester) async {
    await pumpApp(tester, const Center(child: AvatarQuiet(initial: 'A', size: 48)));

    expect(find.text('A'), findsOneWidget);
    expect(tester.getSize(find.byType(AvatarQuiet)), const Size(48, 48));
  });
}
