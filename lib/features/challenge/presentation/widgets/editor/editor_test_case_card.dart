import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/ltr_content.dart';
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
      fillColor: ThemeEnum.surface,
      borderColorOverride: ThemeEnum.hairline,
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
            _FailureMessage(grade: grade),
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
            color: ThemeEnum.inkThirdTitle,
            maxLines: 1,
          ),
        ),
        if (grade.error == null)
          SemiBoldText(
            StringsManager.passedOfTotal(context, grade.passedCount, grade.totalCount),
            fontSize: 10.5,
            color: ThemeEnum.dataEasy,
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
          /// Both lines are literals the learner's code produced, so they
          /// keep code direction while the marker and card around them
          /// mirror normally.
          child: LtrContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RegularText(
                  result.input ?? '',
                  fontFamily: FontConstants.fontFamily,
                  fontSize: 11,
                  color: ThemeEnum.inkSecondaryTitle,
                  maxLines: 2,
                  translate: false,
                ),
                if (!result.passed) ...[
                  const RSizedBox(height: 2),
                  RegularText(
                    '${StringsManager.gotPrefix.tr(context)}${result.actualOutput}',
                    fontFamily: FontConstants.fontFamily,
                    fontSize: 11,
                    color: ThemeEnum.dataHard,
                    maxLines: 2,
                    translate: false,
                  ),
                ],
              ],
            ),
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
    final fill = passed ? ThemeEnum.raised : ThemeEnum.raised;
    final glyphColor = passed ? ThemeEnum.dataEasy : ThemeEnum.dataHard;

    return Container(
      width: 16.r,
      height: 16.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: context.getColor(fill), shape: BoxShape.circle),
      child: SemiBoldText(passed ? '✓' : '✕', fontSize: 9, color: glyphColor, maxLines: 1),
    );
  }
}

/// The failure line, said in the app's current language.
///
/// [CodeGradeResult.failure] still carries the engine's `code` and the values
/// involved, so the sentence is built here, at render time, with a
/// `BuildContext` in hand. [CodeGradeResult.error] is the fallback for the
/// one failure that has no engine code behind it — a signature the runner
/// could not parse — and is English either way.
class _FailureMessage extends StatelessWidget {
  const _FailureMessage({required this.grade});

  final CodeGradeResult grade;

  @override
  Widget build(BuildContext context) {
    final failure = grade.failure;
    final tr = AppLocalizations.of(context).tr;

    final message = failure == null
        ? grade.error!
        : StringsManager.executionFailureHeadline(
            kind: failure.kind,
            line: failure.line,
            code: failure.code,
            data: failure.data,
            tr: tr,
          );

    /// Identifiers the learner typed are quoted inside this sentence
    /// (`Undefined variable 'nums'`), but the sentence itself is prose, so it
    /// follows the page direction and lets the bidi algorithm place them.
    return RegularText(
      message,
      fontSize: 11,
      color: ThemeEnum.dataHard,
      maxLines: 4,
      translate: false,
    );
  }
}
