import 'package:algorithm_visualizer/features/challange/presentation/view_model/code_editor/code_editor_controller.dart';
import 'package:algorithm_visualizer/features/challange/presentation/view_model/code_editor/code_editor_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scoped per `problemId` — each problem screen gets its own controller,
/// runner repository and disposes when the screen is popped.
///
/// Keyed by the id (not the `CodingProblem` instance) so a solution save that
/// publishes a fresh problem instance doesn't recreate the controller and wipe
/// the editor session mid-run. The problem snapshot is read once at creation;
/// it only holds the (immutable) problem definition used for grading.
final codeEditorControllerProvider = NotifierProvider.autoDispose
    .family<CodeEditorController, CodeEditorState, int>((int problemId) {
  return CodeEditorController(problemId: problemId);
});
