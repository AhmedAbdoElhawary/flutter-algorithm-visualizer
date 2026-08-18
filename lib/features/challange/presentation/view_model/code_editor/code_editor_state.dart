import 'package:algorithm_visualizer/features/challange/domain/usecases/grade_code_usecase.dart';

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
    int? highlightedLine,
    CodeGradeResult? grade,
  }) {
    return CodeEditorState(
      isRunning: isRunning ?? this.isRunning,
      copied: copied ?? this.copied,
      highlightedLine: highlightedLine ?? this.highlightedLine,
      grade: grade ?? this.grade,
    );
  }
}
