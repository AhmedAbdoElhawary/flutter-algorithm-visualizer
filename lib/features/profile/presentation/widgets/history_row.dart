import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bar_chart_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_problem_card.dart';
import 'package:algorithm_visualizer/features/profile/presentation/entities/practice_history_entry.dart';
import 'package:algorithm_visualizer/features/profile/presentation/entities/recent_submission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryRow extends StatefulWidget {
  const HistoryRow({
    super.key,
    required this.entry,
    this.addCardDecoration = true,
    this.addAttemptsCharts = true,
  });

  final PracticeHistoryEntry entry;
  final bool addCardDecoration;
  final bool addAttemptsCharts;
  @override
  State<HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<HistoryRow> {
  final ValueNotifier<bool> _expanded = ValueNotifier(false);

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final count = entry.attempts.length;
    final unit = count == 1 ? StringsManager.submission : StringsManager.submissions;

    return SecondaryProblemCard(
      onTap: () => _expanded.value = !_expanded.value,
      onLongTap: () => context.pushTo(Routes.problem, queryParameters: widget.entry.problemId.toString()),
      isSolved: entry.isSolved,
      problemName: entry.problemName,
      problemId: entry.problemId,
      difficulty: entry.difficulty,
      addCardDecoration: widget.addCardDecoration,
      subTitle: RegularText(
        '$count ${unit.toLowerCase()} · ${StringsManager.lastLabel} ${_relative(entry.lastSubmittedAt)}',
        color: ThemeEnum.textSecond,
        fontSize: 10.5,
      ),
      leading: _AnimatedArrow(expanded: _expanded),
      bottomWidgets: [
        if (widget.addAttemptsCharts) ...[
          const RSizedBox(height: 12),
          Padding(
            padding: REdgeInsetsDirectional.only(start: 39),
            child: _AttemptStrip(attempts: entry.attempts),
          ),
        ],
        AnimatedSize(
          duration: CdMotion.expand,
          curve: Curves.easeInOut,
          child: ValueListenableBuilder(
            valueListenable: _expanded,
            builder: (context, value, child) =>
                value ? _AttemptTable(entry: entry) : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }

  String _relative(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return StringsManager.justNow;
    if (d.inMinutes < 60) return '${d.inMinutes}${StringsManager.mAgo}';
    if (d.inHours < 24) return '${d.inHours}${StringsManager.hAgo}';
    if (d.inDays == 1) return '1 ${StringsManager.dayAgo}';
    return '${d.inDays} ${StringsManager.daysAgo}';
  }
}

class _AnimatedArrow extends StatelessWidget {
  const _AnimatedArrow({required this.expanded});
  final ValueNotifier<bool> expanded;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: expanded,
      builder: (context, value, child) => AnimatedRotation(
        turns: value ? 0.5 : 0,
        duration: CdMotion.fade,
        child: const CustomIcon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: ThemeEnum.textSecond,
        ),
      ),
    );
  }
}

class _AttemptStrip extends StatelessWidget {
  const _AttemptStrip({required this.attempts});

  final List<RecentSubmission> attempts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(attempts.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: i == attempts.length - 1 ? 0 : 4.w),
            child: QuietBar(
                width: double.infinity,
                height: 4.r,
                fill: attempts[i].isCorrect ? ThemeEnum.difficultyEasy : ThemeEnum.difficultyHard),
          ),
        );
      }),
    );
  }
}

class _AttemptTable extends StatelessWidget {
  const _AttemptTable({required this.entry});

  final PracticeHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: REdgeInsetsDirectional.only(top: 12, start: 39),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(child: SemiBoldText(StringsManager.date, color: ThemeEnum.textSecond, fontSize: 11)),
              SemiBoldText(StringsManager.result, color: ThemeEnum.textSecond, fontSize: 11),
            ],
          ),
          const RSizedBox(height: 6),
          for (final attempt in entry.attempts) ...[
            Row(
              children: [
                Expanded(
                  child:
                      SemiBoldText(_formatDate(attempt.submittedAt), color: ThemeEnum.textBody, fontSize: 12),
                ),
                SemiBoldText(
                  attempt.isCorrect ? StringsManager.passed : StringsManager.failed,
                  color: attempt.isCorrect ? ThemeEnum.difficultyEasy : ThemeEnum.difficultyHard,
                  fontSize: 12,
                ),
              ],
            ),
            if (attempt != entry.attempts.last) const RSizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hh:$mm';
  }
}
