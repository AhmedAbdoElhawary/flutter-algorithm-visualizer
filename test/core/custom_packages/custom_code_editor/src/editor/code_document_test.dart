import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/editor/code_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final doc = CodeDocument('int a;\n  return a;\n}');

  test('splits into lines', () {
    expect(doc.lines, ['int a;', '  return a;', '}']);
    expect(doc.lineCount, 3);
    expect(doc.lineAt(1), '  return a;');
  });

  test('an empty document is one empty line, and a trailing newline adds one', () {
    expect(CodeDocument('').lines, ['']);
    expect(CodeDocument('a\n').lineCount, 2);
  });

  test('an offset becomes a line and a column', () {
    expect(doc.lineColumnAt(0), (line: 0, column: 0));
    expect(doc.lineColumnAt(6), (line: 0, column: 6), reason: 'the end of a line is still on it');
    expect(doc.lineColumnAt(7), (line: 1, column: 0));
    expect(doc.lineColumnAt(doc.text.length), (line: 2, column: 1));
  });

  test('an offset past the end lands at the end of the last line', () {
    expect(doc.lineColumnAt(999), (line: 2, column: 1));
  });

  test('a line and a column become the same offset back', () {
    for (var offset = 0; offset <= doc.text.length; offset++) {
      final position = doc.lineColumnAt(offset);
      expect(doc.offsetAt(position.line, position.column), offset);
    }
  });
}
