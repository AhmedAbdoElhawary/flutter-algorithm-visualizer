import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DemoAccountCard extends StatelessWidget {
  final VoidCallback onAutoFill;

  const DemoAccountCard({
    super.key,
    required this.onAutoFill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.card),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.getColor(ThemeEnum.border)),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: context.getColor(ThemeEnum.accentBg),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: context.getColor(ThemeEnum.borderAccent),
                width: 1.r,
              ),
            ),
            child: Center(
              child: CustomIcon(
                Icons.vpn_key_rounded,
                size: 18,
                color: ThemeEnum.accent,
              ),
            ),
          ),
          RSizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediumText(
                  StringsManager.demoAccount,
                  color: ThemeEnum.textPrimary,
                  fontSize: 13,
                ),
                RSizedBox(height: 2),
                RegularText(
                  StringsManager.demoAccountUser,
                  color: ThemeEnum.textSecond,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAutoFill,
            child: Container(
              padding: REdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.accentBg),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.getColor(ThemeEnum.borderAccent),
                  width: 1.r,
                ),
              ),
              child: MediumText(
                StringsManager.autoFill,
                color: ThemeEnum.accent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
