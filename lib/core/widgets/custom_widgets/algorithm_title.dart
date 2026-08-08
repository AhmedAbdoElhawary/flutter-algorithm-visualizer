import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:flutter/material.dart';

class AlgorithmTitle extends StatelessWidget {
  const AlgorithmTitle({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText(title, fontSize: 20),
        RegularText(
          description,
          fontSize: 11,
          color: ThemeEnum.hoverColor,
        )
      ],
    );
  }
}
