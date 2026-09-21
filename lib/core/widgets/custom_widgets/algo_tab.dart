import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainAlgoTab extends ConsumerWidget {
  const MainAlgoTab({
    this.icon,
    required this.label,
    required this.isSelected,
    required this.addEndPadding,
    this.verticalPadding = 0,
    super.key,
  });
  final String label;
  final bool isSelected;
  final bool addEndPadding;
  final IconData? icon;
  final double verticalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = isSelected ? ThemeEnum.inkTitle : ThemeEnum.inkSecondaryTitle;
    final border = isSelected ? ThemeEnum.raised : ThemeEnum.transparentColor;
    final style = isSelected ? CdSurface.simpleColored : CdSurface.outlined;

    return CardContainer(
      padding: REdgeInsets.symmetric(vertical: 8),
      radius: CdRadius.sm,
      surface: style,
      borderColorOverride: border,
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 10, vertical: verticalPadding),
        child: _AlgoTabLabel(
          label: label,
          color: textColor,
        ),
      ),
    );
  }
}

class AlgoTab extends ConsumerWidget {
  const AlgoTab({
    this.icon,
    required this.label,
    this.borderColorOverride,
    required this.isSelected,
    required this.addEndPadding,
    this.verticalPadding = 0,
    super.key,
  });
  final String label;
  final bool isSelected;
  final bool addEndPadding;
  final IconData? icon;
  final double verticalPadding;
  final ThemeEnum? borderColorOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = isSelected ? ThemeEnum.ground : ThemeEnum.inkSecondaryTitle;
    final style = isSelected ? CdSurface.fill : CdSurface.main;

    return CardContainer(
      padding: REdgeInsets.symmetric(vertical: 8),
      radius: CdRadius.sm,
      surface: style,
      showBorder: false,
      child: Padding(
        padding: REdgeInsets.symmetric(horizontal: 10, vertical: verticalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[CustomIcon(icon!, color: color, size: 20), const RSizedBox(width: 5)],
            _AlgoTabLabel(
              label: label,
              color: color
            ),
          ],
        ),
      ),
    );
  }
}

class _AlgoTabLabel extends StatelessWidget {
  const _AlgoTabLabel({required this.label, required this.color});

  final String label;
  final ThemeEnum color;

  @override
  Widget build(BuildContext context) {
    final text = SemiBoldText(
      label,
      textAlign: TextAlign.center,
      fontFamily: FontConstants.fontFamily,
      color: color,
      fontSize: 12.5,
    );

    return text;
  }
}
