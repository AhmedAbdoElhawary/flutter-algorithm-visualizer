import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show CodeController;
import 'package:algorithm_visualizer/core/helpers/constants.dart';
import 'package:algorithm_visualizer/core/helpers/current_device.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/empty_state_quiet.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/loading_state.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view/celebration_page.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/error_state.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_action_bar.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_code_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_keyboard_toolbar.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_test_case_card.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_title_row.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// The `04 · EDITOR` screen. A single page-level scroll (title row, code
/// card, test case card) plus a pinned action bar above the main nav bar
/// (`contracts/ui-contract.md` §1).
class CodeEditorPage extends ConsumerStatefulWidget {
  const CodeEditorPage({super.key, required this.problemId});

  final int problemId;

  @override
  ConsumerState<CodeEditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<CodeEditorPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();

  int get _effectiveProblemId => widget.problemId <= 0
      ? (ref.read(homeDataProvider.select((s) => s.continueProblem))?.getProblemId ?? -1)
      : widget.problemId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 1.0,
      );
    });
  }

  Future<void> _handleRun(CodingProblem problem, int problemId) async {
    final provider = codeEditorControllerProvider(problemId);
    final notifier = ref.read(provider.notifier);

    CodeGradeResult? finalResult;
    await notifier.runCode((result) async {
      if (result == null) return;
      finalResult = result;
      if (!problem.isThereAnyCorrectCodeSaved) {
        await ref.read(challengesProvider.notifier).updateProblemSubmission(problem, result);
      }
    });

    if (!mounted) return;
    final passed = finalResult;
    if (passed != null && passed.allPassed) {
      context.pushNamed(
        Routes.celebration.name,
        extra: CelebrationArgs(
          problemName: problem.getName,
          passedCount: passed.passedCount,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final problemId = _effectiveProblemId;
    final provider = codeEditorControllerProvider(problemId);

    ref.listen<bool>(provider.select((s) => s.isRunning), (wasRunning, isRunning) {
      if ((wasRunning ?? false) && !isRunning) {
        if (ref.read(provider.select((s) => s.grade)) != null) _scrollToResult();
      }
    });

    return Material(
      child: ref.watch(getProblemProvider(problemId)).when(
            loading: () => const ChallengesLoadingState(),
            error: (error, stackTrace) => const ChallengesErrorState(),
            data: (problem) {
              if (problem == null) {
                return const EmptyStateQuiet(title: StringsManager.noChallengeSelected);
              }
              return _EditorContent(
                problem: problem,
                problemId: problemId,
                scrollController: _scrollController,
                resultKey: _resultKey,
                onRun: () => _handleRun(problem, problemId),
              );
            },
          ),
    );
  }
}

class _EditorContent extends ConsumerStatefulWidget {
  const _EditorContent({
    required this.problem,
    required this.problemId,
    required this.scrollController,
    required this.resultKey,
    required this.onRun,
  });

  final CodingProblem problem;
  final int problemId;
  final ScrollController scrollController;
  final GlobalKey resultKey;
  final VoidCallback onRun;

  @override
  ConsumerState<_EditorContent> createState() => _EditorContentState();
}

class _EditorContentState extends ConsumerState<_EditorContent> {
  // Owned here, not in the notifier: this is a raw editing handle for the
  // keyboard toolbar to write into, not app state anything else needs to
  // react to. Set once by EditorCodeCard's onControllerAttached, alongside
  // the notifier's own attachCodeController.
  CodeController? _codeController;

  @override
  Widget build(BuildContext context) {
    final problem = widget.problem;
    final problemId = widget.problemId;
    final provider = codeEditorControllerProvider(problemId);
    final notifier = ref.read(provider.notifier);

    // The keyboard toolbar only makes sense while the language it's showing
    // symbols for is actually current, so read it here too rather than
    // trusting whatever language _codeController was last attached under.
    final language = ref.watch(provider.select((s) => s.language));
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final codeController = _codeController;

    return Stack(
      children: [
        CustomScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: REdgeInsets.fromLTRB(
                  16, context.isAndroid ? kAndroidTopPageSpacing : kIOSTopPageSpacing, 16, 0),
              sliver: SliverToBoxAdapter(
                child: EditorTitleRow(problemName: problem.getName, problemId: problemId),
              ),
            ),
            SliverPadding(
              padding: REdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final isRunning = ref.watch(provider.select((s) => s.isRunning));
                    final highlightedLine = ref.watch(provider.select((s) => s.highlightedLine));
                    final language = ref.watch(provider.select((s) => s.language));

                    return EditorCodeCard(
                      fileName: problem.getNameWithLanguageName,
                      initialCode: notifier.initialCode,
                      highlightedLine: highlightedLine,
                      running: isRunning,
                      onControllerAttached: (controller) {
                        notifier.attachCodeController(controller);
                        // Deferred a frame: this runs from EditorCodeCard's
                        // initState/didUpdateWidget by way of _CodeArea, and
                        // setState during a descendant's build phase throws.
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _codeController = controller);
                        });
                      },
                      language: language,
                    );
                  },
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final grade = ref.watch(provider.select((s) => s.grade));
                if (grade == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverPadding(
                  key: widget.resultKey,
                  padding: REdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(child: EditorTestCaseCard(grade: grade)),
                );
              },
            ),
            SliverToBoxAdapter(
                child: RSizedBox(height: MediaQuery.of(context).viewInsets.bottom + CdSpace.ctaReserve)),
          ],
        ),
        // Above the OS keyboard, in place of the action bar (which sits at
        // bottom: 0 and is covered by the keyboard anyway — Run/Reset make
        // no sense mid-edit). Nothing else on this page takes text input, so
        // "keyboard visible" and "editor focused" are the same condition.
        if (keyboardVisible && codeController != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.viewInsetsOf(context).bottom - 60.h,
            child: EditorKeyboardToolbar(controller: codeController, language: language),
          )
        else
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer(
              builder: (context, ref, child) {
                final isRunning = ref.watch(provider.select((s) => s.isRunning));

                return EditorActionBar(
                  running: isRunning,
                  onReset: notifier.resetCode,
                  onRun: widget.onRun,
                );
              },
            ),
          ),
      ],
    );
  }
}
