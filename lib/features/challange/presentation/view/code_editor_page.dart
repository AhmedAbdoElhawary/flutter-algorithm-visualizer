import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/code_editor.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/challenges/empty_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/challenges/error_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/challenges/loading_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/code_editor/code_editor_header.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/code_editor/code_editor_lang_bar.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/code_editor/code_grade_result_card.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/code_editor/code_problem_description_card.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();

  @override
  void didUpdateWidget(covariant CodeEditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.problemId != widget.problemId) {
      _scrollToTop();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 1.0,
        );
      }
    });
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = codeEditorControllerProvider(widget.problemId);

    ref.listen(provider.select((s) => (s.isRunning, s.grade)), (prev, next) {
      final wasRunning = prev?.$1 ?? false;
      final isRunning = next.$1;
      final grade = next.$2;
      if (wasRunning && !isRunning && grade != null) {
        _scrollToResult();
      }
    });

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

            return CustomScrollView(
              controller: _scrollController,
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
                          title: problem.getNameWithLanguageName,
                          code: notifier.initialCode,
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

                    if (grade != null) {
                      return SliverPadding(
                        key: _resultKey,
                        padding: EdgeInsets.zero,
                        sliver: CodeGradeResultCard(grade: grade),
                      );
                    }

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
