import 'dart:async';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/editor/code_controller.dart';
import 'package:algorithm_visualizer/features/challange/challange/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challange/challange/presentation/providers/code_editor_state.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodeEditorController extends StateNotifier<CodeEditorState> {
  CodeEditorController({required this.codingProblem}) : super(CodeEditorState.initial());

  final CodingProblem codingProblem;

  // Kept directly (in addition to being handed to the repository) purely so
  // the line-count animation below can read `.text` — that's a UI concern,
  // not business logic, so it doesn't need to go through the repository.
  CodeController? _codeController;

  Timer? _highlightTimer;

  void attachCodeController(CodeController controller) {
    if (_codeController != null && _codeController?.text == controller.text) return;
    _codeController = controller;
  }

  Future<void> copyCode() async {
    final text = _codeController?.text;
    if (text == null) return;

    state = state.copyWith(copied: true);
    await Clipboard.setData(ClipboardData(text: text));

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) state = state.copyWith(copied: false);
    });
  }

  CodeController get _getCodeController {
    final con = _codeController;
    if (con == null) {
      /// todo: test this

      throw StateError(
        'CodeControllerRunnerRepository: no CodeController attached yet.',
      );
    }
    return con;
  }

  Future<void> runCode() async {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true, grade: null);

    final controller = _getCodeController;
    final result = const GradeCodeUseCase().grade(
      problem: codingProblem,
      userCode: controller.text,
    );

    state = state.copyWith(isRunning: false, grade: result);
  }

  /// Purely cosmetic "line highlight sweep" while the code "runs" — kept in
  /// the presentation layer since it's an animation detail, not a business
  /// rule.
  Future<void> _animateLineByLine(int totalLines) {
    final completer = Completer<void>();
    var line = 0;
    _highlightTimer?.cancel();
    _highlightTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }
      line++;
      if (line <= totalLines) {
        state = state.copyWith(highlightedLine: line);
      } else {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }
}
