import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A [CardContainer] whose body is preceded by a [SectionHeader] row — title
/// plus optional trailing meta, e.g. "Continue" / "Solved 12/50".
class TitledCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget body;

  const TitledCard({super.key, required this.title, this.trailing, required this.body});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      surface: CdSurface.main,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, trailing: trailing),
          const RSizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}
