import 'package:flutter/material.dart';

/// Raw hex primitives. Nothing outside this file may hold a literal colour.
///
/// The `*Dk` / `*Lt` values below now carry the **CoreDive** palette (brass
/// interactive colour on near-black, brass progress, three fixed difficulty
/// hues clear of the brand colour). The legacy constant *names* are kept so
/// pre-CoreDive screens keep compiling; each screen swaps to the CoreDive-native
/// [ThemeEnum] entries during its migration phase.
///
/// Source of truth: design_handoff_coredive/tokens/coredive_tokens.dart
abstract final class ColorManager {
  /// -------- shared / static (not theme-resolved) ------------>

  static const Color targetSearchingPoint = Color.fromRGBO(66, 8, 99, 1.0);
  static const Color wallBlack = Color.fromRGBO(22, 68, 101, 1.0);

  static const Color pinkColor = Color.fromRGBO(192, 132, 252, 1);
  static const Color lightPinkColor = Color.fromRGBO(192, 132, 252, 0.1);
  static const Color columnSortColor = Color.fromRGBO(26, 47, 80, 0.7);
  static const Color backgroundForSortingColor = Color.fromRGBO(14, 23, 41, 0.3);
  static const Color white2DarkColor = Color(0xFF9BAAA6);
  static const Color textDarkColor = Color(0xFF5C6360);
  static const Color text2DarkColor = Color(0xFF9BAAA6);
  static const Color howItWorksColor = Color(0xFF0C0E0D);
  static const Color lightPurpleColor = Color(0xFF1A1F1D);
  static const Color borderPurpleColor = Color(0xFF31372F);
  static const Color codeEditorBackground = Color(0xFF0A0C0B);
  static const Color codeEditorNumberColor = Color(0xFF4A4F49);

  /// ======================================================================
  /// CoreDive primitives — DARK (primary theme)
  /// ======================================================================
  static const cdBgBaseDk = Color(0xFF050605);
  static const cdBgRaisedDk = Color(0xFF0A0C0B);
  static const cdSurfaceDk = Color(0xFF0C0E0D);
  static const cdSurfaceAltDk = Color(0xFF1A1F1D);

  /// Brass-tinted card. Streak and XP surfaces only.
  static const cdSurfaceWarmDk = Color(0xFF15100A);
  static const cdBorderSubtleDk = Color(0xFF1C201E);
  static const cdBorderDk = Color(0xFF222725);
  static const cdBorderStrongDk = Color(0xFF31372F);

  static const cdPrimaryDk = Color(0xFFE0A33E);
  static const cdPrimaryHoverDk = Color(0xFFF0BC63);
  static const cdPrimaryPressDk = Color(0xFFC9922E);
  static const cdOnPrimaryDk = Color(0xFF1A1206);
  static const cdPrimaryTintDk = Color(0x24E0A33E);
  static const cdPrimaryRingDk = Color(0x29E0A33E);

  /// XP IS the brand colour — identity and progress are deliberately the same brass.
  static const cdAccentXpDk = cdPrimaryPressDk;
  static const cdAccentXpTextDk = cdPrimaryDk;
  static const cdOnAccentXpDk = cdOnPrimaryDk;

  static const cdTextPrimaryDk = Color(0xFFF5F7F6);
  static const cdTextBodyDk = Color(0xFFB9BEBB);
  static const cdTextSecondaryDk = Color(0xFF7E8582);
  static const cdTextDisabledDk = Color(0xFF5C6360);

  static const cdSuccessDk = Color(0xFF4FC38C);

  /// Burnt orange, NOT amber — amber is the brand colour.
  static const cdWarningDk = Color(0xFFD97742);
  static const cdErrorDk = Color(0xFFDF5B67);
  static const cdOnErrorDk = Color(0xFF2A0709);

  static const cdBarIdleDk = Color(0xFF3A3226);
  static const cdBarCompareDk = cdWarningDk;
  static const cdBarSwapDk = Color(0xFFB85F2E);
  static const cdBarDoneDk = Color(0xFFF2F4F3);

