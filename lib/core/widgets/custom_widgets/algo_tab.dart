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
    this.constrainLabelWidth = false,
    super.key,
  });
  final String label;
  final bool isSelected;
  final bool addEndPadding;
  final IconData? icon;
  final double verticalPadding;

  /// Set this only where the tab's own parent gives it a **bounded** width —
  /// today, the three searching tabs split evenly across one row via
  /// `Expanded`.
  ///
  /// The sorting tabs are the opposite case: they live in a horizontally
  /// scrolling `Row` with no width bound at all, and a `Flexible`/`Expanded`
  /// child there is a hard crash (`RenderFlex` needs a bounded main axis to
  /// give a flex child a size), not a soft overflow. So the label only gets
  /// wrapped in `Flexible` — and only then does it need `maxLines` and
  /// ellipsis — when the caller has confirmed its own layout can supply that
  /// bound.
  final bool constrainLabelWidth;
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
          constrainWidth: constrainLabelWidth,
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
    this.constrainLabelWidth = false,
    super.key,
  });
  final String label;
  final bool isSelected;
  final bool addEndPadding;
  final IconData? icon;
  final double verticalPadding;
  final ThemeEnum? borderColorOverride;

  /// Set this only where the tab's own parent gives it a **bounded** width —
  /// today, the three searching tabs split evenly across one row via
  /// `Expanded`.
  ///
  /// The sorting tabs are the opposite case: they live in a horizontally
  /// scrolling `Row` with no width bound at all, and a `Flexible`/`Expanded`
  /// child there is a hard crash (`RenderFlex` needs a bounded main axis to
  /// give a flex child a size), not a soft overflow. So the label only gets
  /// wrapped in `Flexible` — and only then does it need `maxLines` and
  /// ellipsis — when the caller has confirmed its own layout can supply that
  /// bound.
  final bool constrainLabelWidth;
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
              color: color,
              constrainWidth: constrainLabelWidth,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bare when [constrainWidth] is false (the old, unconstrained-safe shape);
/// wrapped in [Flexible] with a one-line ellipsis when it is true. See
/// [AlgoTab.constrainLabelWidth] for which contexts need which.
class _AlgoTabLabel extends StatelessWidget {
  const _AlgoTabLabel({required this.label, required this.color, required this.constrainWidth});

  final String label;
  final ThemeEnum color;
  final bool constrainWidth;

  @override
  Widget build(BuildContext context) {
    final text = SemiBoldText(
      label,
      textAlign: TextAlign.center,
      fontFamily: FontConstants.fontFamily,
      color: color,
      fontSize: 12.5,
      maxLines: constrainWidth ? 1 : 2,
    );

    return constrainWidth ? Flexible(child: text) : text;
  }
}
