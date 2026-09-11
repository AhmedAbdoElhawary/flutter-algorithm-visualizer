import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/aurora_buttons.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/statistics/profile_statistics_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/history_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentSubmissionsPage extends ConsumerWidget {
  const RecentSubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(
        profileStatisticsProvider.select((value) => value.practiceHistory));

    return Scaffold(
      backgroundColor: context.getColor(ThemeEnum.primary),
      body: AuroraGround(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: REdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  children: [
                   CustomBackButton(),
                    const RSizedBox(width: 12),
                    const BoldText(StringsManager.practiceHistory,
                        color: ThemeEnum.textPrimary, fontSize: 17),
                  ],
                ),
              ),
              Expanded(
                child: all.isEmpty
                    ? const Center(
                        child: MediumText(StringsManager.noProblemsFound,
                            color: ThemeEnum.textSecond),
                      )
                    : ListView.separated(
                        padding: REdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: all.length + 1,
                        separatorBuilder: (_, __) =>
                            const RSizedBox(height: 10),
                        itemBuilder: (context, i) {
                          if (i == all.length) return const _DashedEndState();
                          return HistoryRow(entry: all[i]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The only dashed border in the app — the end-of-history marker.
class _DashedEndState extends StatelessWidget {
  const _DashedEndState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(top: 6),
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: context.getColor(ThemeEnum.border),
          radius: CdRadius.lg.r,
        ),
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: const Column(
            children: [
              SemiBoldText(StringsManager.historyEndTitle,
                  color: ThemeEnum.textBody,
                  fontSize: 12.5,
                  textAlign: TextAlign.center),
              RSizedBox(height: 5),
              RegularText(StringsManager.historyEndSubtitle,
                  color: ThemeEnum.textSecond,
                  fontSize: 11,
                  textAlign: TextAlign.center,
                  maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}
