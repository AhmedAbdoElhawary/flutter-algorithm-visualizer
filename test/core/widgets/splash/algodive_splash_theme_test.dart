// The splash is the one screen drawn with no `MaterialApp` above it, so
// `Theme.of` cannot tell it what the phone is set to — it returns Flutter's
// light fallback on every device. That made the splash paint one fixed look
// for everyone, and an inverted one: the page took `inkPrimary` and the mark
// took `ground`, so a light phone went near-white (native) then near-black
// (Flutter) in the space of one frame.
//
// These tests pin the two things that prevents: the background follows the
// requested brightness, and the mark stays legible on it.

import 'dart:math' as math;

import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/widgets/splash/algodive_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The splash's own background — the [ColoredBox] it wraps everything in.
Future<Color> _backgroundOf(WidgetTester tester, {required bool dark}) async {
  await tester.pumpWidget(
    AlgoDiveSplash(key: ValueKey<bool>(dark), dark: dark, onFinished: () {}),
  );
  await tester.pump();

  final box = tester.widget<ColoredBox>(
    find.descendant(of: find.byType(Directionality), matching: find.byType(ColoredBox)).first,
  );

  // Let the 1s intro finish so no timer is left pending.
  await tester.pumpAndSettle(const Duration(seconds: 2));
  return box.color;
}

void main() {
  testWidgets('a dark launch paints the dark ground, not the ink', (tester) async {
    expect(await _backgroundOf(tester, dark: true), ColorManager.groundDk);
  });

  testWidgets('a light launch paints the light ground', (tester) async {
    expect(await _backgroundOf(tester, dark: false), ColorManager.groundLt);
  });

  testWidgets('the two are not the same screen', (tester) async {
    final dark = await _backgroundOf(tester, dark: true);
    final light = await _backgroundOf(tester, dark: false);

    expect(dark, isNot(light), reason: 'the splash ignores the brightness it was given');
  });

  testWidgets('the mark is legible on whichever ground it lands on', (tester) async {
    // Same pairing the splash itself uses, held to the AA text tier: the
    // wordmark is text, and it is the first thing anyone sees of the app.
    expect(
      _contrastRatio(ColorManager.inkPrimaryDk, ColorManager.groundDk),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(ColorManager.inkPrimaryLt, ColorManager.groundLt),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('the Flutter splash agrees with the native launch screen', (tester) async {
    // `android/app/src/main/res/values/colors.xml` and its `-night` sibling.
    // A mismatch here is a visible flip on the way into the app, which is
    // exactly what the hand-off is supposed to hide.
    const nativeLightBackground = Color(0xFFF4F5F7);
    const nativeDarkBackground = Color(0xFF0B0B0D);

    expect(await _backgroundOf(tester, dark: false), nativeLightBackground);
    expect(await _backgroundOf(tester, dark: true), nativeDarkBackground);
  });
}
