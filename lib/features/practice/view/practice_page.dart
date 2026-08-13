import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view_model/challenges_providers.dart';
import '../widgets/challenges_filter_tabs.dart';
import '../widgets/challenges_header.dart';
import '../widgets/challenges_search_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/problem_tile.dart';

class PracticePage extends ConsumerWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredProblemsProvider);

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
            filtered.isEmpty
                ? SliverFillRemaining(child: const ChallengesEmptyState())
                : SliverPadding(
                    padding: REdgeInsets.fromLTRB(16, 0, 16, 60),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => ProblemTile(
                        problem: filtered[i],
                        onSolve: () {},
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
