import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/code_editor.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/providers/code_editor_providers.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/widgets/code_editor_header.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/widgets/code_editor_lang_bar.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/widgets/code_grade_result_card.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/widgets/code_problem_description_card.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/empty_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/error_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CodeEditorPage extends ConsumerStatefulWidget {
  const CodeEditorPage({required this.problemId, super.key});

  final int problemId;

  @override
  ConsumerState<CodeEditorPage> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends ConsumerState<CodeEditorPage> {
  @override
  Widget build(BuildContext context) {
    final codingProblem = ref.watch(getProblemProvider(widget.problemId));

    return Scaffold(
      body: SafeArea(
        child: codingProblem.when(
          data: (problem) {
            if (problem == null) {
              return const ChallengesEmptyState(
                showIcon: false,
                title: StringsManager.noChallengeSelected,
                subTitle: StringsManager.tryToPracticeAChallenge,
              );
            }
            final provider = codeEditorControllerProvider(problem);

            return CustomScrollView(
              slivers: [
                CodeEditorHeader(),
                CodeProblemDescriptionCard(problem: problem),
                CodeEditorLangBar(problem: problem),
                Consumer(
                  builder: (context, ref, child) {
                    final notifier = ref.read(provider.notifier);

                    final highlightedLine = ref.watch(provider.select((value) => value.highlightedLine));
                    final isRunning = ref.watch(provider.select((value) => value.isRunning));

                    return SliverPadding(
                      padding: REdgeInsets.fromLTRB(16, 0, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: CodeEditorBlock(
                          code: problem.getDefaultCode,
                          highlightLineNumber: highlightedLine ?? -1,
                          executing: isRunning,
                          controllerCallback: notifier.attachCodeController,
                        ),
                      ),
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final grade = ref.watch(provider.select((value) => value.grade));

                    if (grade != null) CodeGradeResultCard(grade: grade);

                    return SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
                SliverToBoxAdapter(child: RSizedBox(height: 20)),
              ],
            );
          },
          error: (error, stackTrace) => ChallengesErrorState(),
          loading: () => ChallengesLoadingState(),
        ),
      ),
    );
  }
}
