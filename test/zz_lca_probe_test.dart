import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/custom_object_shape.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/problem_runner.dart';
import 'package:flutter/foundation.dart' show debugPrint;

const treeNodeSource = '''
class TreeNode {
  int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode([this.val = 0, this.left, this.right]);
}
''';

void main() {
  grade('LCA', ProblemData(
    functionSignature: 'TreeNode? lowestCommonAncestor(TreeNode? root, TreeNode? p, TreeNode? q)',
    customObjects: const {'TreeNode': CustomObjectShape.binaryTree},
    customObjectSources: const [treeNodeSource],
    testCases: const [
      ProblemTestCase(input: 'root=[6,2,8,0,4,7,9,null,null,3,5], p=2, q=8', expectedOutput: '6'),
      ProblemTestCase(input: 'root=[6,2,8,0,4,7,9,null,null,3,5], p=0, q=5', expectedOutput: '2'),
    ],
  ), '''
TreeNode? lowestCommonAncestor(TreeNode? root, int p, int q) {
  var cur = root;
  while (cur != null) {
    if (cur.val < p && cur.val < q) {
      cur = cur.right;
    } else if (cur.val > p && cur.val > q) {
      cur = cur.left;
    } else {
      return cur;
    }
  }
  return null;
}
''');
}

void grade(String name, ProblemData problem, String userCode) {
  final result = const ProblemRunner().runAll(problem: problem, userCode: userCode);
  final status = result.allPassed ? 'PASS' : 'FAIL';
  debugPrint('$status: $name (${result.passedCount}/${result.totalCount})');
  for (final r in result.testCaseResults) {
    debugPrint('   input: ${r.testCase.input}');
    debugPrint('   expected: ${r.testCase.expectedOutput}');
    debugPrint('   actual:   ${r.actualOutput}');
    if (r.errorMessage != null) debugPrint('   error: ${r.errorMessage}');
  }
}
