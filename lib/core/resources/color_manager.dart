import 'package:flutter/material.dart';

/// Raw hex primitives. Nothing outside this file may hold a literal colour.
///
/// The `*Dk` / `*Lt` values below now carry the **Aurora glass** palette: white
/// carries every primary action, the ground is blue-black, surfaces are glass
/// over a dim indigo/cyan aurora, and the three difficulty hues plus the
/// comparing cyan are retuned to the cold ground. The legacy constant *names*
/// are kept so pre-Aurora screens keep compiling; each screen swaps to the
/// Aurora-native [ThemeEnum] entries during its migration phase.
///
/// Dark is the source of truth (see design_handoff_coredive/AURORA_REFERENCE.html
/// §3a). Light values that the reference does not draw are placeholders derived
/// from the stated rules and are polished in a later pass.
abstract final class ColorManager {
  /// -------- shared / static (not theme-resolved) ------------>

  static const Color targetSearchingPoint = Color.fromRGBO(66, 8, 99, 1.0);
  static const Color wallBlack = Color.fromRGBO(22, 68, 101, 1.0);

  static const Color pinkColor = Color.fromRGBO(192, 132, 252, 1);
  static const Color lightPinkColor = Color.fromRGBO(192, 132, 252, 0.1);
  static const Color columnSortColor = Color.fromRGBO(26, 47, 80, 0.7);
  static const Color backgroundForSortingColor = Color.fromRGBO(14, 23, 41, 0.3);
  static const Color white2DarkColor = Color(0xFF9BAAA6);
  static const Color textDarkColor = Color(0xFF7C87A3);
  static const Color text2DarkColor = Color(0xFF7C87A3);
  static const Color howItWorksColor = Color(0xFF0B0E17);
  static const Color lightPurpleColor = Color(0xFF11141D);
  static const Color borderPurpleColor = Color(0xFF2A3350);
  static const Color codeEditorBackground = Color(0xFF080A12);
  static const Color codeEditorNumberColor = Color(0xFF7C87A3);

  /// ======================================================================
  /// Aurora primitives — DARK (primary theme)
  /// ======================================================================
  static const cdBgBaseDk = Color(0xFF04050A);
  static const cdBgRaisedDk = Color(0xFF080A12);
  static const cdSurfaceDk = Color(0xFF0B0E17);
  static const cdSurfaceAltDk = Color(0xFF0E1119);

  /// Borders are white alphas now — that is what lets the glass read.
  static const cdBorderSubtleDk = Color(0x1FFFFFFF); // white 12%
  static const cdBorderDk = Color(0x21FFFFFF); // white 13%
  static const cdBorderStrongDk = Color(0x33FFFFFF); // white 20%

  /// White carries every primary action. No hue ramp — hover/press are cooler
  /// whites.
  static const cdPrimaryDk = Color(0xFFFFFFFF);
  static const cdPrimaryHoverDk = Color(0xFFF1F3FB);
  static const cdPrimaryPressDk = Color(0xFFE4E7F2);
  static const cdOnPrimaryDk = Color(0xFF06070C);
  static const cdPrimaryTintDk = Color(0x1AFFFFFF); // white 10% — pressed/selected wash
  static const cdPrimaryRingDk = Color(0x668B7CF6); // violet @ 40% — focus ring

  /// XP / streak / level progress is white now, like every other primary action.
  static const cdAccentXpDk = cdPrimaryDk;
  static const cdAccentXpTextDk = cdTextPrimaryDk;
  static const cdOnAccentXpDk = cdOnPrimaryDk;

  static const cdTextPrimaryDk = Color(0xFFF4F6FF);
  static const cdTextBodyDk = Color(0xFFAFB6CC);
  static const cdTextSecondaryDk = Color(0xFF7C87A3); // contrast floor for real content ≈4.6:1
  static const cdTextDisabledDk = Color(0xFF5F6A85);

  static const cdSuccessDk = Color(0xFF4FE0A8);
  static const cdWarningDk = Color(0xFFF3B25A);
  static const cdErrorDk = Color(0xFFFF6B7E);
  static const cdOnErrorDk = Color(0xFF3A0A12);

  /// "currently comparing" — was brass, now cyan; it belongs to the palette.
  static const cdComparingDk = Color(0xFF46D8E6);

  static const cdBarIdleDk = Color(0x8038415C);
  static const cdBarExcludedDk = Color(0xFF171C2A);
  static const cdBarCompareDk = cdComparingDk;
  static const cdBarSwapDk = cdErrorDk;
  static const cdBarDoneDk = cdSuccessDk;

