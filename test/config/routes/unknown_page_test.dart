import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/screen_matrix.dart';

void main() {
  testScreenMatrix('says the page is unknown, with a way back', (tester, variant) async {
    await pumpApp(
      tester,
      const SizedBox(),
      initialRoute: '/no-such-page',
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );
    await tester.pump();

    expect(find.text(StringsManager.unknownPage), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the view alone centres its message', (tester) async {
    await pumpApp(tester, const UnknownView());

    expect(
      find.ancestor(of: find.text(StringsManager.unknownPage), matching: find.byType(Center)),
      findsWidgets,
    );
  });
}
