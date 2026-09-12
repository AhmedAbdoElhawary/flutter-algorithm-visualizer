import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/section_header.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/history_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePracticeHistory extends ConsumerWidget {
  const ProfilePracticeHistory({super.key});

  static const _maxPreview = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceHistory = ref.watch(profileStatisticsProvider.select((value) => value.practiceHistory));

    if (practiceHistory.isEmpty) return const SizedBox.shrink();

    final preview = practiceHistory.take(_maxPreview).toList();

    return HorizontalPadding(
      padding: 16,
      child: CardContainer(
        surface: CdSurface.main,
        padding: EdgeInsets.zero,
        clip: true,
        child: Column(
          children: [
            const _HeaderOfCard(),
            Container(height: 1, color: context.getColor(ThemeEnum.border)),
            ...preview.map((entry) => HistoryRow(entry: entry,addAttemptsCharts: false,addCardDecoration: false)),
          ],
        ),
      ),
    );
  }
}

class _HeaderOfCard extends StatelessWidget {
  const _HeaderOfCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          const Expanded(child: SectionHeader(title: StringsManager.practiceHistory)),
          GestureDetector(
            onTap: () => context.pushTo(Routes.recentSubmissions),
            child: const Row(
              children: [
                SemiBoldText(StringsManager.viewAll, color: ThemeEnum.accent, fontSize: 12),
                CustomIcon(Icons.chevron_right_rounded, size: 14, color: ThemeEnum.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}