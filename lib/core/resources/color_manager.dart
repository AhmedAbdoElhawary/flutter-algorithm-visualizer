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

  static const Color pinkColor = Color.fromRGBO(192, 132, 252, 1);
  static const Color lightPinkColor = Color.fromRGBO(192, 132, 252, 0.1);
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
  static const cdBgBaseDk = Color(0xFF0B0B0D);
  static const cdBgRaisedDk = Color(0xFF101112);
  static const cdSurfaceDk = Color(0xFF121317);
  static const cdSurfaceRaisedDk = Color(0xFF181A1F);
  static const cdSurfaceAltDk = Color(0xFF0E1119);

  /// Quiet: hairlines are solid greys now, never white alpha.
  static const cdBorderSubtleDk = Color(0xFF1C1D22);
  static const cdBorderDk = Color(0xFF24262C);
  static const cdBorderStrongDk = Color(0xFF3A3D46);

  /// White carries every primary action. No hue ramp — hover/press are cooler
  /// whites.
  static const cdPrimaryDk = Color(0xFFFFFFFF);
  static const cdPrimaryHoverDk = Color(0xFFF1F3FB);
  static const cdOnPrimaryDk = Color(0xFF0B0B0D);
  static const cdPrimaryTintDk = Color(0xFF24262C); // Quiet: solid selected/pressed wash
  static const cdPrimaryRingDk = Color(0x8CFFFFFF); // white @ 55% — focus ring only, not a fill

  /// XP / streak / level progress is white now, like every other primary action.
  static const cdAccentXpDk = cdPrimaryDk;
  static const cdAccentXpTextDk = cdTextPrimaryDk;
  static const cdOnAccentXpDk = cdOnPrimaryDk;

  static const cdTextPrimaryDk = Color(0xFFF2F3F5);
  static const cdTextBodyDk = Color(0xFF9A9FAB);
  static const cdTextSecondaryDk = Color(0xFF7C87A3); // contrast floor for real content ≈4.6:1
  static const cdTextDisabledDk = Color(0xFF4A4E5A);

  static const cdSuccessDk = Color(0xFF79C9A4);
  static const cdWarningDk = Color(0xFFD9AE72);
  static const cdErrorDk = Color(0xFFDE8189);
  static const cdOnErrorDk = Color(0xFF3A0A12);

  /// Quiet: "currently comparing" is white now — the retired cyan is gone.
  static const cdComparingDk = Color(0xFFFFFFFF);

  static const cdBarIdleDk = Color(0xFF2A2D35);
  static const cdBarExcludedDk = Color(0xFF181A1F);
  static const cdBarCompareDk = cdComparingDk;
  static const cdBarSwapDk = cdErrorDk;
  static const cdBarDoneDk = cdSuccessDk;

  /// Quiet's "primary" ink/action role (see research.md R3) — repoints this
  /// existing member instead of adding a new one.
  static const cdTextBrightDk = Color(0xFFFFFFFF);
  static const cdErrorRingDk = Color(0x1FFF6B7E);

  /// Inactive bottom-nav item (design is explicit — distinct from text secondary).
  static const cdNavInactiveDk = Color(0xFF8892AC);

  static const cdCodeGutterDk = cdTextSecondaryDk;
  static const cdCodeLineDk = Color(0x12FFFFFF); // current line — white 7%
  static const cdCodeKeywordDk = cdWarningDk;
  static const cdCodeTypeDk = cdTextPrimaryDk;
  static const cdCodePunctDk = cdTextBrightDk;
  static const cdCodeNumberDk = cdSuccessDk;

  /// Activity heat — five solid steps, low → high.
  static const cdHeatDk = <Color>[
    Color(0xFF181A1F),
    Color(0xFF21312B),
    Color(0xFF375749),
    Color(0xFF548871),
    Color(0xFF79C9A4),
  ];

  /// Quiet: generic 3px progress-bar track, distinct from the sorting bar rail.
  static const cdTrackDk = Color(0xFF2A2D35);

  /// Quiet: solid chip fills — never alpha over a surface.
  static const cdChipEasyFillDk = Color(0xFF17241F);
  static const cdChipMediumFillDk = Color(0xFF25200F);
  static const cdChipHardFillDk = Color(0xFF291619);
  static const cdChipNeutralFillDk = Color(0xFF1C1D22);

  /// ======================================================================
  /// Aurora primitives — LIGHT (cool off-white, cool greys)
  /// ======================================================================
  static const cdBgBaseLt = Color(0xFFFBFBFC);
  static const cdBgRaisedLt = Color(0xFFF4F5F7);
  static const cdSurfaceLt = Color(0xFFFFFFFF);
  static const cdSurfaceAltLt = Color(0xFFEEF0F6);
  static const cdBorderSubtleLt = Color(0xFFE8E9ED);
  static const cdBorderLt = Color(0xFFDCDEE3);
  static const cdBorderStrongLt = Color(0xFFB9BCC4);

  static const cdPrimaryLt = Color(0xFF12141C);
  static const cdPrimaryHoverLt = Color(0xFF2A2D38);
  static const cdOnPrimaryLt = Color(0xFFFFFFFF);
  static const cdPrimaryTintLt = Color(0xFFECEDF0);
  static const cdPrimaryRingLt = Color(0x73101114); // #101114 @ 45% — focus ring only, not a fill

  static const cdAccentXpLt = cdPrimaryLt;
  static const cdAccentXpTextLt = cdPrimaryLt;
  static const cdOnAccentXpLt = Color(0xFFFFFFFF);

  static const cdTextPrimaryLt = Color(0xFF101114);
  static const cdTextBodyLt = Color(0xFF4A4F5A);
  static const cdTextSecondaryLt = Color(0xFF667080); // T054: darkened from 6A7387 — 4.5:1 vs bgRaisedLt
  static const cdTextDisabledLt = Color(0xFFA0A5AE);

  static const cdSuccessLt = Color(0xFF11704E);
  static const cdWarningLt = Color(0xFF8A5D12);
  static const cdErrorLt = Color(0xFFA83F49);
  static const cdOnErrorLt = Color(0xFFFFFFFF);

  /// Quiet: "currently comparing" is ink-black now, matching the dark theme's white.
  static const cdComparingLt = Color(0xFF101114);

  static const cdBarIdleLt = Color(0xFFDCDEE3);
  static const cdBarExcludedLt = Color(0xFFEDEEF1);
  static const cdBarCompareLt = cdComparingLt;
  static const cdBarSwapLt = cdErrorLt;
  static const cdBarDoneLt = cdSuccessLt;

  /// Quiet's "primary" ink/action role (see research.md R3) — repoints this
  /// existing member instead of adding a new one.
  static const cdTextBrightLt = Color(0xFF101114);
  static const cdErrorRingLt = Color(0x1FC1414D);

  static const cdNavInactiveLt = Color(0xFF6A7387);

  static const cdCodeGutterLt = cdTextSecondaryLt;
  static const cdCodeLineLt = Color(0x0A000000);
  static const cdCodeKeywordLt = cdWarningLt;
  static const cdCodeTypeLt = cdTextPrimaryLt;
  static const cdCodePunctLt = cdTextPrimaryLt;
  static const cdCodeNumberLt = cdSuccessLt;

  static const cdHeatLt = <Color>[
    Color(0xFFEDEEF1),
    Color(0xFFDBEBE2),
    Color(0xFFB5D8C6),
    Color(0xFF7FBBA0),
    Color(0xFF11704E),
  ];

  static const cdTrackLt = Color(0xFFE2E4E9);

  static const cdChipEasyFillLt = Color(0xFFE7F3EC);
  static const cdChipMediumFillLt = Color(0xFFF6EFE2);
  static const cdChipHardFillLt = Color(0xFFF9EAEB);
  static const cdChipNeutralFillLt = Color(0xFFF0F1F4);

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
