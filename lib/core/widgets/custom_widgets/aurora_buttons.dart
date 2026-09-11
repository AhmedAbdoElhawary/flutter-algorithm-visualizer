import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Every filled CTA — solid white, on-primary label, no gradient. The white
/// glow is the one place a glow is allowed. Press = 0.98 scale over 90ms.
/// Disabled = recessed fill / disabled ink, no glow.
class AuroraPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;

  const AuroraPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
  });

  @override
  State<AuroraPrimaryButton> createState() => _AuroraPrimaryButtonState();
}

class _AuroraPrimaryButtonState extends State<AuroraPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;
    // The white pill. ThemeEnum.primary is the dark ground in this theme, not
    // white — the white primary-action colour is accentXp (→ #FFFFFF in dark).
    final bg = disabled
        ? ThemeEnum.glassRecessedFill
        : _pressed
            ? ThemeEnum.primaryPress
            : ThemeEnum.accentXp;
    final fg = disabled ? ThemeEnum.textDisabled : ThemeEnum.onPrimary;

    return GestureDetector(
      onTap: disabled ? null : widget.onPressed,
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? CdMotion.pressScale : 1,
        duration: CdMotion.press,
        child: AnimatedContainer(
          duration: CdMotion.press,
          padding: REdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: context.getColor(bg),
            borderRadius: BorderRadius.circular(CdRadius.md.r),
            boxShadow: disabled ? null : context.cdGlow,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2.r,
                      valueColor: AlwaysStoppedAnimation<Color>(context.getColor(ThemeEnum.onPrimary)),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.leadingIcon != null) ...[
                        CustomIcon(widget.leadingIcon!, size: 16, color: fg),
                        const RSizedBox(width: 8),
                      ],
                      SemiBoldText(widget.label, color: fg, fontSize: 14, maxLines: 1),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Outlined CTA — Reset, "See the visual trace". [ThemeEnum.borderStrong]
/// outline, code-punct label, no fill. Press = 0.98 scale.
class AuroraSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const AuroraSecondaryButton({super.key, required this.label, required this.onPressed});

  @override
  State<AuroraSecondaryButton> createState() => _AuroraSecondaryButtonState();
}

class _AuroraSecondaryButtonState extends State<AuroraSecondaryButton> {
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
          padding: REdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CdRadius.md.r),
            border: Border.all(color: context.getColor(ThemeEnum.borderStrong)),
          ),
          child: Center(
            child: SemiBoldText(widget.label, color: ThemeEnum.textBright, fontSize: 13, maxLines: 1),
          ),
        ),
      ),
    );
  }
}

/// The pinned action area — a scrim fading from transparent to the base colour,
/// with the CTA(s) on top. The scrim is the one gradient the design sanctions
/// outside the theme file.
class BottomCtaBar extends StatelessWidget {
  final Widget child;

  const BottomCtaBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final base = context.getColor(ThemeEnum.primary);
    return Container(
      padding: REdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [base.withValues(alpha: 0), base.withValues(alpha: 0.96)],
          stops: const [0, 0.4],
        ),
      ),
      child: child,
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({this.onTap,super.key});
final VoidCallback?onTap;
  @override
  Widget build(BuildContext context) {
    return AuroraIconButton(
      background: ThemeEnum.glassRecessedFill100,
      icon: Icons.arrow_back_ios_new_rounded,
      size: 35,
      iconSize: 18,
      onPressed:onTap?? () => context.back(),
    );
  }
}

/// Square outlined icon button — back arrow, transport controls, header
/// actions. Sizes in use are 30 and 44.
class AuroraIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final ThemeEnum iconColor;
  final ThemeEnum? background;

  const AuroraIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 30,
    this.iconSize = 14,
    this.iconColor = ThemeEnum.textBody,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size.r,
        height: size.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CdRadius.sm.r),
            border: Border.all(color: context.getColor(ThemeEnum.border)),
            color: background == null ? null : context.getColor(background!)),
        child: CustomIcon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
