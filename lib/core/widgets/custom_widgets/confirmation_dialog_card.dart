import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_rounded_elevated_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/rounded_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The card body shared by every confirmation popup, meant to be returned from
/// an [AnimatedPopup] builder.
class ConfirmationDialogCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String confirmLabel;
  final ThemeEnum accentColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialogCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.accentColor = ThemeEnum.accentRed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.w,
      padding: REdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.getColor(ThemeEnum.card),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.getColor(ThemeEnum.border)),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: context.getColor(accentColor).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIcon(
                icon,
                size: 24,
                color: accentColor,
              ),
            ),
          ),
          const RSizedBox(height: 14),
          BoldText(
            title,
            color: ThemeEnum.textPrimary,
            fontSize: 16,
            fontWeight: FontWeightManager.bold800,
            textAlign: TextAlign.center,
          ),
          const RSizedBox(height: 6),
          RegularText(
            description,
            color: ThemeEnum.textSecond,
            fontSize: 12,
            textAlign: TextAlign.center,
          ),
          const RSizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: RoundedOutlinedButton(
                  borderColor: ThemeEnum.border,
                  onPressed: onCancel,
                  child: const MediumText(
                    StringsManager.cancel,
                    color: ThemeEnum.textSecond,
                    fontSize: 13,
                  ),
                ),
              ),
              const RSizedBox(width: 10),
              Expanded(
                child: CustomRoundedElevatedButton(
                  backgroundColor: accentColor,
                  onPressed: onConfirm,
                  child: SemiBoldText(
                    confirmLabel,
                    color: ThemeEnum.solidWhite,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
