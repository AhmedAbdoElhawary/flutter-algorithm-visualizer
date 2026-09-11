import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A [SurfaceCard] whose body is preceded by a [SectionHeader] row — title
/// plus optional trailing meta, e.g. "Continue" / "Solved 12/50".
class TitledCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget body;

  const TitledCard({super.key, required this.title, this.trailing, required this.body});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, trailing: trailing),
          RSizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}
