import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';

/// A section title row — "Activity", "Topics", "This week" — with an optional
/// trailing meta string. Used at the top of a screen section, never inside a
/// card (see [TitledCard] for that shape).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Flexible, not bare: a title long enough to fill the row — a wordy
        // section name, or the Arabic translation of a short one — otherwise
        // overflows the Row instead of wrapping.
        Flexible(
          child: SemiBoldText(title, fontSize: 15, color: ThemeEnum.inkTitle, maxLines: 2),
        ),
        if (trailing != null) RegularText(trailing!, fontSize: 11, color: ThemeEnum.inkSecondaryTitle),
      ],
    );
  }
}
