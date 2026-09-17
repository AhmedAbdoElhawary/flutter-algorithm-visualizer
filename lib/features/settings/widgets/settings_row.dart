import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One tappable line on the settings screen: icon, title, optional caption and
/// a chevron.
///
/// Rows carry no surface of their own — they are meant to be stacked inside a
/// single [CardContainer] so a section reads as one grouped card rather than a
/// column of separate tiles.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.accentColor = ThemeEnum.inkTitle,
    this.trailing,
    this.showChevron = true,
    this.translateLabels = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final ThemeEnum accentColor;
  final Widget? trailing;
  final bool showChevron;

  /// Off for a row whose text is a proper noun that must not be translated —
  /// the language picker names each language in itself.
  final bool translateLabels;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: VerticalPadding(
        padding: 10,
        child: Row(
          children: [
            IconButtonQuiet(icon: icon, size: 36, iconSize: 18, iconColor: accentColor),
            const RSizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoldText(
                    title,
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeightManager.bold800,
                    translate: translateLabels,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const RSizedBox(height: 2),
                    RegularText(
                      subtitle!,
                      color: ThemeEnum.inkBody,
                      fontSize: 11,
                      maxLines: 3,
                      translate: translateLabels,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && showChevron)
              const CustomIcon(Icons.chevron_right_rounded, size: 18, color: ThemeEnum.track),
          ],
        ),
      ),
    );
  }
}

/// The hairline between two [SettingsRow]s inside the same card.
class SettingsRowDivider extends StatelessWidget {
  const SettingsRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1.h,
      thickness: 1,
      color: context.getColor(ThemeEnum.hairline),
    );
  }
}
