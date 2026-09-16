import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemOverlay extends StatelessWidget {
  const SystemOverlay({
    required this.child,
    this.isBlackTheme = true,
    super.key,
  });
  final Widget child;
  final bool isBlackTheme;
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isBlackTheme ? blackTheme() : whiteTheme(),
      child: child,
    );
  }

  SystemUiOverlayStyle blackTheme() {
    return const SystemUiOverlayStyle(
        statusBarColor: ColorManager.groundDk,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorManager.groundDk,
        systemNavigationBarIconBrightness: Brightness.light);
  }

  /// The bars take `groundLt`, the light page background — not pure white.
  /// They sit flush against the page, so anything else draws a seam along the
  /// top and bottom of every screen.
  SystemUiOverlayStyle whiteTheme() {
    return const SystemUiOverlayStyle(
        statusBarColor: ColorManager.groundLt,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.groundLt,
        systemNavigationBarIconBrightness: Brightness.dark);
  }
}

class TransparentSystemOverlay extends StatelessWidget {
  const TransparentSystemOverlay({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: transparentTheme(),
      child: child,
    );
  }

  SystemUiOverlayStyle transparentTheme() {
    return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: ColorManager.transparent);
  }
}
