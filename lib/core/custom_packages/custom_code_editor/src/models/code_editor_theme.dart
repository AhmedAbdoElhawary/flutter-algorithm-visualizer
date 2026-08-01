import 'package:flutter/widgets.dart';

import '../syntax/token_type.dart';

/// Visual appearance for [CodeEditor].
///
/// A single flat object — no cascading ThemeData-style inheritance. Pass
/// one in, get one predictable look.
class CodeEditorTheme {
  const CodeEditorTheme({
    required this.background,
    required this.caretColor,
    required this.selectionColor,
    required this.textStyle,
    required this.tokenColors,
    required this.lineNumberStyle,
    this.lineNumberBackground,
    this.activeLineBackground,
    this.errorColor = const Color(0xFFFF5252),
    this.gutterPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.editorPadding = const EdgeInsets.all(12),
  });

  /// Editor background color.
  final Color background;

  /// Color of the text cursor.
  final Color caretColor;

  /// Color of the text selection highlight.
  final Color selectionColor;

  /// Base text style. Token colors in [tokenColors] are layered on top of
  /// this style's font family/size/weight.
  final TextStyle textStyle;

  /// Color for each [TokenType]. Any type missing from this map falls back
  /// to [textStyle]'s color.
  final Map<TokenType, Color> tokenColors;

  /// Text style used for the line-number gutter.
  final TextStyle lineNumberStyle;

  /// Optional distinct background for the line-number gutter. Defaults to
  /// [background] when null.
  final Color? lineNumberBackground;

  /// Optional highlight color for the line the caret currently sits on.
  /// No highlight when null.
  final Color? activeLineBackground;

  /// Color used to flag a line with a syntax/runtime error (see
  /// `CodeController.execute`): a translucent background plus a wavy
  /// underline are drawn using this color.
  final Color errorColor;

  /// Horizontal padding inside the line-number gutter.
  final EdgeInsets gutterPadding;

  /// Padding around the editable text area.
  final EdgeInsets editorPadding;

  /// A dark theme reminiscent of common editor "dark" presets.
  factory CodeEditorTheme.dark() {
    const Color fg = Color(0xFFD4D4D4);
    return CodeEditorTheme(
      background: const Color(0xFF1E1E1E),
      caretColor: const Color(0xFFAEAFAD),
      selectionColor: const Color(0x554B6EAF),
      textStyle: const TextStyle(
        color: fg,
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
      ),
      lineNumberStyle: const TextStyle(
        color: Color(0xFF6E7681),
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
      ),
      lineNumberBackground: const Color(0xFF1E1E1E),
      activeLineBackground: const Color(0x14FFFFFF),
      tokenColors: const <TokenType, Color>{
        TokenType.keyword: Color(0xFF569CD6),
        TokenType.string: Color(0xFFCE9178),
        TokenType.number: Color(0xFFB5CEA8),
        TokenType.comment: Color(0xFF6A9955),
        TokenType.identifier: fg,
        TokenType.operator: Color(0xFFD4D4D4),
        TokenType.punctuation: Color(0xFFD4D4D4),
        TokenType.builtin: Color(0xFF4EC9B0),
        TokenType.plain: fg,
      },
    );
  }

  /// A light theme reminiscent of common editor "light" presets.
  factory CodeEditorTheme.light() {
    const Color fg = Color(0xFF1F1F1F);
    return CodeEditorTheme(
      background: const Color(0xFFFFFFFF),
      caretColor: const Color(0xFF000000),
      selectionColor: const Color(0x33ADD6FF),
      textStyle: const TextStyle(
        color: fg,
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
      ),
      lineNumberStyle: const TextStyle(
        color: Color(0xFF999999),
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
      ),
      lineNumberBackground: const Color(0xFFFFFFFF),
      activeLineBackground: const Color(0x11000000),
      tokenColors: const <TokenType, Color>{
        TokenType.keyword: Color(0xFF0000FF),
        TokenType.string: Color(0xFFA31515),
        TokenType.number: Color(0xFF098658),
        TokenType.comment: Color(0xFF008000),
        TokenType.identifier: fg,
        TokenType.operator: Color(0xFF1F1F1F),
        TokenType.punctuation: Color(0xFF1F1F1F),
        TokenType.builtin: Color(0xFF267F99),
        TokenType.plain: fg,
      },
    );
  }

  CodeEditorTheme copyWith({
    Color? background,
    Color? caretColor,
    Color? selectionColor,
    TextStyle? textStyle,
    Map<TokenType, Color>? tokenColors,
    TextStyle? lineNumberStyle,
    Color? lineNumberBackground,
    Color? activeLineBackground,
    Color? errorColor,
    EdgeInsets? gutterPadding,
    EdgeInsets? editorPadding,
  }) {
    return CodeEditorTheme(
      background: background ?? this.background,
      caretColor: caretColor ?? this.caretColor,
      selectionColor: selectionColor ?? this.selectionColor,
      textStyle: textStyle ?? this.textStyle,
      tokenColors: tokenColors ?? this.tokenColors,
      lineNumberStyle: lineNumberStyle ?? this.lineNumberStyle,
      lineNumberBackground: lineNumberBackground ?? this.lineNumberBackground,
      activeLineBackground: activeLineBackground ?? this.activeLineBackground,
      errorColor: errorColor ?? this.errorColor,
      gutterPadding: gutterPadding ?? this.gutterPadding,
      editorPadding: editorPadding ?? this.editorPadding,
    );
  }
}
