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

/// Backdrop-blur sigmas for the glass material and the ground.
///
/// [recessed] / [card] / [floating] are the three glass depths; [groundMask] is
/// the blur-mask sigma for the aurora bands (not a BackdropFilter).
abstract final class CdBlur {
  static const double recessed = 14;
  static const double card = 22;
  static const double floating = 30;
  static const double groundMask = 34;
}

/// The named elevation levels. No ad-hoc shadows anywhere else.
///
/// [e2] is the default card shadow, [e3] the floating shadow, [nav] the tab
/// bar's, and [glow] the one sanctioned CTA glow (white, on the primary button).
abstract final class CdElevation {
  static const List<BoxShadow> e1 = [
    BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> e2 = [
    BoxShadow(color: Color(0x80000000), blurRadius: 44, offset: Offset(0, 18)),
  ];
  static const List<BoxShadow> e3 = [
    BoxShadow(color: Color(0x99000000), blurRadius: 60, offset: Offset(0, 26)),
  ];
  static const List<BoxShadow> nav = [
    BoxShadow(color: Color(0x8C000000), blurRadius: 46, offset: Offset(0, 20)),
  ];
  static const List<BoxShadow> glow = [
    BoxShadow(color: Color(0x4DFFFFFF), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

extension CdElevationX on BuildContext {
  /// The white CTA glow — the one place a glow is allowed, because it is a
  /// primary action and not a data mark. Theme-independent.
  List<BoxShadow> get cdGlow => CdElevation.glow;
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
