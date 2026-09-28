import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the name, the return type and each parameter', () {
    final signature = parseFunctionSignature('List<int> twoSum(List<int> nums, int target)');

    expect(signature.name, 'twoSum');
    expect(signature.returnType, 'List<int>');
    expect(signature.params.map((p) => (p.type, p.name)), [('List<int>', 'nums'), ('int', 'target')]);
    expect(signature.isVoid, isFalse);
  });

  test('nullable types, and a function with no parameters', () {
    expect(parseFunctionSignature('int maxDepth(TreeNode? root)').params.single.type, 'TreeNode?');
    expect(parseFunctionSignature('int answer()').params, isEmpty);
  });

  test('a void function is known as void', () {
    expect(parseFunctionSignature('void rotate(List<int> nums, int k)').isVoid, isTrue);
  });

  test('a name with no return type', () {
    final signature = parseFunctionSignature('solve(a)');

    expect(signature.name, 'solve');
    expect(signature.returnType, isEmpty);
  });

  test('a signature with no parentheses is refused, never guessed', () {
    expect(() => parseFunctionSignature('int twoSum'), throwsFormatException);
    expect(() => parseFunctionSignature('int twoSum(int a'), throwsFormatException);
  });
}
