import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/pump_app.dart';
import '../../../../../../helpers/screen_matrix.dart';

void main() {
  testScreenMatrix('names every role and fits the screen', (tester, variant) async {
    await pumpApp(
      tester,
      const Scaffold(body: PFLegend()),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    for (final role in kSearchRolePriority) {
      expect(find.text(searchRoleLabel(role)), findsOneWidget, reason: role.name);
    }
    expect(tester.takeException(), isNull);
  });
}
