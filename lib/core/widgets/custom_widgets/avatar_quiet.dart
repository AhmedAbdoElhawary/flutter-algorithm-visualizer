import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one profile avatar shape — solid `textBright` fill, `onPrimary`
/// initial, radius scaling with [size]. Single-screen today, but any literal
/// still has to live in a shared widget, not the screen file.
class AvatarQuiet extends StatelessWidget {
  final String initial;
  final double size;
  final double fontSize;

  const AvatarQuiet({super.key, required this.initial, this.size = 64, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.textBright),
        borderRadius: BorderRadius.circular((size * 0.28).r),
      ),
      alignment: Alignment.center,
      child: BoldText(initial, color: ThemeEnum.onPrimary, fontSize: fontSize),
    );
  }
}
