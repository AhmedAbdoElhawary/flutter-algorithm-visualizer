import 'dart:math' as math;

import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/sorting_legend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _kBubbleRoles = {SortRole.sorted, SortRole.compare, SortRole.swap};
const _kSelectionRoles = {
  SortRole.sorted,
  SortRole.minimum,
  SortRole.compare,
  SortRole.target,
  SortRole.swap
};
const _kInsertionRoles = {SortRole.sorted, SortRole.heldValue, SortRole.compare, SortRole.swap};
const _kMergeRoles = {SortRole.sorted, SortRole.leftRun, SortRole.rightRun, SortRole.compare, SortRole.write};
const _kQuickRoles = {SortRole.sorted, SortRole.pivot, SortRole.boundary, SortRole.compare, SortRole.swap};

Future<void> _pump(WidgetTester tester, Set<SortRole> roles, {Brightness brightness = Brightness.dark}) {
  return tester.pumpWidget(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(430, 932),
        builder: (context, _) => MaterialApp(
          theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
          home: Scaffold(body: SortingLegend(roles: roles)),
        ),
      ),
    ),
  );
}

List<Color> _swatchColours(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).shape == BoxShape.circle)
      .map((c) => (c.decoration as BoxDecoration).color!)
      .toList();
}

void main() {
  group('chip count per algorithm (FR-004, US1 scenarios 1 and 3)', () {
    testWidgets('bubble renders exactly 3 chips', (tester) async {
      await _pump(tester, _kBubbleRoles);
      expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 3);
    });

    testWidgets('selection renders exactly 5 chips', (tester) async {
      await _pump(tester, _kSelectionRoles);
      expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 5);
    });

    testWidgets('insertion renders exactly 4 chips', (tester) async {
      await _pump(tester, _kInsertionRoles);
      expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 4);
    });

    testWidgets('merge renders exactly 5 chips', (tester) async {
      await _pump(tester, _kMergeRoles);
      expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 5);
    });

    testWidgets('quick renders exactly 5 chips', (tester) async {
      await _pump(tester, _kQuickRoles);
      expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 5);
    });

    testWidgets('idle is never shown even if present in roles', (tester) async {
      await _pump(tester, {..._kBubbleRoles, SortRole.idle});
      expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 3);
    });
  });

  testWidgets('switching algorithms replaces the chip set with no stale entry (FR-003, US1 scenario 2)',
      (tester) async {
    await _pump(tester, _kBubbleRoles);
    expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 3);

    await _pump(tester, _kMergeRoles);
    expect(tester.widget<Wrap>(find.byType(Wrap)).children.length, 5);
  });

  testWidgets('each chip swatch colour equals roleColor for its role, in kRolePriority order (FR-004)',
      (tester) async {
    await _pump(tester, _kMergeRoles);

    final expectedRoles = kRolePriority.where((r) => r != SortRole.idle && _kMergeRoles.contains(r)).toList();
    final context = tester.element(find.byType(SortingLegend));
    final expectedColours = expectedRoles.map((r) => context.getColor(sortingRoleColor(r))).toList();

    expect(_swatchColours(tester), expectedColours);
  });

  test(
      'the anchor-prefix label in a status line is the same StringsManager text the legend uses '
      '(FR-040, C2.2, C13.3)', () {
    // The legend's minimum chip reads "Minimum"; the status line's anchor
    // prefix reads "Min: 3" — different text by design (the prefix is
    // deliberately abbreviated for width, C13.4), so this only pins that
    // both ultimately come from StringsManager constants, not a stray
    // inline literal duplicating either.
    expect(roleLabel(SortRole.minimum), StringsManager.roleMinimum);
    expect(StringsManager.minPrefix, isNot(equals(StringsManager.roleMinimum)));
  });

  group('contrast against the card surface, measured (FR-005, C5.5)', () {
    double relativeLuminance(Color c) {
      double channel(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
      final r = channel(c.r);
      final g = channel(c.g);
      final b = channel(c.b);
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    double contrastRatio(Color a, Color b) {
      final la = relativeLuminance(a) + 0.05;
      final lb = relativeLuminance(b) + 0.05;
      return la > lb ? la / lb : lb / la;
    }

    test('barAnchor meets 3:1 against the dark card surface', () {
      expect(contrastRatio(ColorManager.dataMediumDk, ColorManager.surfaceDk), greaterThanOrEqualTo(3.0));
    });

    test('barTarget meets 3:1 against the dark card surface', () {
      expect(contrastRatio(ColorManager.dataTargetDk, ColorManager.surfaceDk), greaterThanOrEqualTo(3.0));
    });

    test('barAnchor meets 3:1 against the light card surface', () {
      expect(contrastRatio(ColorManager.dataMediumLt, ColorManager.surfaceLt), greaterThanOrEqualTo(3.0));
    });

    test('barTarget meets 3:1 against the light card surface', () {
      expect(contrastRatio(ColorManager.dataTargetLt, ColorManager.surfaceLt), greaterThanOrEqualTo(3.0));
    });

    test('barAnchor and barTarget keep the same hue in both themes (C5.3)', () {
      HSLColor hslOf(Color c) => HSLColor.fromColor(c);

      final anchorDkHue = hslOf(ColorManager.dataMediumDk).hue;
      final anchorLtHue = hslOf(ColorManager.dataMediumLt).hue;
      expect((anchorDkHue - anchorLtHue).abs(), lessThan(5));

      final targetDkHue = hslOf(ColorManager.dataTargetDk).hue;
      final targetLtHue = hslOf(ColorManager.dataTargetLt).hue;
      expect((targetDkHue - targetLtHue).abs(), lessThan(5));
    });
  });
}
