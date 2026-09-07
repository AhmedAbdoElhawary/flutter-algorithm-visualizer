import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
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
  static const double md = 13;
  static const double lg = 19;
  static const double xl = 24;
  static const double pill = 999;
}

/// The four named elevation levels. No ad-hoc shadows anywhere else.
///
/// [glow] is brass-tinted; prefer [CdElevationX.cdGlow] so it follows the active
/// theme's primary. The alpha values below are the design constants.
abstract final class CdElevation {
  static const List<BoxShadow> e1 = [
    BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> e2 = [
    BoxShadow(color: Color(0x73000000), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> e3 = [
    BoxShadow(color: Color(0xB3000000), blurRadius: 60, offset: Offset(0, 24)),
  ];
  static const List<BoxShadow> glow = [
    BoxShadow(color: Color(0x42E0A33E), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

extension CdElevationX on BuildContext {
  /// Brass glow that tracks the active theme's primary colour. Brass is brighter
  /// than teal, so the alpha sits lower than the old teal glow (.26 dark / .20 light).
  List<BoxShadow> get cdGlow => [
        BoxShadow(
          color: getColor(ThemeEnum.primary).withValues(alpha: isThemeDark ? 0.26 : 0.20),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

abstract final class CdMotion {
  static const Duration press = Duration(milliseconds: 90);
  static const Duration fade = Duration(milliseconds: 120);
  static const Duration step = Duration(milliseconds: 180);
  static const Duration dialog = Duration(milliseconds: 200);
  static const Duration expand = Duration(milliseconds: 240);
  static const Duration ring = Duration(milliseconds: 2400);

  static const Curve easeOut = Cubic(.2, .8, .4, 1);
  static const Curve easePop = Cubic(.2, 1.3, .4, 1);
  static const Curve dialogIn = Cubic(.2, 1.1, .4, 1);

  static const double pressScale = 0.98;
}
