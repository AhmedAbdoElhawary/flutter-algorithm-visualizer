
import 'package:algorithm_visualizer/features/challange/challange/domain/entities/execution_result.dart';

/// Sentinel so `copyWith` can tell "leave unchanged" apart from "set this
/// nullable field to null".
class _Unset {
  const _Unset();
}

const _unset = _Unset();

class CodeEditorState {
  const CodeEditorState({
    required this.isRunning,
    required this.showOutput,
    required this.copied,
    required this.highlightedLine,
    // required this.testCases,
    required this.loadingTestCases,
    required this.result,
  });

  factory CodeEditorState.initial() => const CodeEditorState(
        isRunning: false,
        showOutput: false,
        copied: false,
        highlightedLine: null,
        // testCases: [],
        loadingTestCases: true,
        result: null,
      );

  final bool isRunning;
  final bool showOutput;
  final bool copied;
  final int? highlightedLine;
  // final List<CodeTestCase> testCases;
  final bool loadingTestCases;
  final ExecutionResult? result;

  CodeEditorState copyWith({
    bool? isRunning,
    bool? showOutput,
    bool? copied,
    Object? highlightedLine = _unset,
    // List<CodeTestCase>? testCases,
    bool? loadingTestCases,
    Object? result = _unset,
  }) {
    return CodeEditorState(
      isRunning: isRunning ?? this.isRunning,
      showOutput: showOutput ?? this.showOutput,
      copied: copied ?? this.copied,
      highlightedLine: identical(highlightedLine, _unset)
          ? this.highlightedLine
          : highlightedLine as int?,
      // testCases: testCases ?? this.testCases,
      loadingTestCases: loadingTestCases ?? this.loadingTestCases,
      result: identical(result, _unset) ? this.result : result as ExecutionResult?,
    );
  }
}
