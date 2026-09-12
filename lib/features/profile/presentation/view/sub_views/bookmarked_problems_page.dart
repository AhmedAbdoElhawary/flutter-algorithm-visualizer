import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/empty_state_quiet.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/bookmark_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookmarkedProblemsPage extends ConsumerWidget {
  const BookmarkedProblemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problems = ref.watch(problemsProvider);

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: SafeArea(
          child: problems.when(
            data: (all) {
              final bookmarked = all.where((p) => p.getIsBookmarked).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(count: bookmarked.length),
                  Expanded(
                    child: bookmarked.isEmpty
                        ? const Center(
                            child: MediumText(StringsManager.noProblemsFound,
                                color: ThemeEnum.textSecond),
                          )
                        : ListView.separated(
                            padding: REdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: bookmarked.length + 1,
                            separatorBuilder: (_, __) =>
                                const RSizedBox(height: 9),
                            itemBuilder: (context, i) {
                              if (i == bookmarked.length) {
                                return const EmptyStateQuiet(
                                  title: StringsManager.bookmarkEndTitle,
                                  caption: StringsManager.swipeToRemoveBookmark,
                                );
                              }
                              final problem = bookmarked[i];
                              return BookmarkRow(
                                problem: problem,
                                onTap: () => context.pushTo(
                                  Routes.problem,
                                  queryParameters: "${problem.getProblemId}",
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () =>
                Center(child: CircularProgressIndicator(strokeWidth: 2.r)),
            error: (_, __) => const Center(
              child: MediumText(StringsManager.notAbleToLoadAnyChallenge,
                  color: ThemeEnum.textSecond),
            ),
          ),
        ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final unit = count == 1 ? StringsManager.problem : StringsManager.problems;
    return Padding(
      padding: REdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: [
          const CustomBackButton(),
          BoldText(StringsManager.bookmarked.trim(),
              color: ThemeEnum.textPrimary, fontSize: 17),
          const Spacer(),
          RegularText('$count ${unit.toLowerCase()}',
              color: ThemeEnum.textSecond, fontSize: 11),
        ],
      ),
    );
  }
}
