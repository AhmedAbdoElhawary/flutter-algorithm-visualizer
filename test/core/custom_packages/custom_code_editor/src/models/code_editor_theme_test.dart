import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the dark and light defaults colour every kind of token', () {
    for (final theme in [CodeEditorTheme.dark(), CodeEditorTheme.light()]) {
      expect(theme.tokenColors.keys, containsAll(TokenType.values));
    }
    expect(CodeEditorTheme.dark().background, isNot(CodeEditorTheme.light().background));
  });

  test('copyWith changes only what it is given, every field kept', () {
    final theme = CodeEditorTheme.dark().copyWith(
      caretWidth: 3,
      caretHeight: 20,
      border: Border.all(),
      borderBetweenNumbersAndEditor: false,
    );

    final copy = theme.copyWith(errorColor: const Color(0xFF00FF00));

    expect(copy.errorColor, const Color(0xFF00FF00));
    expect(copy.background, theme.background);
    expect(copy.tokenColors, theme.tokenColors);
    expect(copy.caretWidth, 3);
    expect(copy.caretHeight, 20);
    expect(copy.borderRadius, theme.borderRadius);
    expect(copy.border, theme.border);
    expect(copy.borderBetweenNumbersAndEditor, isFalse);
  });

  test('every other field can be replaced too', () {
    const style = TextStyle(fontSize: 20);
    final copy = CodeEditorTheme.light().copyWith(
      background: const Color(0xFF000001),
      caretColor: const Color(0xFF000002),
      selectionColor: const Color(0xFF000003),
      textStyle: style,
      tokenColors: const {TokenType.plain: Color(0xFF000004)},
      lineNumberStyle: style,
      lineNumberBackground: const Color(0xFF000005),
      activeLineBackground: const Color(0xFF000006),
      gutterPadding: EdgeInsets.zero,
      editorPadding: EdgeInsets.zero,
      borderRadius: BorderRadiusDirectional.zero,
    );

    expect(copy.background, const Color(0xFF000001));
    expect(copy.caretColor, const Color(0xFF000002));
    expect(copy.selectionColor, const Color(0xFF000003));
    expect(copy.textStyle, style);
    expect(copy.tokenColors, const {TokenType.plain: Color(0xFF000004)});
    expect(copy.lineNumberBackground, const Color(0xFF000005));
    expect(copy.activeLineBackground, const Color(0xFF000006));
    expect(copy.gutterPadding, EdgeInsets.zero);
    expect(copy.borderRadius, BorderRadiusDirectional.zero);
  });
}
