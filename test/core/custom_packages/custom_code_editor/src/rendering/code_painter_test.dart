import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/rendering/code_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = CodeEditorTheme.dark();
  const base = TextStyle(fontSize: 14);

  List<TextSpan> spansOf(TextSpan root) => root.children!.cast<TextSpan>();

  List<Token> tokensOf(String line) =>
      const DartTokenizer().tokenizeLine(line, const StatelessLineState()).tokens;

  TextSpan build(List<String> lines, {int? errorLine, Map<int, Color>? highlighted}) => CodeSpanBuilder.build(
        lines: lines,
        lineTokens: [for (final line in lines) tokensOf(line)],
        baseStyle: base,
        theme: theme,
        errorLine: errorLine,
        highlightedLines: highlighted,
      );

  test('every character of the source is painted, gaps included', () {
    const lines = ['  int a = 1;', '', 'return a;'];

    expect(build(lines).toPlainText(), lines.join('\n'));
  });

  test('each token takes its colour from the theme', () {
    final spans = spansOf(build(['int a']));

    expect(spans.firstWhere((s) => s.text == 'int').style!.color, theme.tokenColors[TokenType.builtin]);
    expect(spans.firstWhere((s) => s.text == 'a').style!.color, theme.tokenColors[TokenType.identifier]);
  });

  test('the error line gets a wavy underline, the others do not', () {
    final spans = spansOf(build(['int a', 'int b'], errorLine: 1));

    final underlined = spans.where((s) => s.style?.decoration == TextDecoration.underline).map((s) => s.text);
    expect(underlined, containsAll(['int', 'b']));
    expect(underlined, isNot(contains('a')));
    expect(spans.firstWhere((s) => s.text == 'b').style!.decorationStyle, TextDecorationStyle.wavy);
  });

  test('an empty error line still gets a span to carry its mark', () {
    final spans = spansOf(build(['int a', ''], errorLine: 1));

    expect(spans.last.text, '');
    expect(spans.last.style!.decoration, TextDecoration.underline);
  });

  test('text the tokenizer left out is still painted, in the base style', () {
    final span = CodeSpanBuilder.build(
      lines: const ['abc def'],
      lineTokens: const [
        [Token(type: TokenType.keyword, text: 'abc', start: 0, end: 3)],
      ],
      baseStyle: base,
      theme: theme,
    );

    expect(span.toPlainText(), 'abc def');
    expect(spansOf(span).last.style, isNull);
  });

  test('a line with no tokens at all is painted plain', () {
    final span =
        CodeSpanBuilder.build(lines: const ['x y'], lineTokens: const [], baseStyle: base, theme: theme);

    expect(span.toPlainText(), 'x y');
  });
}
