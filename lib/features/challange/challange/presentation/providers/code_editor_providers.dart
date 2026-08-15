import 'package:algorithm_visualizer/features/challange/challange/presentation/providers/code_editor_controller.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/providers/code_editor_state.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Scoped per `problemId` — each problem screen gets its own controller,
/// runner repository and disposes when the screen is popped.
final codeEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<CodeEditorController, CodeEditorState, CodingProblem>((ref, codingProblem) {
  return CodeEditorController(
    codingProblem: codingProblem,
  );
});
