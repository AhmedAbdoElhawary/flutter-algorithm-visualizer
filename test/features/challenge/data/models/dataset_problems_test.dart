import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// Known-correct Dart solutions, used to prove that the stored expected outputs
/// in `assets/problems.json` are what a real correct solution actually produces
/// when run through the real grader (not just through an offline model of it).
///
/// The sample deliberately covers every output shape the dataset uses: int,
/// `bool`, `double`, `String`, `List<int>`, `List<List<int>>`, `List<String>`, a linked
/// list, a tree, and an in-place (`void`) function.
const _solutions = <int, String>{
  1: '''
List<int> twoSum(List<int> nums, int target) {
  for (var i = 0; i < nums.length; i++) {
    for (var j = i + 1; j < nums.length; j++) {
      if (nums[i] + nums[j] == target) return [i, j];
    }
  }
  return [];
}
''',
  4: '''
double findMedianSortedArrays(List<int> nums1, List<int> nums2) {
  // Merged by hand: the on-device interpreter has no List.sort.
  final all = <int>[];
  var i = 0;
  var j = 0;
  while (i < nums1.length || j < nums2.length) {
    if (j >= nums2.length || (i < nums1.length && nums1[i] <= nums2[j])) {
      all.add(nums1[i]);
      i++;
    } else {
      all.add(nums2[j]);
      j++;
    }
  }
  final n = all.length;
  if (n % 2 == 1) return all[n ~/ 2] + 0.0;
  return (all[n ~/ 2 - 1] + all[n ~/ 2]) / 2.0;
}
''',
  9: '''
bool isValid(String s) {
  final st = <String>[];
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '(' || c == '[' || c == '{') {
      st.add(c);
    } else {
      if (st.isEmpty) return false;
      final open = st.removeLast();
      if (c == ')' && open != '(') return false;
      if (c == ']' && open != '[') return false;
      if (c == '}' && open != '{') return false;
    }
  }
  return st.isEmpty;
}
''',
  10: '''
ListNode? mergeTwoLists(ListNode? list1, ListNode? list2) {
  final dummy = ListNode(0);
  var tail = dummy;
  var a = list1;
  var b = list2;
  while (a != null && b != null) {
    if (a.val <= b.val) {
      tail.next = a;
      a = a.next;
    } else {
      tail.next = b;
      b = b.next;
    }
    tail = tail.next!;
  }
  tail.next = a ?? b;
  return dummy.next;
}
''',
  28: '''
String minWindow(String s, String t) {
  if (s.length < t.length || t.isEmpty) return '';
  final need = <String, int>{};
  for (var i = 0; i < t.length; i++) {
    need[t[i]] = (need[t[i]] ?? 0) + 1;
  }
  var missing = t.length;
  var best = -1;
  var bi = 0;
  var lo = 0;
  for (var hi = 0; hi < s.length; hi++) {
    final c = s[hi];
    final have = need[c] ?? 0;
    if (have > 0) missing--;
    need[c] = have - 1;
    if (missing == 0) {
      while ((need[s[lo]] ?? 0) < 0) {
        need[s[lo]] = (need[s[lo]] ?? 0) + 1;
        lo++;
      }
      if (best == -1 || hi - lo + 1 < best) {
        best = hi - lo + 1;
        bi = lo;
      }
    }
  }
  return best == -1 ? '' : s.substring(bi, bi + best);
}
''',
  29: '''
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
''',
  39: '''
int maxDepth(TreeNode? root) {
  if (root == null) return 0;
  final l = maxDepth(root.left);
  final r = maxDepth(root.right);
  return 1 + (l > r ? l : r);
}
''',
  54: '''
bool hasCycle(List<int> next) {
  if (next.isEmpty) return false;
  var slow = 0;
  var fast = 0;
  while (true) {
    if (fast == -1) return false;
    fast = next[fast];
    if (fast == -1) return false;
    fast = next[fast];
    if (fast == -1) return false;
    slow = next[slow];
    if (slow == fast) return true;
  }
}
''',
  72: '''
TreeNode? invertTree(TreeNode? root) {
  if (root == null) return null;
  final left = invertTree(root.left);
  final right = invertTree(root.right);
  root.left = right;
  root.right = left;
  return root;
}
''',
  80: '''
int firstBadVersion(List<bool> versions) {
  var lo = 0;
  var hi = versions.length - 1;
  while (lo < hi) {
    final mid = lo + (hi - lo) ~/ 2;
    if (versions[mid]) {
      hi = mid;
    } else {
      lo = mid + 1;
    }
  }
  return lo + 1;
}
''',
  81: '''
void moveZeroes(List<int> nums) {
  var w = 0;
  for (var i = 0; i < nums.length; i++) {
    if (nums[i] != 0) {
      nums[w] = nums[i];
      w++;
    }
  }
  while (w < nums.length) {
    nums[w] = 0;
    w++;
  }
}
''',
  95: '''
int search(List<int> nums, int target) {
  var lo = 0;
  var hi = nums.length - 1;
  while (lo <= hi) {
    final mid = (lo + hi) ~/ 2;
    if (nums[mid] == target) return mid;
    if (nums[mid] < target) {
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }
  return -1;
}
''',
  96: '''
List<int> dailyTemperatures(List<int> temperatures) {
  final out = <int>[];
  for (var i = 0; i < temperatures.length; i++) {
    out.add(0);
  }
  final st = <int>[];
  for (var i = 0; i < temperatures.length; i++) {
    while (st.isNotEmpty && temperatures[st[st.length - 1]] < temperatures[i]) {
      final j = st.removeLast();
      out[j] = i - j;
    }
    st.add(i);
  }
  return out;
}
''',
};

