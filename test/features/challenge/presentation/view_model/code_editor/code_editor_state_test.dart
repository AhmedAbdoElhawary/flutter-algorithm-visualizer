import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart' show EditorLanguage;
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/code_editor/code_editor_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const grade = CodeGradeResult(allTestCaseResults: [], totalCount: 0, code: '');

  test('starts idle in Dart, or the language it is given', () {
    final state = CodeEditorState.initial();

    expect(state.isRunning, isFalse);
    expect(state.copied, isFalse);
    expect(state.highlightedLine, isNull);
    expect(state.grade, isNull);
    expect(state.language, EditorLanguage.dart);
    expect(CodeEditorState.initial(language: EditorLanguage.python).language, EditorLanguage.python);
  });

  test('copyWith leaves out fields alone, but an explicit null clears them', () {
    final state = CodeEditorState.initial().copyWith(highlightedLine: 3, grade: grade);

    final untouched = state.copyWith(isRunning: true);
    expect(untouched.highlightedLine, 3);
    expect(untouched.grade, same(grade));

    final cleared = state.copyWith(highlightedLine: null, grade: null);
    expect(cleared.highlightedLine, isNull);
    expect(cleared.grade, isNull);
  });

  test('copyWith sets each field', () {
    final state = CodeEditorState.initial().copyWith(
      isRunning: true,
      copied: true,
      language: EditorLanguage.javascript,
    );

    expect(state.isRunning, isTrue);
    expect(state.copied, isTrue);
    expect(state.language, EditorLanguage.javascript);
  });
}
