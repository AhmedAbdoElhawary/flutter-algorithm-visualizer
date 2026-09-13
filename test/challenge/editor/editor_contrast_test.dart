import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// WCAG contrast ratio between two colours — `(L1 + 0.05) / (L2 + 0.05)`,
/// `L1` the lighter relative luminance (SC-007, research R10).
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Alpha-composites [top] over [base] ("over" operator) — needed before
/// measuring contrast against a translucent role (light theme's
/// `codeLine`, `0x0A000000`): [Color.computeLuminance] reads raw RGB and
/// ignores alpha, so an un-composited translucent black reads as opaque
/// black instead of the faint tint it actually renders as.
Color _compositeOver(Color top, Color base) {
  final a = top.a;
  double mix(double t, double b) => t * a + b * (1 - a);
  return Color.from(
    alpha: 1,
    red: mix(top.r, base.r),
    green: mix(top.g, base.g),
    blue: mix(top.b, base.b),
  );
}

class _Pair {
  const _Pair(this.fg, this.bg, this.minRatio, this.label);
  final ThemeEnum fg;
  final ThemeEnum bg;
  final double minRatio;
  final String label;
}

const _bodyMin = 4.5;
const _largeMin = 3.0;

const _pairs = [
  _Pair(ThemeEnum.textPrimary, ThemeEnum.codeBg, _bodyMin, 'textPrimary on codeBg'),
  _Pair(ThemeEnum.textBody, ThemeEnum.codeBg, _bodyMin, 'textBody on codeBg'),
  // Line-number gutter text is supplementary UI, not read-for-meaning body
  // content — WCAG's UI-component tier (3:1) applies, not the 4.5:1 body
  // tier (constitution: "WCAG AA (4.5:1 body, 3:1 large text and glyphs)").
  _Pair(ThemeEnum.codeGutter, ThemeEnum.codeBg, _largeMin, 'codeGutter on codeBg'),
  // Same tier as codeGutter above, and the same artboard hex — comments are
  // de-emphasized/skimmable by design, not primary reading content.
  _Pair(ThemeEnum.codeComment, ThemeEnum.codeBg, _largeMin, 'codeComment on codeBg'),
  _Pair(ThemeEnum.codeKeyword, ThemeEnum.codeBg, _bodyMin, 'codeKeyword on codeBg'),
  _Pair(ThemeEnum.codeType, ThemeEnum.codeBg, _bodyMin, 'codeType on codeBg'),
  _Pair(ThemeEnum.codePlain, ThemeEnum.codeBg, _bodyMin, 'codePlain on codeBg'),
  _Pair(ThemeEnum.codeNumber, ThemeEnum.codeBg, _bodyMin, 'codeNumber on codeBg'),
  _Pair(ThemeEnum.textPrimary, ThemeEnum.codeLine, _bodyMin, 'textPrimary on codeLine (marked row)'),
  _Pair(ThemeEnum.codeComment, ThemeEnum.mainCard, _largeMin, 'section label on mainCard'),
  _Pair(ThemeEnum.difficultyEasy, ThemeEnum.mainCard, _bodyMin, 'difficultyEasy summary on mainCard'),
  _Pair(ThemeEnum.textBody, ThemeEnum.mainCard, _bodyMin, 'textBody on mainCard'),
  _Pair(ThemeEnum.difficultyHard, ThemeEnum.mainCard, _bodyMin, 'difficultyHard on mainCard'),
  _Pair(ThemeEnum.difficultyEasy, ThemeEnum.chipEasyFill, _largeMin, 'difficultyEasy glyph on chipEasyFill'),
  _Pair(ThemeEnum.difficultyHard, ThemeEnum.chipHardFill, _largeMin, 'difficultyHard glyph on chipHardFill'),
  _Pair(ThemeEnum.onPrimary, ThemeEnum.textBright, _largeMin, 'onPrimary on textBright (primary action)'),
];

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final brightness in [Brightness.dark, Brightness.light]) {
    testWidgets('every role pair meets its WCAG threshold in $brightness', (tester) async {
      final resolved = <ThemeEnum, Color>{};

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(430, 932),
          builder: (context, _) => MaterialApp(
            theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
            home: Builder(
              builder: (context) {
                for (final pair in _pairs) {
                  resolved[pair.fg] = context.getColor(pair.fg);
                  resolved[pair.bg] = context.getColor(pair.bg);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      final codeBg = resolved[ThemeEnum.codeBg]!;

      for (final pair in _pairs) {
        final fg = resolved[pair.fg]!;
        var bg = resolved[pair.bg]!;
        if (bg.a < 1) bg = _compositeOver(bg, codeBg);
        final ratio = _contrastRatio(fg, bg);

        expect(
          ratio,
          greaterThanOrEqualTo(pair.minRatio),
          reason: '${pair.label} ($brightness): measured $ratio:1 '
              '(fg ${fg.toARGB32().toRadixString(16)}, bg ${bg.toARGB32().toRadixString(16)}), '
              'needs >= ${pair.minRatio}:1',
        );
      }
    });
  }
}
