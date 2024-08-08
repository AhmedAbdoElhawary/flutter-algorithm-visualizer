import 'package:flutter/material.dart';

extension CurrentDevice on BuildContext {
  bool get isAndroid {
    final ThemeData theme = Theme.of(this);
    return theme.platform == TargetPlatform.android;
  }
}
