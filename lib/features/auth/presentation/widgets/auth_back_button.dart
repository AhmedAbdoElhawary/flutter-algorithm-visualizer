import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AuthBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => context.pop(),
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        child: Center(
          child: CustomIcon(
            Icons.arrow_back_rounded,
            size: 18,
            color: ThemeEnum.textPrimary,
          ),
        ),
      ),
    );
  }
}
