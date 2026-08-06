import '../models/code_editor_config.dart';

/// Pure functions for computing indentation. Kept free of any
/// [TextEditingController] / widget concerns so they're trivial to unit
/// test in isolation.
class Indentation {
  const Indentation._();

  static const String _openBrackets = '({[';
  static const String _closeBrackets = ')}]';

  /// Returns the leading whitespace of [line] (its current indentation).
  static String leadingWhitespaceOf(String line) {
    final RegExpMatch? match = RegExp(r'^[ \t]*').firstMatch(line);
    return match?.group(0) ?? '';
  }

  /// Computes the whitespace that should be inserted after the user
  /// presses Enter at [cursorColumn] within [currentLine].
  ///
  /// Rules:
  /// - Start from the current line's indentation.
  /// - If the last non-whitespace character before the cursor is an
  ///   opening bracket, increase indentation by one level.
  /// - If the cursor sits between a just-typed opening bracket and its
  ///   matching closing bracket (e.g. `{|}`), the closing bracket is
  ///   pushed to its own de-indented line and the returned "between"
  ///   indent is one level deeper than that — callers should special-case
  ///   this via [computeNewlineInsertion].
  static String nextLineIndent(
    String currentLine,
    int cursorColumn,
    CodeEditorConfig config,
  ) {
    final String before = currentLine.substring(0, cursorColumn);
    final String base = leadingWhitespaceOf(currentLine);
    final String trimmedBefore = before.trimRight();

    if (trimmedBefore.isNotEmpty && _openBrackets.contains(trimmedBefore[trimmedBefore.length - 1])) {
      return base + config.indentUnit;
    }
    return base;
  }

  /// Describes what should be inserted when the user presses Enter.
  ///
  /// Returns the full replacement text to insert at the cursor (which may
  /// contain more than one `\n`, e.g. when splitting `{|}` into three
  /// lines), plus the offset — relative to the start of the inserted
  /// text — where the cursor should end up afterwards.
  static NewlineInsertion computeNewlineInsertion(
    String currentLine,
    int cursorColumn,
    CodeEditorConfig config,
  ) {
    if (!config.autoIndent) {
      return const NewlineInsertion(text: '\n', caretOffset: 1);
    }

    final String before = currentLine.substring(0, cursorColumn);
    final String after = currentLine.substring(cursorColumn);
    final String trimmedBefore = before.trimRight();
    final String trimmedAfter = after.trimLeft();

    final bool beforeEndsWithOpen =
        trimmedBefore.isNotEmpty && _openBrackets.contains(trimmedBefore[trimmedBefore.length - 1]);
    final bool afterStartsWithMatchingClose = trimmedAfter.isNotEmpty &&
        _closeBrackets.contains(trimmedAfter[0]) &&
        beforeEndsWithOpen &&
        _matches(
          trimmedBefore[trimmedBefore.length - 1],
          trimmedAfter[0],
        );

    final String base = leadingWhitespaceOf(currentLine);

    if (afterStartsWithMatchingClose) {
      // `{|}` -> split into three lines:
      // {
      //   |
      // }
      final String innerIndent = base + config.indentUnit;
      final String text = '\n$innerIndent\n$base';
      return NewlineInsertion(text: text, caretOffset: 1 + innerIndent.length);
    }

    final String indent = beforeEndsWithOpen ? base + config.indentUnit : base;
    final String text = '\n$indent';
    return NewlineInsertion(text: text, caretOffset: text.length);
  }

  static bool _matches(String open, String close) {
    switch (open) {
      case '(':
        return close == ')';
      case '{':
        return close == '}';
      case '[':
        return close == ']';
      default:
        return false;
    }
  }
}

/// The result of [Indentation.computeNewlineInsertion]: the text to
/// insert in place of a plain `\n`, and where within that text the caret
/// should land.
class NewlineInsertion {
  const NewlineInsertion({required this.text, required this.caretOffset});

  final String text;
  final int caretOffset;
}
