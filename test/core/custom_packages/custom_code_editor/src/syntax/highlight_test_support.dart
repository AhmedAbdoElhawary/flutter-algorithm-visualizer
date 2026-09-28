import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';

/// Tokenizes [lines] in order, carrying the state across, as the editor does.
List<List<Token>> tokenize(Tokenizer tokenizer, List<String> lines) {
  var state = tokenizer.initialState;
  return [
    for (final line in lines)
      () {
        final result = tokenizer.tokenizeLine(line, state);
        state = result.nextState;
        return result.tokens;
      }(),
  ];
}

/// `(type, text)` for every token on one line, which is what these tests compare.
List<(TokenType, String)> kinds(Tokenizer tokenizer, String line) =>
    tokenize(tokenizer, [line]).single.map((token) => (token.type, token.text)).toList();

/// The type of the one token spelled [text] on [line].
TokenType typeOf(Tokenizer tokenizer, String line, String text) =>
    tokenize(tokenizer, [line]).single.firstWhere((token) => token.text == text).type;
