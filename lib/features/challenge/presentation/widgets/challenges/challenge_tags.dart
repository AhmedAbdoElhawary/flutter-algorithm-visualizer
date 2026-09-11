import 'package:algorithm_visualizer/core/widgets/custom_widgets/tag_chip.dart';
import 'package:flutter/material.dart';

class ChallengeTags extends StatelessWidget {
  const ChallengeTags({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: tags.map((t) => TagChip(label: t)).toList(),
    );
  }
}
