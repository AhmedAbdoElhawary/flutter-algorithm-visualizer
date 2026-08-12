import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:flutter/material.dart';

enum ThemeEnum {
  primary,
  focus,
  card,
  mainCard,
  outputHeader,
  accent,
  borderAccent,
  accentBg,
  accentGreen,
  accentGreenBg,
  accentYellow,
  accentRed,
  accentBlue,
  textSecond,
  textPrimary,
  hover,
  hoverSecond,
  border,

  /// --------------
  howItWorksColor,
  columnColor,
  backgroundForSortingColor,
  white2DarkColor,
  textDarkColor,
  text2DarkColor,
  borderPurpleColor,
  lightPurpleColor,
  codeEditorNumberColor,

  whiteD4Color,
  whiteD5Color,
  whiteD7Color,
  whiteColor,
  transparentColor,

  mediumBlueColor,
  //
}

extension ThemeExtension on BuildContext {
  bool get isThemeDark => Theme.of(this).brightness == Brightness.dark;

  List<BoxShadow> get cardShadow => isThemeDark
      ? []
      : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), spreadRadius: 1),
        ];

  Map<ThemeEnum, Color> get _colors {
    return {
      ThemeEnum.primary: Theme.of(this).primaryColor,
      ThemeEnum.focus: Theme.of(this).focusColor,
      ThemeEnum.card: Theme.of(this).hintColor,
      ThemeEnum.mainCard: ColorManager.mainCardDk,
      ThemeEnum.outputHeader: isThemeDark ? ColorManager.outputHeaderDk : ColorManager.outputHeaderLt,
      ThemeEnum.accent: isThemeDark ? ColorManager.accentDk : ColorManager.accentLt,
      ThemeEnum.borderAccent: isThemeDark
          ? ColorManager.accentDk.withValues(alpha: 0.22)
          : ColorManager.accentLt.withValues(alpha: 0.25),
      ThemeEnum.accentBg: isThemeDark
          ? ColorManager.accentDk.withValues(alpha: 0.12)
          : ColorManager.accentLt.withValues(alpha: 0.08),
      ThemeEnum.accentGreen: isThemeDark ? ColorManager.accentGreenDk : ColorManager.accentGreenLt,
      ThemeEnum.accentGreenBg: isThemeDark
          ? ColorManager.accentGreenDk.withValues(alpha: 0.12)
          : ColorManager.accentGreenLt.withValues(alpha: 0.08),
      ThemeEnum.accentYellow: isThemeDark ? ColorManager.accentYellowDk : ColorManager.accentYellowLt,
      ThemeEnum.accentRed: isThemeDark ? ColorManager.accentRedDk : ColorManager.accentRedLt,
      ThemeEnum.accentBlue: isThemeDark ? ColorManager.accentBlueDk : ColorManager.accentBlueLt,
      ThemeEnum.textSecond: isThemeDark ? ColorManager.textSecondDk : ColorManager.textSecondLt,
      ThemeEnum.textPrimary: isThemeDark ? ColorManager.textPrimaryDk : ColorManager.textPrimaryLt,
      ThemeEnum.hover: isThemeDark ? ColorManager.hoverDk : ColorManager.hoverLt,
      ThemeEnum.hoverSecond: isThemeDark ? ColorManager.hoverSecondDk : ColorManager.hoverSecondLt,
      ThemeEnum.border: isThemeDark ? ColorManager.borderDk : ColorManager.borderLt,

      ///-------------------->
      ThemeEnum.howItWorksColor: ColorManager.howItWorksColor,
      ThemeEnum.white2DarkColor: ColorManager.white2DarkColor,
      ThemeEnum.columnColor: ColorManager.columnSortColor,
      ThemeEnum.backgroundForSortingColor: ColorManager.backgroundForSortingColor,
      ThemeEnum.textDarkColor: ColorManager.textDarkColor,
      ThemeEnum.text2DarkColor: ColorManager.text2DarkColor,
      ThemeEnum.lightPurpleColor: ColorManager.lightPurpleColor,
      ThemeEnum.borderPurpleColor: ColorManager.borderPurpleColor,

      /// what ever dark or light. Maybe if we have multiple themes, it will save a lot of time.
      ThemeEnum.whiteD4Color: ColorManager.grey,

      ThemeEnum.whiteD5Color: ColorManager.whiteD5,
      ThemeEnum.whiteD7Color: ColorManager.whiteD7,
      ThemeEnum.transparentColor: ColorManager.transparent,
      ThemeEnum.whiteColor: ColorManager.white,
      ThemeEnum.codeEditorNumberColor: ColorManager.codeEditorNumberColor,
      ThemeEnum.mediumBlueColor: ColorManager.mediumBlue,
    };
  }

  Color getColor(ThemeEnum color) => _colors[color] ?? Theme.of(this).primaryColor;
}

