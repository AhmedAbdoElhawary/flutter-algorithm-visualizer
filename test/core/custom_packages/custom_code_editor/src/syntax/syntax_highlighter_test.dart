import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts how many lines the highlighter actually hands to the tokenizer.
class _CountingTokenizer extends Tokenizer {
  _CountingTokenizer();

  final DartTokenizer _dart = const DartTokenizer();
  var calls = 0;

  @override
  LineState get initialState => _dart.initialState;

  @override
  TokenizeResult tokenizeLine(String line, LineState state) {
    calls++;
    return _dart.tokenizeLine(line, state);
  }
}

void main() {
  late _CountingTokenizer tokenizer;
  late SyntaxHighlighter highlighter;

  setUp(() {
    tokenizer = _CountingTokenizer();
    highlighter = SyntaxHighlighter(tokenizer);
  });

  List<TokenType> typesOn(List<List<Token>> lines, int line) => lines[line].map((t) => t.type).toList();

  test('each line gets its tokens', () {
    final lines = highlighter.highlight(['int a = 1;', '// done']);

    expect(typesOn(lines, 0).first, TokenType.builtin);
    expect(typesOn(lines, 1), [TokenType.comment]);
  });

  test('the same text again is not tokenized again', () {
    final first = highlighter.highlight(['int a;', 'int b;']);
    final calls = tokenizer.calls;

    expect(highlighter.highlight(['int a;', 'int b;']), same(first));
    expect(tokenizer.calls, calls);
  });

  test('an edit re-tokenizes from the edited line and stops once the rest is unchanged', () {
    final lines = List.generate(50, (i) => 'int v$i = $i;');
    highlighter.highlight(lines);
    highlighter.reset();
    highlighter.highlight(lines);
    tokenizer.calls = 0;

    final edited = [...lines]..[10] = 'int changed = 0;';
    highlighter.highlight(edited);

    expect(tokenizer.calls, lessThanOrEqualTo(2));
  });

  test('opening a block comment recolours every line after it', () {
    highlighter.highlight(['int a;', 'int b;', 'int c;']);

    final lines = highlighter.highlight(['/* int a;', 'int b;', 'int c;']);

    expect(typesOn(lines, 1), [TokenType.comment]);
    expect(typesOn(lines, 2), [TokenType.comment]);
  });

  test('adding and removing lines keeps every line right', () {
    highlighter.highlight(['int a;', 'int b;']);

    final grown = highlighter.highlight(['int a;', '// new', 'int b;']);
    expect(typesOn(grown, 1), [TokenType.comment]);
    expect(typesOn(grown, 2).first, TokenType.builtin);

    final shrunk = highlighter.highlight(['int b;']);
    expect(shrunk, hasLength(1));
    expect(typesOn(shrunk, 0).first, TokenType.builtin);
  });

  test('a line seen before in the same state comes from the cache', () {
    highlighter.highlight(['int a;']);
    highlighter.highlight(['x']);
    tokenizer.calls = 0;

    highlighter.highlight(['int a;']);

    expect(tokenizer.calls, 0);
  });

  test('reset forgets everything', () {
    highlighter.highlight(['int a;']);
    highlighter.reset();
    tokenizer.calls = 0;

    highlighter.highlight(['int a;']);

    expect(tokenizer.calls, 1);
  });

  test('a huge document empties the cache instead of growing without end', () {
    highlighter.highlight([for (var i = 0; i < 7000; i++) 'int v$i;']);
    tokenizer.calls = 0;

    // A new first line, so `int v0;` has to come from the cache, which was emptied when it filled up.
    highlighter.highlight(['x', 'int v0;']);

    expect(tokenizer.calls, 2);
  });
}
