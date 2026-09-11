import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/heat_grid.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/surface_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeatmap extends StatelessWidget {
  const ProfileHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return HorizontalPadding(
      padding: 16,
      child: SurfaceCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(title: StringsManager.activityHeatmap),
          RSizedBox(height: 8),
          const HeatGridLegend(),
          RSizedBox(height: 10),
          Consumer(
            builder: (context, ref, child) {
              final heatmapData =
                  ref.watch(profileStatisticsProvider.select((value) => value.heatmapData));

              return HeatGrid(dailyCounts: heatmapData);
            },
          ),
        ]),
      ),
    );
  }
}
