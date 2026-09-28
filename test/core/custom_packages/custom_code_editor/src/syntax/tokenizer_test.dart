import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

class _WordTokenizer extends Tokenizer {
  const _WordTokenizer();

  @override
  TokenizeResult tokenizeLine(String line, LineState state) => TokenizeResult(
        [Token(type: TokenType.plain, text: line, start: 0, end: line.length)],
        state,
      );
}

void main() {
  test('a tokenizer with no state of its own starts, and stays, stateless', () {
    const tokenizer = _WordTokenizer();

    expect(tokenizer.initialState, isA<StatelessLineState>());
    expect(tokenizer.tokenizeLine('x', tokenizer.initialState).nextState, isA<StatelessLineState>());
  });

  test('the cache key of a plain state is its type', () {
    expect(const StatelessLineState().cacheKey, 'StatelessLineState');
  });
}
