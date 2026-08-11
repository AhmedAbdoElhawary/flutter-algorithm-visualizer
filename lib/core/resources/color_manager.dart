import 'package:flutter/material.dart';

/// [ColorManager]
/// colorD means that get dark version from the color for example:
/// greyD2 means that get version 2 darker from grey.
/// "less darker D1 < D2 < D4 < D7 < D9 more darker"
/// ------------------------>
/// colorL means that get light version from the color for example:
/// blackL4 means that get version 4 lighter from dark.
/// "less lighter L1 < L2 < L3 < L5 < L8 more lighter"
/// ------------------------>
/// colorOp means that get less opacity version from the main color for example:
/// blackT1 means that get the same main color "black" but with less opacity.
/// opacity  for main black:
/// black => 100%
/// blackOp90 => 90%
/// blackOp80 => 80%
/// blackOp70 => 70%
/// blackOp60 => 60%
/// blackOp50 => 50%
/// blackOp40 => 40%
/// blackOp30 => 30%
/// blackOp20 => 20%
/// blackOp10 => 10%

abstract final class ColorManager {
  /// -------- dark theme ------------>
  static const primaryDk = Color.fromRGBO(8, 13, 26, 1);
  static const cardDk = Color.fromRGBO(14, 23, 41, 0.8);
  static const mainCardDk = Color.fromRGBO(24, 29, 43, 0.7);
  static const outputHeaderDk = Color.fromRGBO(22, 32, 53, 1);
  static const accentDk = Color.fromRGBO(129, 140, 248, 1);

  static const accentGreenDk = Color.fromRGBO(52, 211, 153, 1);
  static const accentYellowDk = Color.fromRGBO(251, 191, 36, 1);
  static const accentRedDk = Color.fromRGBO(248, 113, 113, 1);

  static const accentBlueDk = Color.fromRGBO(96, 165, 250, 1);

  /// -------- dark theme ------------>
  static const Color main2DarkColor = Color.fromRGBO(192, 132, 252, 1);
  static const Color completeColumnSortColor = Color.fromRGBO(25, 42, 69, 1);
  static const Color columnSortColor = Color.fromRGBO(26, 47, 80, 0.7);
  static const Color backgroundForSortingColor = Color.fromRGBO(14, 23, 41, 0.30980392156862746);
  static const Color borderGlassDarkColor = Color(0x1BFFFFFF);
  static const Color white2DarkColor = Color.fromRGBO(148, 163, 184, 1);
  static const Color textDarkColor = Color.fromRGBO(67, 84, 116, 1);
  static const Color text2DarkColor = Color.fromRGBO(160, 179, 217, 1.0);
  static const Color howItWorksColor = Color.fromRGBO(23, 28, 53, 1);

  static const Color lightPurpleColor = Color.fromRGBO(23, 28, 53, 1.0);
  static const Color borderPurpleColor = Color.fromRGBO(67, 73, 128, 1.0);

  static const Color codeEditorBackground = Color.fromRGBO(12, 17, 23, 1);
  static const Color codeEditorNumberColor = Color.fromRGBO(44, 60, 87, 1);

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

  /// -------------------------------->

  static const Color transparent = Colors.transparent;
  static const Color transparentWhite = Color.fromRGBO(255, 255, 255, 0.48627450980392156);
  static const Color whiteOp10 = Color.fromRGBO(166, 170, 218, .1);
  static const Color whiteOp20 = Color.fromRGBO(166, 170, 218, .2);
  static const Color whiteOp30 = Color.fromRGBO(166, 170, 218, .3);
  static const Color whiteOp40 = Color.fromRGBO(67, 86, 122, 1.0);
  static const Color whiteOp50 = Color.fromRGBO(63, 78, 109, 1);
  static const Color whiteOp60 = Color.fromRGBO(166, 170, 218, .6);
  static const Color whiteOp70 = Color.fromRGBO(166, 170, 218, .7);
  static const Color whiteOp80 = Color.fromRGBO(166, 170, 218, .8);
  static const Color whiteOp90 = Color.fromRGBO(166, 170, 218, .9);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color whiteD1 = Color.fromRGBO(245, 245, 245, 1);
  static const Color whiteD2 = Color.fromRGBO(240, 240, 240, 1);
  static const Color whiteD3 = Color.fromRGBO(235, 235, 235, 1);
  static const Color whiteD4 = Color.fromRGBO(225, 225, 225, 1);
  static const Color whiteD5 = Color.fromRGBO(215, 215, 215, 1);
  static const Color whiteD6 = Color.fromRGBO(205, 205, 205, 1);
  static const Color whiteD7 = Color.fromRGBO(195, 195, 195, 1);
  static const Color whiteD8 = Color.fromRGBO(185, 185, 185, 1);
  static const Color whiteD9 = Color.fromRGBO(175, 175, 175, 1);
  static const Color whiteD10 = Color.fromRGBO(165, 165, 165, 1);

