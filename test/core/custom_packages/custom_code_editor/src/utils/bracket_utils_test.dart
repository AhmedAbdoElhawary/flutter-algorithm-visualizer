import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/utils/bracket_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brackets and quotes pair with their closer', () {
    expect(BracketUtils.closingFor('('), ')');
    expect(BracketUtils.closingFor('['), ']');
    expect(BracketUtils.closingFor('{'), '}');
    expect(BracketUtils.closingFor('"'), '"');
    expect(BracketUtils.closingFor("'"), "'");
    expect(BracketUtils.closingFor('a'), isNull);
  });

  test('< is not paired, it is almost always less-than', () {
    expect(BracketUtils.closingFor('<'), isNull);
    expect(BracketUtils.isOpener('<'), isFalse);
    expect(BracketUtils.isCloser('>'), isFalse);
  });

  test('openers, closers and quotes', () {
    expect(BracketUtils.isOpener('('), isTrue);
    expect(BracketUtils.isOpener(')'), isFalse);
    expect(BracketUtils.isCloser('}'), isTrue);
    expect(BracketUtils.isCloser('{'), isFalse);
    expect(BracketUtils.isQuote('"'), isTrue);
    expect(BracketUtils.isQuote("'"), isTrue);
    expect(BracketUtils.isQuote('`'), isFalse);
    expect(BracketUtils.quotes, {'"', "'"});
  });

  test('a matching pair, and a mismatched one', () {
    expect(BracketUtils.isMatchingPair('(', ')'), isTrue);
    expect(BracketUtils.isMatchingPair('(', ']'), isFalse);
  });
}
