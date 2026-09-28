import 'package:algorithm_visualizer/core/widgets/custom_widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('tapping the child opens the popup, animating in', (tester) async {
    await pumpApp(tester, const AnimatedPopup(builder: _dialog, child: Text('Open')));

    await tester.tap(find.text('Open'));
    await tester.pump();
    final opacity = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('Are you sure?'), matching: find.byType(FadeTransition)).first,
    );
    expect(opacity.opacity.value, lessThan(1));

    await tester.pumpAndSettle();
    expect(opacity.opacity.value, 1);
  });

  testWidgets('the builder can close it', (tester) async {
    await pumpApp(tester, const AnimatedPopup(builder: _dialog, child: Text('Open')));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure?'), findsNothing);
  });

  testWidgets('tapping outside closes it, tapping the card does not', (tester) async {
    await pumpApp(tester, const AnimatedPopup(builder: _dialog, child: Text('Open')));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Are you sure?'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsNothing);
  });

  testWidgets('show opens it with no child, from code', (tester) async {
    await pumpApp(tester, const Scaffold(body: SizedBox()));

    AnimatedPopup.show(tester.element(find.byType(SizedBox).last), builder: _dialog);
    await tester.pumpAndSettle();

    expect(find.text('Are you sure?'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets('the keyboard pushes the card up instead of covering it', (tester) async {
    await pumpApp(tester, const AnimatedPopup(builder: _dialog, child: Text('Open')));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final before = tester.getCenter(find.text('Are you sure?')).dy;

    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('Are you sure?')).dy, lessThan(before));
    expect(tester.takeException(), isNull);
  });
}

Widget _dialog(VoidCallback close) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Are you sure?'),
        TextButton(onPressed: close, child: const Text('Close')),
      ],
    );
