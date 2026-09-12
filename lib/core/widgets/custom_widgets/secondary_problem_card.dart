import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/problem_row.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/status_box.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecondaryProblemCard extends StatefulWidget {
  const SecondaryProblemCard({
    super.key,
    required this.subTitle,
    required this.leading,
    required this.onTap,
     this.onLongTap,
    required this.isSolved,
    required this.problemName,
    required this.problemId,
    required this.difficulty,
    this.bottomWidgets = const [],
    this.addCardDecoration = true,
  });

  final bool addCardDecoration;
  final Widget subTitle;
  final Widget leading;
  final List<Widget> bottomWidgets;
  final VoidCallback onTap;
  final VoidCallback? onLongTap;
  final bool isSolved;
  final String problemName;
  final int problemId;
  final ProblemDifficulty difficulty;
  @override
  State<SecondaryProblemCard> createState() => _SecondaryProblemCardState();
}

class _SecondaryProblemCardState extends State<SecondaryProblemCard> {
  final ValueNotifier<bool> _expanded = ValueNotifier(false);

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StatusBox(isCorrect: widget.isSolved),
            const RSizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => context.pushTo(Routes.problem, queryParameters: widget.problemId.toString()),
                    child: SemiBoldText(
                      widget.problemName,
                      color: ThemeEnum.textBright,
                      fontSize: 12.5,
                      maxLines: 2,
                    ),
                  ),
                  const RSizedBox(height: 3),
                  widget.subTitle,
                ],
              ),
            ),
            DifficultyChip(
              difficulty: widget.difficulty,
              label: widget.difficulty.difficultyString,
              fontSize: 9.5,
              radius: 6,
            ),
            const RSizedBox(width: 8),
            widget.leading,
          ],
        ),
        ...widget.bottomWidgets,
      ],
    );

    if (widget.addCardDecoration) {
      return ProblemRow(
        padding: REdgeInsets.symmetric(horizontal: 15, vertical: 14),
        onTap: widget.onTap,
        onLongTap: widget.onLongTap,
        child: child,
      );
    }
    return InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongTap,
        child: Padding(padding: REdgeInsets.symmetric(horizontal: 15, vertical: 14), child: child));
  }
}