void main() {
  late Map<int, ProblemDTO> problems;

  setUpAll(() {
    final raw = File('assets/problems.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    problems = {
      for (final p in decoded['problems'] as List)
        (p as Map<String, dynamic>)['problem_id'] as int: ProblemDTO.fromJson(p),
    };
  });

  ProblemData dataFor(ProblemDTO dto) {
    final objects = dto.customObjects?['dart'] ?? const [];
    final shapes = <String, CustomObjectShape>{};
    for (final o in objects) {
      final shape = CustomObjectShape.fromKey(o.getShape);
      final name = RegExp(r'class\s+(\w+)').firstMatch(o.getCode.trim())?.group(1);
      if (shape != null && name != null) shapes[name] = shape;
    }
    return ProblemData(
      functionSignature: dto.functionSignature?.dart ?? '',
      testCases: [
        for (final t in <TestCase>[...?dto.testCases, ...?dto.hiddenTestCases])
          ProblemTestCase(input: t.input?.trim() ?? '', expectedOutput: t.expectedOutput?.trim() ?? ''),
      ],
      customObjects: shapes,
      customObjectSources: [for (final o in objects) o.getCode],
      comparison: OutputComparison.fromKey(dto.comparison),
    );
  }

  _solutions.forEach((id, code) {
    test('problem $id: a correct Dart solution passes every stored test case', () {
      final dto = problems[id]!;
      final result = const ProblemRunner().runAll(problem: dataFor(dto), userCode: code);

      expect(result.error, isNull, reason: 'problem $id (${dto.name}) failed to run');
      expect(result.totalCount, greaterThan(0), reason: 'problem $id has no test cases');

      final failures = result.testCaseResults.where((r) => !r.passed).map((r) {
        return 'input: ${r.testCase.input}\n'
            '  expected: ${r.testCase.expectedOutput}\n'
            '  actual:   ${r.actualOutput}';
      }).toList();

      expect(
        failures,
        isEmpty,
        reason: 'problem $id (${dto.name}) - ${failures.length}/${result.totalCount} '
            'stored cases disagree with a correct solution:\n${failures.join('\n')}',
      );
    });
  });

  test('every gradable problem has test cases, and the ungradable ones say why', () {
    const ungradable = {50, 56, 60, 74, 82};
    for (final entry in problems.entries) {
      final dto = entry.value;
      final count = (dto.testCases?.length ?? 0) + (dto.hiddenTestCases?.length ?? 0);
      if (ungradable.contains(entry.key)) {
        expect(count, 0, reason: 'problem ${entry.key} cannot be graded, so it must store no cases');
      } else {
        expect(count, greaterThanOrEqualTo(8), reason: 'problem ${entry.key} (${dto.name}) is thin');
      }
    }
  });
}
