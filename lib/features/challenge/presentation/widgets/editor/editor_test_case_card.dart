import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditorTestCaseCard extends StatelessWidget {
  const EditorTestCaseCard({super.key, required this.grade});

  final CodeGradeResult grade;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      fillColor: ThemeEnum.mainCard,
      borderColorOverride: ThemeEnum.border,
      radius: CdRadius.md,
      padding: REdgeInsets.symmetric(vertical: 13, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(grade: grade),
          if (grade.error == null) ...[
            const RSizedBox(height: 11),
            for (final (index, result) in grade.firstThreeTestCaseResults.indexed) ...[
              _ResultRow(result: result),
              if (index != grade.firstThreeTestCaseResults.length - 1) const RSizedBox(height: 8),
            ],
          ] else ...[
            const RSizedBox(height: 11),
            RegularText(grade.error!, fontSize: 11, color: ThemeEnum.difficultyHard, maxLines: 4),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.grade});

  final CodeGradeResult grade;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: SemiBoldText(
            StringsManager.testCases,
            fontSize: 11,
            letterSpacing: 0.88,
            color: ThemeEnum.codeComment,
            maxLines: 1,
          ),
        ),
        if (grade.error == null)
          SemiBoldText(
            StringsManager.passedOfTotal(grade.passedCount, grade.totalCount),
            fontSize: 10.5,
            color: ThemeEnum.difficultyEasy,
            maxLines: 1,
          ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final TestCaseResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Marker(passed: result.passed),
        const RSizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RegularText(
                result.input ?? '',
                fontFamily: FontConstants.fontJetBrainsMono,
                fontSize: 11,
                color: ThemeEnum.textBody,
                maxLines: 2,
              ),
              if (!result.passed) ...[
                const RSizedBox(height: 2),
                RegularText(
                  '${StringsManager.gotPrefix}${result.actualOutput}',
                  fontFamily: FontConstants.fontJetBrainsMono,
                  fontSize: 11,
                  color: ThemeEnum.difficultyHard,
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.passed});

  final bool passed;

  @override
  Widget build(BuildContext context) {
    final fill = passed ? ThemeEnum.chipEasyFill : ThemeEnum.chipHardFill;
    final glyphColor = passed ? ThemeEnum.difficultyEasy : ThemeEnum.difficultyHard;

    return Container(
      width: 16.r,
      height: 16.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: context.getColor(fill), shape: BoxShape.circle),
      child: SemiBoldText(passed ? '✓' : '✕', fontSize: 9, color: glyphColor, maxLines: 1),
    );
  }
}
