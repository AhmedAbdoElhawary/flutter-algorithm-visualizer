import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileRecentSubmissions extends ConsumerWidget {
  const ProfileRecentSubmissions({super.key});

  static const _maxPreview = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);

    if (stats.recentSubmissions.isEmpty) return const SizedBox.shrink();

    final preview = stats.recentSubmissions.take(_maxPreview).toList();

    return HorizontalPadding(
      padding: 16,
      child: Container(
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(children: [
          Padding(
            padding: REdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              BoldText(StringsManager.recentSubmissions, color: ThemeEnum.textSecond, fontSize: 13),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/profile/recent-submissions'),
                child: Row(children: [
                  RegularText(StringsManager.viewAll, color: ThemeEnum.accent, fontSize: 12),
                  CustomIcon(Icons.chevron_right_rounded, size: 14, color: ThemeEnum.accent),
                ]),
              ),
            ]),
          ),
          ...preview.map((sub) => Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border))),
            ),
            padding: REdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: context.getColor(ThemeEnum.accentBg),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Icon(
                  sub.isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  size: 14.r,
                  color: context.getColor(sub.isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed),
                )),
              ),
              RSizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SemiBoldText(sub.problemName, color: ThemeEnum.textSecond, fontSize: 13),
                RSizedBox(height: 2),
                Row(children: [
                  RegularText(_difficultyLabel(sub.difficulty), color: _difficultyColor(sub.difficulty), fontSize: 11),
                  RegularText(' · ', color: ThemeEnum.hoverSecond, fontSize: 11),
                  RegularText(_relativeTime(sub.submittedAt), color: ThemeEnum.hoverSecond, fontSize: 11),
                ]),
              ])),
              RegularText(
                sub.isCorrect ? StringsManager.passed : StringsManager.failed,
                color: sub.isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed,
                fontSize: 11,
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  String _difficultyLabel(ProblemDifficulty diff) {
    switch (diff) {
      case ProblemDifficulty.easy: return StringsManager.easy;
      case ProblemDifficulty.medium: return StringsManager.medium;
      case ProblemDifficulty.hard: return StringsManager.hard;
      case ProblemDifficulty.none: return StringsManager.all;
    }
  }

  ThemeEnum _difficultyColor(ProblemDifficulty diff) {
    switch (diff) {
      case ProblemDifficulty.easy: return ThemeEnum.accentGreen;
      case ProblemDifficulty.medium: return ThemeEnum.accentYellow;
      case ProblemDifficulty.hard: return ThemeEnum.accentRed;
      case ProblemDifficulty.none: return ThemeEnum.hoverSecond;
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
