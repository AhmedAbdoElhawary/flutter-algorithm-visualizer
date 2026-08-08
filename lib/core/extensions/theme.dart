import 'package:flutter/material.dart';

extension AppThemeExt on BuildContext {
  bool get isThemeDark => Theme.of(this).brightness == Brightness.dark;
}
