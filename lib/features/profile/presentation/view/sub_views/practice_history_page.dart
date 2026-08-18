import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_practice_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecentSubmissionsPage extends ConsumerWidget {
  const RecentSubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(profileStatisticsProvider.select((value) => value.practiceHistory));

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      appBar: AppBar(
        backgroundColor: context.getColor(ThemeEnum.primary),
        leading: IconButton(
          icon: CustomIcon(Icons.arrow_back_ios_rounded, size: 20, color: ThemeEnum.textSecond),
          onPressed: () => context.pop(),
        ),
        title: BoldText(StringsManager.practiceHistory, color: ThemeEnum.textSecond, fontSize: 16),
        centerTitle: false,
      ),
      body: all.isEmpty
          ? Center(child: MediumText(StringsManager.noProblemsFound, color: ThemeEnum.hoverSecond))
          : ListView.separated(
              padding: REdgeInsetsDirectional.only(start: 16, top: 8, bottom: 50),
              itemCount: all.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: context.getColor(ThemeEnum.border)),
              itemBuilder: (context, i) => Padding(
                padding: REdgeInsetsDirectional.only(end: 16),
                child: PracticeHistoryRow(entry: all[i], isFullPage: true),
              ),
            ),
    );
  }
}
