import 'package:algorithm_visualizer/core/extensions/navigators.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/font_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/bottom_cta_bar.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/icon_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/primary_button_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/surface_card.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/example.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/helper/problem_style.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _ProblemTab { problem, hints, similar }

/// Aurora screen 03. The problem statement as its own screen — reached from the
/// practice list, with a white "Solve in editor" CTA that pushes the editor.
class ProblemPage extends ConsumerStatefulWidget {
  const ProblemPage({super.key, required this.problemId});

  final int problemId;

  @override
  ConsumerState<ProblemPage> createState() => _ProblemPageState();
}

class _ProblemPageState extends ConsumerState<ProblemPage> {
  _ProblemTab _tab = _ProblemTab.problem;
  bool _constraintsOpen = false;

  @override
  Widget build(BuildContext context) {
    final problemId = widget.problemId <= 0
        ? (ref.read(homeDataProvider.select((s) => s.continueProblem))?.getProblemId ?? -1)
        : widget.problemId;

    final problem = ref.watch(getProblemProvider(problemId).select((a) => a.value));

    return problem == null
        ? const Center(child: MediumText(StringsManager.noChallengeSelected, color: ThemeEnum.textSecond))
        : Stack(
            children: [
              ListView(
                padding: REdgeInsets.fromLTRB(16, 4, 16, 120),
                children: [
                  _Header(problem: problem),
                  const RSizedBox(height: 13),
                  _TabBar(active: _tab, onChanged: (t) => setState(() => _tab = t)),
                  const RSizedBox(height: 13),
                  ..._tabContent(problem),
                ],
              ),
              _PinnedCta(
                onSolve: () {
                  /// TODO: move to new editor page
                  // context.pushTo(
                  // Routes.code,
                  // queryParameters: "${problem.getProblemId}",
                  // );
                },
              ),
            ],
          );
  }

  List<Widget> _tabContent(CodingProblem problem) {
    switch (_tab) {
      case _ProblemTab.problem:
        return [
          if (problem.getDescription.trim().isNotEmpty)
            RegularText(
              problem.getDescription.trim(),
              color: ThemeEnum.textBody,
              fontSize: 12.5,
              height: 1.75,
              maxLines: 40,
            ),
          if (problem.getConstraints.isNotEmpty) ...[
            const RSizedBox(height: 13),
            _ConstraintsCard(
              constraints: problem.getConstraints,
              open: _constraintsOpen,
              onToggle: () => setState(() => _constraintsOpen = !_constraintsOpen),
            ),
          ],
          for (var i = 0; i < problem.getExamples.length; i++) ...[
            const RSizedBox(height: 13),
            _ExampleBlock(index: i, example: problem.getExamples[i]),
          ],
        ];
      case _ProblemTab.hints:
        final hints = problem.getHints;
        if (hints.isEmpty) {
          return const [MediumText(StringsManager.hints, color: ThemeEnum.textSecond)];
        }
        return [
          for (var i = 0; i < hints.length; i++)
            Padding(
              padding: REdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                child: RegularText('${i + 1}.  ${hints[i]}',
                    color: ThemeEnum.textBody, fontSize: 12, height: 1.6, maxLines: 20),
              ),
            ),
        ];
      case _ProblemTab.similar:
        final similar = problem.getSimilarQuestions;
        if (similar.isEmpty) {
          return const [MediumText(StringsManager.similarQuestions, color: ThemeEnum.textSecond)];
        }
        return [
          for (final sq in similar)
            Padding(
              padding: REdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                // onTap: () {
                //   context.pushTo(Routes.subProblem, queryParameters: sq.problemId?.toString() ?? "");
                // },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomIcon(Icons.arrow_outward_rounded, size: 14, color: ThemeEnum.textSecond),
                    const RSizedBox(width: 8),
                    Expanded(
                      child:
                          SemiBoldText(sq.name ?? '', color: ThemeEnum.textBright, fontSize: 12, maxLines: 3),
                    ),
                  ],
                ),
              ),
            ),
        ];
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.problem});

  final CodingProblem problem;

  @override
  Widget build(BuildContext context) {
    final chipDifficulty = ProblemStyle.quietChipDifficulty(problem.getDifficulty);
    final tags = problem.getTags;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButtonQuiet(icon: Icons.arrow_back_ios_new_rounded, size: 30, iconSize: 14, onTap: context.back),
        const RSizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              BoldText(problem.getName, color: ThemeEnum.textPrimary, fontSize: 17, maxLines: 2),
              if (tags.isNotEmpty) ...[
                const RSizedBox(height: 2),
                RegularText(tags.join(', '), color: ThemeEnum.textSecond, fontSize: 10, maxLines: 1),
              ],
            ],
          ),
        ),
        if (chipDifficulty != null) ...[
          const RSizedBox(width: 8),
          DifficultyChip(difficulty: chipDifficulty, label: problem.getDifficulty.difficultyString),
        ],
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.active, required this.onChanged});

  final _ProblemTab active;
  final ValueChanged<_ProblemTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.getColor(ThemeEnum.borderSubtle))),
      ),
      padding: REdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          _tab(context, StringsManager.problemTab, _ProblemTab.problem),
          const RSizedBox(width: 16),
          _tab(context, StringsManager.hints, _ProblemTab.hints),
          /// TODO: add this with push to different problem
          // const RSizedBox(width: 16),
          // _tab(context, StringsManager.similarQuestions, _ProblemTab.similar),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label, _ProblemTab value) {
    final selected = value == active;
    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: selected
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.getColor(ThemeEnum.solidWhite), width: 2),
                ),
              )
            : null,
        padding: REdgeInsets.only(bottom: 9),
        child: selected
            ? SemiBoldText(label, color: ThemeEnum.textPrimary, fontSize: 12, maxLines: 1)
            : MediumText(label, color: ThemeEnum.textSecond, fontSize: 12, maxLines: 1),
      ),
    );
  }
}

