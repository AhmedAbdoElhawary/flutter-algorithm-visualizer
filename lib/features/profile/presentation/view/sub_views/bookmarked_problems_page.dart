import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_button.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/challenge_tags.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_practice_history.dart';
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
            return Center(child: MediumText(StringsManager.noProblemsFound, color: ThemeEnum.hoverSecond));
          }
          return ListView.separated(
            padding: REdgeInsetsDirectional.only(start: 16, top: 8, bottom: 50),
            itemCount: bookmarked.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: context.getColor(ThemeEnum.border)),
            itemBuilder: (context, i) {
              final problem = bookmarked[i];
              return ProblemRow(
                addTopBorder: false,
                problemName: problem.getName,
                difficulty: problem.getDifficulty,
                isCorrect: problem.problemStatus == ProblemStatus.solved,
                onTapCard: () => context.pushTo(Routes.code, queryParameters: "${problem.getProblemId}"),
                onTapTitle: () => context.pushTo(Routes.code, queryParameters: "${problem.getProblemId}"),
                subTitle: ChallengeTags(tags: problem.getTags.take(2).toList()),
                trailing: Padding(
                  padding: REdgeInsets.symmetric(horizontal: 16),
                  child: BookmarkButton(isBookmarked: problem.getIsBookmarked, problem: problem),
                ),
                subUnderWidget: SizedBox.shrink(),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2.r)),
        error: (_, __) =>
            Center(child: MediumText(StringsManager.notAbleToLoadAnyChallenge, color: ThemeEnum.hover)),
      ),
    );
  }
}
