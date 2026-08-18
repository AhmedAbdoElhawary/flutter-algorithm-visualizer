import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/data/profile_stats_provider.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/status_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePracticeHistory extends ConsumerWidget {
  const ProfilePracticeHistory({super.key});

  static const _maxPreview = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(profileStatsProvider);

    if (stats.practiceHistory.isEmpty) return const SizedBox.shrink();

    final preview = stats.practiceHistory.take(_maxPreview).toList();

    return HorizontalPadding(
      padding: 16,
      child: Container(
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
          boxShadow: context.cardShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(children: [
          Padding(
            padding: REdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              BoldText(StringsManager.practiceHistory,
                  color: ThemeEnum.textSecond, fontSize: 13, fontWeight: FontWeightManager.bold800),
              const Spacer(),
              GestureDetector(
                onTap: () => context.pushTo(Routes.recentSubmissions),
                child: Row(children: [
                  SemiBoldText(StringsManager.viewAll, color: ThemeEnum.accent, fontSize: 12),
                  CustomIcon(Icons.chevron_right_rounded, size: 14, color: ThemeEnum.accent),
                ]),
              ),
            ]),
          ),
          ...preview.map((entry) => PracticeHistoryRow(entry: entry)),
        ]),
      ),
    );
  }
}

class PracticeHistoryRow extends StatefulWidget {
  const PracticeHistoryRow({super.key, this.isFullPage = false, required this.entry});

  final PracticeHistoryEntry entry;
  final bool isFullPage;
  @override
  State<PracticeHistoryRow> createState() => _PracticeHistoryRowState();
}

class _PracticeHistoryRowState extends State<PracticeHistoryRow> with SingleTickerProviderStateMixin {
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
    return ProblemRow(
      addTopBorder: !widget.isFullPage,
      problemName: entry.problemName,
      difficulty: entry.difficulty,
      isCorrect: entry.lastResult,
      onTapCard: _toggle,
      onTapTitle: () => context.pushTo(Routes.code, queryParameters: "${entry.problemId}"),
      subTitle: MediumText('${entry.attempts.length} ${StringsManager.problems.toLowerCase()}',
          color: ThemeEnum.hover, fontSize: 11),
      trailing: GestureDetector(
        child: AnimatedRotation(
          turns: _expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: CustomIcon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: ThemeEnum.hoverSecond,
          ),
        ),
      ),
      subUnderWidget: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: _expanded
            ? ScaleTransition(
                scale: _scaleAnim,
                child: FadeTransition(
                  opacity: _opacityAnim,
                  child: Container(
                    width: double.infinity,
                    margin: REdgeInsetsDirectional.only(
                        bottom: 10, start: widget.isFullPage ? 37 : 50, end: widget.isFullPage ? 5 : 20),
                    padding: REdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: context.getColor(ThemeEnum.mainCard),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.getColor(ThemeEnum.border)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SemiBoldText(
                                StringsManager.date,
                                color: ThemeEnum.hover,
                                fontSize: 11,
                              ),
                            ),
                            SemiBoldText(
                              StringsManager.result,
                              color: ThemeEnum.hover,
                              fontSize: 11,
                            ),
                          ],
                        ),
                        RSizedBox(height: 6),
                        for (final attempt in entry.attempts) ...[
                          Row(children: [
                            Expanded(
                              child: SemiBoldText(
                                _formatDate(attempt.submittedAt),
                                color: ThemeEnum.textSecond,
                                fontSize: 12,
                              ),
                            ),
                            SemiBoldText(
                              attempt.isCorrect ? StringsManager.passed : StringsManager.failed,
                              color: attempt.isCorrect ? ThemeEnum.accentGreen : ThemeEnum.accentRed,
                              fontSize: 12,
                            ),
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
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class ProblemRow extends StatefulWidget {
  const ProblemRow({
    super.key,
    this.addTopBorder = false,
    required this.onTapTitle,
    required this.onTapCard,
    required this.trailing,
    required this.subTitle,
    required this.subUnderWidget,
    required this.problemName,
    required this.difficulty,
    required this.isCorrect,
  });

  final bool addTopBorder;
  final VoidCallback onTapTitle;
  final VoidCallback onTapCard;
  final Widget trailing;
  final Widget subTitle;
  final Widget subUnderWidget;
  final String problemName;
  final ProblemDifficulty difficulty;
  final bool isCorrect;
  @override
  State<ProblemRow> createState() => _ProblemRowState();
}

class _ProblemRowState extends State<ProblemRow> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTapCard,
      child: Container(
        decoration: widget.addTopBorder
            ?BoxDecoration(
          border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border))),
        )
            :null ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: REdgeInsets.symmetric(horizontal: widget.addTopBorder ? 14 : 0, vertical: 10),
              child: Row(
                children: [
                  InkWell(onTap: widget.onTapTitle, child: StatusBox(isCorrect: widget.isCorrect)),
                  RSizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            onTap: widget.onTapTitle,
                            child: BoldText(widget.problemName, color: ThemeEnum.textSecond, fontSize: 13)),
                        RSizedBox(height: 2),
                        InkWell(
                          onTap: widget.onTapTitle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SemiBoldText(_difficultyLabel(widget.difficulty),
                                  color: _difficultyColor(widget.difficulty), fontSize: 11),
                              RegularText('   ·   ', color: ThemeEnum.hover, fontSize: 11),
                              widget.subTitle,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.trailing,
                ],
              ),
            ),
            widget.subUnderWidget,
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(ProblemDifficulty diff) {
    switch (diff) {
      case ProblemDifficulty.easy:
        return StringsManager.easy;
      case ProblemDifficulty.medium:
        return StringsManager.medium;
      case ProblemDifficulty.hard:
        return StringsManager.hard;
      case ProblemDifficulty.none:
        return StringsManager.all;
    }
  }

  ThemeEnum _difficultyColor(ProblemDifficulty diff) {
    switch (diff) {
      case ProblemDifficulty.easy:
        return ThemeEnum.accentGreen;
      case ProblemDifficulty.medium:
        return ThemeEnum.accentYellow;
      case ProblemDifficulty.hard:
        return ThemeEnum.accentRed;
      case ProblemDifficulty.none:
        return ThemeEnum.hoverSecond;
    }
  }
}
