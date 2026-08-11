import 'package:flutter/widgets.dart';

import '../execution/runner.dart';
import '../formatting/formatter.dart';
import '../models/code_editor_config.dart';
import '../models/code_editor_theme.dart';
import '../rendering/code_painter.dart';
import '../syntax/syntax_highlighter.dart';
import '../syntax/token.dart';
import '../syntax/tokenizer.dart';
import '../utils/bracket_utils.dart';
import '../utils/indentation.dart';
import 'code_document.dart';

/// A [TextEditingController] specialized for code editing.
///
/// This is where "smart" editing behavior lives: every time the text
/// value changes, [_transform] inspects *what* changed (a single
/// character insertion? a newline? a backspace?) and, depending on
/// [config], adjusts the resulting [TextEditingValue] before it becomes
/// the controller's actual value — e.g. inserting a matching closing
/// bracket, or indenting a freshly-created line.
///
/// It also drives syntax highlighting via [buildTextSpan], which is the
/// same hook Flutter's own `TextField` uses to let a controller supply
/// custom rich text instead of a single flat style.
class CodeController extends TextEditingController {
  CodeController({
    String text = '',
    Tokenizer? tokenizer,
    this.config = const CodeEditorConfig(),
    this.formatter,
    this.runner,
    CodeEditorTheme? theme,
  })  : _highlighter = tokenizer != null ? SyntaxHighlighter(tokenizer) : null,
        theme = theme ?? CodeEditorTheme.dark(),
        super(text: text);

  /// Behavioral configuration (indentation, bracket pairing, ...).
  CodeEditorConfig config;

  /// Optional formatter used by [format]. No-op when null.
  CodeFormatter? formatter;

  /// Optional runner used by [execute]. No-op (returns a failed
  /// [RunResult]) when null.
  CodeRunner? runner;

  /// Theme used for syntax-highlight coloring in [buildTextSpan].
  ///
  /// [CodeEditor] keeps this in sync with its own `theme` property; you
  /// generally don't need to set this directly.
  CodeEditorTheme theme;

  SyntaxHighlighter? _highlighter;

  /// 0-indexed line currently flagged as having a syntax/runtime error,
  /// or null when there isn't one. Set by [execute]; cleared automatically
  /// the next time the text actually changes.
  int? errorLine;

  /// Arbitrary `{0-indexed line: color}` highlights, layered under
  /// [errorLine] (which always wins if both target the same line). Use
  /// [highlightLine] / [unhighlightLine] / [clearHighlights] to manage
  /// this rather than mutating it directly, so listeners get notified.
  ///
  /// Unlike [errorLine], these are **not** cleared automatically on edit
  /// — different use cases want different lifetimes (a "current line"
  /// marker during step-through debugging should move with you; a
  /// breakpoint should survive edits above it; a search-hit highlight
  /// should clear on the next search). Clear them yourself when done.
  final Map<int, Color> highlightedLines = <int, Color>{};

  /// Highlights [line] (0-indexed) with a translucent [color] background.
  /// Overwrites any existing highlight on that line. Notifies listeners.
  void highlightLine(int line, Color color) {
    highlightedLines[line] = color;
    notifyListeners();
  }

  /// Highlights every line in [lines] with [color] in one notification,
  /// instead of one `notifyListeners()` call per line.
  void highlightLines(Iterable<int> lines, Color color) {
    for (final int line in lines) {
      highlightedLines[line] = color;
    }
    notifyListeners();
  }

  /// Removes the highlight from [line], if any. Notifies listeners only
  /// if something actually changed.
  void unhighlightLine(int line) {
    if (highlightedLines.remove(line) != null) {
      notifyListeners();
    }
  }

  /// Removes every highlight added via [highlightLine]/[highlightLines].
  /// Does not affect [errorLine]; see [clearError] for that.
  void clearHighlights() {
    if (highlightedLines.isNotEmpty) {
      highlightedLines.clear();
      notifyListeners();
    }
  }

  /// The most recent result from [execute], if any.
  RunResult? lastRunResult;

