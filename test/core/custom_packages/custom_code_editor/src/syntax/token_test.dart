import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const token = Token(type: TokenType.keyword, text: 'int', start: 0, end: 3);

  test('tokens with the same type, text and place are equal', () {
    const same = Token(type: TokenType.keyword, text: 'int', start: 0, end: 3);

    expect(token, same);
    expect(token.hashCode, same.hashCode);
    expect(token, isNot(const Token(type: TokenType.builtin, text: 'int', start: 0, end: 3)));
    expect(token, isNot(const Token(type: TokenType.keyword, text: 'int', start: 4, end: 7)));
  });

  test('prints what it is and where', () {
    expect(token.toString(), 'Token(TokenType.keyword, "int", 0-3)');
  });
}
