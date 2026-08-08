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
  ///
  /// When [errorLine] is non-null (0-indexed), that line is painted with
  /// [CodeEditorTheme.errorColor] as a translucent background plus a wavy
  /// underline, on top of whatever syntax colors it would otherwise get.
  static TextSpan build({
    required List<String> lines,
    required List<List<Token>> lineTokens,
    required TextStyle baseStyle,
    required CodeEditorTheme theme,
    int? errorLine,
  }) {
    final List<InlineSpan> children = <InlineSpan>[];
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      final List<Token> tokens = i < lineTokens.length ? lineTokens[i] : const <Token>[];
      _appendLine(
        children,
        line,
        tokens,
        baseStyle,
        theme,
        isErrorLine: i == errorLine,
      );
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
    CodeEditorTheme theme, {
    required bool isErrorLine,
  }) {
    // An empty line still needs *something* painted on it for the error
    // background/underline to be visible, so fall through to a
    // zero-width-safe single space span rather than bailing out early.
    if (line.isEmpty) {
      if (isErrorLine) {
        out.add(TextSpan(text: '', style: _errorStyle(theme, null)));
      }
      return;
    }

    int cursor = 0;
    for (final Token token in tokens) {
      // Fill any gap the tokenizer left uncovered (e.g. leading spaces)
      // with the base style so no source text is ever silently dropped.
      if (token.start > cursor) {
        final String gap = line.substring(cursor, token.start);
        out.add(TextSpan(
          text: gap,
          style: isErrorLine ? _errorStyle(theme, null) : null,
        ));
      }
      final Color? color = theme.tokenColors[token.type];
      out.add(TextSpan(
        text: token.text,
        style: isErrorLine ? _errorStyle(theme, color) : _colorStyle(color),
      ));
      cursor = token.end;
    }
    if (cursor < line.length) {
      final String tail = line.substring(cursor);
      out.add(TextSpan(
        text: tail,
        style: isErrorLine ? _errorStyle(theme, null) : null,
      ));
    }
  }

  static TextStyle? _colorStyle(Color? color) => color != null ? TextStyle(color: color) : null;

  static TextStyle _errorStyle(CodeEditorTheme theme, Color? tokenColor) {
    return TextStyle(
      color: tokenColor,
      backgroundColor: theme.errorColor.withValues(alpha: 0.16),
      decoration: TextDecoration.underline,
      decorationColor: theme.errorColor,
      decorationStyle: TextDecorationStyle.wavy,
    );
  }
}
