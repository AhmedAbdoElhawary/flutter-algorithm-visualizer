import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/problems_notifier.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/challenges/challenge_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BookmarkedProblemsPage extends ConsumerWidget {
  const BookmarkedProblemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problems = ref.watch(problemsProvider);

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      appBar: AppBar(
        backgroundColor: context.getColor(ThemeEnum.primary),
        leading: IconButton(
          icon: CustomIcon(Icons.arrow_back_ios_rounded, size: 20, color: ThemeEnum.textSecond),
          onPressed: () => context.pop(),
        ),
        title: BoldText(StringsManager.bookmarked.trim(), color: ThemeEnum.textSecond, fontSize: 16),
        centerTitle: false,
      ),
      body: problems.when(
        data: (all) {
          final bookmarked = all.where((p) => p.getIsBookmarked).toList();
          if (bookmarked.isEmpty) {
            return Center(
              child: RegularText(StringsManager.noProblemsFound, color: ThemeEnum.hoverSecond, fontSize: 14),
            );
          }
          return ListView.separated(
            padding: REdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: bookmarked.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: context.getColor(ThemeEnum.border)),
            itemBuilder: (context, i) {
              final problem = bookmarked[i];
              final diffColor = ProblemStyle.difficultyColor(problem.getDifficulty);
              final (statusColor, statusIcon) = ProblemStyle.getStatus(problem.problemStatus);
              return GestureDetector(
                onTap: () => context.pushTo(Routes.code, queryParameters: "${problem.getProblemId}"),
                child: Padding(
                  padding: REdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: context.getColor(statusColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: CustomIcon(statusIcon, size: 16.r, color: statusColor)),
                    ),
                    RSizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SemiBoldText(problem.getName, color: ThemeEnum.textSecond, fontSize: 14),
                      RSizedBox(height: 4),
                      Row(children: [
                        RegularText(
                          problem.getDifficulty.difficultyString,
                          color: diffColor,
                          fontSize: 12,
                        ),
                        if (problem.getTags.isNotEmpty) ...[
                          RegularText(' · ', color: ThemeEnum.hoverSecond, fontSize: 12),
                          ChallengeTags(tags: problem.getTags.take(2).toList()),
                        ],
                      ]),
                    ])),
                    CustomIcon(Icons.bookmark_rounded, size: 16, color: ThemeEnum.accent),
                  ]),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: RegularText(StringsManager.notAbleToLoadAnyChallenge, color: ThemeEnum.hoverSecond)),
      ),
    );
  }
}
