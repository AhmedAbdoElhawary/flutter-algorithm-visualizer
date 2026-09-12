import 'package:flutter/material.dart';

/// CoreDive design tokens. Names match README.md and coredive_tokens.css.
/// Never use a raw hex, size or radius outside this file.

class CdDark {
  static const bgBase = Color(0xFF050605);
  static const bgRaised = Color(0xFF0A0C0B);
  static const surface = Color(0xFF0C0E0D);
  static const surfaceAlt = Color(0xFF1A1F1D);

  /// Brass-tinted card. Streak and XP surfaces only.
  static const surfaceWarm = Color(0xFF15100A);
  static const borderSubtle = Color(0xFF1C201E);
  static const border = Color(0xFF222725);
  static const borderStrong = Color(0xFF31372F);

  static const primary = Color(0xFFE0A33E);
  static const primaryHover = Color(0xFFF0BC63);
  static const primaryPress = Color(0xFFC9922E);
  static const onPrimary = Color(0xFF1A1206);
  static const primaryTint = Color(0x24E0A33E);
  static const primaryRing = Color(0x29E0A33E);

  /// XP IS the brand colour — identity and progress are deliberately the same brass.
  static const accentXp = primaryPress;
  static const accentXpText = primary;
  static const onAccentXp = onPrimary;

  static const textPrimary = Color(0xFFF5F7F6);
  static const textBody = Color(0xFFB9BEBB);
  static const textSecondary = Color(0xFF7E8582);
  static const textDisabled = Color(0xFF5C6360);

  static const success = Color(0xFF4FC38C);

  /// Burnt orange, NOT amber — amber is the brand colour.
  static const warning = Color(0xFFD97742);
  static const error = Color(0xFFDF5B67);
  static const onError = Color(0xFF2A0709);

  static const difficultyEasy = success;
  static const difficultyMedium = warning;
  static const difficultyHard = error;

  // Visualizer states, all from the app palette: brass = comparing (the
  // algorithm's hand), white = the held element, red = the swap frame,
  // green = settled, neutral = at rest. Burnt orange is reserved for
  // difficultyMedium and never appears in the plot.
  static const barIdle = Color(0xFF4E5A57);
  static const barCompare = primary;
  static const barSwap = error;
  static const barKey = textPrimary;
  static const barSorted = success;
  static const barExcluded = Color(0xFF262B29);
  static const barLabelIdle = textSecondary;
  static const barLabelActive = textPrimary;
  @Deprecated('Use barSorted')
  static const barDone = success;

  static const codeBg = bgRaised;
  static const codeGutter = Color(0xFF4A4F49);
  static const codeLine = Color(0x12E0A33E);
  static const codeKeyword = Color(0xFFD97742);
  static const codeType = Color(0xFFF0BC63);
  static const codePlain = textBody;
  static const codePunct = Color(0xFFE8EAE9);
  static const codeNumber = Color(0xFF4FC38C);
  static const codeComment = textDisabled;

  static const heat = <Color>[
    Color(0xFF1A1F1D), Color(0xFF5C3F12), Color(0xFFC9922E), Color(0xFFF0BC63),
  ];
}

class CdLight {
  static const bgBase = Color(0xFFFAF8F4);
  static const bgRaised = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF2EEE6);
  static const surfaceWarm = Color(0xFFFBF3E3);
  static const borderSubtle = Color(0xFFEFEBE2);
  static const border = Color(0xFFE5E0D6);
  static const borderStrong = Color(0xFFCBC4B5);

  static const primary = Color(0xFF8F6216);
  static const primaryHover = Color(0xFFA9761D);
  static const primaryPress = Color(0xFF734E0F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryTint = Color(0x1A8F6216);
  static const primaryRing = Color(0x298F6216);

  static const accentXp = primary;
  static const accentXpText = primaryPress;
  static const onAccentXp = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF12100C);
  static const textBody = Color(0xFF2E2A22);
  static const textSecondary = Color(0xFF6B665C);
  static const textDisabled = Color(0xFFA09A8D);

  static const success = Color(0xFF1B7F5A);
  static const warning = Color(0xFFA85426);
  static const error = Color(0xFFC1414D);
  static const onError = Color(0xFFFFFFFF);

  static const difficultyEasy = success;
  static const difficultyMedium = warning;
  static const difficultyHard = error;

  static const barIdle = Color(0xFFC3CBC8);
  static const barCompare = primary;
  static const barSwap = error;
  static const barKey = textPrimary;
  static const barSorted = success;
  static const barExcluded = Color(0xFFEFEBE2);
  static const barLabelIdle = textSecondary;
  static const barLabelActive = textPrimary;
  @Deprecated('Use barSorted')
  static const barDone = success;

  static const codeBg = Color(0xFFF5F2EB);
  static const codeGutter = Color(0xFFA6A093);
  static const codeLine = Color(0x148F6216);
  static const codeKeyword = Color(0xFFA85426);
  static const codeType = primary;
  static const codePlain = textBody;
  static const codePunct = textPrimary;
  static const codeNumber = success;
  static const codeComment = textDisabled;

  static const heat = <Color>[
    Color(0xFFEFEBE2), Color(0xFFE8CE96), Color(0xFFC9922E), Color(0xFF8F6216),
  ];
}

