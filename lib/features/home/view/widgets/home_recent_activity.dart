import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/entities/recent_submission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeRecentActivity extends ConsumerWidget {
  const HomeRecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(homeDataProvider.select((s) => s.recentActivity));

    if (recent.isEmpty) return const SizedBox.shrink();

    return OnlyPadding(
      startPadding: 16,
      endPadding: 16,
      topPadding: 4,
      bottomPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldText(StringsManager.recentActivity, fontSize: 15, color: ThemeEnum.textPrimary),
          SizedBox(height: 10.h),
          ...recent.take(5).map((item) => _ActivityTile(item: item)),
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
    final diffColor = ProblemStyle.difficultyColor(item.difficulty);
    final diffLabel = item.difficulty.difficultyString;

    final timeAgo = _formatTimeAgo(item.submittedAt);

    return GestureDetector(
      onTap: () => context.pushTo(Routes.code, queryParameters: '${item.problemId}'),
      child: Container(
        margin: REdgeInsets.only(bottom: 8),
        padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: SimpleGlassButton.cardDecoration(context),
        child: Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: context.getColor(item.isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentYellow),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediumText(item.problemName, fontSize: 13, color: ThemeEnum.textPrimary, maxLines: 1),
                  RegularText(timeAgo, fontSize: 11, color: ThemeEnum.textSecond),
                ],
              ),
            ),
            if (diffLabel.isNotEmpty)
              Container(
                padding: REdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.getColor(diffColor).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: RegularText(diffLabel, fontSize: 11, color: diffColor),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return StringsManager.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}${StringsManager.mAgo}';
    if (diff.inHours < 24) return '${diff.inHours}${StringsManager.hAgo}';
    if (diff.inDays == 1) return StringsManager.yesterday;
    return '${diff.inDays}${StringsManager.dAgo}';
  }
}
