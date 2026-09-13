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
  });

  factory CodeEditorState.initial() =>
      const CodeEditorState(isRunning: false, copied: false, highlightedLine: null, grade: null);

  final bool isRunning;
  final bool copied;
  final int? highlightedLine;
  final CodeGradeResult? grade;

  CodeEditorState copyWith({
    bool? isRunning,
    bool? copied,
    Object? highlightedLine = _unset,
    Object? grade = _unset,
  }) {
    return CodeEditorState(
      isRunning: isRunning ?? this.isRunning,
      copied: copied ?? this.copied,
      highlightedLine:
          identical(highlightedLine, _unset) ? this.highlightedLine : highlightedLine as int?,
      grade: identical(grade, _unset) ? this.grade : grade as CodeGradeResult?,
    );
  }
}
