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
        SemiBoldText(title, fontSize: 15, color: ThemeEnum.textPrimary),
        if (trailing != null) RegularText(trailing!, fontSize: 11, color: ThemeEnum.textSecond),
      ],
    );
  }
}
