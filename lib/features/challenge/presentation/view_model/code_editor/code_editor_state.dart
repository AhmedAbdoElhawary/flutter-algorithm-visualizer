import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show EditorLanguage;
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';

/// Marks "field not passed to copyWith" so an explicit `null` (clear this
/// field) can be told apart from "leave it as it is" — a plain `?? this.x`
/// can never represent the former for an already-nullable field.
class _Unset {
  const _Unset();
}

const _unset = _Unset();

class CodeEditorState {
  const CodeEditorState({
    required this.isRunning,
    required this.copied,
    required this.highlightedLine,
    required this.grade,
    required this.language,
  });

  factory CodeEditorState.initial({EditorLanguage language = EditorLanguage.dart}) => CodeEditorState(
        isRunning: false,
        copied: false,
        highlightedLine: null,
        grade: null,
        language: language,
      );

  final bool isRunning;
  final bool copied;
  final int? highlightedLine;
  final CodeGradeResult? grade;

  /// The language the editor is currently showing. Each language keeps its
  /// own draft, so switching never costs the learner work (SC-018).
  final EditorLanguage language;

  CodeEditorState copyWith({
    bool? isRunning,
    bool? copied,
    EditorLanguage? language,
    Object? highlightedLine = _unset,
    Object? grade = _unset,
  }) {
    return CodeEditorState(
      isRunning: isRunning ?? this.isRunning,
      copied: copied ?? this.copied,
      language: language ?? this.language,
      highlightedLine: identical(highlightedLine, _unset) ? this.highlightedLine : highlightedLine as int?,
      grade: identical(grade, _unset) ? this.grade : grade as CodeGradeResult?,
    );
  }
}
