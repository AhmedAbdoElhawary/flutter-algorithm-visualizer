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
  accentGreenRc,
  accentYellow,
  accentYellowRc,
  accentRed,
  accentRedRc,
  accentBlue,
  textSecond,
  textPrimary,
  hover,
  hoverSecond,
  border,

  /// ---- CoreDive semantic tokens ----
  /// Surfaces
  bgRaised,
  surfaceAlt,
  borderSubtle,
  borderStrong,

  /// Text
  textBody,
  textDisabled,
  textBright,

  /// Interactive (brass — the only interactive colour)
  primaryHover,
  primaryTint,
  primaryRing,
  onPrimary,

  /// Quiet: generic progress-bar track + solid chip fills
  track,
  chipEasyFill,
  chipMediumFill,
  chipHardFill,
  chipNeutralFill,

  /// Feedback
  onError,
  errorRing,

  /// Progress (brass — only ever streak / XP / level)
  accentXp,
  accentXpText,
  onAccentXp,

  /// Difficulty (three fixed hues — only ever difficulty)
  difficultyEasy,
  difficultyMedium,
  difficultyHard,

  /// Visualizer bar states
  barIdle,
  barExcluded,
  barCompare,
  barSwap,
  barDone,

  /// "currently comparing" — cyan, the same mark everywhere (bars, live dot)
  comparing,

  /// Code syntax
  codeBg,
  codeGutter,
  codeLine,
  codeKeyword,
  codeType,
  codePlain,
  codePunct,
  codeNumber,
  codeComment,

  /// Activity heat ramp (low → high) — five steps
  heat0,
  heat1,
  heat2,
  heat3,
  heat4,

  /// Bottom-nav inactive item
  navInactive,

  /// The glass material — fill / sheen per depth; recessed hairline
  glassRecessedFill,
  glassCardFill,
  glassFloatingFill,
  glassHairlineRecessed,

  /// static colors
  solidWhite,
  purple,
  pink,
  lightPink,
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
  whiteColor,
  transparentColor,

  //
}

extension ThemeExtension on BuildContext {
  bool get isThemeDark => Theme.of(this).brightness == Brightness.dark;

  T _pick<T>(T dark, T light) => isThemeDark ? dark : light;

