import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

const _treeNodeSource = '''
class TreeNode {
  int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode([this.val = 0, this.left, this.right]);
}
''';

ProblemData _problem({
  required String signature,
  required List<ProblemTestCase> cases,
  OutputComparison comparison = OutputComparison.exact,
  bool tree = false,
}) {
  return ProblemData(
    functionSignature: signature,
    testCases: cases,
    customObjects: tree ? const {'TreeNode': CustomObjectShape.binaryTree} : const {},
    customObjectSources: tree ? const [_treeNodeSource] : const [],
    comparison: comparison,
  );
}

void main() {
  group('binary tree test cases use LeetCode level-order', () {
    test('a null child claims no slots of its own, so a left chain is 4 deep', () {
      // In the old heap layout (children at 2i+1 / 2i+2) this same array is
      // only 3 deep, because index 5's parent is the `null` at index 2.
      final result = const ProblemRunner().runAll(
        problem: _problem(
          signature: 'int maxDepth(TreeNode? root)',
          tree: true,
          cases: const [ProblemTestCase(input: 'root=[1,2,null,3,null,4]', expectedOutput: '4')],
        ),
        userCode: '''
int maxDepth(TreeNode? root) {
  if (root == null) return 0;
  final l = maxDepth(root.left);
  final r = maxDepth(root.right);
  return 1 + (l > r ? l : r);
}
''',
      );

      expect(result.error, isNull);
      expect(result.testCaseResults.single.actualOutput, '4');
      expect(result.allPassed, isTrue);
    });

    test('a returned tree serializes back into the same level-order array', () {
      final result = const ProblemRunner().runAll(
        problem: _problem(
          signature: 'TreeNode? invertTree(TreeNode? root)',
          tree: true,
          cases: const [
            ProblemTestCase(input: 'root=[1,2,null,3]', expectedOutput: '[1,null,2,null,3]'),
          ],
        ),
        userCode: '''
TreeNode? invertTree(TreeNode? root) {
  if (root == null) return null;
  final left = invertTree(root.left);
  final right = invertTree(root.right);
  root.left = right;
  root.right = left;
  return root;
}
''',
      );

      expect(result.error, isNull);
      expect(result.allPassed, isTrue);
    });
  });

  group('OutputComparison', () {
    const subsetsCode = '''
List<List<int>> subsets(List<int> nums) {
  final res = <List<int>>[];
  res.add(<int>[]);
  for (var i = 0; i < nums.length; i++) {
    final size = res.length;
    for (var j = 0; j < size; j++) {
      final copy = <int>[];
      for (var k = 0; k < res[j].length; k++) {
        copy.add(res[j][k]);
      }
      copy.add(nums[i]);
      res.add(copy);
    }
  }
  return res;
}
''';

    // The expected output lists the same subsets in a different (also correct)
    // order than the code above produces.
    const shuffledExpected = ProblemTestCase(
      input: 'nums=[1,2]',
      expectedOutput: '[[1,2],[2],[],[1]]',
    );

    test('exact mode fails a correct answer that is ordered differently', () {
      final result = const ProblemRunner().runAll(
        problem: _problem(
          signature: 'List<List<int>> subsets(List<int> nums)',
          cases: const [shuffledExpected],
        ),
        userCode: subsetsCode,
      );

      expect(result.allPassed, isFalse);
    });

    test('unordered mode passes it', () {
      final result = const ProblemRunner().runAll(
        problem: _problem(
          signature: 'List<List<int>> subsets(List<int> nums)',
          cases: const [shuffledExpected],
          comparison: OutputComparison.unordered,
        ),
        userCode: subsetsCode,
      );

      expect(result.error, isNull);
      expect(result.allPassed, isTrue);
    });

    test('unordered mode still fails a genuinely wrong answer', () {
      final result = const ProblemRunner().runAll(
        problem: _problem(
          signature: 'List<List<int>> subsets(List<int> nums)',
          cases: const [
            // `[2,1]` is not a subset this problem should ever emit, and `[1]`
            // is missing: reordering must not rescue that.
            ProblemTestCase(input: 'nums=[1,2]', expectedOutput: '[[],[2],[2,1],[1,2]]'),
          ],
          comparison: OutputComparison.unordered,
        ),
        userCode: subsetsCode,
      );

      expect(result.allPassed, isFalse);
    });

    test('unordered does not reorder within an element, unorderedDeep does', () {
      const code = '''
List<List<int>> f(List<int> nums) {
  return [[1, 2]];
}
''';
      ProblemData build(OutputComparison mode) => _problem(
            signature: 'List<List<int>> f(List<int> nums)',
            cases: const [ProblemTestCase(input: 'nums=[0]', expectedOutput: '[[2,1]]')],
            comparison: mode,
          );

      expect(
          const ProblemRunner().runAll(problem: build(OutputComparison.unordered), userCode: code).allPassed,
          isFalse);
      expect(
          const ProblemRunner()
              .runAll(problem: build(OutputComparison.unorderedDeep), userCode: code)
              .allPassed,
          isTrue);
    });
  });

  group('a number is graded as a number, not as the way a language prints it', () {
    // JavaScript has one number type, so a correct median of 2 comes back as
    // `2` where the stored answer says `2.0`. Failing that is a grader bug,
    // not a learner's wrong answer.
    ProblemData problem(String expected) => _problem(
          signature: 'double half(int n)',
          cases: [ProblemTestCase(input: 'n=4', expectedOutput: expected)],
        );

    test('a whole double matches the integer spelling of the same value', () {
      const code = 'double half(int n) { return n / 2; }';
      expect(const ProblemRunner().runAll(problem: problem('2.0'), userCode: code).allPassed, isTrue);
      expect(const ProblemRunner().runAll(problem: problem('2'), userCode: code).allPassed, isTrue);
    });

    test('a genuinely different number still fails', () {
      const code = 'double half(int n) { return n / 2; }';
      expect(const ProblemRunner().runAll(problem: problem('2.5'), userCode: code).allPassed, isFalse);
      expect(const ProblemRunner().runAll(problem: problem('3'), userCode: code).allPassed, isFalse);
    });

    test('a fraction is never rounded away', () {
      const code = 'double half(int n) { return n / 8; }';
      expect(const ProblemRunner().runAll(problem: problem('0.5'), userCode: code).allPassed, isTrue);
      expect(const ProblemRunner().runAll(problem: problem('0'), userCode: code).allPassed, isFalse);
    });
  });
}