  static const Color grey = Color.fromRGBO(131, 137, 155, 1.0);
  static const Color greyOp70 = Color.fromRGBO(125, 133, 154, 0.8392156862745098);
  static const Color greyD1 = Color.fromRGBO(145, 145, 145, 1);
  static const Color greyD2 = Color.fromRGBO(135, 135, 135, 1);
  static const Color greyD3 = Color.fromRGBO(125, 125, 125, 1);
  static const Color greyD4 = Color.fromRGBO(115, 115, 115, 1);
  static const Color greyD5 = Color.fromRGBO(105, 105, 105, 1);
  static const Color greyD6 = Color.fromRGBO(95, 95, 95, 1);
  static const Color greyD7 = Color.fromRGBO(85, 85, 85, 1);
  static const Color greyD8 = Color.fromRGBO(75, 75, 75, 1);
  static const Color greyD9 = Color.fromRGBO(65, 65, 65, 1);

  static const Color blackL6 = Color.fromRGBO(55, 55, 55, 1);
  static const Color blackL5 = Color.fromRGBO(45, 45, 45, 1);
  static const Color blackL4 = Color.fromRGBO(35, 35, 35, 1);
  static const Color blackL3 = Color.fromRGBO(25, 25, 25, 1);
  static const Color blackL2 = Color.fromRGBO(15, 15, 15, 1);
  static const Color blackL1 = Color.fromRGBO(05, 05, 05, 1);
  static const Color black = Color.fromRGBO(00, 00, 00, 1);
  static const Color blackOp90 = Color.fromRGBO(00, 00, 00, 0.9);
  static const Color blackOp80 = Color.fromRGBO(00, 00, 00, 0.8);
  static const Color blackOp70 = Color.fromRGBO(00, 00, 00, 0.7);
  static const Color blackOp60 = Color.fromRGBO(00, 00, 00, 0.6);
  static const Color blackOp50 = Color.fromRGBO(00, 00, 00, 0.5);
  static const Color blackOp40 = Color.fromRGBO(00, 00, 00, 0.4);
  static const Color blackOp30 = Color.fromRGBO(00, 00, 00, 0.3);
  static const Color blackOp20 = Color.fromRGBO(00, 00, 00, 0.2);
  static const Color blackOp10 = Color.fromRGBO(00, 00, 00, 0.1);
  static const Color rankingGrey = Color.fromRGBO(153, 156, 159, 1.0);

  /// ------------------------------------------>

  static const Color wallBlack = Color.fromRGBO(22, 68, 101, 1.0);
  static const Color dividerBlue = Color.fromRGBO(175, 216, 248, 1.0);
  static const Color mediumBlue = Color.fromRGBO(111, 149, 230, 1.0);
  static const Color lightBlue = Color.fromRGBO(177, 221, 255, 1.0);
  static const Color lightBlueM2 = Color.fromRGBO(209, 234, 255, 1.0);
  static const Color lightBlueWhiteD1 = Color.fromRGBO(243, 243, 246, 1.0);
  static const Color blackL3Blue = Color.fromRGBO(14, 14, 19, 1.0);
  static const Color darkPurple = Color.fromRGBO(66, 8, 99, 1.0);

  static const Color purple = Color.fromRGBO(160, 4, 238, 1);
  static const Color purple2 = Color.fromRGBO(198, 0, 229, 1.0);
}
