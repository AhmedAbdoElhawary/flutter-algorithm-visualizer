import 'package:flutter/material.dart';

abstract final class ColorManager {
  /// -------- unified theme ------------>

  static const Color targetSearchingPoint = Color.fromRGBO(66, 8, 99, 1.0);
  static const Color wallBlack = Color.fromRGBO(22, 68, 101, 1.0);
  /// -------- dark theme Only------------>
  static const Color pinkColor = Color.fromRGBO(192, 132, 252, 1);
  static const Color lightPinkColor = Color.fromRGBO(192, 132, 252, 0.1);
  static const Color columnSortColor = Color.fromRGBO(26, 47, 80, 0.7);
  static const Color backgroundForSortingColor = Color.fromRGBO(14, 23, 41, 0.3);
  static const Color white2DarkColor = Color.fromRGBO(148, 163, 184, 1);
  static const Color textDarkColor = Color.fromRGBO(67, 84, 116, 1);
  static const Color text2DarkColor = Color.fromRGBO(160, 179, 217, 1.0);
  static const Color howItWorksColor = Color.fromRGBO(23, 28, 53, 1);
  static const Color lightPurpleColor = Color.fromRGBO(23, 28, 53, 1.0);
  static const Color borderPurpleColor = Color.fromRGBO(67, 73, 128, 1.0);
  static const Color codeEditorBackground = Color.fromRGBO(12, 17, 23, 1);
  static const Color codeEditorNumberColor = Color.fromRGBO(44, 60, 87, 1);

  /// -------- dark theme ------------>
  static const primaryDk = Color.fromRGBO(8, 13, 26, 1);
  static const cardDk = Color.fromRGBO(14, 23, 41, 0.8);
  static const mainCardDk = Color.fromRGBO(24, 29, 43, 0.7);
  static const outputHeaderDk = Color.fromRGBO(22, 32, 53, 1);
  static const accentDk = Color.fromRGBO(129, 140, 248, 1);
  static const accentGreenDk = Color.fromRGBO(52, 211, 153, 1);
  static const accentGreenBgDk = Color.fromRGBO(17, 185, 129, 1);
  static const accentYellowDk = Color.fromRGBO(251, 191, 36, 1);
  static const accentYellowBgDk = Color.fromRGBO(245, 158, 11, 1);
  static const accentRedDk = Color.fromRGBO(248, 113, 113, 1);
  static const accentRedBgDk = Color.fromRGBO(239, 68, 68, 1);
  static const accentBlueDk = Color.fromRGBO(96, 165, 250, 1);
  static const textPrimaryDk = Color.fromRGBO(226, 232, 240, 1);
  static const textSecondDk = Color.fromRGBO(148, 163, 184, 1);
  static const hoverDk = Color.fromRGBO(74, 92, 126, 1);
  static const hoverSecondDk = Color.fromRGBO(42, 58, 85, 1);
  static const borderDk = Color.fromRGBO(255, 255, 255, 0.04);

  /// -------- light theme ------------>
  static const primaryLt = Color.fromRGBO(238, 242, 255, 1);
  static const cardLt = Color.fromRGBO(255, 255, 255, 1);
  static const mainCardLt = Color.fromRGBO(134, 139, 158, 0.7);
  static const outputHeaderLt = Color.fromRGBO(244, 247, 255, 1);
  static const accentLt = Color.fromRGBO(99, 102, 241, 1);
  static const accentGreenLt = Color.fromRGBO(5, 150, 105, 1);
  static const accentYellowLt = Color.fromRGBO(217, 119, 6, 1);
  static const accentRedLt = Color.fromRGBO(220, 38, 38, 1);
  static const accentBlueLt = Color.fromRGBO(37, 99, 235, 1);
  static const textPrimaryLt = Color.fromRGBO(15, 23, 42, 1);
  static const textSecondLt = Color.fromRGBO(71, 85, 105, 1);
  static const hoverLt = Color.fromRGBO(100, 116, 139, 1);
  static const hoverSecondLt = Color.fromRGBO(148, 163, 184, 1);
  static const borderLt = Color.fromRGBO(0, 0, 0, 0.06);

  /// -------------------------------->

  static const Color transparent = Colors.transparent;
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color whiteD5 = Color.fromRGBO(215, 215, 215, 1);
  static const Color whiteD6 = Color.fromRGBO(205, 205, 205, 1);
  static const Color grey = Color.fromRGBO(65, 65, 65, 1);
  static const Color grey2 = Color.fromRGBO(75, 75, 75, 1);
  static const Color black = Color.fromRGBO(00, 00, 00, 1);
}