/*
* import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colour constants ─────────────────────────────────────────────────────────

class AppColors {
  // Dark palette
  static const dkBg = Color(0xFF080D1A);
  static const dkBgCard = Color(0xFF0F1729);
  static const dkBgElevated = Color(0xFF162035);
  static const dkBgInput = Color(0xFF1A2538);
  static const dkAccent = Color(0xFF818CF8);
  static const dkAccentGreen = Color(0xFF34D399);
  static const dkAccentYellow = Color(0xFFFBBF24);
  static const dkAccentRed = Color(0xFFF87171);
  static const dkAccentBlue = Color(0xFF60A5FA);
  static const dkTextPrimary = Color(0xFFE2E8F0);
  static const dkTextSec = Color(0xFF94A3B8);
  static const dkTextMuted = Color(0xFF4A5C7E);
  static const dkTextVMuted = Color(0xFF2A3A55);

  // Light palette
  static const ltBg = Color(0xFFEEF2FF);
  static const ltBgCard = Color(0xFFFFFFFF);
  static const ltBgElevated = Color(0xFFF4F7FF);
  static const ltBgInput = Color(0xFFE8EDFA);
  static const ltAccent = Color(0xFF6366F1);
  static const ltAccentGreen = Color(0xFF059669);
  static const ltAccentYellow = Color(0xFFD97706);
  static const ltAccentRed = Color(0xFFDC2626);
  static const ltAccentBlue = Color(0xFF2563EB);
  static const ltTextPrimary = Color(0xFF0F172A);
  static const ltTextSec = Color(0xFF475569);
  static const ltTextMuted = Color(0xFF64748B);
  static const ltTextVMuted = Color(0xFF94A3B8);
}

// ─── BuildContext extension ───────────────────────────────────────────────────

extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? AppColors.dkBg : AppColors.ltBg;
  Color get bgCard => isDark ? AppColors.dkBgCard : AppColors.ltBgCard;
  Color get bgElevated => isDark ? AppColors.dkBgElevated : AppColors.ltBgElevated;
  Color get bgInput => isDark ? AppColors.dkBgInput : AppColors.ltBgInput;
  Color get textPrimary => isDark ? AppColors.dkTextPrimary : AppColors.ltTextPrimary;
  Color get textSec => isDark ? AppColors.dkTextSec : AppColors.ltTextSec;
  Color get textMuted => isDark ? AppColors.dkTextMuted : AppColors.ltTextMuted;
  Color get textVMuted => isDark ? AppColors.dkTextVMuted : AppColors.ltTextVMuted;
  Color get accent => isDark ? AppColors.dkAccent : AppColors.ltAccent;
  Color get accentGreen => isDark ? AppColors.dkAccentGreen : AppColors.ltAccentGreen;
  Color get accentYellow => isDark ? AppColors.dkAccentYellow : AppColors.ltAccentYellow;
  Color get accentRed => isDark ? AppColors.dkAccentRed : AppColors.ltAccentRed;
  Color get accentBlue => isDark ? AppColors.dkAccentBlue : AppColors.ltAccentBlue;
  Color get borderColor => isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.06);
  Color get borderStrong => isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.10);
  Color get borderAccent => accent.withValues(alpha: isDark ? 0.22 : 0.25);
  Color get accentBg => accent.withValues(alpha: isDark ? 0.12 : 0.08);
  Color get accentGreenBg => accentGreen.withValues(alpha: isDark ? 0.12 : 0.08);
  Color get navBg => isDark ? AppColors.dkBg : Colors.white;
  Color get navBorder => isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.07);

  List<Color> get accentGradient =>
      isDark ? [const Color(0xFF818CF8), const Color(0xFFC084FC)] : [const Color(0xFF6366F1), const Color(0xFFA855F7)];

  List<BoxShadow> get cardShadow => isDark
      ? []
      : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), spreadRadius: 1),
        ];

  Decoration cardDecoration({Color? border, Color? bg}) => BoxDecoration(
        color: bg ?? bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border ?? borderColor),
        boxShadow: cardShadow,
      );
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.dkBg : AppColors.ltBg,
      cardColor: isDark ? AppColors.dkBgCard : AppColors.ltBgCard,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: isDark ? AppColors.dkAccent : AppColors.ltAccent,
        secondary: isDark ? AppColors.dkAccentGreen : AppColors.ltAccentGreen,
        surface: isDark ? AppColors.dkBgCard : AppColors.ltBgCard,
        error: isDark ? AppColors.dkAccentRed : AppColors.ltAccentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDark ? AppColors.dkTextPrimary : AppColors.ltTextPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: isDark ? AppColors.dkTextPrimary : AppColors.ltTextPrimary,
        displayColor: isDark ? AppColors.dkTextPrimary : AppColors.ltTextPrimary,
      ),
      dividerColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.06),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}

* */