class CdSpace {
  static const double x1 = 4, x2 = 8, x3 = 12, x4 = 16, x6 = 24, x8 = 32, x12 = 48, x16 = 64;
  static const double screenInset = 16, authInset = 24;
  static const EdgeInsets card = EdgeInsets.symmetric(vertical: 16, horizontal: 18);
  static const EdgeInsets row = EdgeInsets.symmetric(vertical: 13, horizontal: 14);
  static const double gapCard = 14, gapRow = 8;
  static const double tabBarHeight = 74, ctaReserve = 134, hitMin = 44;
}

class CdRadius {
  static const double sm = 9, md = 13, lg = 19, xl = 24, pill = 999;
}

class CdElevation {
  static const e1 = <BoxShadow>[BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1))];
  static const e2 = <BoxShadow>[BoxShadow(color: Color(0x73000000), blurRadius: 18, offset: Offset(0, 6))];
  static const e3 = <BoxShadow>[BoxShadow(color: Color(0xB3000000), blurRadius: 60, offset: Offset(0, 24))];
  static const glow = <BoxShadow>[BoxShadow(color: Color(0x42E0A33E), blurRadius: 24, offset: Offset(0, 8))];
}

class CdMotion {
  static const press = Duration(milliseconds: 90);
  static const fade = Duration(milliseconds: 120);
  static const step = Duration(milliseconds: 180);
  static const dialog = Duration(milliseconds: 200);
  static const expand = Duration(milliseconds: 240);
  static const easeOut = Cubic(.2, .8, .4, 1);
  static const easePop = Cubic(.2, 1.3, .4, 1);
}

/// Type scale. [arabic] adds 0.1 to every line-height — the scale is per-script,
/// the family is not: IBM Plex Sans Arabic serves both.
class CdType {
  /// Family names assume either bundled assets under these names or the
  /// google_fonts package (see FONTS.md). If you have neither, pass null for
  /// [ui] and let fontFamilyFallback resolve to the platform's Arabic face.
  static const ui = 'IBMPlexSansArabic';
  static const mono = 'JetBrainsMono';

  /// Used when the primary family is unavailable — covers Latin and Arabic
  /// on iOS/macOS (SF Arabic is the system default), Android and Windows.
  static const uiFallback = <String>['Noto Sans Arabic', 'Segoe UI', 'Arial'];
  static const monoFallback = <String>['Menlo', 'Roboto Mono', 'Cascadia Mono', 'monospace'];

  static TextStyle _s(double size, FontWeight w, double lh, {double? track, bool mono = false, bool arabic = false}) =>
      TextStyle(
        fontFamily: mono ? CdType.mono : ui,
        fontFamilyFallback: mono ? monoFallback : uiFallback,
        fontSize: size,
        fontWeight: w,
        height: arabic ? lh + 0.1 : lh,
        letterSpacing: track,
      );

  static TextStyle display({bool ar = false}) => _s(26, FontWeight.w700, 1.23, track: -0.52, arabic: ar);
  static TextStyle h1({bool ar = false}) => _s(21, FontWeight.w700, 1.24, track: -0.21, arabic: ar);
  static TextStyle h2({bool ar = false}) => _s(17, FontWeight.w700, 1.29, arabic: ar);
  static TextStyle h3({bool ar = false}) => _s(13, FontWeight.w600, 1.38, arabic: ar);
  static TextStyle bodyLg({bool ar = false}) => _s(13.5, FontWeight.w400, 1.63, arabic: ar);
  static TextStyle body({bool ar = false}) => _s(12.5, FontWeight.w400, 1.68, arabic: ar);
  static TextStyle label({bool ar = false}) => _s(11, FontWeight.w500, 1.27, arabic: ar);
  static TextStyle caption({bool ar = false}) => _s(10.5, FontWeight.w400, 1.52, arabic: ar);
  static TextStyle eyebrow({bool ar = false}) => _s(10, FontWeight.w600, 1.2, track: 1.0, arabic: ar);
  static TextStyle code() => _s(11.5, FontWeight.w400, 1.74, mono: true);
}

/// Wire these into ThemeData / a ThemeExtension so widgets read semantic names only.
ThemeData cdDarkTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CdDark.bgBase,
      fontFamily: CdType.ui,
      colorScheme: const ColorScheme.dark(
        primary: CdDark.primary,
        onPrimary: CdDark.onPrimary,
        surface: CdDark.surface,
        onSurface: CdDark.textPrimary,
        error: CdDark.error,
        onError: CdDark.onError,
        outline: CdDark.border,
      ),
    );

ThemeData cdLightTheme() => ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: CdLight.bgBase,
      fontFamily: CdType.ui,
      colorScheme: const ColorScheme.light(
        primary: CdLight.primary,
        onPrimary: CdLight.onPrimary,
        surface: CdLight.surface,
        onSurface: CdLight.textPrimary,
        error: CdLight.error,
        onError: CdLight.onError,
        outline: CdLight.border,
      ),
    );
