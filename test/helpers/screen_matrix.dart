import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';

class ScreenVariant {
  const ScreenVariant(this.screen, this.theme, this.textScale);

  final ScreenSize screen;
  final ThemeMode theme;
  final double textScale;

  /// Shows in the test name, so a failure says which combination broke.
  @override
  String toString() => '${screen.name} · ${theme.name} · ${textScale.toStringAsFixed(1)}x';
}

final screenVariants = ValueVariant<ScreenVariant>({
  for (final screen in ScreenSize.values)
    for (final theme in [ThemeMode.light, ThemeMode.dark])
      for (final textScale in [1.0, 2.0]) ScreenVariant(screen, theme, textScale),
});

/// For render tests only. Pass the variant's fields on to [pumpApp].
void testScreenMatrix(String description, Future<void> Function(WidgetTester, ScreenVariant) body) {
  testWidgets(description, (tester) => body(tester, screenVariants.currentValue!), variant: screenVariants);
}
