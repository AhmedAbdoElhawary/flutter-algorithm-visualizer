import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/surface_card.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/tag_chip.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCategoryChart extends ConsumerWidget {
  const ProfileCategoryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySolved = ref.watch(profileStatisticsProvider.select((value) => value.categorySolved));

    final entries = categorySolved.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return const SizedBox.shrink();

    return HorizontalPadding(
      padding: 16,
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: StringsManager.solvedTopics),
            const RSizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entries.map((e) => TagChip(label: '${e.key}  ${e.value}')).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
