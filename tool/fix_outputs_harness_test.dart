import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/custom_object_shape.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/problem_runner.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Reference solutions (interpretable Dart subset) for the affected problems.
/// Each is run through the same [ProblemRunner] used for grading, so the
/// printed actual output is exactly what a correct user solution produces.
const Map<int, String> _references = <int, String>{
  2: r'''
ListNode? addTwoNumbers(ListNode? l1, ListNode? l2) {
  final dummy = ListNode(0);
  var tail = dummy;
  var carry = 0;
  var a = l1;
  var b = l2;
  while (a != null || b != null || carry > 0) {
    var sum = carry;
    if (a != null) { sum = sum + a.val; a = a.next; }
    if (b != null) { sum = sum + b.val; b = b.next; }
    carry = sum ~/ 10;
    tail.next = ListNode(sum % 10);
    tail = tail.next;
  }
  return dummy.next;
}
''',
  3: r'''
int lengthOfLongestSubstring(String s) {
  final last = <String, int>{};
  var start = 0;
  var best = 0;
  for (int i = 0; i < s.length; i++) {
    final ch = s[i];
    if (last.containsKey(ch)) {
      final p = last[ch];
      if (p + 1 > start) start = p + 1;
    }
    last[ch] = i;
    final len = i - start + 1;
    if (len > best) best = len;
  }
  return best;
}
''',
  4: r'''
double findMedianSortedArrays(List<int> nums1, List<int> nums2) {
  final merged = <int>[];
  var i = 0;
  var j = 0;
  while (i < nums1.length && j < nums2.length) {
    if (nums1[i] < nums2[j]) { merged.add(nums1[i]); i++; }
    else { merged.add(nums2[j]); j++; }
  }
  while (i < nums1.length) { merged.add(nums1[i]); i++; }
  while (j < nums2.length) { merged.add(nums2[j]); j++; }
  final n = merged.length;
  if (n % 2 == 1) return merged[n ~/ 2] / 1;
  return (merged[n ~/ 2 - 1] + merged[n ~/ 2]) / 2;
}
''',
  5: r'''
int maxArea(List<int> height) {
  var i = 0;
  var j = height.length - 1;
  var best = 0;
  while (i < j) {
    final w = j - i;
    var h = height[i];
    if (height[j] < h) h = height[j];
    final area = w * h;
    if (area > best) best = area;
    if (height[i] < height[j]) i++; else j--;
  }
  return best;
}
''',
  6: r'''
List<int> sortNums(List<int> a) {
  for (int i = 0; i < a.length; i++) {
    var m = i;
    for (int k = i + 1; k < a.length; k++) {
      if (a[k] < a[m]) m = k;
    }
    if (m != i) { final t = a[i]; a[i] = a[m]; a[m] = t; }
  }
  return a;
}
List<List<int>> threeSum(List<int> nums) {
  sortNums(nums);
  final res = <List<int>>[];
  final n = nums.length;
  for (int i = 0; i < n - 2; i++) {
    if (i > 0 && nums[i] == nums[i - 1]) continue;
    var lo = i + 1;
    var hi = n - 1;
    while (lo < hi) {
      final s = nums[i] + nums[lo] + nums[hi];
      if (s == 0) {
        res.add([nums[i], nums[lo], nums[hi]]);
        while (lo < hi && nums[lo] == nums[lo + 1]) lo++;
        while (lo < hi && nums[hi] == nums[hi - 1]) hi--;
        lo++;
        hi--;
      } else if (s < 0) {
        lo++;
      } else {
        hi--;
      }
    }
  }
  return res;
}
''',
  7: r'''
List<String> letterCombinations(String digits) {
  if (digits.isEmpty) return <String>[];
  final mapping = <String, String>{
    '2': 'abc', '3': 'def', '4': 'ghi', '5': 'jkl',
    '6': 'mno', '7': 'pqrs', '8': 'tuv', '9': 'wxyz'
  };
  var result = <String>[''];
  for (int i = 0; i < digits.length; i++) {
    final letters = mapping[digits[i]];
    final next = <String>[];
    for (int k = 0; k < result.length; k++) {
      for (int m = 0; m < letters.length; m++) {
        next.add(result[k] + letters[m]);
      }
    }
    result = next;
  }
  return result;
}
''',
  11: r'''
void parenHelper(List<String> res, String cur, int open, int close, int n) {
  if (cur.length == n * 2) { res.add(cur); return; }
  if (open < n) parenHelper(res, cur + '(', open + 1, close, n);
  if (close < open) parenHelper(res, cur + ')', open, close + 1, n);
}
List<String> generateParenthesis(int n) {
  final res = <String>[];
  parenHelper(res, '', 0, 0, n);
  return res;
}
''',
  12: r'''
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
''',
  14: r'''
void csHelper(List<List<int>> res, List<int> cand, int target, List<int> cur, int start) {
  if (target == 0) {
    final copy = <int>[];
    for (int k = 0; k < cur.length; k++) copy.add(cur[k]);
    res.add(copy);
    return;
  }
  if (target < 0) return;
  for (int i = start; i < cand.length; i++) {
    cur.add(cand[i]);
    csHelper(res, cand, target - cand[i], cur, i);
    cur.removeLast();
  }
}
List<int> csSort(List<int> a) {
  for (int i = 0; i < a.length; i++) {
    var m = i;
    for (int k = i + 1; k < a.length; k++) {
      if (a[k] < a[m]) m = k;
    }
    if (m != i) { final t = a[i]; a[i] = a[m]; a[m] = t; }
  }
  return a;
}
List<List<int>> combinationSum(List<int> candidates, int target) {
  csSort(candidates);
  final res = <List<int>>[];
  csHelper(res, candidates, target, <int>[], 0);
  return res;
}
''',
  15: r'''
int trap(List<int> height) {
  final n = height.length;
  if (n < 3) return 0;
  final left = <int>[];
  var lm = 0;
  for (int i = 0; i < n; i++) {
    if (height[i] > lm) lm = height[i];
    left.add(lm);
  }
  final right = <int>[];
  var rm = 0;
  for (int i = n - 1; i >= 0; i--) {
    if (height[i] > rm) rm = height[i];
    right.add(rm);
  }
  var total = 0;
  for (int i = 0; i < n; i++) {
    var h = left[i];
    if (right[n - 1 - i] < h) h = right[n - 1 - i];
    total = total + (h - height[i]);
  }
  return total;
}
''',
  16: r'''
void permHelper(List<List<int>> res, List<int> nums, List<int> cur, List<int> used) {
  if (cur.length == nums.length) {
    final copy = <int>[];
    for (int k = 0; k < cur.length; k++) copy.add(cur[k]);
    res.add(copy);
    return;
  }
  for (int i = 0; i < nums.length; i++) {
    if (used[i] == 1) continue;
    used[i] = 1;
    cur.add(nums[i]);
    permHelper(res, nums, cur, used);
    cur.removeLast();
    used[i] = 0;
  }
}
List<List<int>> permute(List<int> nums) {
  final used = <int>[];
  for (int i = 0; i < nums.length; i++) used.add(0);
  final res = <List<int>>[];
  permHelper(res, nums, <int>[], used);
  return res;
}
''',
   17: r'''
String sortWord(String w) {
  final chars = <String>[];
  for (int i = 0; i < w.length; i++) chars.add(w.substring(i, i + 1));
  final alpha = 'abcdefghijklmnopqrstuvwxyz';
  for (int i = 0; i < chars.length; i++) {
    var m = i;
    for (int k = i + 1; k < chars.length; k++) {
      if (alpha.indexOf(chars[k]) < alpha.indexOf(chars[m])) m = k;
    }
    if (m != i) { final t = chars[i]; chars[i] = chars[m]; chars[m] = t; }
  }
  var s = '';
  for (int i = 0; i < chars.length; i++) s = s + chars[i];
  return s;
}
List<List<String>> groupAnagrams(List<String> strs) {
  final keyToIdx = <String, int>{};
  final groups = <List<String>>[];
  for (int i = 0; i < strs.length; i++) {
    final key = sortWord(strs[i]);
    if (keyToIdx.containsKey(key)) {
      groups[keyToIdx[key]].add(strs[i]);
    } else {
      keyToIdx[key] = groups.length;
      groups.add(<String>[strs[i]]);
    }
  }
  return groups;
}
''',
  18: r'''
void nqHelper(List<List<String>> res, int n, int row, List<int> cols, List<int> diag1, List<int> diag2, List<String> board) {
  if (row == n) {
    final copy = <String>[];
    for (int i = 0; i < n; i++) copy.add(board[i]);
    res.add(copy);
    return;
  }
  for (int c = 0; c < n; c++) {
    if (cols[c] == 1) continue;
    if (diag1[row + c] == 1) continue;
    if (diag2[row - c + n - 1] == 1) continue;
    cols[c] = 1;
    diag1[row + c] = 1;
    diag2[row - c + n - 1] = 1;
    var s = '';
    for (int k = 0; k < n; k++) s = s + (k == c ? 'Q' : '.');
    board[row] = s;
    nqHelper(res, n, row + 1, cols, diag1, diag2, board);
    cols[c] = 0;
    diag1[row + c] = 0;
    diag2[row - c + n - 1] = 0;
  }
}
List<List<String>> solveNQueens(int n) {
  final cols = <int>[];
  final diag1 = <int>[];
  final diag2 = <int>[];
  final board = <String>[];
  for (int i = 0; i < n; i++) { cols.add(0); board.add(''); }
  for (int i = 0; i < 2 * n - 1; i++) { diag1.add(0); diag2.add(0); }
  final res = <List<String>>[];
  nqHelper(res, n, 0, cols, diag1, diag2, board);
  return res;
}
''',
  21: r'''
List<List<int>> intervalSort(List<List<int>> a) {
  for (int i = 0; i < a.length; i++) {
    var m = i;
    for (int k = i + 1; k < a.length; k++) {
      final swap = a[k][0] < a[m][0] || (a[k][0] == a[m][0] && a[k][1] < a[m][1]);
      if (swap) m = k;
    }
    if (m != i) { final t = a[i]; a[i] = a[m]; a[m] = t; }
  }
  return a;
}
List<List<int>> merge(List<List<int>> intervals) {
  intervalSort(intervals);
  final res = <List<int>>[];
  for (int i = 0; i < intervals.length; i++) {
    if (res.isEmpty) { res.add(<int>[intervals[i][0], intervals[i][1]]); continue; }
    final last = res[res.length - 1];
    if (intervals[i][0] <= last[1]) {
      if (intervals[i][1] > last[1]) last[1] = intervals[i][1];
    } else {
      res.add(<int>[intervals[i][0], intervals[i][1]]);
    }
  }
  return res;
}
''',
  22: r'''
List<List<int>> insert(List<List<int>> intervals, List<int> newInterval) {
  final res = <List<int>>[];
  var i = 0;
  while (i < intervals.length && intervals[i][1] < newInterval[0]) {
    res.add(<int>[intervals[i][0], intervals[i][1]]);
    i++;
  }
  var start = newInterval[0];
  var end = newInterval[1];
  while (i < intervals.length && intervals[i][0] <= end) {
    if (intervals[i][0] < start) start = intervals[i][0];
    if (intervals[i][1] > end) end = intervals[i][1];
    i++;
  }
  res.add(<int>[start, end]);
  while (i < intervals.length) {
    res.add(<int>[intervals[i][0], intervals[i][1]]);
    i++;
  }
  return res;
}
''',
  23: r'''
int uniquePaths(int m, int n) {
  final dp = <List<int>>[];
  for (int i = 0; i < m; i++) {
    final row = <int>[];
    for (int k = 0; k < n; k++) row.add(0);
    dp.add(row);
  }
  for (int i = 0; i < m; i++) dp[i][0] = 1;
  for (int k = 0; k < n; k++) dp[0][k] = 1;
  for (int i = 1; i < m; i++) {
    for (int k = 1; k < n; k++) {
      dp[i][k] = dp[i - 1][k] + dp[i][k - 1];
    }
  }
  return dp[m - 1][n - 1];
}
''',
  25: r'''
int minDistance(String word1, String word2) {
  final m = word1.length;
  final n = word2.length;
  final dp = <List<int>>[];
  for (int i = 0; i <= m; i++) {
    final row = <int>[];
    for (int k = 0; k <= n; k++) row.add(0);
    dp.add(row);
  }
  for (int i = 0; i <= m; i++) dp[i][0] = i;
  for (int k = 0; k <= n; k++) dp[0][k] = k;
  for (int i = 1; i <= m; i++) {
    for (int k = 1; k <= n; k++) {
      if (word1[i - 1] == word2[k - 1]) {
        dp[i][k] = dp[i - 1][k - 1];
      } else {
        var best = dp[i - 1][k];
        if (dp[i][k - 1] < best) best = dp[i][k - 1];
        if (dp[i - 1][k - 1] < best) best = dp[i - 1][k - 1];
        dp[i][k] = best + 1;
      }
    }
  }
  return dp[m][n];
}
''',
  28: r'''
String minWindow(String s, String t) {
  final need = <String, int>{};
  for (int i = 0; i < t.length; i++) {
    final c = t[i];
    if (need.containsKey(c)) need[c] = need[c] + 1; else need[c] = 1;
  }
  final have = <String, int>{};
  var left = 0;
  var bestL = -1;
  var bestLen = 0;
  var matched = 0;
  for (int right = 0; right < s.length; right++) {
    final c = s[right];
    if (have.containsKey(c)) have[c] = have[c] + 1; else have[c] = 1;
    if (need.containsKey(c) && have[c] <= need[c]) matched++;
    while (matched == t.length && left <= right) {
      final len = right - left + 1;
      if (bestL == -1 || len < bestLen) { bestL = left; bestLen = len; }
      final lc = s[left];
      if (need.containsKey(lc) && have[lc] == need[lc]) matched--;
      have[lc] = have[lc] - 1;
      left++;
    }
  }
  if (bestL == -1) return '';
  return s.substring(bestL, bestL + bestLen);
}
''',
  29: r'''
List<List<int>> subsets(List<int> nums) {
  final res = <List<int>>[];
  res.add(<int>[]);
  for (int i = 0; i < nums.length; i++) {
    final cur = nums[i];
    final sz = res.length;
    for (int k = 0; k < sz; k++) {
      final copy = <int>[];
      for (int m = 0; m < res[k].length; m++) copy.add(res[k][m]);
      copy.add(cur);
      res.add(copy);
    }
  }
  return res;
}
''',
  30: r'''
bool existHelper(List<List<String>> board, int r, int c, String word, int idx, List<List<int>> used) {
  if (idx == word.length) return true;
  if (r < 0 || r >= board.length || c < 0 || c >= board[0].length) return false;
  if (used[r][c] == 1) return false;
  if (board[r][c] != word[idx]) return false;
  used[r][c] = 1;
  if (existHelper(board, r + 1, c, word, idx + 1, used)) return true;
  if (existHelper(board, r - 1, c, word, idx + 1, used)) return true;
  if (existHelper(board, r, c + 1, word, idx + 1, used)) return true;
  if (existHelper(board, r, c - 1, word, idx + 1, used)) return true;
  used[r][c] = 0;
  return false;
}
bool exist(List<List<String>> board, String word) {
  final used = <List<int>>[];
  for (int r = 0; r < board.length; r++) {
    final row = <int>[];
    for (int k = 0; k < board[0].length; k++) row.add(0);
    used.add(row);
  }
  for (int r = 0; r < board.length; r++) {
    for (int c = 0; c < board[0].length; c++) {
      if (existHelper(board, r, c, word, 0, used)) return true;
    }
  }
  return false;
}
''',
  31: r'''
int largestRectangleArea(List<int> heights) {
  final stack = <int>[];
  var best = 0;
  for (int i = 0; i <= heights.length; i++) {
    var h = 0;
    if (i < heights.length) h = heights[i];
    while (stack.isNotEmpty && h < heights[stack[stack.length - 1]]) {
      final idx = stack.removeLast();
      final height = heights[idx];
      var width = i;
      if (stack.isNotEmpty) width = i - stack[stack.length - 1] - 1;
      final area = height * width;
      if (area > best) best = area;
    }
    stack.add(i);
  }
  return best;
}
''',
  33: r'''
int numDecodings(String s) {
  if (s.isEmpty) return 0;
  if (s[0] == '0') return 0;
  if (s.length == 1) return 1;
  var prev = 1;
  var prevPrev = 1;
  for (int i = 1; i < s.length; i++) {
    var cur = 0;
    if (s[i] != '0') cur = cur + prev;
    if (s[i - 1] == '1' || (s[i - 1] == '2' && '0123456'.indexOf(s[i]) >= 0)) {
      cur = cur + prevPrev;
    }
    if (cur == 0) return 0;
    prevPrev = prev;
    prev = cur;
  }
  return prev;
}
''',
  37: r'''
List<List<int>> levelOrder(TreeNode? root) {
  final res = <List<int>>[];
  if (root == null) return res;
  var level = <TreeNode>[root];
  while (level.isNotEmpty) {
    final vals = <int>[];
    final next = <TreeNode>[];
    for (int i = 0; i < level.length; i++) {
      vals.add(level[i].val);
      if (level[i].left != null) next.add(level[i].left);
      if (level[i].right != null) next.add(level[i].right);
    }
    res.add(vals);
    level = next;
  }
  return res;
}
''',
  40: r'''
TreeNode? buildTreeHelper(List<int> preorder, int ps, int pe, List<int> inorder, int is_, int ie) {
  if (ps > pe) return null;
  final rootVal = preorder[ps];
  final node = TreeNode(rootVal);
  var mid = -1;
  for (int i = is_; i <= ie; i++) {
    if (inorder[i] == rootVal) { mid = i; break; }
  }
  final leftCount = mid - is_;
  node.left = buildTreeHelper(preorder, ps + 1, ps + leftCount, inorder, is_, mid - 1);
  node.right = buildTreeHelper(preorder, ps + leftCount + 1, pe, inorder, mid + 1, ie);
  return node;
}
TreeNode? buildTree(List<int> preorder, List<int> inorder) {
  if (preorder.isEmpty) return null;
  return buildTreeHelper(preorder, 0, preorder.length - 1, inorder, 0, inorder.length - 1);
}
''',
  41: r'''
TreeNode? bstHelper(List<int> nums, int lo, int hi) {
  if (lo > hi) return null;
  final mid = (lo + hi) ~/ 2;
  final node = TreeNode(nums[mid]);
  node.left = bstHelper(nums, lo, mid - 1);
  node.right = bstHelper(nums, mid + 1, hi);
  return node;
}
TreeNode? sortedArrayToBST(List<int> nums) {
  if (nums.isEmpty) return null;
  return bstHelper(nums, 0, nums.length - 1);
}
''',
  45: r'''
var gMps = 0;
int mpsHelper(TreeNode? node) {
  if (node == null) return 0;
  var l = mpsHelper(node.left);
  var r = mpsHelper(node.right);
  if (l < 0) l = 0;
  if (r < 0) r = 0;
  final through = l + r + node.val;
  if (through > gMps) gMps = through;
  var up = l;
  if (r > up) up = r;
  return up + node.val;
}
int maxPathSum(TreeNode? root) {
  gMps = -1000000000;
  mpsHelper(root);
  return gMps;
}
''',
  47: r'''
int ladderLength(String beginWord, String endWord, List<String> wordList) {
  var hasEnd = false;
  for (int i = 0; i < wordList.length; i++) {
    if (wordList[i] == endWord) { hasEnd = true; break; }
  }
  if (!hasEnd) return 0;
  final q = <String>[beginWord];
  final seen = <String, int>{beginWord: 1};
  var depth = 1;
  while (q.isNotEmpty) {
    final levelCount = q.length;
    for (int lvl = 0; lvl < levelCount; lvl++) {
      final cur = q[0];
      q.removeAt(0);
      if (cur == endWord) return depth;
      for (int w = 0; w < wordList.length; w++) {
        final candidate = wordList[w];
        if (seen.containsKey(candidate)) continue;
        var diff = 0;
        for (int k = 0; k < cur.length; k++) {
          if (cur[k] != candidate[k]) diff++;
        }
        if (diff == 1) {
          seen[candidate] = 1;
          q.add(candidate);
        }
      }
    }
    depth++;
  }
  return 0;
}
''',
  49: r'''
bool isPal(String s) {
  var i = 0;
  var j = s.length - 1;
  while (i < j) {
    if (s[i] != s[j]) return false;
    i++;
    j--;
  }
  return true;
}
void partHelper(List<List<String>> res, String s, int start, List<String> cur) {
  if (start == s.length) {
    final copy = <String>[];
    for (int k = 0; k < cur.length; k++) copy.add(cur[k]);
    res.add(copy);
    return;
  }
  for (int i = start + 1; i <= s.length; i++) {
    final sub = s.substring(start, i);
    if (isPal(sub)) {
      cur.add(sub);
      partHelper(res, s, i, cur);
      cur.removeLast();
    }
  }
}
List<List<String>> partition(String s) {
  final res = <List<String>>[];
  partHelper(res, s, 0, <String>[]);
  return res;
}
''',
  55: r'''
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
''',
  58: r'''
int maxProduct(List<int> nums) {
  var maxP = nums[0];
  var minP = nums[0];
  var best = nums[0];
  for (int i = 1; i < nums.length; i++) {
    final x = nums[i];
    var newMax = x;
    final m1 = maxP * x;
    final m2 = minP * x;
    if (m1 > newMax) newMax = m1;
    if (m2 > newMax) newMax = m2;
    var newMin = x;
    if (m1 < newMin) newMin = m1;
    if (m2 < newMin) newMin = m2;
    maxP = newMax;
    minP = newMin;
    if (maxP > best) best = maxP;
  }
  return best;
}
''',
  63: r'''
int rob(List<int> nums) {
  var prev = 0;
  var prevPrev = 0;
  for (int i = 0; i < nums.length; i++) {
    final take = prevPrev + nums[i];
    final skip = prev;
    final cur = take > skip ? take : skip;
    prevPrev = prev;
    prev = cur;
  }
  return prev;
}
''',
  64: r'''
List<int> rightSideView(TreeNode? root) {
  final res = <int>[];
  if (root == null) return res;
  var level = <TreeNode>[root];
  while (level.isNotEmpty) {
    res.add(level[level.length - 1].val);
    final next = <TreeNode>[];
    for (int i = 0; i < level.length; i++) {
      if (level[i].left != null) next.add(level[i].left);
      if (level[i].right != null) next.add(level[i].right);
    }
    level = next;
  }
  return res;
}
''',
  65: r'''
void sink(List<List<String>> grid, int r, int c) {
  if (r < 0 || r >= grid.length || c < 0 || c >= grid[0].length) return;
  if (grid[r][c] == '0') return;
  grid[r][c] = '0';
  sink(grid, r + 1, c);
  sink(grid, r - 1, c);
  sink(grid, r, c + 1);
  sink(grid, r, c - 1);
}
int numIslands(List<List<String>> grid) {
  var count = 0;
  for (int r = 0; r < grid.length; r++) {
    for (int c = 0; c < grid[0].length; c++) {
      if (grid[r][c] == '1') {
        count++;
        sink(grid, r, c);
      }
    }
  }
  return count;
}
''',
  68: r'''
List<int> findOrder(int numCourses, List<List<int>> prerequisites) {
  final indeg = <int>[];
  for (int i = 0; i < numCourses; i++) indeg.add(0);
  final adj = <List<int>>[];
  for (int i = 0; i < numCourses; i++) adj.add(<int>[]);
  for (int i = 0; i < prerequisites.length; i++) {
    final a = prerequisites[i][0];
    final b = prerequisites[i][1];
    adj[b].add(a);
    indeg[a] = indeg[a] + 1;
  }
  final res = <int>[];
  final added = <int>[];
  for (int i = 0; i < numCourses; i++) added.add(0);
  for (int iter = 0; iter < numCourses; iter++) {
    var next = -1;
    for (int i = 0; i < numCourses; i++) {
      if (added[i] == 0 && indeg[i] == 0) { next = i; break; }
    }
    if (next == -1) return <int>[];
    added[next] = 1;
    res.add(next);
    for (int k = 0; k < adj[next].length; k++) {
      indeg[adj[next][k]] = indeg[adj[next][k]] - 1;
    }
  }
  return res;
}
''',
  69: r'''
int robLine(List<int> nums, int lo, int hi) {
  var prev = 0;
  var prevPrev = 0;
  for (int i = lo; i <= hi; i++) {
    final take = prevPrev + nums[i];
    final skip = prev;
    final cur = take > skip ? take : skip;
    prevPrev = prev;
    prev = cur;
  }
  return prev;
}
int rob(List<int> nums) {
  if (nums.length == 1) return nums[0];
  final a = robLine(nums, 0, nums.length - 2);
  final b = robLine(nums, 1, nums.length - 1);
  return a > b ? a : b;
}
''',
  70: r'''
List<int> sortNums(List<int> a) {
  for (int i = 0; i < a.length; i++) {
    var m = i;
    for (int k = i + 1; k < a.length; k++) {
      if (a[k] < a[m]) m = k;
    }
    if (m != i) { final t = a[i]; a[i] = a[m]; a[m] = t; }
  }
  return a;
}
int findKthLargest(List<int> nums, int k) {
  sortNums(nums);
  return nums[nums.length - k];
}
''',
  73: r'''
int kthSmallest(TreeNode? root, int k) {
  final stack = <TreeNode>[];
  var node = root;
  var count = 0;
  while (stack.isNotEmpty || node != null) {
    while (node != null) {
      stack.add(node);
      node = node.left;
    }
    node = stack.removeLast();
    count++;
    if (count == k) return node.val;
    node = node.right;
  }
  return -1;
}
''',
  75: r'''
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
''',
  76: r'''
List<int> productExceptSelf(List<int> nums) {
  final n = nums.length;
  final left = <int>[];
  var prod = 1;
  for (int i = 0; i < n; i++) { left.add(prod); prod = prod * nums[i]; }
  prod = 1;
  final right = <int>[];
  for (int i = n - 1; i >= 0; i--) { right.add(prod); prod = prod * nums[i]; }
  final res = <int>[];
  for (int i = 0; i < n; i++) {
    res.add(left[i] * right[n - 1 - i]);
  }
  return res;
}
''',
  77: r'''
List<int> maxSlidingWindow(List<int> nums, int k) {
  final dq = <int>[];
  final res = <int>[];
  for (int i = 0; i < nums.length; i++) {
    while (dq.isNotEmpty && dq[0] <= i - k) dq.removeAt(0);
    while (dq.isNotEmpty && nums[dq[dq.length - 1]] <= nums[i]) dq.removeLast();
    dq.add(i);
    if (i >= k - 1) res.add(nums[dq[0]]);
  }
  return res;
}
''',
  83: r'''
int lengthOfLIS(List<int> nums) {
  final dp = <int>[];
  var best = 0;
  for (int i = 0; i < nums.length; i++) {
    var cur = 1;
    for (int j = 0; j < i; j++) {
      if (nums[j] < nums[i] && dp[j] + 1 > cur) cur = dp[j] + 1;
    }
    dp.add(cur);
    if (cur > best) best = cur;
  }
  return best;
}
''',
  86: r'''
List<int> topKFrequent(List<int> nums, int k) {
  final freq = <int, int>{};
  final order = <int>[];
  for (int i = 0; i < nums.length; i++) {
    final v = nums[i];
    if (freq.containsKey(v)) {
      freq[v] = freq[v] + 1;
    } else {
      freq[v] = 1;
      order.add(v);
    }
  }
  for (int i = 0; i < order.length; i++) {
    var m = i;
    for (int j = i + 1; j < order.length; j++) {
      final swap = freq[order[j]] > freq[order[m]] ||
          (freq[order[j]] == freq[order[m]] && order[j] < order[m]);
      if (swap) m = j;
    }
    if (m != i) { final t = order[i]; order[i] = order[m]; order[m] = t; }
  }
  final res = <int>[];
  for (int i = 0; i < k && i < order.length; i++) res.add(order[i]);
  return res;
}
''',
  87: r'''
bool canPartition(List<int> nums) {
  var total = 0;
  for (int i = 0; i < nums.length; i++) total = total + nums[i];
  if (total % 2 == 1) return false;
  final target = total ~/ 2;
  final dp = <int>[];
  for (int s = 0; s <= target; s++) dp.add(0);
  dp[0] = 1;
  for (int i = 0; i < nums.length; i++) {
    for (int s = target; s >= nums[i]; s--) {
      if (dp[s - nums[i]] == 1) dp[s] = 1;
    }
  }
  return dp[target] == 1;
}
''',
  88: r'''
int canFlow(List<List<int>> h, int r, int c, List<List<int>> visited, bool toPacific) {
  if (toPacific && (r == 0 || c == 0)) return 1;
  if (!toPacific && (r == h.length - 1 || c == h[0].length - 1)) return 1;
  if (visited[r][c] == 1) return 0;
  visited[r][c] = 1;
  var res = 0;
  if (r + 1 < h.length && h[r + 1][c] <= h[r][c] && canFlow(h, r + 1, c, visited, toPacific) == 1) res = 1;
  if (r - 1 >= 0 && h[r - 1][c] <= h[r][c] && canFlow(h, r - 1, c, visited, toPacific) == 1) res = 1;
  if (c + 1 < h[0].length && h[r][c + 1] <= h[r][c] && canFlow(h, r, c + 1, visited, toPacific) == 1) res = 1;
  if (c - 1 >= 0 && h[r][c - 1] <= h[r][c] && canFlow(h, r, c - 1, visited, toPacific) == 1) res = 1;
  return res;
}
List<List<int>> pacificAtlantic(List<List<int>> heights) {
  final res = <List<int>>[];
  final rows = heights.length;
  final cols = heights[0].length;
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      final vp = <List<int>>[];
      for (int i = 0; i < rows; i++) {
        final row = <int>[];
        for (int k = 0; k < cols; k++) row.add(0);
        vp.add(row);
      }
      final va = <List<int>>[];
      for (int i = 0; i < rows; i++) {
        final row = <int>[];
        for (int k = 0; k < cols; k++) row.add(0);
        va.add(row);
      }
      if (canFlow(heights, r, c, vp, true) == 1 && canFlow(heights, r, c, va, false) == 1) {
        res.add(<int>[r, c]);
      }
    }
  }
  return res;
}
''',
  90: r'''
var gDia = 0;
int diaHeight(TreeNode? node) {
  if (node == null) return 0;
  final l = diaHeight(node.left);
  final r = diaHeight(node.right);
  if (l + r > gDia) gDia = l + r;
  return (l > r ? l : r) + 1;
}
int diameterOfBinaryTree(TreeNode? root) {
  gDia = 0;
  diaHeight(root);
  return gDia;
}
''',
  93: r'''
int leastInterval(List<String> tasks, int n) {
  final freq = <String, int>{};
  var maxF = 0;
  for (int i = 0; i < tasks.length; i++) {
    final t = tasks[i];
    if (freq.containsKey(t)) freq[t] = freq[t] + 1; else freq[t] = 1;
    if (freq[t] > maxF) maxF = freq[t];
  }
  var countMax = 0;
  final counted = <String>[];
  for (int i = 0; i < tasks.length; i++) {
    final t = tasks[i];
    if (freq[t] == maxF) {
      var seen = false;
      for (int k = 0; k < counted.length; k++) {
        if (counted[k] == t) seen = true;
      }
      if (!seen) { counted.add(t); countMax++; }
    }
  }
  final idle = (maxF - 1) * (n + 1) + countMax;
  final len = tasks.length;
  return idle > len ? idle : len;
}
''',
  94: r'''
int dsuFind(int x, List<int> parent) {
  while (parent[x] != x) x = parent[x];
  return x;
}
List<int> findRedundantConnection(List<List<int>> edges) {
  final parent = <int>[];
  for (int i = 0; i <= edges.length + 1; i++) parent.add(i);
  for (int i = 0; i < edges.length; i++) {
    final a = edges[i][0];
    final b = edges[i][1];
    final ra = dsuFind(a, parent);
    final rb = dsuFind(b, parent);
    if (ra == rb) return <int>[a, b];
    parent[rb] = ra;
  }
  return <int>[0, 0];
}
''',
  96: r'''
List<int> dailyTemperatures(List<int> temperatures) {
  final n = temperatures.length;
  final res = <int>[];
  for (int i = 0; i < n; i++) res.add(0);
  final stack = <int>[];
  for (int i = n - 1; i >= 0; i--) {
    while (stack.isNotEmpty && temperatures[stack[stack.length - 1]] <= temperatures[i]) {
      stack.removeLast();
    }
    if (stack.isNotEmpty) res[i] = stack[stack.length - 1] - i;
    stack.add(i);
  }
  return res;
}
''',
  97: r'''
int networkDelayTime(List<List<int>> times, int n, int k) {
  final dist = <int>[];
  for (int i = 0; i <= n; i++) dist.add(-1);
  dist[k] = 0;
  final done = <int>[];
  for (int i = 0; i <= n; i++) done.add(0);
  for (int iter = 0; iter < n; iter++) {
    var u = -1;
    var best = 1000000000;
    for (int i = 1; i <= n; i++) {
      if (done[i] == 0 && dist[i] != -1 && dist[i] < best) { best = dist[i]; u = i; }
    }
    if (u == -1) break;
    done[u] = 1;
    for (int e = 0; e < times.length; e++) {
      if (times[e][0] == u) {
        final v = times[e][1];
        final w = times[e][2];
        if (dist[v] == -1 || dist[u] + w < dist[v]) dist[v] = dist[u] + w;
      }
    }
  }
  var maxT = 0;
  for (int i = 1; i <= n; i++) {
    if (dist[i] == -1) return -1;
    if (dist[i] > maxT) maxT = dist[i];
  }
  return maxT;
}
''',
  99: r'''
int orangesRotting(List<List<int>> grid) {
  final rows = grid.length;
  final cols = grid[0].length;
  var fresh = 0;
  final q = <List<int>>[];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (grid[r][c] == 1) fresh++;
      if (grid[r][c] == 2) q.add(<int>[r, c]);
    }
  }
  var minutes = 0;
  while (q.isNotEmpty && fresh > 0) {
    final sz = q.length;
    for (int i = 0; i < sz; i++) {
      final cur = q[0];
      q.removeAt(0);
      final r = cur[0];
      final c = cur[1];
      if (r + 1 < rows && grid[r + 1][c] == 1) { grid[r + 1][c] = 2; fresh--; q.add(<int>[r + 1, c]); }
      if (r - 1 >= 0 && grid[r - 1][c] == 1) { grid[r - 1][c] = 2; fresh--; q.add(<int>[r - 1, c]); }
      if (c + 1 < cols && grid[r][c + 1] == 1) { grid[r][c + 1] = 2; fresh--; q.add(<int>[r, c + 1]); }
      if (c - 1 >= 0 && grid[r][c - 1] == 1) { grid[r][c - 1] = 2; fresh--; q.add(<int>[r, c - 1]); }
    }
    minutes++;
  }
  if (fresh > 0) return -1;
  return minutes;
}
''',
  100: r'''
int longestCommonSubsequence(String text1, String text2) {
  final m = text1.length;
  final n = text2.length;
  final dp = <List<int>>[];
  for (int i = 0; i <= m; i++) {
    final row = <int>[];
    for (int k = 0; k <= n; k++) row.add(0);
    dp.add(row);
  }
  for (int i = 1; i <= m; i++) {
    for (int k = 1; k <= n; k++) {
      if (text1[i - 1] == text2[k - 1]) {
        dp[i][k] = dp[i - 1][k - 1] + 1;
      } else {
        dp[i][k] = dp[i - 1][k] > dp[i][k - 1] ? dp[i - 1][k] : dp[i][k - 1];
      }
    }
  }
  return dp[m][n];
}
''',
};