class _ConstraintsCard extends StatelessWidget {
  const _ConstraintsCard({required this.constraints, required this.open, required this.onToggle});

  final List<String> constraints;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: REdgeInsets.symmetric(horizontal: 15, vertical: 13),
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SemiBoldText(StringsManager.constraints, color: ThemeEnum.textBright, fontSize: 12),
              ),
              CustomIcon(open ? Icons.remove_rounded : Icons.add_rounded,
                  size: 16, color: ThemeEnum.textSecond),
            ],
          ),
          AnimatedSize(
            duration: CdMotion.expand,
            curve: Curves.easeInOut,
            child: open
                ? Padding(
                    padding: REdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final c in constraints)
                          Padding(
                            padding: REdgeInsets.only(bottom: 4),
                            child: RegularText('•  $c',
                                color: ThemeEnum.textBody, fontSize: 11.5, height: 1.5, maxLines: 10),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  const _ExampleBlock({required this.index, required this.example});

  final int index;
  final Example example;

  @override
  Widget build(BuildContext context) {
    final explanation = example.explanation?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemiBoldText(
          '${StringsManager.example} ${index + 1}'.toUpperCase(),
          color: ThemeEnum.textSecond,
          fontSize: 10,
          letterSpacing: 1,
        ),
        const RSizedBox(height: 9),
        SurfaceCard(
          padding: REdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((example.input ?? '').trim().isNotEmpty)
                _MonoRow(label: StringsManager.input, value: example.input!.trim(), strong: false),
              if ((example.output ?? '').trim().isNotEmpty) ...[
                const RSizedBox(height: 7),
                _MonoRow(label: StringsManager.output, value: example.output!.trim(), strong: true),
              ],
              if (explanation != null && explanation.isNotEmpty) ...[
                const RSizedBox(height: 7),
                Container(
                  width: double.infinity,
                  padding: REdgeInsets.only(top: 7),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: context.getColor(ThemeEnum.borderSubtle))),
                  ),
                  child: RegularText(
                    explanation,
                    color: ThemeEnum.textSecond,
                    fontFamily: FontConstants.fontJetBrainsMono,
                    fontSize: 11,
                    height: 1.6,
                    maxLines: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MonoRow extends StatelessWidget {
  const _MonoRow({required this.label, required this.value, required this.strong});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegularText('$label: ',
            color: ThemeEnum.textBody,
            fontFamily: FontConstants.fontJetBrainsMono,
            fontSize: 11,
            maxLines: 1),
        Expanded(
          child: RegularText(
            value,
            color: strong ? ThemeEnum.textPrimary : ThemeEnum.textBright,
            fontFamily: FontConstants.fontJetBrainsMono,
            fontSize: 11,
            height: 1.5,
            maxLines: 10,
          ),
        ),
      ],
    );
  }
}

class _PinnedCta extends StatelessWidget {
  const _PinnedCta({required this.onSolve});

  final VoidCallback onSolve;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: BottomCtaBar(
        child: PrimaryButtonQuiet(label: StringsManager.solveInEditor, onPressed: onSolve),
      ),
    );
  }
}
