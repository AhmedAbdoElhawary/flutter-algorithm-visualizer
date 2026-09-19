import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Which fill an onboarding button carries. Geometry is identical for both —
/// same height, same radius, same label size — so "Continue as guest" never
/// reads as a downgrade next to "Get started" (spec §4).
enum OnboardingButtonStyle {
  /// Surface fill + 1 px border. `Next` and `Continue as guest`.
  outlined,

  /// Accent fill + inverted label. `Get started`.
  filled,
}

class OnboardingButton extends StatefulWidget {
  const OnboardingButton({
    required this.label,
    required this.onPressed,
    this.style = OnboardingButtonStyle.outlined,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final OnboardingButtonStyle style;

  @override
  State<OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<OnboardingButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isFilled = widget.style == OnboardingButtonStyle.filled;

    // Pressed states come from the spec: the filled button darkens its fill,
    // the outlined one lifts fill + border one step and dims its label to 80%.
    final Color fill = isFilled
        ? context.getColor(_pressed ? ThemeEnum.inkTitle : ThemeEnum.inkPrimary)
        : context.getColor(_pressed ? ThemeEnum.hairline : ThemeEnum.track);

    final labelColor = isFilled
        ? context.getColor(ThemeEnum.ground)
        : context.getColor(ThemeEnum.inkTitle).withValues(alpha: _pressed ? 0.8 : 1);

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: Container(
        height: 52.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12.r)),
        child: AdaptiveText(
          widget.label,
          maxLines: 1,
          style: GetSemiBoldStyle(fontSize: 17, color: labelColor),
        ),
      ),
    );
  }
}
