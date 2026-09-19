import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/domain/entities/recent_submission.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeRecentActivity extends ConsumerWidget {
  const HomeRecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(profileStatisticsProvider.select((value) => value.recentSubmissions));

    if (recent.isEmpty) return const SizedBox.shrink();

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      bottomPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: StringsManager.recentActivity),
          SizedBox(height: 10.h),
          ...recent.take(5).map((item) => OnlyPadding(
                bottomPadding: 7,
                child: _ActivityTile(item: item),
              )),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});

  final RecentSubmission item;

  @override
  Widget build(BuildContext context) {
    final diffLabel = item.difficulty.difficultyString;

    final timeAgo = _formatTimeAgo(context, item.submittedAt);

    final quietDifficulty = item.difficulty;

    return GestureDetector(
      onTap: () => context.pushProblem('${item.problemId}'),
      child: CardContainer(
        surface: CdSurface.main,
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 8.r,
              color: context.getColor(item.isCorrect ? ThemeEnum.dataEasy : ThemeEnum.dataMedium),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumText(item.problemName, fontSize: 13, color: ThemeEnum.inkTitle, maxLines: 1),
                  RegularText(timeAgo, fontSize: 11, color: ThemeEnum.inkSecondaryTitle),
                ],
              ),
            ),
            if (quietDifficulty != ProblemDifficulty.none)
              DifficultyChip(difficulty: quietDifficulty, label: diffLabel),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(BuildContext context, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return StringsManager.justNow.tr(context);
    if (diff.inMinutes < 60) return '${diff.inMinutes}${StringsManager.mAgo.tr(context)}';
    if (diff.inHours < 24) return '${diff.inHours}${StringsManager.hAgo.tr(context)}';
    if (diff.inDays == 1) return StringsManager.yesterday.tr(context);
    return '${diff.inDays}${StringsManager.dAgo.tr(context)}';
  }
}
