import 'package:algorithm_visualizer/core/widgets/custom_widgets/filter_chip_quiet.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_notifier.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChallengesFilterTabs extends ConsumerWidget {
  const ChallengesFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(challengesProvider.select((s) => s.filter));

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ChallengesNotifier.filters.map((f) {
            final active = activeFilter == f;
            final count = ref
                .watch(specificDifficultyCountProvider(f))
                .maybeWhen(data: (data) => "$data", orElse: () => "");

            return Padding(
              padding: REdgeInsetsDirectional.only(end: 8),
              child: FilterChipQuiet(
                label: f.difficultyString,
                selected: active,
                count: count,
                onTap: () => ref.read(challengesProvider.notifier).setFilter(f),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
