import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_button_quiet.dart';
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
    return CardContainer(
      radius: CdRadius.dialog,
      padding: REdgeInsets.all(20),
      child: SizedBox(
        width: 320.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.chipNeutralFill),
                shape: BoxShape.circle,
              ),
              child: CustomIcon(icon, size: 24, color: accentColor),
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
                  child: SecondaryButtonQuiet(label: StringsManager.cancel, onPressed: onCancel),
                ),
                const RSizedBox(width: 10),
                Expanded(
                  child: PrimaryButtonQuiet(label: confirmLabel, onPressed: onConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
