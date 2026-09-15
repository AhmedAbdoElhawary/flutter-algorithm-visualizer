import 'package:flutter/material.dart';

/// [ColorManager]
/// SURFACES   ground → surface → raised → hairline → track
/// INK        inkPrimary → inkTitle → inkBody → inkMuted
/// DATA       dataEasy · dataMedium · dataHard · dataTarget · dataActive

abstract final class ColorManager {
  static const Color groundDk = Color(0xFF0B0B0D);
  static const Color surfaceDk = Color(0xFF121317);
  static const Color raisedDk = Color(0xFF181A1F);
  static const Color hairlineDk = Color(0xFF24262C);
  static const Color trackDk = Color(0xFF2A2D35);

  static const Color inkPrimaryDk = Color(0xFFFFFFFF);
  static const Color inkTitleDk = Color(0xFFF2F3F5);
  static const Color inkBodyDk = Color(0xFF9A9FAB);
  static const Color inkMutedDk = Color(0xFF63687A);

  static const Color dataEasyDk = Color(0xFF79C9A4);
  static const Color dataMediumDk = Color(0xFFD9AE72);
  static const Color dataHardDk = Color(0xFFDE8189);
  static const Color dataTargetDk = Color(0xFF72A8D9);
  static const Color dataActiveDk = inkPrimaryDk;

  static const Color groundLt = Color(0xFFF4F5F7);
  static const Color surfaceLt = Color(0xFFFFFFFF);
  static const Color raisedLt = Color(0xFFEEF0F6);
  static const Color hairlineLt = Color(0xFFE2E4E9);
  static const Color trackLt = Color(0xFFDCDEE3);

  static const Color inkPrimaryLt = Color(0xFF0B0B0D);
  static const Color inkTitleLt = Color(0xFF101114);
  static const Color inkBodyLt = Color(0xFF4A4F5A);
  static const Color inkMutedLt = Color(0xFF667080);

  static const Color dataEasyLt = Color(0xFF11704E);
  static const Color dataMediumLt = Color(0xFF8A5D12);
  static const Color dataHardLt = Color(0xFFA83F49);
  static const Color dataTargetLt = Color(0xFF12518A);
  static const Color dataActiveLt = inkTitleLt;

  /// low → high.
  /// 0 / 25 / 50 / 75 / 100 %
  static const List<Color> heatDk = <Color>[
    raisedDk,
    Color(0xFF304640),
    Color(0xFF497262),
    Color(0xFF619D83),
    dataEasyDk,
  ];

  static const List<Color> heatLt = <Color>[
    raisedLt,
    Color(0xFFB7D0CC),
    Color(0xFF80B0A2),
    Color(0xFF489078),
    dataEasyLt,
  ];

  static const Color transparent = Colors.transparent;
}
