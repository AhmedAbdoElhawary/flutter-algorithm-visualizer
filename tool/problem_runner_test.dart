import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/custom_object_shape.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/problem_runner.dart';
import 'package:flutter/foundation.dart' show debugPrint;

const listNodeSource = '''
class ListNode {
  int val;
  ListNode? next;
  ListNode([this.val = 0, this.next]);
}
''';

const treeNodeSource = '''
class TreeNode {
  int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode([this.val = 0, this.left, this.right]);
}
''';

void main() {
  // 1. Two Sum
  grade(
      'Two Sum',
      const ProblemData(
        functionSignature: 'List<int> twoSum(List<int> nums, int target)',
        testCases: [
          ProblemTestCase(input: 'nums=[2,7,11,15], target=9', expectedOutput: '[0,1]'),
          ProblemTestCase(input: 'nums=[1,5,3,8], target=11', expectedOutput: '[2,3]'),
        ],
      ),
      '''
List<int> twoSum(List<int> nums, int target) {
  final seen = <int, int>{};
  for (int i = 0; i < nums.length; i++) {
    final comp = target - nums[i];
    if (seen.containsKey(comp)) return [seen[comp], i];
    seen[nums[i]] = i;
  }
  return [];
}
''');

  // 2. Contains Duplicate
  grade(
      'Contains Duplicate',
      const ProblemData(
        functionSignature: 'bool containsDuplicate(List<int> nums)',
        testCases: [
          ProblemTestCase(input: 'nums=[1,2,3,1]', expectedOutput: 'true'),
          ProblemTestCase(input: 'nums=[1,2,3,4]', expectedOutput: 'false'),
        ],
      ),
      '''
bool containsDuplicate(List<int> nums) {
  final set = <int>{};
  for (final n in nums) {
    if (set.contains(n)) return true;
    set.add(n);
  }
  return false;
}
''');

  // 3. Merge Two Sorted Lists (custom object)
  grade(
      'Merge Two Sorted Lists',
      const ProblemData(
        functionSignature: 'ListNode? mergeTwoLists(ListNode? list1, ListNode? list2)',
        customObjects: {'ListNode': CustomObjectShape.linkedList},
        customObjectSources: [listNodeSource],
        testCases: [
          ProblemTestCase(input: 'list1=[1,2,4], list2=[1,3,4]', expectedOutput: '[1,1,2,3,4,4]'),
          ProblemTestCase(input: 'list1=[], list2=[]', expectedOutput: '[]'),
          ProblemTestCase(input: 'list1=[], list2=[0]', expectedOutput: '[0]'),
        ],
      ),
      '''
ListNode? mergeTwoLists(ListNode? list1, ListNode? list2) {
  final dummy = ListNode();
  var tail = dummy;
  while (list1 != null && list2 != null) {
    if (list1.val < list2.val) {
      tail.next = list1;
      list1 = list1.next;
    } else {
      tail.next = list2;
      list2 = list2.next;
    }
    tail = tail.next;
  }
  tail.next = list1 ?? list2;
  return dummy.next;
}
''');

  // 4. Reverse String (void, List<String> in-place)
  grade(
      'Reverse String',
      const ProblemData(
        functionSignature: 'void reverseString(List<String> s)',
        testCases: [
          ProblemTestCase(input: 's=["h","e","l","l","o"]', expectedOutput: '["o","l","l","e","h"]'),
          ProblemTestCase(
              input: 's=["H","a","n","n","a","h"]', expectedOutput: '["h","a","n","n","a","H"]'),
        ],
      ),
      '''
void reverseString(List<String> s) {
  int i = 0;
  int j = s.length - 1;
  while (i < j) {
    final t = s[i];
    s[i] = s[j];
    s[j] = t;
    i++;
    j--;
  }
}
''');

  // 5. Move Zeroes (void, List<int> in-place)
  grade(
      'Move Zeroes',
      const ProblemData(
        functionSignature: 'void moveZeroes(List<int> nums)',
        testCases: [
          ProblemTestCase(input: 'nums=[0,1,0,3,12]', expectedOutput: '[1,3,12,0,0]'),
          ProblemTestCase(input: 'nums=[0]', expectedOutput: '[0]'),
        ],
      ),
      '''
void moveZeroes(List<int> nums) {
  var write = 0;
  for (final n in nums) {
    if (n != 0) {
      nums[write] = n;
      write++;
    }
  }
  while (write < nums.length) {
    nums[write] = 0;
    write++;
  }
}
''');

  // 6. Reorder List (void, custom object in-place)
  grade(
      'Reorder List',
      const ProblemData(
        functionSignature: 'void reorderList(ListNode? head)',
        customObjects: {'ListNode': CustomObjectShape.linkedList},
        customObjectSources: [listNodeSource],
        testCases: [
          ProblemTestCase(input: 'head=[1,2,3,4]', expectedOutput: '[1,4,2,3]'),
          ProblemTestCase(input: 'head=[1,2,3,4,5]', expectedOutput: '[1,5,2,4,3]'),
        ],
      ),
      '''
void reorderList(ListNode? head) {
  if (head == null) return;
  final nodes = <ListNode>[];
  var cur = head;
  while (cur != null) {
    nodes.add(cur);
    cur = cur.next;
  }
  var i = 0;
  var j = nodes.length - 1;
  while (i < j) {
    nodes[i].next = nodes[j];
    i++;
    if (i == j) break;
    nodes[j].next = nodes[i];
    j--;
  }
  nodes[i].next = null;
}
''');

  // 7. Is Same Tree (TreeNode params, bool return)
  grade(
      'Is Same Tree',
      const ProblemData(
        functionSignature: 'bool isSameTree(TreeNode? p, TreeNode? q)',
        customObjects: {'TreeNode': CustomObjectShape.binaryTree},
        customObjectSources: [treeNodeSource],
        testCases: [
          ProblemTestCase(input: 'p=[1,2,3], q=[1,2,3]', expectedOutput: 'true'),
          ProblemTestCase(input: 'p=[1,2], q=[1,null,2]', expectedOutput: 'false'),
          ProblemTestCase(input: 'p=[1,2,1], q=[1,1,2]', expectedOutput: 'false'),
        ],
      ),
      '''
bool isSameTree(TreeNode? p, TreeNode? q) {
  if (p == null && q == null) return true;
  if (p == null || q == null) return false;
  if (p.val != q.val) return false;
  return isSameTree(p.left, q.left) && isSameTree(p.right, q.right);
}
''');

  // 8. Max Depth of Binary Tree
  grade(
      'Max Depth',
      const ProblemData(
        functionSignature: 'int maxDepth(TreeNode? root)',
        customObjects: {'TreeNode': CustomObjectShape.binaryTree},
        customObjectSources: [treeNodeSource],
        testCases: [
          ProblemTestCase(input: 'root=[3,9,20,null,null,15,7]', expectedOutput: '3'),
          ProblemTestCase(input: 'root=[1,null,2]', expectedOutput: '2'),
          ProblemTestCase(input: 'root=[]', expectedOutput: '0'),
        ],
      ),
      '''
int maxDepth(TreeNode? root) {
  if (root == null) return 0;
  final l = maxDepth(root.left);
  final r = maxDepth(root.right);
  return (l > r ? l : r) + 1;
}
''');

  // 9. Merge K Sorted Lists (List<ListNode?> param)
  grade(
      'Merge K Sorted Lists',
      const ProblemData(
        functionSignature: 'ListNode? mergeKLists(List<ListNode?> lists)',
        customObjects: {'ListNode': CustomObjectShape.linkedList},
        customObjectSources: [listNodeSource],
        testCases: [
          ProblemTestCase(input: 'lists=[[1,4,5],[1,3,4],[2,6]]', expectedOutput: '[1,1,2,3,4,4,5,6]'),
          ProblemTestCase(input: 'lists=[]', expectedOutput: '[]'),
          ProblemTestCase(input: 'lists=[[]]', expectedOutput: '[]'),
        ],
      ),
      '''
ListNode? mergeKLists(List<ListNode?> lists) {
  if (lists.isEmpty) return null;
  ListNode? dummy = ListNode();
  final head = dummy;
  var any = true;
  while (any) {
    any = false;
    var best = -1;
    for (int i = 0; i < lists.length; i++) {
      if (lists[i] != null && (best == -1 || lists[i]!.val < lists[best]!.val)) {
        best = i;
        any = true;
      }
    }
    if (best != -1) {
      dummy.next = lists[best];
      dummy = dummy.next;
      lists[best] = lists[best]!.next;
    }
  }
  return head.next;
}
''');
}

void grade(String name, ProblemData problem, String userCode) {
  final result = const ProblemRunner().runAll(problem: problem, userCode: userCode);
  final status = result.allPassed ? 'PASS' : 'FAIL';
  debugPrint('$status: $name (${result.passedCount}/${result.totalCount})');
  if (!result.allPassed) {
    for (final r in result.testCaseResults) {
      if (!r.passed) {
        debugPrint('   input: ${r.testCase.input}');
        debugPrint('   expected: ${r.testCase.expectedOutput}');
        debugPrint('   actual:   ${r.actualOutput}');
        if (r.errorMessage != null) debugPrint('   error: ${r.errorMessage}');
      }
    }
  }
}
