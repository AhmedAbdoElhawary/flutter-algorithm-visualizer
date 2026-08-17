import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecentSubmissionsPage extends ConsumerWidget {
  const RecentSubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);
    final all = stats.practiceHistory;

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
          ? Center(child: RegularText(StringsManager.noProblemsFound, color: ThemeEnum.hoverSecond, fontSize: 14))
          : ListView.separated(
              padding: REdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: all.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: context.getColor(ThemeEnum.border)),
              itemBuilder: (context, i) {
                return _PracticeHistoryTile(entry: all[i]);
              },
            ),
    );
  }
}

class _PracticeHistoryTile extends StatefulWidget {
  const _PracticeHistoryTile({required this.entry});

  final PracticeHistoryEntry entry;

  @override
  State<_PracticeHistoryTile> createState() => _PracticeHistoryTileState();
}

class _PracticeHistoryTileState extends State<_PracticeHistoryTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scaleAnim = Tween(begin: 0.85, end: 1.0).animate(curve);
    _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final isCorrect = entry.lastResult;

    return Padding(
      padding: REdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: context.getColor(isCorrect ? ThemeEnum.accentGreenBg : ThemeEnum.accentRedRc),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(
                isCorrect ? Icons.check_rounded : Icons.close_rounded,
                size: 16.r,
                color: context.getColor(isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed),
              )),
            ),
            RSizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SemiBoldText(entry.problemName, color: ThemeEnum.textSecond, fontSize: 14),
              RSizedBox(height: 3),
              Row(children: [
                RegularText(_difficultyLabel(entry.difficulty), color: _difficultyColor(entry.difficulty), fontSize: 12),
                RegularText(' · ', color: ThemeEnum.hoverSecond, fontSize: 12),
                RegularText('${entry.attempts.length} attempts', color: ThemeEnum.hoverSecond, fontSize: 12),
              ]),
            ])),
            GestureDetector(
              onTap: _toggle,
              child: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: CustomIcon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: ThemeEnum.hoverSecond,
                ),
              ),
            ),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _opacityAnim,
                      child: Container(
                        width: double.infinity,
                        margin: REdgeInsets.only(top: 10),
                        padding: REdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.getColor(ThemeEnum.mainCard),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.getColor(ThemeEnum.border)),
                        ),
                        child: Column(
                          children: [
                            Row(children: [
                              Expanded(child: RegularText('Date', color: ThemeEnum.hover, fontSize: 11)),
                              Expanded(child: RegularText('Result', color: ThemeEnum.hover, fontSize: 11)),
                            ]),
                            RSizedBox(height: 6),
                            for (final attempt in entry.attempts) ...[
                              Row(children: [
                                Expanded(child: RegularText(
                                  _formatDate(attempt.submittedAt),
                                  color: ThemeEnum.textSecond,
                                  fontSize: 12,
                                )),
                                Expanded(child: RegularText(
                                  attempt.isCorrect ? StringsManager.passed : StringsManager.failed,
                                  color: attempt.isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed,
                                  fontSize: 12,
                                )),
                              ]),
                              if (attempt != entry.attempts.last) RSizedBox(height: 4),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _difficultyLabel(ProblemDifficulty diff) {
    switch (diff) {
      case ProblemDifficulty.easy: return StringsManager.easy;
      case ProblemDifficulty.medium: return StringsManager.medium;
      case ProblemDifficulty.hard: return StringsManager.hard;
      case ProblemDifficulty.none: return StringsManager.all;
    }
  }

  ThemeEnum _difficultyColor(ProblemDifficulty diff) {
    switch (diff) {
      case ProblemDifficulty.easy: return ThemeEnum.accentGreen;
      case ProblemDifficulty.medium: return ThemeEnum.accentYellow;
      case ProblemDifficulty.hard: return ThemeEnum.accentRed;
      case ProblemDifficulty.none: return ThemeEnum.hoverSecond;
    }
  }
}
