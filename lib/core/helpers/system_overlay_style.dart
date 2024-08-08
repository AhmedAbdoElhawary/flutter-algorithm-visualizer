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
        statusBarColor: ColorManager.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: ColorManager.blackL2,
        systemNavigationBarIconBrightness: Brightness.light);
  }

  SystemUiOverlayStyle whiteTheme() {
    return const SystemUiOverlayStyle(
        statusBarColor: ColorManager.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: ColorManager.white,
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
      systemNavigationBarDividerColor: ColorManager.transparent
    );
  }
}
