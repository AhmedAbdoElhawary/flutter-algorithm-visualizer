/// Behavioral configuration for [CodeEditor] / [CodeController].
///
/// This is a plain, immutable value object — there is deliberately no
/// hierarchy of config classes. Everything the editor's *behavior* (as
/// opposed to its *appearance*, see `CodeEditorTheme`) depends on lives
/// here.
class CodeEditorConfig {
  const CodeEditorConfig({
    this.tabSize = 4,
    this.useSpaces = true,
    this.autoIndent = true,
    this.autoCloseBrackets = true,
    this.smartSpaces = true,
    this.showLineNumbers = true,
    this.trimTrailingWhitespaceOnNewLine = true,
  });

  /// Number of spaces one indentation level represents.
  final int tabSize;

  /// Whether pressing the tab key / auto-indent inserts spaces (`true`,
  /// the default and recommended for mobile, since it behaves predictably
  /// across keyboards) or a literal `\t` character (`false`).
  final bool useSpaces;

  /// Whether pressing Enter preserves/increases/decreases indentation
  /// based on the previous line and surrounding brackets.
  final bool autoIndent;

  /// Whether typing an opening bracket/quote automatically inserts its
  /// matching closing character, and whether backspace removes an empty
  /// pair as a unit.
  final bool autoCloseBrackets;

  /// Whether the editor performs small "smart" whitespace adjustments,
  /// such as trimming trailing whitespace left behind on a line once the
  /// cursor moves off of it via Enter.
  final bool smartSpaces;

  /// Whether the line-number gutter is shown.
  final bool showLineNumbers;

  /// When [smartSpaces] is enabled, whether trailing whitespace on the
  /// line the cursor just left (because Enter was pressed) is stripped.
  final bool trimTrailingWhitespaceOnNewLine;

  /// The literal string inserted for one indentation level, honoring
  /// [useSpaces] and [tabSize].
  String get indentUnit => useSpaces ? ' ' * tabSize : '\t';

  CodeEditorConfig copyWith({
    int? tabSize,
    bool? useSpaces,
    bool? autoIndent,
    bool? autoCloseBrackets,
    bool? smartSpaces,
    bool? showLineNumbers,
    bool? trimTrailingWhitespaceOnNewLine,
  }) {
    return CodeEditorConfig(
      tabSize: tabSize ?? this.tabSize,
      useSpaces: useSpaces ?? this.useSpaces,
      autoIndent: autoIndent ?? this.autoIndent,
      autoCloseBrackets: autoCloseBrackets ?? this.autoCloseBrackets,
      smartSpaces: smartSpaces ?? this.smartSpaces,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      trimTrailingWhitespaceOnNewLine:
          trimTrailingWhitespaceOnNewLine ?? this.trimTrailingWhitespaceOnNewLine,
    );
  }
}
