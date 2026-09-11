import 'package:flutter/material.dart';

/// CoreDive spacing / radius / elevation / motion scales.
///
/// These are the raw numbers only. Apply ScreenUtil suffixes at the call site
/// (`CdSpace.x4.h`, `CdRadius.lg.r`) exactly as with any other size in this repo.
/// The adaptive `*Padding` widgets scale internally, so pass the bare value
/// there (`AllPadding(padding: CdSpace.x4, ...)`).
///
/// Source of truth: design_handoff_coredive/tokens/coredive_tokens.dart
abstract final class CdSpace {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x12 = 48;
  static const double x16 = 64;

  static const double screenInset = 16;
  static const double authInset = 24;

  static const double gapCard = 14;
  static const double gapRow = 8;

  static const double tabBarHeight = 74;
  static const double ctaReserve = 134;
  static const double hitMin = 44;
}

abstract final class CdRadius {
  static const double sm = 9;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 19;
  static const double pill = 999;
}

abstract final class CdMotion {
  static const Duration press = Duration(milliseconds: 90);
  static const Duration fade = Duration(milliseconds: 120);
  static const Duration step = Duration(milliseconds: 180);
  static const Duration dialog = Duration(milliseconds: 200);
  static const Duration expand = Duration(milliseconds: 240);
  static const Duration ring = Duration(milliseconds: 2400);

  /// Colour vs height on a chart bar — resolve independently.
  static const Duration barColour = Duration(milliseconds: 180);
  static const Duration barHeight = Duration(milliseconds: 240);

  /// The pulsing live dot (Step 8) and Home's ground drift (Step 2).
  static const Duration live = Duration(milliseconds: 1600);
  static const Duration ground = Duration(seconds: 28);

  static const Curve easeOut = Cubic(.2, .8, .4, 1);
  static const Curve easePop = Cubic(.2, 1.3, .4, 1);
  static const Curve dialogIn = Cubic(.2, 1.1, .4, 1);

  static const double pressScale = 0.98;
}
