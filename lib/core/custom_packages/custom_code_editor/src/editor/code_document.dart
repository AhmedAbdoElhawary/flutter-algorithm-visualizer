/// A thin, immutable-ish wrapper around a document's source text that
/// provides cheap access to it as individual lines.
///
/// [CodeController] holds one [CodeDocument] and replaces it wholesale on
/// every text change (cheap: it's just a String + a lazily-computed line
/// list). Keeping this separate from [CodeController] means the
/// line-splitting logic — and any future document-level concerns like
/// line-ending normalization — has a single, testable home.
class CodeDocument {
  CodeDocument(this.text) : _lines = text.split('\n');

  /// The full document text.
  final String text;

  final List<String> _lines;

  /// The document split into lines. `\n` is the line separator; the
  /// returned list therefore has `text.split('\n').length` entries, same
  /// as calling `text.split('\n')` directly, but computed once.
  List<String> get lines => _lines;

  int get lineCount => _lines.length;

  String lineAt(int index) => _lines[index];

  /// Converts a flat character [offset] into a `(line, column)` pair.
  ({int line, int column}) lineColumnAt(int offset) {
    int remaining = offset;
    for (int i = 0; i < _lines.length; i++) {
      final int lineLength = _lines[i].length;
      if (remaining <= lineLength) {
        return (line: i, column: remaining);
      }
      remaining -= lineLength + 1; // +1 for the '\n'
    }
    final int lastIndex = _lines.length - 1;
    return (line: lastIndex, column: _lines[lastIndex].length);
  }

  /// Converts a `(line, column)` pair back into a flat character offset.
  int offsetAt(int line, int column) {
    int offset = 0;
    for (int i = 0; i < line; i++) {
      offset += _lines[i].length + 1;
    }
    return offset + column;
  }
}
