import 'dart:async';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/editor/code_controller.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodeEditorController extends Notifier<CodeEditorState> {
  CodeEditorController({required this.problemId});

  final int problemId;

  CodingProblem? get codingProblem => ref.read(getProblemProvider(problemId)).value;

  late final String initialCode = codingProblem?.getCode ?? "";

  CodeController? _codeController;
  Timer? _highlightTimer;

  final _gradeCodeUseCase = const GradeCodeUseCase();

  @override
  CodeEditorState build() {
    ref.onDispose(() => _highlightTimer?.cancel());
    return CodeEditorState.initial();
  }

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
      if (ref.mounted) state = state.copyWith(copied: false);
    });
  }

  void resetCode() {
    final controller = _codeController;
    if (controller == null) return;
    controller.text = codingProblem?.getDefaultCode ?? "";
    state = state.copyWith(grade: null, highlightedLine: null);
  }

  CodeController get _getCodeController {
    final con = _codeController;
    if (con == null) {
      /// todo: test this

      throw StateError('CodeControllerRunnerRepository: no CodeController attached yet.');
    }
    return con;
  }

  Future<void> runCode(void Function(CodeGradeResult? result) result) async {
    final codingProblem = this.codingProblem;
    if (state.isRunning || codingProblem == null) return result.call(null);
    state = state.copyWith(isRunning: true, grade: null);

    final controller = _getCodeController;
    final resultGrade = _gradeCodeUseCase.grade(
      problem: codingProblem,
      userCode: controller.text,
    );

    result.call(resultGrade);
    await _animateLineByLine(controller.text.split('\n').length);

    state = state.copyWith(isRunning: false, grade: resultGrade);
  }

  Future<void> _animateLineByLine(int totalLines) {
    final completer = Completer<void>();
    int line = 0;
    _highlightTimer?.cancel();
    _highlightTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }
      line++;
      if (line <= totalLines) {
        state = state.copyWith(highlightedLine: line);
      } else {
        state = state.copyWith(highlightedLine: -1);

        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });
    return completer.future;
  }
}
