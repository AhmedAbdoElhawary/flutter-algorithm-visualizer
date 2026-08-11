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
  /// Two independent line-highlight mechanisms are layered on top of the
  /// normal token colors, in priority order:
  ///
  /// 1. [errorLine] (0-indexed): painted with [CodeEditorTheme.errorColor]
  ///    as a translucent background plus a wavy underline. Wins over
  ///    [highlightedLines] if both target the same line.
  /// 2. [highlightedLines]: an arbitrary `{0-indexed line: color}` map —
  ///    each entry gets a plain translucent background in its color, no
  ///    underline. Use this for anything that isn't an error: the current
  ///    line during step-through debugging, breakpoints, search hits,
  ///    diff markers, etc.
  static TextSpan build({
    required List<String> lines,
    required List<List<Token>> lineTokens,
    required TextStyle baseStyle,
    required CodeEditorTheme theme,
    int? errorLine,
    Map<int, Color>? highlightedLines,
  }) {
    final List<InlineSpan> children = <InlineSpan>[];
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      final List<Token> tokens = i < lineTokens.length ? lineTokens[i] : const <Token>[];
      final bool isError = i == errorLine;
      final Color? highlight = isError ? null : highlightedLines?[i];
      _appendLine(
        children,
        line,
        tokens,
        theme,
        isError: isError,
        highlight: highlight,
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
    CodeEditorTheme theme, {
    required bool isError,
    Color? highlight,
  }) {
    // An empty line still needs *something* painted on it for a
    // background/underline to be visible, so fall through to a
    // zero-width-safe span rather than bailing out early.
    if (line.isEmpty) {
      if (isError || highlight != null) {
        out.add(TextSpan(
          text: '',
          style: _styleFor(theme, null, isError: isError),
        ));
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
          style: _styleFor(theme, null, isError: isError),
        ));
      }
      final Color? color = theme.tokenColors[token.type];
      out.add(TextSpan(
        text: token.text,
        style: _styleFor(theme, color, isError: isError),
      ));
      cursor = token.end;
    }
    if (cursor < line.length) {
      final String tail = line.substring(cursor);
      out.add(TextSpan(
        text: tail,
        style: _styleFor(theme, null, isError: isError),
      ));
    }
  }

  static TextStyle? _styleFor(CodeEditorTheme theme, Color? tokenColor, {required bool isError}) {
    if (isError) {
      return TextStyle(
        color: tokenColor,
        decoration: TextDecoration.underline,
        decorationColor: theme.errorColor,
        decorationStyle: TextDecorationStyle.wavy,
      );
    }
    return tokenColor != null ? TextStyle(color: tokenColor) : null;
  }
}
