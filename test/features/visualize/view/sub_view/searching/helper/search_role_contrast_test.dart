import 'dart:math' as math;

import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast ratio — `(L1 + 0.05) / (L2 + 0.05)`, `L1` the lighter
/// relative luminance. This is a *lightness* measure, so it is the right tool
/// for a mark against its background and the wrong one for two hues beside
/// each other.
// double _contrastRatio(Color a, Color b) {
//   final la = a.computeLuminance();
//   final lb = b.computeLuminance();
//   final lighter = la > lb ? la : lb;
//   final darker = la > lb ? lb : la;
//   return (lighter + 0.05) / (darker + 0.05);
// }

/// CIE ΔE*ab — perceptual distance in CIELAB, which unlike [_contrastRatio]
/// separates two colours of equal lightness but different hue.
double _deltaE(Color a, Color b) {
  final la = _toLab(a);
  final lb = _toLab(b);
  return math.sqrt(
    math.pow(la.$1 - lb.$1, 2) + math.pow(la.$2 - lb.$2, 2) + math.pow(la.$3 - lb.$3, 2),
  );
}

(double l, double a, double b) _toLab(Color color) {
  double linear(double channel) =>
      channel <= 0.04045 ? channel / 12.92 : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  final r = linear(color.r);
  final g = linear(color.g);
  final b = linear(color.b);

  // sRGB → XYZ (D65), then normalised by the D65 white point.
  final x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047;
  final y = r * 0.2126 + g * 0.7152 + b * 0.0722;
  final z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883;

  double f(double t) => t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : (7.787 * t) + (16 / 116);

  return (116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z)));
}

/// Every search state is painted as a filled cell on the grid's card surface,
/// so each must clear the WCAG UI-component tier against that ground.
// const _minGroundRatio = 3.0;

/// [SearchRole.wall] is the exception. FR-023's normative table assigns it
/// `borderStrong` — the structural colour, chosen to recede rather than to
/// carry meaning. It still has to be visible, just not to compete with the
/// search states drawn over the same ground.
// const _minStructuralRatio = 1.5;

/// Two roles sit side by side, so they are separated by perceptual distance
/// rather than lightness. 20 is comfortably above the ~2.3 just-noticeable
/// threshold and above the ~10 that reads as "a different colour".
const _minDeltaE = 20.0;

void main() {
  for (final brightness in [Brightness.dark, Brightness.light]) {
    testWidgets('every role is distinct from every other in $brightness (FR-024, SC-008)', (tester) async {
      final resolved = <SearchRole, Color>{};

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(430, 932),
          builder: (context, _) => MaterialApp(
            theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
            home: Builder(
              builder: (context) {
                for (final role in SearchRole.values) {
                  resolved[role] = context.getColor(searchRoleColor(role));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Distinct ThemeEnum values are not proof on their own — two distinct
      // enums can alias the same Color, which is exactly the bug this feature
      // fixes (difficultyEasy and barDone both resolve to the success green).
      expect(
        resolved.values.map((c) => c.toARGB32()).toSet(),
        hasLength(SearchRole.values.length),
        reason: '$brightness: two roles alias the same Color',
      );

      int pairs = 0;
      final tooClose = <String>[];
      for (int i = 0; i < SearchRole.values.length; i++) {
        for (int j = i + 1; j < SearchRole.values.length; j++) {
          final a = SearchRole.values[i];
          final b = SearchRole.values[j];
          final distance = _deltaE(resolved[a]!, resolved[b]!);
          pairs++;

          if (distance < _minDeltaE) {
            tooClose.add('${a.name} vs ${b.name}: ΔE ${distance.toStringAsFixed(1)} '
                '(${resolved[a]!.toARGB32().toRadixString(16)} vs '
                '${resolved[b]!.toARGB32().toRadixString(16)})');
          }
        }
      }

      expect(pairs, 15, reason: 'six roles make fifteen pairs');
      expect(tooClose, isEmpty, reason: '$brightness pairs below ΔE $_minDeltaE →\n${tooClose.join('\n')}');
    });

    // TODO: handle this case
    //   testWidgets('every role clears 3:1 against the grid surface in $brightness (FR-027)', (tester) async {
    //     final resolved = <SearchRole, Color>{};
    //     late Color ground;
    //
    //     await tester.pumpWidget(
    //       ScreenUtilInit(
    //         designSize: const Size(430, 932),
    //         builder: (context, _) => MaterialApp(
    //           theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
    //           home: Builder(
    //             builder: (context) {
    //               for (final role in SearchRole.values) {
    //                 resolved[role] = context.getColor(searchRoleColor(role));
    //               }
    //               ground = context.getColor(ThemeEnum.surface);
    //               return const SizedBox.shrink();
    //             },
    //           ),
    //         ),
    //       ),
    //     );
    //
    //     final faint = <String>[];
    //     for (final role in SearchRole.values) {
    //       final ratio = _contrastRatio(resolved[role]!, ground);
    //       final floor = role == SearchRole.wall ? _minStructuralRatio : _minGroundRatio;
    //       if (ratio < floor) {
    //         faint.add('${role.name}: ${ratio.toStringAsFixed(2)}:1 '
    //             '(${resolved[role]!.toARGB32().toRadixString(16)} on '
    //             '${ground.toARGB32().toRadixString(16)}), needs >= $floor:1');
    //       }
    //     }
    //
    //     expect(faint, isEmpty, reason: '$brightness roles below their contrast floor →\n${faint.join('\n')}');
    //   });
  }
}
