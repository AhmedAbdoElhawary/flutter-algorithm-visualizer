import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/practice/view_model/challenges_providers.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengesHeader extends ConsumerWidget {
  const ChallengesHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solved = ref.watch(solvedCountProvider);
    final total = ref.watch(problemsProvider).length;

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRACTICE',
            style: GoogleFonts.inter(
              color: context.textMuted,
              fontSize: 12.r,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const RSizedBox(height: 2),
          Row(
            children: [
              Text(
                'Challenges',
                style: GoogleFonts.inter(
                  color: context.textPrimary,
                  fontSize: 20.r,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              CustomIcon(Icons.local_fire_department_rounded, size: 14, color: ThemeEnum.accentRed),
              const RSizedBox(width: 3),
              Text(
                '$solved',
                style: GoogleFonts.inter(
                    color: context.getColor(ThemeEnum.accentBg), fontSize: 13.r, fontWeight: FontWeight.w600),
              ),
              Text(' / $total solved', style: GoogleFonts.inter(color: context.textMuted, fontSize: 13.r)),
            ],
          ),
          const RSizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: total == 0 ? 0 : solved / total),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 4.r,
                backgroundColor: context.getColor(ThemeEnum.outputHeader),
                valueColor: AlwaysStoppedAnimation(context.getColor(ThemeEnum.accentGreen)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
