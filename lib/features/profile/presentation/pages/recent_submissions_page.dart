import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecentSubmissionsPage extends ConsumerWidget {
  const RecentSubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);
    final all = stats.recentSubmissions;

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      appBar: AppBar(
        backgroundColor: context.getColor(ThemeEnum.primary),
        leading: IconButton(
          icon: CustomIcon(Icons.arrow_back_ios_rounded, size: 20, color: ThemeEnum.textSecond),
          onPressed: () => context.pop(),
        ),
        title: BoldText(StringsManager.recentSubmissions, color: ThemeEnum.textSecond, fontSize: 16),
        centerTitle: false,
      ),
      body: all.isEmpty
          ? Center(child: RegularText(StringsManager.noProblemsFound, color: ThemeEnum.hoverSecond, fontSize: 14))
          : ListView.separated(
              padding: REdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: all.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: context.getColor(ThemeEnum.border)),
              itemBuilder: (context, i) {
                final sub = all[i];
                return _SubmissionRow(sub: sub);
              },
            ),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  const _SubmissionRow({required this.sub});

  final RecentSubmission sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: context.getColor(sub.isCorrect ? ThemeEnum.accentGreenBg : ThemeEnum.accentRedRc),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(
            sub.isCorrect ? Icons.check_rounded : Icons.close_rounded,
            size: 16.r,
            color: context.getColor(sub.isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed),
          )),
        ),
        RSizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SemiBoldText(sub.problemName, color: ThemeEnum.textSecond, fontSize: 14),
          RSizedBox(height: 3),
          Row(children: [
            RegularText(_difficultyLabel(sub.difficulty), color: _difficultyColor(sub.difficulty), fontSize: 12),
            RegularText(' · ', color: ThemeEnum.hoverSecond, fontSize: 12),
            RegularText(_relativeTime(sub.submittedAt), color: ThemeEnum.hoverSecond, fontSize: 12),
          ]),
        ])),
        RegularText(
          sub.isCorrect ? StringsManager.passed : StringsManager.failed,
          color: sub.isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed,
          fontSize: 12,
        ),
      ]),
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