  static const cdTextBrightDk = Color(0xFFE8EAF4); // code punctuation / row title ink
  static const cdErrorRingDk = Color(0x1FFF6B7E);

  /// The aurora glow — only indigo and a trace of cyan reach the ground, in one
  /// broad soft band rising from the bottom edge.
  static const cdGlowIndigoDk = Color(0x664A5BD8); // #4A5BD8 @ 40%
  static const cdGlowCyanDk = Color(0x4D2FA3B8); // #2FA3B8 @ 30%
  static const cdDotGridDk = Color(0x0EFFFFFF); // white 5.5%

  /// Accent marks only — never on the ground, never on a data mark.
  static const cdAccentVioletDk = Color(0xFF8B7CF6); // focus, key-bar label
  static const cdAccentAzureDk = Color(0xFF3FA9F5);

  /// Inactive bottom-nav item (design is explicit — distinct from text secondary).
  static const cdNavInactiveDk = Color(0xFF8892AC);

  /// The glass material — one recipe, three depths. Fill + blur carry the depth.
  static const glassRecessedFill100DK = Color.fromRGBO(9, 10, 15, 1); // white 4%
  static const cdGlassRecessedFillDk = Color(0x06ffffff); // white 4%
  static const cdGlassCardFillDk = Color.fromRGBO(18, 19, 25, 1); // white 5.5%
  static const cdGlassCardFill2Dk = Color.fromRGBO(22, 24, 32, 0.803921568627451); // white 5.5%
  static const cdGlassFloatingFillDk =  Color.fromRGBO(18, 19, 25, 1); // white 10%
  static const cdGlassSheenRecessedDk = Color(0x1AFFFFFF); // white 10%
  static const cdGlassSheenCardDk = Color(0x29FFFFFF); // white 16%
  static const cdGlassSheenFloatingDk = Color(0x3DFFFFFF); // white 24%

  /// Card / floating hairlines reuse [cdBorderDk] / [cdBorderStrongDk]; only the
  /// recessed hairline (9%) has no border-role equivalent.
  static const cdGlassHairlineRecessedDk = Color(0x17FFFFFF); // white 9%

  static const cdCodeGutterDk = cdTextSecondaryDk;
  static const cdCodeLineDk = Color(0x12FFFFFF); // current line — white 7%
  static const cdCodeKeywordDk = cdWarningDk;
  static const cdCodeTypeDk = cdTextPrimaryDk;
  static const cdCodePunctDk = cdTextBrightDk;
  static const cdCodeNumberDk = cdSuccessDk;

  /// Activity heat — five steps: white 7% empty, then success @ 20 / 40 / 66 / 100%.
  static const cdHeatDk = <Color>[
    Color(0x12FFFFFF),
    Color(0x334FE0A8),
    Color(0x664FE0A8),
    Color(0xA84FE0A8),
    Color(0xFF4FE0A8),
  ];

  /// ======================================================================
  /// Aurora primitives — LIGHT (cool off-white, cool greys)
  /// ======================================================================
  static const cdBgBaseLt = Color(0xFFF6F7FC);
  static const cdBgRaisedLt = Color(0xFFFFFFFF);
  static const cdSurfaceLt = Color(0xFFFFFFFF);
  static const cdSurfaceAltLt = Color(0xFFEEF0F6);
  static const cdBorderSubtleLt = Color(0x14000000); // black 8%
  static const cdBorderLt = Color(0x1F000000); // black 12%
  static const cdBorderStrongLt = Color(0x2E000000); // black 18%

  static const cdPrimaryLt = Color(0xFF12141C);
  static const cdPrimaryHoverLt = Color(0xFF2A2D38);
  static const cdPrimaryPressLt = Color(0xFF0B0D14);
  static const cdOnPrimaryLt = Color(0xFFFFFFFF);
  static const cdPrimaryTintLt = Color(0x14000000); // black 8%
  static const cdPrimaryRingLt = Color(0x665C6CF2); // indigo @ 40%

  static const cdAccentXpLt = cdPrimaryLt;
  static const cdAccentXpTextLt = cdPrimaryLt;
  static const cdOnAccentXpLt = Color(0xFFFFFFFF);

  static const cdTextPrimaryLt = Color(0xFF12141C);
  static const cdTextBodyLt = Color(0xFF454C60);
  static const cdTextSecondaryLt = Color(0xFF6A7387);
  static const cdTextDisabledLt = Color(0xFF9AA1B3);

  static const cdSuccessLt = Color(0xFF128A5E);
  static const cdWarningLt = Color(0xFFA9670F);
  static const cdErrorLt = Color(0xFFC1414D);
  static const cdOnErrorLt = Color(0xFFFFFFFF);

