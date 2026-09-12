import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/empty_state_quiet.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/history_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentSubmissionsPage extends ConsumerWidget {
  const RecentSubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(profileStatisticsProvider.select((value) => value.practiceHistory));

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: REdgeInsets.fromLTRB(16, 4, 16, 16),
              child: const Row(
                children: [
                  CustomBackButton(),
                  BoldText(StringsManager.practiceHistory, color: ThemeEnum.textPrimary, fontSize: 17),
                ],
              ),
            ),
            Expanded(
              child: all.isEmpty
                  ? const Center(
                      child: MediumText(StringsManager.noProblemsFound, color: ThemeEnum.textSecond),
                    )
                  : ListView.separated(
                      padding: REdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: all.length + 1,
                      separatorBuilder: (_, __) => const RSizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i == all.length) {
                          return const EmptyStateQuiet(
                            title: StringsManager.historyEndTitle,
                            caption: StringsManager.longPressExplain,
                          );
                        }
                        return HistoryRow(entry: all[i]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
