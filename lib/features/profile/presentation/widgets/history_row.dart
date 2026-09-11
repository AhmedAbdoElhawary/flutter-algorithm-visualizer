import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bar_chart_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/problem_row.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/presentation/entities/practice_history_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Aurora screen 09. A card-depth glass row: difficulty-initial badge, title +
/// "N submissions · last …", an expander, and an always-visible attempt strip
/// (one pill per submission, in the row's difficulty colour at 50%). Expanding
/// reveals the per-attempt date / result list.
class HistoryRow extends StatefulWidget {
  const HistoryRow({super.key, required this.entry});

  final PracticeHistoryEntry entry;

  @override
  State<HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<HistoryRow> {
  bool _expanded = false;

  ThemeEnum get _difficultyRole => switch (widget.entry.difficulty) {
        ProblemDifficulty.easy => ThemeEnum.difficultyEasy,
        ProblemDifficulty.medium => ThemeEnum.difficultyMedium,
        ProblemDifficulty.hard => ThemeEnum.difficultyHard,
        ProblemDifficulty.none => ThemeEnum.textSecond,
      };

  Difficulty? get _quietDifficulty => switch (widget.entry.difficulty) {
        ProblemDifficulty.easy => Difficulty.easy,
        ProblemDifficulty.medium => Difficulty.medium,
        ProblemDifficulty.hard => Difficulty.hard,
        ProblemDifficulty.none => null,
      };

  String get _initial => switch (widget.entry.difficulty) {
        ProblemDifficulty.easy => 'E',
        ProblemDifficulty.medium => 'M',
        ProblemDifficulty.hard => 'H',
        ProblemDifficulty.none => '·',
      };

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final count = entry.attempts.length;
    final unit =
        count == 1 ? StringsManager.submission : StringsManager.submissions;

    return ProblemRow(
      padding: REdgeInsets.symmetric(horizontal: 15, vertical: 14),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DifficultySquareBadge(difficulty: _quietDifficulty, label: _initial),
              const RSizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => context.pushTo(Routes.problem,
                          queryParameters: "${entry.problemId}"),
                      child: SemiBoldText(
                        entry.problemName,
                        color: ThemeEnum.textBright,
                        fontSize: 12.5,
                        maxLines: 2,
                      ),
                    ),
                    const RSizedBox(height: 3),
                    RegularText(
                      '$count ${unit.toLowerCase()} · ${StringsManager.lastLabel} ${_relative(entry.lastSubmittedAt)}',
                      color: ThemeEnum.textSecond,
                      fontSize: 10.5,
                    ),
                  ],
                ),
              ),
              const RSizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: CdMotion.fade,
                child: const CustomIcon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: ThemeEnum.textSecond,
                ),
              ),
            ],
          ),
          const RSizedBox(height: 12),
          Padding(
            padding: REdgeInsetsDirectional.only(start: 39),
            child: _AttemptStrip(count: count, fill: _difficultyRole),
          ),
          AnimatedSize(
            duration: CdMotion.expand,
            curve: Curves.easeInOut,
            child: _expanded
                ? _AttemptTable(entry: entry)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
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

class _AttemptStrip extends StatelessWidget {
  const _AttemptStrip({required this.count, required this.fill});

  final int count;
  final ThemeEnum fill;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: i == count - 1 ? 0 : 4.w),
            child: QuietBar(width: double.infinity, height: 4.r, fill: fill),
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
              Expanded(
                  child: SemiBoldText(StringsManager.date,
                      color: ThemeEnum.textSecond, fontSize: 11)),
              SemiBoldText(StringsManager.result,
                  color: ThemeEnum.textSecond, fontSize: 11),
            ],
          ),
          const RSizedBox(height: 6),
          for (final attempt in entry.attempts) ...[
            Row(
              children: [
                Expanded(
                  child: SemiBoldText(_formatDate(attempt.submittedAt),
                      color: ThemeEnum.textBody, fontSize: 12),
                ),
                SemiBoldText(
                  attempt.isCorrect
                      ? StringsManager.passed
                      : StringsManager.failed,
                  color: attempt.isCorrect
                      ? ThemeEnum.difficultyEasy
                      : ThemeEnum.difficultyHard,
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hh:$mm';
  }
}
