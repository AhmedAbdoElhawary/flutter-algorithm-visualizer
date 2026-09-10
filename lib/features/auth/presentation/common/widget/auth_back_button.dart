import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// 32px outline back square — CoreDive screens 12 / 03 header pattern. The
/// chevron is directional: it mirrors in RTL.
class AuthBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onPressed ?? () => context.pop(),
      child: Container(
        width: 32.r,
        height: 32.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CdRadius.sm.r),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
        ),
        child: Transform.flip(
          flipX: isRtl,
          child: const CustomIcon(Icons.chevron_left_rounded, size: 15, color: ThemeEnum.text2DarkColor),
        ),
      ),
    );
  }
}