  Map<ThemeEnum, Color> get _colors {
    return {
      ThemeEnum.primary: Theme.of(this).primaryColor,
      ThemeEnum.focus: Theme.of(this).focusColor,
      ThemeEnum.card: Theme.of(this).hintColor,
      ThemeEnum.mainCard: _pick(ColorManager.cdSurfaceDk, ColorManager.cdSurfaceLt),
      ThemeEnum.outputHeader: _pick(ColorManager.outputHeaderDk, ColorManager.outputHeaderLt),
      ThemeEnum.accent: _pick(ColorManager.accentDk, ColorManager.accentLt),
      ThemeEnum.borderAccent: _pick(
        ColorManager.accentDk.withValues(alpha: 0.22),
        ColorManager.accentLt.withValues(alpha: 0.25),
      ),
      ThemeEnum.accentBg: _pick(
        ColorManager.accentDk.withValues(alpha: 0.12),
        ColorManager.accentLt.withValues(alpha: 0.08),
      ),
      ThemeEnum.accentGreenRc: ColorManager.accentGreenBgDk,
      ThemeEnum.accentGreen: _pick(ColorManager.accentGreenDk, ColorManager.accentGreenLt),
      ThemeEnum.accentYellow: _pick(ColorManager.accentYellowDk, ColorManager.accentYellowLt),
      ThemeEnum.accentYellowRc: _pick(ColorManager.accentYellowDk, ColorManager.accentYellowLt),
      ThemeEnum.accentRed: _pick(ColorManager.accentRedDk, ColorManager.accentRedLt),
      ThemeEnum.accentRedRc: ColorManager.accentRedBgDk,
      ThemeEnum.accentBlue: _pick(ColorManager.accentBlueDk, ColorManager.accentBlueLt),
      ThemeEnum.textSecond: _pick(ColorManager.textSecondDk, ColorManager.textSecondLt),
      ThemeEnum.textPrimary: _pick(ColorManager.textPrimaryDk, ColorManager.textPrimaryLt),
      ThemeEnum.hover: _pick(ColorManager.hoverDk, ColorManager.hoverLt),
      ThemeEnum.hoverSecond: _pick(ColorManager.hoverSecondDk, ColorManager.hoverSecondLt),
      ThemeEnum.border: _pick(ColorManager.borderDk, ColorManager.borderLt),

      /// ---- CoreDive semantic tokens ---->
      ThemeEnum.bgRaised: _pick(ColorManager.cdBgRaisedDk, ColorManager.cdBgRaisedLt),
      ThemeEnum.surfaceAlt: _pick(ColorManager.cdSurfaceAltDk, ColorManager.cdSurfaceAltLt),
      ThemeEnum.borderSubtle: _pick(ColorManager.cdBorderSubtleDk, ColorManager.cdBorderSubtleLt),
      ThemeEnum.borderStrong: _pick(ColorManager.cdBorderStrongDk, ColorManager.cdBorderStrongLt),

      ThemeEnum.textBody: _pick(ColorManager.cdTextBodyDk, ColorManager.cdTextBodyLt),
      ThemeEnum.textDisabled: _pick(ColorManager.cdTextDisabledDk, ColorManager.cdTextDisabledLt),
      ThemeEnum.textBright: _pick(ColorManager.cdTextBrightDk, ColorManager.cdTextBrightLt),

      ThemeEnum.primaryHover: _pick(ColorManager.cdPrimaryHoverDk, ColorManager.cdPrimaryHoverLt),
      ThemeEnum.primaryTint: _pick(ColorManager.cdPrimaryTintDk, ColorManager.cdPrimaryTintLt),
      ThemeEnum.primaryRing: _pick(ColorManager.cdPrimaryRingDk, ColorManager.cdPrimaryRingLt),
      ThemeEnum.onPrimary: _pick(ColorManager.cdOnPrimaryDk, ColorManager.cdOnPrimaryLt),

      ThemeEnum.track: _pick(ColorManager.cdTrackDk, ColorManager.cdTrackLt),
      ThemeEnum.chipEasyFill: _pick(ColorManager.cdChipEasyFillDk, ColorManager.cdChipEasyFillLt),
      ThemeEnum.chipMediumFill: _pick(ColorManager.cdChipMediumFillDk, ColorManager.cdChipMediumFillLt),
      ThemeEnum.chipHardFill: _pick(ColorManager.cdChipHardFillDk, ColorManager.cdChipHardFillLt),
      ThemeEnum.chipNeutralFill: _pick(ColorManager.cdChipNeutralFillDk, ColorManager.cdChipNeutralFillLt),

      ThemeEnum.onError: _pick(ColorManager.cdOnErrorDk, ColorManager.cdOnErrorLt),
      ThemeEnum.errorRing: _pick(ColorManager.cdErrorRingDk, ColorManager.cdErrorRingLt),

      ThemeEnum.accentXp: _pick(ColorManager.cdAccentXpDk, ColorManager.cdAccentXpLt),
      ThemeEnum.accentXpText: _pick(ColorManager.cdAccentXpTextDk, ColorManager.cdAccentXpTextLt),
      ThemeEnum.onAccentXp: _pick(ColorManager.cdOnAccentXpDk, ColorManager.cdOnAccentXpLt),

      ThemeEnum.difficultyEasy: _pick(ColorManager.cdSuccessDk, ColorManager.cdSuccessLt),
      ThemeEnum.difficultyMedium: _pick(ColorManager.cdWarningDk, ColorManager.cdWarningLt),
      ThemeEnum.difficultyHard: _pick(ColorManager.cdErrorDk, ColorManager.cdErrorLt),

      ThemeEnum.barIdle: _pick(ColorManager.cdBarIdleDk, ColorManager.cdBarIdleLt),
      ThemeEnum.barExcluded: _pick(ColorManager.cdBarExcludedDk, ColorManager.cdBarExcludedLt),
      ThemeEnum.barCompare: _pick(ColorManager.cdBarCompareDk, ColorManager.cdBarCompareLt),
      ThemeEnum.barSwap: _pick(ColorManager.cdBarSwapDk, ColorManager.cdBarSwapLt),
      ThemeEnum.barDone: _pick(ColorManager.cdBarDoneDk, ColorManager.cdBarDoneLt),
      ThemeEnum.comparing: _pick(ColorManager.cdComparingDk, ColorManager.cdComparingLt),

      ThemeEnum.codeBg: _pick(ColorManager.cdBgRaisedDk, ColorManager.cdBgRaisedLt),
      ThemeEnum.codeGutter: _pick(ColorManager.cdCodeGutterDk, ColorManager.cdCodeGutterLt),
      ThemeEnum.codeLine: _pick(ColorManager.cdCodeLineDk, ColorManager.cdCodeLineLt),
      ThemeEnum.codeKeyword: _pick(ColorManager.cdCodeKeywordDk, ColorManager.cdCodeKeywordLt),
      ThemeEnum.codeType: _pick(ColorManager.cdCodeTypeDk, ColorManager.cdCodeTypeLt),
      ThemeEnum.codePlain: _pick(ColorManager.cdTextBodyDk, ColorManager.cdTextBodyLt),
      ThemeEnum.codePunct: _pick(ColorManager.cdCodePunctDk, ColorManager.cdCodePunctLt),
      ThemeEnum.codeNumber: _pick(ColorManager.cdCodeNumberDk, ColorManager.cdCodeNumberLt),
      ThemeEnum.codeComment: _pick(ColorManager.cdTextDisabledDk, ColorManager.cdTextDisabledLt),

      ThemeEnum.heat0: _pick(ColorManager.cdHeatDk[0], ColorManager.cdHeatLt[0]),
      ThemeEnum.heat1: _pick(ColorManager.cdHeatDk[1], ColorManager.cdHeatLt[1]),
      ThemeEnum.heat2: _pick(ColorManager.cdHeatDk[2], ColorManager.cdHeatLt[2]),
      ThemeEnum.heat3: _pick(ColorManager.cdHeatDk[3], ColorManager.cdHeatLt[3]),
      ThemeEnum.heat4: _pick(ColorManager.cdHeatDk[4], ColorManager.cdHeatLt[4]),

      ThemeEnum.navInactive: _pick(ColorManager.cdNavInactiveDk, ColorManager.cdNavInactiveLt),

      ThemeEnum.glassRecessedFill: _pick(ColorManager.cdGlassRecessedFillDk, ColorManager.cdGlassRecessedFillLt),
      ThemeEnum.glassCardFill: _pick(ColorManager.cdGlassCardFillDk, ColorManager.cdGlassCardFillLt),
      ThemeEnum.glassFloatingFill: _pick(ColorManager.cdGlassFloatingFillDk, ColorManager.cdGlassFloatingFillLt),
      ThemeEnum.glassHairlineRecessed: _pick(ColorManager.cdGlassHairlineRecessedDk, ColorManager.cdGlassHairlineRecessedLt),

      ///-------------------->
      ThemeEnum.solidWhite: ColorManager.white,
      ThemeEnum.purple: ColorManager.targetSearchingPoint,
      ThemeEnum.pink: ColorManager.pinkColor,
      ThemeEnum.lightPink: ColorManager.lightPinkColor,
      ThemeEnum.howItWorksColor: ColorManager.howItWorksColor,
      ThemeEnum.white2DarkColor: ColorManager.white2DarkColor,
      // Visualizer canvas + idle bar rail — CoreDive screen 02.
      ThemeEnum.columnColor: _pick(ColorManager.cdBarIdleDk, ColorManager.cdBarIdleLt),
      ThemeEnum.backgroundForSortingColor: _pick(ColorManager.cdBgRaisedDk, ColorManager.cdBgRaisedLt),
      ThemeEnum.textDarkColor: ColorManager.textDarkColor,
      ThemeEnum.text2DarkColor: ColorManager.text2DarkColor,
      ThemeEnum.lightPurpleColor: ColorManager.lightPurpleColor,
      ThemeEnum.borderPurpleColor: ColorManager.borderPurpleColor,

      /// what ever dark or light. Maybe if we have multiple themes, it will save a lot of time.
      ThemeEnum.whiteD4Color: ColorManager.grey,

      ThemeEnum.whiteD5Color: ColorManager.whiteD5,
      ThemeEnum.transparentColor: ColorManager.transparent,
      ThemeEnum.whiteColor: ColorManager.white,
      ThemeEnum.codeEditorNumberColor: ColorManager.codeEditorNumberColor,
    };
  }

  Color getColor(ThemeEnum color) => _colors[color] ?? Theme.of(this).primaryColor;
}
