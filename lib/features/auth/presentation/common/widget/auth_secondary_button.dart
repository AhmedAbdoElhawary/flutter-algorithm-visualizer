import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// CoreDive secondary action — outline, bright label, no fill. Press = 0.98 scale.
class AuthSecondaryButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;

  const AuthSecondaryButton({super.key, required this.title, required this.onPressed});

  @override
  State<AuthSecondaryButton> createState() => _AuthSecondaryButtonState();
}

class _AuthSecondaryButtonState extends State<AuthSecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? CdMotion.pressScale : 1,
        duration: CdMotion.press,
        child: Container(
          padding: REdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CdRadius.md.r),
            border: Border.all(color: context.getColor(ThemeEnum.borderStrong)),
          ),
          child: Center(
            child: SemiBoldText(widget.title, color: ThemeEnum.textBright, fontSize: 13, maxLines: 1),
          ),
        ),
      ),
    );
  }
}
