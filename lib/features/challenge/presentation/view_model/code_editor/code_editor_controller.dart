import 'dart:async';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage, languageFromKey;
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

  /// The language the editor opens in: whichever the learner last used here,
  /// falling back to the first this problem offers.
  late final EditorLanguage initialLanguage = _openingLanguage();

  late final String initialCode = codingProblem?.getCodeFor(initialLanguage) ?? "";

  /// One draft per language, so switching away and back never loses work.
  /// Seeded from whatever was saved, and kept up to date as the learner
  /// types (see [_captureCurrentDraft]).
  final Map<EditorLanguage, String> _drafts = <EditorLanguage, String>{};

  CodeController? _codeController;
  Timer? _highlightTimer;

  final _gradeCodeUseCase = const GradeCodeUseCase();

  @override
  CodeEditorState build() {
    ref.onDispose(() => _highlightTimer?.cancel());
    return CodeEditorState.initial(language: initialLanguage);
  }

  EditorLanguage _openingLanguage() {
    final problem = codingProblem;
    if (problem == null) return EditorLanguage.dart;
    final available = problem.languagesAvailable;
    // The most recently saved draft wins, so reopening a problem puts the
    // learner back where they left off (FR-026).
    final mostRecent = problem.getSolutionsStatus.where((s) => s.submittedAt != null).toList()
      ..sort((a, b) => b.submittedAt!.compareTo(a.submittedAt!));
    for (final saved in mostRecent) {
      final language = languageFromKey(saved.languageKey);
      if (language != null && available.contains(language)) return language;
    }
    return available.isEmpty ? EditorLanguage.dart : available.first;
  }

  /// The languages the picker should offer for this problem.
  List<EditorLanguage> get languagesAvailable =>
      codingProblem?.languagesAvailable ?? const <EditorLanguage>[EditorLanguage.dart];

  /// Switches the editor to [language], keeping the draft of the one being
  /// left behind. No prompt and no confirmation: nothing is lost, so there is
  /// nothing to warn about (SC-018).
  void setLanguage(EditorLanguage language) {
    if (language == state.language || state.isRunning) return;
    if (!languagesAvailable.contains(language)) return;

    _captureCurrentDraft();
    state = state.copyWith(language: language, grade: null, highlightedLine: null);

    final controller = _codeController;
    if (controller != null) controller.text = draftFor(language);
  }

  /// The text to show for [language]: the in-memory draft if this session has
  /// one, then whatever was saved, then the starter code.
  String draftFor(EditorLanguage language) => _drafts[language] ?? codingProblem?.getCodeFor(language) ?? '';

  void _captureCurrentDraft() {
    final text = _codeController?.text;
    if (text != null) _drafts[state.language] = text;
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
    // Resets the language on screen, not every language's draft.
    _drafts.remove(state.language);
    controller.text = codingProblem?.getDefaultCodeFor(state.language) ?? "";
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
    _captureCurrentDraft();
    final resultGrade = _gradeCodeUseCase.grade(
      problem: codingProblem,
      userCode: controller.text,
      language: state.language,
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