  static const cdTextBrightDk = Color(0xFFE8EAE9);
  static const cdAuthWashDk = Color(0xFF15100A);
  static const cdErrorRingDk = Color(0x1FDF5B67);

  static const cdCodeGutterDk = Color(0xFF4A4F49);
  static const cdCodeLineDk = Color(0x12E0A33E);
  static const cdCodeKeywordDk = Color(0xFFD97742);
  static const cdCodeTypeDk = Color(0xFFF0BC63);
  static const cdCodePunctDk = Color(0xFFE8EAE9);
  static const cdCodeNumberDk = Color(0xFF4FC38C);

  static const cdHeatDk = <Color>[
    Color(0xFF1A1F1D),
    Color(0xFF5C3F12),
    Color(0xFFC9922E),
    Color(0xFFF0BC63),
  ];

  /// ======================================================================
  /// CoreDive primitives — LIGHT (warm off-white paper, warm greys)
  /// ======================================================================
  static const cdBgBaseLt = Color(0xFFFAF8F4);
  static const cdBgRaisedLt = Color(0xFFFFFFFF);
  static const cdSurfaceLt = Color(0xFFFFFFFF);
  static const cdSurfaceAltLt = Color(0xFFF2EEE6);
  static const cdSurfaceWarmLt = Color(0xFFFBF3E3);
  static const cdBorderSubtleLt = Color(0xFFEFEBE2);
  static const cdBorderLt = Color(0xFFE5E0D6);
  static const cdBorderStrongLt = Color(0xFFCBC4B5);

  static const cdPrimaryLt = Color(0xFF8F6216);
  static const cdPrimaryHoverLt = Color(0xFFA9761D);
  static const cdPrimaryPressLt = Color(0xFF734E0F);
  static const cdOnPrimaryLt = Color(0xFFFFFFFF);
  static const cdPrimaryTintLt = Color(0x1A8F6216);
  static const cdPrimaryRingLt = Color(0x298F6216);

  static const cdAccentXpLt = cdPrimaryLt;
  static const cdAccentXpTextLt = cdPrimaryPressLt;
  static const cdOnAccentXpLt = Color(0xFFFFFFFF);

  static const cdTextPrimaryLt = Color(0xFF12100C);
  static const cdTextBodyLt = Color(0xFF2E2A22);
  static const cdTextSecondaryLt = Color(0xFF6B665C);
  static const cdTextDisabledLt = Color(0xFFA09A8D);

  static const cdSuccessLt = Color(0xFF1B7F5A);
  static const cdWarningLt = Color(0xFFA85426);
  static const cdErrorLt = Color(0xFFC1414D);
  static const cdOnErrorLt = Color(0xFFFFFFFF);

  static const cdBarIdleLt = Color(0xFFDCD6C9);
  static const cdBarCompareLt = cdWarningLt;
  static const cdBarSwapLt = Color(0xFF8A4520);
  static const cdBarDoneLt = cdTextPrimaryLt;

  static const cdTextBrightLt = cdTextPrimaryLt;
  static const cdAuthWashLt = cdSurfaceWarmLt;
  static const cdErrorRingLt = Color(0x1FC1414D);

  static const cdCodeGutterLt = Color(0xFFA6A093);
  static const cdCodeLineLt = Color(0x148F6216);
  static const cdCodeKeywordLt = Color(0xFFA85426);
  static const cdCodeTypeLt = cdPrimaryLt;
  static const cdCodePunctLt = cdTextPrimaryLt;
  static const cdCodeNumberLt = cdSuccessLt;

  static const cdHeatLt = <Color>[
    Color(0xFFEFEBE2),
    Color(0xFFE8CE96),
    Color(0xFFC9922E),
    Color(0xFF8F6216),
  ];

  /// ======================================================================
  /// Legacy theme names, repointed to CoreDive primitives
  /// ======================================================================

  /// -------- dark ------------>
  static const primaryDk = cdBgBaseDk;
  static const mainCardDk = cdSurfaceDk;
  static const cardDk = mainCardDk;
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