void main() {
  final data = jsonDecode(File('assets/problems.json').readAsStringSync());
  final problems = data['problems'] as List<dynamic>;
  final actuals = <Map<String, dynamic>>[];
  var grandPass = 0;
  var grandTotal = 0;

  for (final p in problems) {
    final id = p['problem_id'] as int;
    final ref = _references[id];
    if (ref == null) continue;

    final sig = ((p['function_signature'] as Map<String, dynamic>)['dart']) as String;
    final cases = _toCases(p['test_cases'] as List<dynamic>);
    final hidden = _toCases(p['hidden_test_cases'] as List<dynamic>);
    if (cases.isEmpty && hidden.isEmpty) continue;

    final customObjects = <String, CustomObjectShape>{};
    final customSources = <String>[];
    for (final obj in (p['custom_objects'] as Map<String, dynamic>?)?['dart'] as List<dynamic>? ?? const []) {
      final o = obj as Map<String, dynamic>;
      final code = o['code'] as String;
      final shape = CustomObjectShape.fromKey(o['shape'] as String?);
      final name = RegExp(r'class\s+(\w+)').firstMatch(code)?.group(1);
      if (name != null && shape != null) customObjects[name] = shape;
      customSources.add(code);
    }

    final problem = ProblemData(
      functionSignature: sig,
      testCases: cases,
      hiddenTestCases: hidden,
      customObjects: customObjects,
      customObjectSources: customSources,
    );

    final result = const ProblemRunner().runAll(problem: problem, userCode: ref);
    grandTotal += result.totalCount;
    grandPass += result.passedCount;
    final status = result.allPassed ? 'PASS' : 'FAIL';
    debugPrint('$status: [$id] ${p['name']} (${result.passedCount}/${result.totalCount})');

    final all = <Map<String, dynamic>>[
      for (final t in p['test_cases'] as List<dynamic>) {'kind': 'test', 'data': t},
      for (final t in p['hidden_test_cases'] as List<dynamic>) {'kind': 'hidden', 'data': t},
    ];
    for (int i = 0; i < result.testCaseResults.length; i++) {
      final r = result.testCaseResults[i];
      actuals.add(<String, dynamic>{
        'problem_id': id,
        'kind': all[i]['kind'],
        'index': i,
        'expected': all[i]['data']['expected_output'],
        'actual': r.actualOutput,
        'passed': r.passed,
      });
      if (!r.passed) {
        final exp = r.testCase.expectedOutput;
        final act = r.actualOutput;
        debugPrint('   [${all[i]['kind']}#$i] expected: ${exp.length > 120 ? '${exp.substring(0, 120)}...' : exp}');
        debugPrint('            actual:   ${act.length > 120 ? '${act.substring(0, 120)}...' : act}');
        if (r.errorMessage != null) debugPrint('            error:   ${r.errorMessage}');
      }
    }
  }

  File('tool/fix_outputs_actuals.json').writeAsStringSync(jsonEncode(actuals));
  debugPrint('TOTAL: $grandPass/$grandTotal passed');
}

List<ProblemTestCase> _toCases(List<dynamic> list) {
  return list.map((t) {
    final m = t as Map<String, dynamic>;
    return ProblemTestCase(input: m['input'] as String, expectedOutput: m['expected_output'] as String);
  }).toList(growable: false);
}
