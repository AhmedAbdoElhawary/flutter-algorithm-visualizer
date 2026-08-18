import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/domain/usecases/grade_code_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/test_case.dart' show TestCaseResult;

class CodeGradeResultCard extends StatelessWidget {
  const CodeGradeResultCard({super.key, required this.grade});

  final CodeGradeResult grade;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: REdgeInsets.fromLTRB(16, 10, 16, 0),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: context.getColor(ThemeEnum.card),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.getColor(ThemeEnum.border)),
            boxShadow: context.cardShadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(grade: grade),
              if (grade.error != null)
                _ErrorBox(error: grade.error!)
              else
                ...grade.firstThreeTestCaseResults
                    .asMap()
                    .entries
                    .map((e) => _TestCaseRow(index: e.key, result: e.value)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.grade});

  final CodeGradeResult grade;

  @override
  Widget build(BuildContext context) {
    final allPassed = grade.allPassed;
    final color = allPassed ? ThemeEnum.accentGreen : ThemeEnum.accentRedRc;

    return Container(
      padding: REdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: context.getColor(ThemeEnum.outputHeader),
      child: Row(children: [
        CustomIcon(Icons.terminal_rounded, size: 14, color: color),
        RSizedBox(width: 6),
        BoldText(StringsManager.output, color: color, fontSize: 12),
        const Spacer(),
        Container(
          padding: REdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: allPassed
                ? context.getColor(ThemeEnum.accentGreenBg)
                : context.getColor(ThemeEnum.accentRedRc).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: MediumText(
            allPassed ? StringsManager.allTestsPassed : '${grade.failedCount} ${StringsManager.failed}',
            color: allPassed ? ThemeEnum.accentGreen : ThemeEnum.accentRedRc,
            fontSize: 12,
          ),
        ),
      ]),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.fromLTRB(14, 9, 14, 9),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border)))),
      child: RegularText(
        error,
        maxLines: 20,
        color: ThemeEnum.accentRedRc,
        fontFamily: FontConstants.fontJetBrainsMono,
        fontSize: 12,
        height: 1.6,
      ),
    );
  }
}

class _TestCaseRow extends StatelessWidget {
  const _TestCaseRow({required this.index, required this.result});

  final int index;
  final TestCaseResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.passed ? ThemeEnum.accentGreen : ThemeEnum.accentRedRc;

    return Container(
      padding: REdgeInsets.fromLTRB(14, 9, 14, 9),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.r,
            height: 18.r,
            decoration: BoxDecoration(
              color: context.getColor(color).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: context.getColor(color).withValues(alpha: 0.6), width: 1.4),
            ),
            child: CustomIcon(
              result.passed ? Icons.check_rounded : Icons.close_rounded,
              size: 10.r,
              color: color,
            ),
          ),
          RSizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SemiBoldText(
                  '${StringsManager.caseS} ${index + 1}${result.errorMessage != null ? ' - ${result.errorMessage}' : ''}',
                  color: ThemeEnum.textSecond,
                  fontSize: 12,
                ),
                RSizedBox(height: 2),
                RegularText(
                  result.input ?? "",
                  maxLines: 2,
                  color: ThemeEnum.textSecond,
                  fontFamily: FontConstants.fontJetBrainsMono,
                  fontSize: 11,
                ),
                if (result.passed) ...[
                  RegularText(
                    '${StringsManager.reset.toLowerCase()}: ${result.actualOutput}',
                    maxLines: 2,
                    color: ThemeEnum.accentGreen,
                    fontFamily: FontConstants.fontJetBrainsMono,
                    fontSize: 11,
                  ),
                ] else ...[
                  RegularText(
                    '${StringsManager.expected}: ${result.expectedOutput ?? ""}',
                    maxLines: 2,
                    color: ThemeEnum.hover,
                    fontFamily: FontConstants.fontJetBrainsMono,
                    fontSize: 11,
                  ),
                ],
                if (!result.passed && result.errorMessage == null) ...[
                  RegularText(
                    '${StringsManager.actual}:   ${result.actualOutput}',
                    maxLines: 2,
                    color: ThemeEnum.accentRedRc,
                    fontFamily: FontConstants.fontJetBrainsMono,
                    fontSize: 11,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
