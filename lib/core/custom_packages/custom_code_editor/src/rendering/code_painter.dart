import 'package:flutter/widgets.dart';

import '../models/code_editor_theme.dart';
import '../syntax/token.dart';

/// Turns per-line [Token] lists into a [TextSpan] tree, applying colors
/// from a [CodeEditorTheme].
///
/// This is the *only* place that knows how to go from "tokens" to
/// "colored text" — [CodeController.buildTextSpan] just calls into this.
/// Keeping it a separate, stateless class (rather than inlining it in the
/// controller) keeps each class single-purpose and makes the mapping
/// trivially testable without needing a controller/widget at all.
class CodeSpanBuilder {
  const CodeSpanBuilder._();

  /// Builds a single [TextSpan] for the whole document, given the
  /// per-line token lists produced by `SyntaxHighlighter.highlight`.
  ///
  /// [lines] must be the same source lines the tokens were computed from
  /// (used to fill in any text a tokenizer didn't emit a token for, e.g.
  /// trailing whitespace) and must have the same length as [lineTokens].
  static TextSpan build({
    required List<String> lines,
    required List<List<Token>> lineTokens,
    required TextStyle baseStyle,
    required CodeEditorTheme theme,
  }) {
    final List<InlineSpan> children = <InlineSpan>[];
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      final List<Token> tokens = i < lineTokens.length
          ? lineTokens[i]
          : const <Token>[];
      _appendLine(children, line, tokens, baseStyle, theme);
      if (i != lines.length - 1) {
        children.add(const TextSpan(text: '\n'));
      }
    }
    return TextSpan(style: baseStyle, children: children);
  }

  static void _appendLine(
    List<InlineSpan> out,
    String line,
    List<Token> tokens,
    TextStyle baseStyle,
    CodeEditorTheme theme,
  ) {
    if (line.isEmpty) return;
    int cursor = 0;
    for (final Token token in tokens) {
      // Fill any gap the tokenizer left uncovered (e.g. leading spaces)
      // with the base style so no source text is ever silently dropped.
      if (token.start > cursor) {
        out.add(TextSpan(text: line.substring(cursor, token.start)));
      }
      final Color? color = theme.tokenColors[token.type];
      out.add(TextSpan(
        text: token.text,
        style: color != null ? TextStyle(color: color) : null,
      ));
      cursor = token.end;
    }
    if (cursor < line.length) {
      out.add(TextSpan(text: line.substring(cursor)));
    }
  }
}
