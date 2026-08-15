import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/error_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view_model/challenges_providers.dart';
import '../widgets/challenges_filter_tabs.dart';
import '../widgets/challenges_header.dart';
import '../widgets/challenges_search_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/problem_tile.dart';

class ChallengePage extends ConsumerWidget {
  const ChallengePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problems = ref.watch(filteredProblemsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              snap: true,
              floating: true,
              stretch: true,
              centerTitle: false,
              titleSpacing: 0,
              leadingWidth: 16.r,
              leading: SizedBox(),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(145.r),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ChallengesHeader(),
                      const ChallengesSearchField(),
                      const ChallengesFilterTabs(),
                    ],
                  ),
                ),
              ),
            ),
            problems.when(
              loading: () => const SliverChallengesLoadingState(),
              error: (error, stackTrace) => SliverFillRemaining(child: ChallengesErrorState()),
              data: (data) {
                if (data.isEmpty) return SliverFillRemaining(child: const ChallengesEmptyState());
                return SliverPadding(
                  padding: REdgeInsets.fromLTRB(16, 0, 16, 60),
                  sliver: SliverList.builder(
                    itemCount: data.length,
                    itemBuilder: (ctx, i) => ProblemTile(
                      problem: data[i],
                      onSolveTap: () {
                        context.pushTo(Routes.code, queryParameters: "${data[i].problemId}");
                      },
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
