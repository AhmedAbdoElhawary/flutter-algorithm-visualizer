import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one indent is the tab size in spaces, or a tab', () {
    expect(const CodeEditorConfig(tabSize: 2).indentUnit, '  ');
    expect(const CodeEditorConfig().indentUnit, '    ');
    expect(const CodeEditorConfig(useSpaces: false).indentUnit, '\t');
  });

  test('copyWith changes only what it is given', () {
    const config = CodeEditorConfig(tabSize: 2, autoIndent: false);

    final copy = config.copyWith(showLineNumbers: false);

    expect(copy.tabSize, 2);
    expect(copy.autoIndent, isFalse);
    expect(copy.showLineNumbers, isFalse);
    expect(copy.autoCloseBrackets, isTrue);

    final all = config.copyWith(
      tabSize: 8,
      useSpaces: false,
      autoIndent: true,
      autoCloseBrackets: false,
      smartSpaces: false,
      trimTrailingWhitespaceOnNewLine: false,
    );
    expect(all.tabSize, 8);
    expect(all.useSpaces, isFalse);
    expect(all.autoIndent, isTrue);
    expect(all.autoCloseBrackets, isFalse);
    expect(all.smartSpaces, isFalse);
    expect(all.trimTrailingWhitespaceOnNewLine, isFalse);
  });
}
