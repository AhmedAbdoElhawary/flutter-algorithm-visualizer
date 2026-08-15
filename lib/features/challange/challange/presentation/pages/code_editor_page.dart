import 'package:algorithm_visualizer/core/widgets/custom_widgets/code_editor.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/providers/code_editor_providers.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/widgets/code_editor_header.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/widgets/code_editor_lang_bar.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/widgets/code_editor_output_card.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/empty_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/error_state.dart';
import 'package:algorithm_visualizer/features/challange/presentation/widgets/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// TODO: source this from the real `CodingProblem` entity once it's fetched
// (title / difficulty in CodeEditorHeader should come from the same place).
const _dartCode = r'''
// Binary Search Algorithm
int binarySearch(List<int> arr, int target) {
  int left = 0;
  int right = arr.length - 1;

  while (left <= right) {
    int mid = (left + right) ~/ 2;

    if (arr[mid] == target) {
      return mid;
    } else if (arr[mid] < target) {
      left = mid + 1;
    } else {
      right = mid - 1;
    }
  }

  return -1;
}

void main() {
  final arr = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91];
  final idx = binarySearch(arr, 23);
  print(idx);
}
''';

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
          data: (data) {
            if (data == null) return const ChallengesEmptyState();

            final provider = codeEditorControllerProvider(data);
            final state = ref.watch(provider);
            final notifier = ref.read(provider.notifier);

            return CustomScrollView(
              slivers: [
                const CodeEditorHeader(),
                CodeEditorLangBar(
                  isRunning: state.isRunning,
                  copied: state.copied,
                  onCopy: notifier.copyCode,
                  onRun: notifier.runCode,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: CodeEditorBlock(
                      code: _dartCode,
                      highlightLineNumber: state.highlightedLine ?? -1,
                      executing: state.isRunning,
                      controllerCallback: notifier.attachCodeController,
                    ),
                  ),
                ),
                if (state.showOutput && state.result != null) CodeEditorOutputCard(result: state.result!),
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
