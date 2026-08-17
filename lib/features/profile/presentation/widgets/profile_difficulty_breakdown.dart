import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileDifficultyBreakdown extends ConsumerWidget {
  const ProfileDifficultyBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);

    final bars = [
      (label: StringsManager.easy, solved: stats.easySolved, total: stats.easyTotal, color: ThemeEnum.accentGreen),
      (label: StringsManager.medium, solved: stats.mediumSolved, total: stats.mediumTotal, color: ThemeEnum.accentYellow),
      (label: StringsManager.hard, solved: stats.hardSolved, total: stats.hardTotal, color: ThemeEnum.accentRed),
    ];

    return HorizontalPadding(
      padding: 16,
      child: Container(
        padding: REdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BoldText(StringsManager.difficultyBreakdown, color: ThemeEnum.textSecond, fontSize: 13),
          RSizedBox(height: 12),
          ...bars.map((b) => Padding(
            padding: REdgeInsets.only(bottom: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SemiBoldText(b.label, color: b.color, fontSize: 12),
                RichText(text: TextSpan(
                  style: TextStyle(color: context.getColor(ThemeEnum.hoverSecond), fontSize: 12.sp),
                  children: [
                    TextSpan(text: '${b.solved}', style: TextStyle(color: context.getColor(ThemeEnum.textSecond), fontWeight: FontWeight.w600)),
                    TextSpan(text: ' / ${b.total}'),
                  ],
                )),
              ]),
              RSizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: b.total == 0 ? 0 : b.solved / b.total),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 6.h,
                    backgroundColor: context.getColor(ThemeEnum.hover),
                    valueColor: AlwaysStoppedAnimation(context.getColor(b.color).withValues(alpha: 0.85)),
                  ),
                ),
              ),
            ]),
          )),
        ]),
      ),
    );
  }
}
