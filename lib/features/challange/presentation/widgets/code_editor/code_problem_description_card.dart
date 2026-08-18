import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/features/challange/data/models/example.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/challenges/challenge_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeProblemDescriptionCard extends StatefulWidget {
  const CodeProblemDescriptionCard({super.key, required this.problem});

  final CodingProblem problem;

  @override
  State<CodeProblemDescriptionCard> createState() => _CodeProblemDescriptionCardState();
}

class _CodeProblemDescriptionCardState extends State<CodeProblemDescriptionCard> {
  final Set<String> _expanded = {};

  bool _isExpanded(String key) => _expanded.contains(key);

  void _toggle(String key) {
    setState(() {
      if (_expanded.contains(key)) {
        _expanded.remove(key);
      } else {
        _expanded.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final problem = widget.problem;
    final examples = problem.getExamples;
    final constraints = problem.getConstraints;
    final tags = problem.getTags;
    final hints = problem.getHints;

    return SliverPadding(
      padding: REdgeInsets.fromLTRB(16, 0, 16, 10),
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
              _Header(
                  title: problem.getName,
                  difficulty: problem.getDifficulty,
                  color: ProblemStyle.difficultyCodeDescriptionColor(problem.getDifficulty)),
              if (problem.getDescription.trim().isNotEmpty)
                _Section(
                  title: StringsManager.description,
                  child: _BodyText(problem.getDescription.trim()),
                ),
              for (var i = 0; i < examples.length; i++) _ExampleSection(index: i, example: examples[i]),
              if (constraints.isNotEmpty)
                _Section(
                  title: StringsManager.constraints,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final constraint in constraints)
                        Padding(
                          padding: REdgeInsets.only(bottom: 4),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _BodyText('•  '),
                            Expanded(child: _BodyText(constraint)),
                          ]),
                        ),
                    ],
                  ),
                ),
              if (tags.isNotEmpty)
                _CollapsibleSection(
                  title: StringsManager.tags,
                  expanded: _isExpanded('tags'),
                  onToggle: () => _toggle('tags'),
                  child: ChallengeTags(tags: tags),
                ),
              for (var i = 0; i < hints.length; i++)
                _CollapsibleSection(
                  title: 'HINT ${i + 1}',
                  expanded: _isExpanded('hint_$i'),
                  onToggle: () => _toggle('hint_$i'),
                  child: _BodyText(hints[i]),
                ),
              if (problem.getSimilarQuestions.isNotEmpty)
                _CollapsibleSection(
                  title: StringsManager.similarQuestions,
                  expanded: _isExpanded('similar'),
                  onToggle: () => _toggle('similar'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final sq in problem.getSimilarQuestions)
                        Padding(
                          padding: REdgeInsets.only(bottom: 4),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            CustomIcon(Icons.arrow_outward_rounded, size: 14, color: ThemeEnum.hover),
                            RSizedBox(width: 6),
                            Expanded(child: _BodyText(sq.name ?? '')),
                            if ((sq.reason ?? '').isNotEmpty)
                              Expanded(flex: 2, child: _BodyText(' — ${sq.reason}')),
                          ]),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: REdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border)))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: SemiBoldText(title.toUpperCase(),
                  fontSize: 11, color: ThemeEnum.hover, maxLines: 2, letterSpacing: 0.5),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: CustomIcon(Icons.expand_more_rounded, size: 16, color: ThemeEnum.hoverSecond),
            ),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child:
                expanded ? Padding(padding: REdgeInsets.only(top: 6), child: child) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.difficulty, required this.color});

  final String title;
  final ProblemDifficulty difficulty;
  final ThemeEnum color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.fromLTRB(14, 12, 14, 10),
      color: context.getColor(ThemeEnum.outputHeader),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: SemiBoldText(title, fontSize: 15, color: ThemeEnum.textPrimary, maxLines: 3)),
        RSizedBox(width: 8),
        Container(
          padding: REdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: context.getColor(color).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: context.getColor(color).withValues(alpha: 0.5)),
          ),
          child: SemiBoldText(difficulty.difficultyString, fontSize: 11, color: color, maxLines: 2),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.getColor(ThemeEnum.border)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SemiBoldText(title.toUpperCase(),
            fontSize: 11, color: ThemeEnum.hover, maxLines: 2, letterSpacing: 0.5),
        RSizedBox(height: 6),
        child,
      ]),
    );
  }
}

class _ExampleSection extends StatelessWidget {
  const _ExampleSection({required this.index, required this.example});

  final int index;
  final Example example;

  @override
  Widget build(BuildContext context) {
    final explanation = example.explanation?.trim();

    return _Section(
      title: '${StringsManager.example} ${index + 1}',
      child: Container(
        width: double.infinity,
        padding: REdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.getColor(ThemeEnum.mainCard),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.getColor(ThemeEnum.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (example.input != null && example.input!.trim().isNotEmpty)
              _ExampleRow(label: StringsManager.input, value: example.input!.trim()),
            if (example.output != null && example.output!.trim().isNotEmpty)
              _ExampleRow(label: StringsManager.output, value: example.output!.trim()),
            if (explanation != null && explanation.isNotEmpty) ...[
              RSizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemiBoldText(StringsManager.explanation,
                      fontSize: 11, color: ThemeEnum.textSecond, maxLines: 5),
                  Expanded(
                    child: RegularText(
                      explanation,
                      color: ThemeEnum.textSecond,
                      fontFamily: FontConstants.fontJetBrainsMono,
                      fontSize: 11.sp,
                      height: 1.5,
                      maxLines: 20,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SemiBoldText(label, fontSize: 11, color: ThemeEnum.textSecond, maxLines: 4),
        SemiBoldText(": ", fontSize: 11, color: ThemeEnum.textSecond, maxLines: 1),
        Expanded(
          child: RegularText(
            value,
            color: ThemeEnum.textPrimary,
            fontFamily: FontConstants.fontJetBrainsMono,
            fontSize: 11.sp,
            height: 1.5,
            maxLines: 20,
          ),
        ),
      ]),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return RegularText(
      text,
      color: ThemeEnum.textSecond,
      fontSize: 12,
      height: 1.55,
      letterSpacing: 0.1,
      maxLines: 20,
    );
  }
}
