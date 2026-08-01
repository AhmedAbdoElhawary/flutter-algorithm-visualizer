/// A pluggable, purely-optional formatting hook.
///
/// The editor core has **no** knowledge of any specific formatting
/// algorithm and no formatter is bundled by default. If you want
/// `controller.format()` to do something, provide a [CodeFormatter]
/// implementation for your language (e.g. calling out to `dart format`
/// via a platform channel, or a small in-process pretty-printer) and pass
/// it into [CodeEditor.formatter] / [CodeController.formatter].
///
/// Keeping this abstract and decoupled means the package stays small: it
/// never has to bundle a real Dart/Python formatter, which would be a
/// large, language-specific dependency.
abstract class CodeFormatter {
  const CodeFormatter();

  /// Returns a formatted version of [source].
  ///
  /// Implementations should be pure (no side effects) and should throw a
  /// descriptive exception if [source] cannot be formatted (e.g. a syntax
  /// error), rather than silently returning it unchanged.
  String format(String source);
}
