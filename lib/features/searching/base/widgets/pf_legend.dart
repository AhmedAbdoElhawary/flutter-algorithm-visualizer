import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/searching/base/widgets/end_point.dart';
import 'package:algorithm_visualizer/features/searching/base/widgets/pf_grid.dart';
import 'package:algorithm_visualizer/features/searching/base/widgets/start_point.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PFLegend extends StatelessWidget {
  const PFLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (context.accentGreen, 'Start'),
      (context.accentRed, 'End'),
      (kWallGridColor, 'Wall'),
      (kSearcherFinishedColor, 'Visited'),
      (kSearcherStartColor, 'Frontier'),
      (kPathGridColor, 'Path'),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Wrap(
          spacing: 12,
          runSpacing: 4,
          children: items.map((item) {
            final (color, label) = item;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              if (label == 'Start')
                PFStartPointWidget(size: 10.r)
              else if (label == 'End')
                PFEndPointWidget(size: 12.r)
              else
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.inter(color: context.textMuted, fontSize: 10)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
