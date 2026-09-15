import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:flutter/material.dart';

enum ThemeEnum {
  ground,
  surface,
  raised,
  hairline,
  track,
  inkPrimary,
  inkTitle,
  inkBody,
  inkMuted,
  dataEasy,
  dataMedium,
  dataHard,
  dataTarget,
  dataActive,

  heat0,
  heat1,
  heat2,
  heat3,
  heat4,

  transparentColor,
}

extension ThemeExtension on BuildContext {
  bool get isThemeDark => Theme.of(this).brightness == Brightness.dark;

  T _pick<T>(T dark, T light) => isThemeDark ? dark : light;

  Map<ThemeEnum, Color> get _colors {
    return {
      ThemeEnum.transparentColor: ColorManager.transparent,
      ThemeEnum.ground: _pick(ColorManager.groundDk, ColorManager.groundLt),
      ThemeEnum.surface: _pick(ColorManager.surfaceDk, ColorManager.surfaceLt),
      ThemeEnum.raised: _pick(ColorManager.raisedDk, ColorManager.raisedLt),
      ThemeEnum.hairline: _pick(ColorManager.hairlineDk, ColorManager.hairlineLt),
      ThemeEnum.track: _pick(ColorManager.trackDk, ColorManager.trackLt),
      ThemeEnum.inkPrimary: _pick(ColorManager.inkPrimaryDk, ColorManager.inkPrimaryLt),
      ThemeEnum.inkTitle: _pick(ColorManager.inkTitleDk, ColorManager.inkTitleLt),
      ThemeEnum.inkBody: _pick(ColorManager.inkBodyDk, ColorManager.inkBodyLt),
      ThemeEnum.inkMuted: _pick(ColorManager.inkMutedDk, ColorManager.inkMutedLt),
      ThemeEnum.dataEasy: _pick(ColorManager.dataEasyDk, ColorManager.dataEasyLt),
      ThemeEnum.dataMedium: _pick(ColorManager.dataMediumDk, ColorManager.dataMediumLt),
      ThemeEnum.dataHard: _pick(ColorManager.dataHardDk, ColorManager.dataHardLt),
      ThemeEnum.dataTarget: _pick(ColorManager.dataTargetDk, ColorManager.dataTargetLt),
      ThemeEnum.dataActive: _pick(ColorManager.dataActiveDk, ColorManager.dataActiveLt),
      ThemeEnum.heat0: _pick(ColorManager.heatDk[0], ColorManager.heatLt[0]),
      ThemeEnum.heat1: _pick(ColorManager.heatDk[1], ColorManager.heatLt[1]),
      ThemeEnum.heat2: _pick(ColorManager.heatDk[2], ColorManager.heatLt[2]),
      ThemeEnum.heat3: _pick(ColorManager.heatDk[3], ColorManager.heatLt[3]),
      ThemeEnum.heat4: _pick(ColorManager.heatDk[4], ColorManager.heatLt[4]),
    };
  }

  Color getColor(ThemeEnum color) => _colors[color] ?? Theme.of(this).primaryColor;
}
