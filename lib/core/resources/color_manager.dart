import 'package:flutter/material.dart';

/// [ColorManager]
/// SURFACES   ground → surface → raised → hairline → track
/// INK        inkPrimary → inkTitle → inkBody → inkMuted
/// DATA       dataEasy · dataMedium · dataHard · dataTarget · dataActive
/// CODE       codeKeyword · codeString · codeNumber · codeBuiltin · codeComment · codePunct
/// SEARCH     searchStart · searchEnd · searchWall · searchVisited · searchSearcher · searchTrail0 · searchTrail1 · searchPath

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

  static const Color dataEasyLt = Color(0xFF228655);
  static const Color dataMediumLt = Color(0xFF9E6B25);
  static const Color dataHardLt = Color(0xFFD33F4C);
  static const Color dataTargetLt = Color(0xFF2D79BC);
  static const Color dataActiveLt = inkTitleLt;

  /// low → high.
  /// 0 / 25 / 50 / 75 / 100 %
  static const List<Color> heatDk = <Color>[
    raisedDk,
    Color(0xFF304640),
    Color(0xFF497262),
    heat3,
    dataEasyDk,
  ];
  static const Color heat3 = Color(0xFF619D83);

  static const List<Color> heatLt = <Color>[
    raisedLt,
    Color(0xFFB7D0CC),
    Color(0xFF80B0A2),
    Color(0xFF489078),
    dataEasyLt,
  ];

  static const Color codeKeywordDk = Color(0xFFC79BE8);
  static const Color codeStringDk = Color(0xFF9ED49B);
  static const Color codeNumberDk = Color(0xFFE8A87C);
  static const Color codeBuiltinDk = Color(0xFF7FB8E8);
  static const Color codeCommentDk = Color(0xFF6B7180);
  static const Color codePunctDk = Color(0xFF8A90A0);

  static const Color codeKeywordLt = Color(0xFF8A3FA8);
  static const Color codeStringLt = Color(0xFF1F7A4D);
  static const Color codeNumberLt = Color(0xFFA85B1A);
  static const Color codeBuiltinLt = Color(0xFF1B6BB5);
  static const Color codeCommentLt = Color(0xFF6B7280);
  static const Color codePunctLt = Color(0xFF4A4F5A);

  static const Color searchStartDk = Color(0xFF4ADE80);
  static const Color searchEndDk = Color(0xFFF87171);
  static const Color searchWallDk = Color(0xFF394050);
  static const Color searchVisitedDk =Color(0xFF67E8F9);
  static const Color searchSearcherDk = Color(0xFFF0ABFC);
  static const Color searchTrail0Dk = Color(0xFF3A6AD1);
  static const Color searchTrail1Dk = Color(0xFF3DDDB8);
  static const Color searchPathDk = Color(0xFFFBBF24);

  static const Color searchStartLt = Color(0xFF16A34A);
  static const Color searchEndLt = Color(0xFFDC2626);
  static const Color searchWallLt = Color(0xFF475569);
  static const Color searchVisitedLt = Color(0xFF06B6D4);
  static const Color searchSearcherLt = Color(0xFFC026D3);
  static const Color searchTrail0Lt = Color(0xFF3974E3);
  static const Color searchTrail1Lt = Color(0xFF42E8D5);
  static const Color searchPathLt = Color(0xFFF59E0B);

  static const Color transparent = Colors.transparent;
}
