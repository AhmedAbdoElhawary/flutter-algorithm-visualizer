// Is text readable, in both themes, on every surface it can land on?
//
// The app has one palette per brightness and every widget reaches it through
// `context.getColor(ThemeEnum.x)`. That indirection is what makes light mode
// possible at all — and it is also what makes a regression invisible: nudging
// one constant in `ColorManager` can leave a caption unreadable on a screen
// nobody re-opened.
//
// So this resolves the roles the way a widget does — through a real
// `AppTheme` — and holds each pairing to the WCAG tier it actually belongs to.

import 'dart:math' as math;

import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative-luminance contrast: `(L1 + 0.05) / (L2 + 0.05)`.
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Surfaces a widget can be drawn on: the page, a card, a raised chip.
const _surfaces = <ThemeEnum>[ThemeEnum.ground, ThemeEnum.surface, ThemeEnum.raised];

/// Roles that carry running text, so they owe the full AA 4.5:1.
const _bodyInks = <ThemeEnum>[ThemeEnum.inkPrimary, ThemeEnum.inkTitle, ThemeEnum.inkSecondaryTitle];

/// The difficulty and state colours. They appear as chips, bars and short
/// labels rather than paragraphs, so the 3:1 UI-component tier is the honest
/// bar — the same one the pathfinding role test uses.
const _dataRoles = <ThemeEnum>[
  ThemeEnum.dataEasy,
  ThemeEnum.dataMedium,
  ThemeEnum.dataHard,
  ThemeEnum.dataTarget,
];

/// Structural lines: a divider has to be *seen* without competing with the
/// content it separates, so it is bounded on both sides.
const _structure = <ThemeEnum>[ThemeEnum.hairline, ThemeEnum.track];

const double _aaText = 4.5;
const double _aaLargeOrUi = 3.0;
const double _structureMin = 1.1;
const double _structureMax = 2.0;

/// Resolves every [ThemeEnum] through a real [AppTheme], exactly as
/// `context.getColor` does inside a widget.
Future<Map<ThemeEnum, Color>> _resolve(WidgetTester tester, Brightness brightness) async {
  late Map<ThemeEnum, Color> resolved;

  // `AppTheme` sizes the app bar with ScreenUtil, so it cannot be built until
  // ScreenUtilInit has run — the same wrapper every other theme test uses.
  await tester.pumpWidget(
    ScreenUtilInit(
      // A key that differs per brightness. Without it a second `pumpWidget`
      // in the same test reuses the element tree and quietly keeps the first
      // theme — which would let "the palettes differ" pass by comparing dark
      // against itself.
      key: ValueKey<Brightness>(brightness),
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        home: Builder(
          builder: (context) {
            resolved = <ThemeEnum, Color>{
              for (final role in ThemeEnum.values)
                if (role != ThemeEnum.transparentColor) role: context.getColor(role),
            };
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  await tester.pump();

  return resolved;
}

void main() {
  for (final brightness in <Brightness>[Brightness.dark, Brightness.light]) {
    final name = brightness == Brightness.dark ? 'dark' : 'light';

    group('$name theme', () {
      testWidgets('body text clears AA on every surface', (tester) async {
        final c = await _resolve(tester, brightness);

        for (final ink in _bodyInks) {
          for (final surface in _surfaces) {
            final ratio = _contrastRatio(c[ink]!, c[surface]!);
            expect(
              ratio,
              greaterThanOrEqualTo(_aaText),
              reason: '${ink.name} on ${surface.name} is ${ratio.toStringAsFixed(2)}:1 '
                  '($name), below AA $_aaText',
            );
          }
        }
      });

      testWidgets('muted captions clear the large-text tier on every surface', (tester) async {
        final c = await _resolve(tester, brightness);

        for (final surface in _surfaces) {
          final ratio = _contrastRatio(c[ThemeEnum.inkThirdTitle]!, c[surface]!);
          expect(
            ratio,
            greaterThanOrEqualTo(_aaLargeOrUi),
            reason: 'inkMuted on ${surface.name} is ${ratio.toStringAsFixed(2)}:1 ($name)',
          );
        }
      });

      testWidgets('difficulty and state colours clear the UI tier on every surface', (tester) async {
        final c = await _resolve(tester, brightness);

        for (final role in _dataRoles) {
          for (final surface in _surfaces) {
            final ratio = _contrastRatio(c[role]!, c[surface]!);
            expect(
              ratio,
              greaterThanOrEqualTo(_aaLargeOrUi),
              reason: '${role.name} on ${surface.name} is ${ratio.toStringAsFixed(2)}:1 ($name)',
            );
          }
        }
      });

      testWidgets('dividers are visible without shouting', (tester) async {
        final c = await _resolve(tester, brightness);

        for (final line in _structure) {
          for (final surface in <ThemeEnum>[ThemeEnum.ground, ThemeEnum.surface]) {
            final ratio = _contrastRatio(c[line]!, c[surface]!);
            expect(
              ratio,
              inInclusiveRange(_structureMin, _structureMax),
              reason: '${line.name} on ${surface.name} is ${ratio.toStringAsFixed(2)}:1 ($name)',
            );
          }
        }
      });

      testWidgets('the page and a card on it are actually different', (tester) async {
        final c = await _resolve(tester, brightness);

        expect(
          c[ThemeEnum.ground],
          isNot(c[ThemeEnum.surface]),
          reason: 'a card would be invisible against the page in $name',
        );
        expect(c[ThemeEnum.surface], isNot(c[ThemeEnum.raised]));
      });

      testWidgets('every role resolves to something, so no widget falls back to primaryColor',
          (tester) async {
        final c = await _resolve(tester, brightness);

        for (final role in ThemeEnum.values) {
          if (role == ThemeEnum.transparentColor) continue;
          expect(c[role], isNotNull, reason: '${role.name} has no mapping in $name');
        }
      });
    });
  }

  testWidgets('the two themes really are different palettes', (tester) async {
    final dark = await _resolve(tester, Brightness.dark);
    final light = await _resolve(tester, Brightness.light);

    // Not an aesthetic claim — this is what catches `_pick` being wired to
    // return the same branch for both, which would make light mode a no-op
    // that still passes every contrast test above.
    for (final role in <ThemeEnum>[...(_surfaces), ...(_bodyInks)]) {
      expect(dark[role], isNot(light[role]), reason: '${role.name} is identical in both themes');
    }
  });
}
