// SC-001a: idiomatic reference solutions for 30+ problems from
// assets/problems.json run correctly through the new engine with zero
// rewrites for the interpreter's sake — unlike test/challenge/grading/'s
// existing solutions (deliberately written *around* the legacy engine's
// missing closures/.sort), these lean into .map/.where/.fold/sort(cmp)/
// closures/Set/Map wherever that's the natural idiom, proving the rewrite.

import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// Idiomatic Dart solutions — 30 problems spanning arrays, hash maps, two
/// pointers, binary search, sliding window, sorting, DP, greedy, and graphs
/// via Set/Map (array-of-strings grid problems are covered by the existing
/// grading suite's custom-object cases; these focus on the closure/
/// collection surface the rewrite specifically unblocks).
const _solutions = <int, String>{
  3: '''
int lengthOfLongestSubstring(String s) {
  final lastSeen = <String, int>{};
  var start = 0;
  var best = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (lastSeen.containsKey(c) && lastSeen[c]! >= start) {
      start = lastSeen[c]! + 1;
    }
    lastSeen[c] = i;
    final len = i - start + 1;
    if (len > best) best = len;
  }
  return best;
}
''',
  5: '''
int maxArea(List<int> height) {
  var lo = 0, hi = height.length - 1;
  var best = 0;
  while (lo < hi) {
    final h = height[lo] < height[hi] ? height[lo] : height[hi];
    final area = h * (hi - lo);
    if (area > best) best = area;
    if (height[lo] < height[hi]) {
      lo++;
    } else {
      hi--;
    }
  }
  return best;
}
''',
  13: '''
int search(List<int> nums, int target) {
  var lo = 0, hi = nums.length - 1;
  while (lo <= hi) {
    final mid = (lo + hi) ~/ 2;
    if (nums[mid] == target) return mid;
    if (nums[lo] <= nums[mid]) {
      if (nums[lo] <= target && target < nums[mid]) {
        hi = mid - 1;
      } else {
        lo = mid + 1;
      }
    } else {
      if (nums[mid] < target && target <= nums[hi]) {
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
  }
  return -1;
}
''',
  15: '''
int trap(List<int> height) {
  final n = height.length;
  if (n == 0) return 0;
  final leftMax = List.generate(n, (i) => 0);
  final rightMax = List.generate(n, (i) => 0);
  leftMax[0] = height[0];
  for (var i = 1; i < n; i++) {
    leftMax[i] = leftMax[i - 1] > height[i] ? leftMax[i - 1] : height[i];
  }
  rightMax[n - 1] = height[n - 1];
  for (var i = n - 2; i >= 0; i--) {
    rightMax[i] = rightMax[i + 1] > height[i] ? rightMax[i + 1] : height[i];
  }
  var total = 0;
  for (var i = 0; i < n; i++) {
    final m = leftMax[i] < rightMax[i] ? leftMax[i] : rightMax[i];
    total += m - height[i];
  }
  return total;
}
''',
  17: '''
List<List<String>> groupAnagrams(List<String> strs) {
  final groups = <String, List<String>>{};
  for (final s in strs) {
    final chars = s.split('')..sort();
    final key = chars.join();
    groups.putIfAbsent(key, () => <String>[]).add(s);
  }
  return groups.values.toList();
}
''',
  19: '''
int maxSubArray(List<int> nums) {
  var best = nums[0];
  var cur = nums[0];
  for (var i = 1; i < nums.length; i++) {
    cur = nums[i] > cur + nums[i] ? nums[i] : cur + nums[i];
    if (cur > best) best = cur;
  }
  return best;
}
''',
  20: '''
bool canJump(List<int> nums) {
  var reach = 0;
  for (var i = 0; i < nums.length; i++) {
    if (i > reach) return false;
    final r = i + nums[i];
    if (r > reach) reach = r;
  }
  return true;
}
''',
  21: '''
List<List<int>> merge(List<List<int>> intervals) {
  final sorted = List.from(intervals)..sort((a, b) => a[0] - b[0]);
  final result = <List<int>>[];
  for (final interval in sorted) {
    if (result.isEmpty || result.last[1] < interval[0]) {
      result.add(interval);
    } else if (interval[1] > result.last[1]) {
      result.last[1] = interval[1];
    }
  }
  return result;
}
''',
  23: '''
int uniquePaths(int m, int n) {
  final dp = List.filled(n, 1);
  for (var i = 1; i < m; i++) {
    for (var j = 1; j < n; j++) {
      dp[j] = dp[j] + dp[j - 1];
    }
  }
  return dp[n - 1];
}
''',
  24: '''
int climbStairs(int n) {
  if (n <= 2) return n;
  var a = 1, b = 2;
  for (var i = 3; i <= n; i++) {
    final c = a + b;
    a = b;
    b = c;
  }
  return b;
}
''',
  26: '''
bool searchMatrix(List<List<int>> matrix, int target) {
  final rows = matrix.length;
  final cols = matrix[0].length;
  var lo = 0, hi = rows * cols - 1;
  while (lo <= hi) {
    final mid = (lo + hi) ~/ 2;
    final val = matrix[mid ~/ cols][mid % cols];
    if (val == target) return true;
    if (val < target) {
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }
  return false;
}
''',
  27: '''
void sortColors(List<int> nums) {
  var low = 0, mid = 0, high = nums.length - 1;
  while (mid <= high) {
    if (nums[mid] == 0) {
      final tmp = nums[low];
      nums[low] = nums[mid];
      nums[mid] = tmp;
      low++;
      mid++;
    } else if (nums[mid] == 1) {
      mid++;
    } else {
      final tmp = nums[mid];
      nums[mid] = nums[high];
      nums[high] = tmp;
      high--;
    }
  }
}
''',
  32: '''
void merge(List<int> nums1, int m, List<int> nums2, int n) {
  var i = m - 1, j = n - 1, k = m + n - 1;
  while (j >= 0) {
    if (i >= 0 && nums1[i] > nums2[j]) {
      nums1[k] = nums1[i];
      i--;
    } else {
      nums1[k] = nums2[j];
      j--;
    }
    k--;
  }
}
''',
  44: '''
int maxProfit(List<int> prices) {
  if (prices.isEmpty) return 0;
  var minPrice = prices[0];
  var best = 0;
  for (final p in prices) {
    if (p < minPrice) minPrice = p;
    final profit = p - minPrice;
    if (profit > best) best = profit;
  }
  return best;
}
''',
  46: '''
bool _isAlnum(String c) {
  final code = c.codeUnitAt(0);
  return (code >= 48 && code <= 57) || (code >= 97 && code <= 122);
}
bool isPalindrome(String s) {
  final cleaned = s.toLowerCase().split('').where((c) => _isAlnum(c)).join();
  var lo = 0, hi = cleaned.length - 1;
  while (lo < hi) {
    if (cleaned[lo] != cleaned[hi]) return false;
    lo++;
    hi--;
  }
  return true;
}
''',
  48: '''
int longestConsecutive(List<int> nums) {
  final numSet = nums.toSet();
  var best = 0;
  for (final n in numSet) {
    if (!numSet.contains(n - 1)) {
      var length = 1;
      var current = n;
      while (numSet.contains(current + 1)) {
        current++;
        length++;
      }
      if (length > best) best = length;
    }
  }
  return best;
}
''',
  51: '''
int canCompleteCircuit(List<int> gas, List<int> cost) {
  var total = 0, tank = 0, start = 0;
  for (var i = 0; i < gas.length; i++) {
    final diff = gas[i] - cost[i];
    total += diff;
    tank += diff;
    if (tank < 0) {
      start = i + 1;
      tank = 0;
    }
  }
  return total >= 0 ? start : -1;
}
''',
  52: '''
int singleNumber(List<int> nums) {
  final seen = <int>{};
  for (final n in nums) {
    if (seen.contains(n)) {
      seen.remove(n);
    } else {
      seen.add(n);
    }
  }
  return seen.toList().first;
}
''',
  58: '''
int maxProduct(List<int> nums) {
  var maxProd = nums[0], minProd = nums[0], result = nums[0];
  for (var i = 1; i < nums.length; i++) {
    final n = nums[i];
    if (n < 0) {
      final tmp = maxProd;
      maxProd = minProd;
      minProd = tmp;
    }
    maxProd = n > maxProd * n ? n : maxProd * n;
    minProd = n < minProd * n ? n : minProd * n;
    if (maxProd > result) result = maxProd;
  }
  return result;
}
''',
  59: '''
int findMin(List<int> nums) {
  var lo = 0, hi = nums.length - 1;
  while (lo < hi) {
    final mid = (lo + hi) ~/ 2;
    if (nums[mid] > nums[hi]) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return nums[lo];
}
''',
  61: '''
int majorityElement(List<int> nums) {
  var count = 0, candidate = 0;
  for (final n in nums) {
    if (count == 0) candidate = n;
    count += (n == candidate) ? 1 : -1;
  }
  return candidate;
}
''',
  62: '''
int hammingWeight(int n) {
  var count = 0;
  var x = n;
  while (x > 0) {
    if (x % 2 == 1) count++;
    x = x ~/ 2;
  }
  return count;
}
''',
  63: '''
int rob(List<int> nums) {
  var prev = 0, curr = 0;
  for (final n in nums) {
    final next = curr > prev + n ? curr : prev + n;
    prev = curr;
    curr = next;
  }
  return curr;
}
''',
  69: '''
int _robLine(List<int> nums) {
  var prev = 0, curr = 0;
  for (final n in nums) {
    final next = curr > prev + n ? curr : prev + n;
    prev = curr;
    curr = next;
  }
  return curr;
}
int rob(List<int> nums) {
  if (nums.length == 1) return nums[0];
  final withoutLast = nums.sublist(0, nums.length - 1);
  final withoutFirst = nums.sublist(1);
  final a = _robLine(withoutLast);
  final b = _robLine(withoutFirst);
  return a > b ? a : b;
}
''',
  70: '''
int findKthLargest(List<int> nums, int k) {
  final sorted = List.from(nums)..sort();
  return sorted[sorted.length - k];
}
''',
  71: '''
bool containsDuplicate(List<int> nums) {
  return nums.toSet().length != nums.length;
}
''',
  76: '''
List<int> productExceptSelf(List<int> nums) {
  final n = nums.length;
  final result = List.filled(n, 1);
  var prefix = 1;
  for (var i = 0; i < n; i++) {
    result[i] = prefix;
    prefix *= nums[i];
  }
  var suffix = 1;
  for (var i = n - 1; i >= 0; i--) {
    result[i] *= suffix;
    suffix *= nums[i];
  }
  return result;
}
''',
  78: '''
bool isAnagram(String s, String t) {
  if (s.length != t.length) return false;
  final a = s.split('')..sort();
  final b = t.split('')..sort();
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
''',
  79: '''
int missingNumber(List<int> nums) {
  final n = nums.length;
  final expected = n * (n + 1) ~/ 2;
  final actual = nums.fold(0, (sum, x) => sum + x);
  return expected - actual;
}
''',
  85: '''
void reverseString(List<String> s) {
  var lo = 0, hi = s.length - 1;
  while (lo < hi) {
    final tmp = s[lo];
    s[lo] = s[hi];
    s[hi] = tmp;
    lo++;
    hi--;
  }
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

  test('SC-001a: at least 30 idiomatic reference solutions are covered', () {
    expect(_solutions.length, greaterThanOrEqualTo(30));
  });

  _solutions.forEach((id, code) {
    test(
        'problem $id: an idiomatic Dart solution (.map/.where/.fold/sort/Set/closures) passes every stored test case',
        () {
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
}