  /// Runs [runner] on the current text and updates [errorLine] /
  /// [lastRunResult] accordingly, notifying listeners so [CodeEditor] and
  /// [LineNumbers] can repaint. Returns a no-op successful [RunResult]
  /// with empty output when no [runner] is attached.
  RunResult execute() {
    final CodeRunner? r = runner;
    if (r == null) {
      const RunResult result = RunResult(stdout: <String>[]);
      lastRunResult = result;
      return result;
    }
    final RunResult result = r.run(text);
    errorLine = result.error != null ? result.error!.line - 1 : null;
    lastRunResult = result;
    notifyListeners();
    return result;
  }

  /// Clears any error-line highlight set by [execute] without re-running
  /// anything.
  void clearError() {
    if (errorLine != null) {
      errorLine = null;
      notifyListeners();
    }
  }

  /// The current text as a [CodeDocument], for line-oriented access.
  CodeDocument get document => CodeDocument(text);

  /// Swaps the language tokenizer at runtime (e.g. switching from Dart to
  /// Python highlighting). Pass null to disable highlighting entirely.
  void setTokenizer(Tokenizer? tokenizer) {
    _highlighter = tokenizer != null ? SyntaxHighlighter(tokenizer) : null;
    notifyListeners();
  }

  /// Runs [formatter] on the current text and replaces it, placing the
  /// caret at the end. Does nothing if no [formatter] is set.
  void format() {
    final CodeFormatter? f = formatter;
    if (f == null) return;
    final String formatted = f.format(text);
    value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  set value(TextEditingValue newValue) {
    final TextEditingValue transformed = _transform(value, newValue);
    if (errorLine != null && transformed.text != value.text) {
      errorLine = null;
    }
    super.value = transformed;
  }

  // ---------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final SyntaxHighlighter? highlighter = _highlighter;
    if (highlighter == null && errorLine == null && highlightedLines.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final CodeDocument doc = document;
    final List<List<Token>> tokens =
        highlighter?.highlight(doc.lines) ?? List<List<Token>>.generate(doc.lineCount, (_) => const <Token>[]);
    return CodeSpanBuilder.build(
      lines: doc.lines,
      lineTokens: tokens,
      baseStyle: style ?? const TextStyle(),
      theme: theme,
      errorLine: errorLine,
      highlightedLines: highlightedLines,
    );
  }

  // ---------------------------------------------------------------------
  // Edit transformation
  // ---------------------------------------------------------------------

  TextEditingValue _transform(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Let in-progress IME composition (e.g. Pinyin/Hangul input) pass
    // through untouched — rewriting text mid-composition confuses input
    // methods.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final _Edit? edit = _diff(oldValue.text, newValue.text, newValue.selection);
    if (edit == null) return newValue;

    // Pure insertion.
    if (edit.deletedLength == 0 && edit.inserted.isNotEmpty) {
      if (edit.inserted == '\n' && config.autoIndent) {
        return _handleNewline(oldValue, edit);
      }
      if (edit.inserted.length == 1 && config.autoCloseBrackets) {
        final TextEditingValue? handled = _handleAutoCloseOrTypeOver(oldValue, edit);
        if (handled != null) return handled;
      }
    }

    // Pure single-character deletion (backspace).
    if (edit.deletedLength == 1 && edit.inserted.isEmpty && config.autoCloseBrackets) {
      final TextEditingValue? handled = _handleBracketPairDeletion(oldValue, edit);
      if (handled != null) return handled;
    }

    return newValue;
  }

  TextEditingValue _handleNewline(TextEditingValue oldValue, _Edit edit) {
    final String oldText = oldValue.text;
    final int insertAt = edit.prefix;

    final CodeDocument doc = CodeDocument(oldText);
    final ({int line, int column}) pos = doc.lineColumnAt(insertAt);
    final String currentLine = doc.lineAt(pos.line);
    final NewlineInsertion insertion = Indentation.computeNewlineInsertion(currentLine, pos.column, config);

    String before = oldText.substring(0, insertAt);
    if (config.smartSpaces && config.trimTrailingWhitespaceOnNewLine) {
      final int lastNewline = before.lastIndexOf('\n');
      final int lineStart = lastNewline + 1;
      final String linePart = before.substring(lineStart);
      final String trimmed = linePart.replaceFirst(RegExp(r'[ \t]+$'), '');
      if (trimmed.length != linePart.length) {
        before = before.substring(0, lineStart) + trimmed;
      }
    }

    final String after = oldText.substring(insertAt);
    final String text = before + insertion.text + after;
    final int caret = before.length + insertion.caretOffset;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  TextEditingValue? _handleAutoCloseOrTypeOver(
    TextEditingValue oldValue,
    _Edit edit,
  ) {
    final String c = edit.inserted;
    final String oldText = oldValue.text;
    final int prefix = edit.prefix;

    if (BracketUtils.isQuote(c)) {
      if (prefix < oldText.length && oldText[prefix] == c) {
        // Type-over: user typed the closing quote that's already there.
        return TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: prefix + 1),
        );
      }
      // Avoid auto-pairing a quote in the middle of an existing word,
      // e.g. typing the apostrophe in "don't".
      final bool precededByWordChar = prefix > 0 && RegExp(r'[A-Za-z0-9_]').hasMatch(oldText[prefix - 1]);
      if (precededByWordChar) return null;

      final String closing = BracketUtils.closingFor(c)!;
      final String text = oldText.substring(0, prefix) + c + closing + oldText.substring(prefix);
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: prefix + 1),
      );
    }

    if (BracketUtils.isOpener(c)) {
      final String closing = BracketUtils.closingFor(c)!;
      final String text = oldText.substring(0, prefix) + c + closing + oldText.substring(prefix);
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: prefix + 1),
      );
    }

    if (BracketUtils.isCloser(c)) {
      // Type-over: user typed a closing bracket that's already the next
      // character (the one we auto-inserted earlier).
      if (prefix < oldText.length && oldText[prefix] == c) {
        return TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: prefix + 1),
        );
      }
    }

    return null;
  }

  TextEditingValue? _handleBracketPairDeletion(
    TextEditingValue oldValue,
    _Edit edit,
  ) {
    final String oldText = oldValue.text;
    final int prefix = edit.prefix;
    if (prefix >= oldText.length) return null;

    final String deletedChar = oldText[prefix];
    final String? matchingClose = BracketUtils.closingFor(deletedChar);
    if (matchingClose == null) return null;
    if (prefix + 1 >= oldText.length) return null;
    if (oldText[prefix + 1] != matchingClose) return null;

    final String text = oldText.substring(0, prefix) + oldText.substring(prefix + 2);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: prefix),
    );
  }

  static _Edit? _diff(
    String oldText,
    String newText,
    TextSelection? newSelection,
  ) {
    if (oldText == newText) return null;

    final int maxPrefix = oldText.length < newText.length ? oldText.length : newText.length;
    int prefix = 0;
    while (prefix < maxPrefix && oldText[prefix] == newText[prefix]) {
      prefix++;
    }

    int oldEnd = oldText.length;
    int newEnd = newText.length;
    while (oldEnd > prefix && newEnd > prefix && oldText[oldEnd - 1] == newText[newEnd - 1]) {
      oldEnd--;
      newEnd--;
    }

    final int deletedLength = oldEnd - prefix;
    final int insertedLength = newEnd - prefix;

    // The longest-common-prefix/suffix diff above is ambiguous when the
    // edit involves repeated characters (e.g. "()" -> "())" could be read
    // as inserting ")" at index 1 or index 2 — both produce the same
    // string). That ambiguity matters for bracket type-over detection, so
    // when we have a reliable, collapsed cursor position for a pure
    // insertion, prefer the insertion point implied by the cursor.
    if (deletedLength == 0 &&
        insertedLength > 0 &&
        newSelection != null &&
        newSelection.isValid &&
        newSelection.isCollapsed) {
      final int cursor = newSelection.baseOffset;
      final int candidateStart = cursor - insertedLength;
      if (candidateStart >= 0 &&
          candidateStart + insertedLength <= newText.length &&
          candidateStart <= oldText.length &&
          oldText.substring(0, candidateStart) == newText.substring(0, candidateStart) &&
          oldText.substring(candidateStart) == newText.substring(candidateStart + insertedLength)) {
        prefix = candidateStart;
      }
    }

    return _Edit(
      prefix: prefix,
      inserted: newText.substring(prefix, prefix + insertedLength),
      deletedLength: deletedLength,
    );
  }
}

/// A minimal description of a single text edit: what got inserted (if
/// anything) starting at [prefix], and how many characters were removed
/// from that same position.
class _Edit {
  const _Edit({
    required this.prefix,
    required this.inserted,
    required this.deletedLength,
  });

  final int prefix;
  final String inserted;
  final int deletedLength;
}