  static const cdComparingLt = Color(0xFF147C90);

  static const cdBarIdleLt = Color(0x80C3CBD8);
  static const cdBarExcludedLt = Color(0xFFEAEDF3);
  static const cdBarCompareLt = cdComparingLt;
  static const cdBarSwapLt = cdErrorLt;
  static const cdBarDoneLt = cdSuccessLt;

  static const cdTextBrightLt = cdTextPrimaryLt;
  static const cdErrorRingLt = Color(0x1FC1414D);

  static const cdGlowIndigoLt = Color(0x294A5BD8); // ~16%
  static const cdGlowCyanLt = Color(0x292FA3B8); // ~16%
  static const cdDotGridLt = Color(0x0D000000); // black ~5%

  static const cdAccentVioletLt = Color(0xFF5C6CF2);
  static const cdAccentAzureLt = Color(0xFF3FA9F5);

  static const cdNavInactiveLt = Color(0xFF6A7387);

  /// Placeholder light glass — black-alpha fills, white sheens. Polished later.
  static const cdGlassRecessedFillLt = Color(0x0A000000);
  /// TODO: edit it based on black, i get the dark theme from the other filter color
  static const cdGlassRecessedFill100Lt = Color(0x0A000000);

  static const cdGlassCardFillLt = Color(0x0E000000);
  static const cdGlassCardFill2Lt = Color(0x0E000000);
  static const cdGlassFloatingFillLt = Color(0x14000000);
  static const cdGlassSheenRecessedLt = Color(0x80FFFFFF);
  static const cdGlassSheenCardLt = Color(0x99FFFFFF);
  static const cdGlassSheenFloatingLt = Color(0xB3FFFFFF);
  static const cdGlassHairlineRecessedLt = Color(0x12000000);

  static const cdCodeGutterLt = cdTextSecondaryLt;
  static const cdCodeLineLt = Color(0x0A000000);
  static const cdCodeKeywordLt = cdWarningLt;
  static const cdCodeTypeLt = cdTextPrimaryLt;
  static const cdCodePunctLt = cdTextPrimaryLt;
  static const cdCodeNumberLt = cdSuccessLt;

  static const cdHeatLt = <Color>[
    Color(0xFFEAEDF3),
    Color(0x33128A5E),
    Color(0x66128A5E),
    Color(0xA8128A5E),
    Color(0xFF128A5E),
  ];

  /// ======================================================================
  /// Legacy theme names, repointed to Aurora primitives
  /// ======================================================================

  /// -------- dark ------------>
  static const primaryDk = cdBgBaseDk;
  static const cardDk = Color.fromRGBO(21, 22, 27, 1.0);
  static const outputHeaderDk = cdBgRaisedDk;
  static const accentDk = cdPrimaryDk;
  static const accentGreenDk = cdSuccessDk;
  static const accentGreenBgDk = cdSuccessDk;
  static const accentYellowDk = cdWarningDk;
  static const accentYellowBgDk = cdWarningDk;
  static const accentRedDk = cdErrorDk;
  static const accentRedBgDk = cdErrorDk;
  static const accentBlueDk = cdPrimaryDk;
  static const textPrimaryDk = cdTextPrimaryDk;
  static const textSecondDk = cdTextSecondaryDk;
  static const hoverDk = cdBorderStrongDk;
  static const hoverSecondDk = cdSurfaceAltDk;
  static const borderDk = cdBorderDk;

  /// -------- light ------------>
  static const primaryLt = cdBgBaseLt;
  static const cardLt = cdSurfaceLt;
  static const mainCardLt = cdSurfaceAltLt;
  static const outputHeaderLt = cdBgRaisedLt;
  static const accentLt = cdPrimaryLt;
  static const accentGreenLt = cdSuccessLt;
  static const accentYellowLt = cdWarningLt;
  static const accentRedLt = cdErrorLt;
  static const accentBlueLt = cdPrimaryLt;
  static const textPrimaryLt = cdTextPrimaryLt;
  static const textSecondLt = cdTextSecondaryLt;
  static const hoverLt = cdBorderStrongLt;
  static const hoverSecondLt = cdSurfaceAltLt;
  static const borderLt = cdBorderLt;

  /// -------------------------------->

  static const Color transparent = Colors.transparent;
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color whiteD5 = Color.fromRGBO(215, 215, 215, 1);
  static const Color whiteD6 = Color.fromRGBO(205, 205, 205, 1);
  static const Color grey = Color.fromRGBO(65, 65, 65, 1);
  static const Color grey2 = Color.fromRGBO(75, 75, 75, 1);
  static const Color black = Color.fromRGBO(00, 00, 00, 1);
}
