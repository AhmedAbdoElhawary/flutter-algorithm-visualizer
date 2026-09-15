// Proves the pilot problems really are solvable in Python and JavaScript
// against the **stored** test cases and expected outputs in
// `assets/problems.json` — not against fixtures written to match.
//
// This is the gate for offering a language on a problem: starter code is only
// added to the dataset for a problem that appears here and passes. A language
// offered on a problem nobody has solved in it is a promise the editor has not
// checked (R10, and the standing rule that a wrong answer must never pass).
//
// The set is chosen for coverage, not ease: hash map, stack, dynamic
// programming, sorting with a key, two pointers, sets, nested lists, string
// work, and an in-place function that returns nothing.

import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// problem id -> language -> a correct solution.
const pilotSolutions = <int, Map<EditorLanguage, String>>{
  // Two Sum — hash map.
  1: <EditorLanguage, String>{
    EditorLanguage.python: '''
def twoSum(nums, target):
    seen = {}
    for i, n in enumerate(nums):
        need = target - n
        if need in seen:
            return [seen[need], i]
        seen[n] = i
    return []
''',
    EditorLanguage.javascript: '''
function twoSum(nums, target) {
  const seen = new Map()
  for (let i = 0; i < nums.length; i++) {
    const need = target - nums[i]
    if (seen.has(need)) return [seen.get(need), i]
    seen.set(nums[i], i)
  }
  return []
}
''',
  },

  // Valid Parentheses — stack and string indexing.
  9: <EditorLanguage, String>{
    EditorLanguage.python: '''
def isValid(s):
    pairs = {")": "(", "]": "[", "}": "{"}
    stack = []
    for c in s:
        if c in pairs:
            if not stack or stack.pop() != pairs[c]:
                return False
        else:
            stack.append(c)
    return len(stack) == 0
''',
    EditorLanguage.javascript: '''
function isValid(s) {
  const pairs = { ")": "(", "]": "[", "}": "{" }
  const stack = []
  for (const c of s) {
    if (c === ")" || c === "]" || c === "}") {
      if (stack.length === 0 || stack.pop() !== pairs[c]) return false
    } else {
      stack.push(c)
    }
  }
  return stack.length === 0
}
''',
  },

  // Group Anagrams — hashing into lists, plus sorting a string's characters.
  17: <EditorLanguage, String>{
    EditorLanguage.python: '''
def groupAnagrams(strs):
    groups = {}
    for word in strs:
        key = "".join(sorted(word))
        if key not in groups:
            groups[key] = []
        groups[key].append(word)
    return list(groups.values())
''',
    EditorLanguage.javascript: '''
function groupAnagrams(strs) {
  const groups = new Map()
  for (const word of strs) {
    const key = word.split("").sort().join("")
    if (!groups.has(key)) groups.set(key, [])
    groups.get(key).push(word)
  }
  return [...groups.values()]
}
''',
  },

  // Maximum Subarray — dynamic programming.
  19: <EditorLanguage, String>{
    EditorLanguage.python: '''
def maxSubArray(nums):
    best = nums[0]
    running = nums[0]
    for n in nums[1:]:
        running = max(n, running + n)
        best = max(best, running)
    return best
''',
    EditorLanguage.javascript: '''
function maxSubArray(nums) {
  let best = nums[0]
  let running = nums[0]
  for (let i = 1; i < nums.length; i++) {
    running = Math.max(nums[i], running + nums[i])
    best = Math.max(best, running)
  }
  return best
}
''',
  },

  // Merge Intervals — sorting by a key, and nested lists.
  21: <EditorLanguage, String>{
    EditorLanguage.python: '''
def merge(intervals):
    if not intervals:
        return []
    ordered = sorted(intervals, key=lambda pair: pair[0])
    merged = [ordered[0]]
    for start, end in ordered[1:]:
        last = merged[-1]
        if start <= last[1]:
            last[1] = max(last[1], end)
        else:
            merged.append([start, end])
    return merged
''',
    EditorLanguage.javascript: '''
function merge(intervals) {
  if (intervals.length === 0) return []
  const ordered = [...intervals].sort((a, b) => a[0] - b[0])
  const merged = [ordered[0]]
  for (let i = 1; i < ordered.length; i++) {
    const last = merged[merged.length - 1]
    if (ordered[i][0] <= last[1]) {
      last[1] = Math.max(last[1], ordered[i][1])
    } else {
      merged.push(ordered[i])
    }
  }
  return merged
}
''',
  },

  // Climbing Stairs — iterative recurrence.
  24: <EditorLanguage, String>{
    EditorLanguage.python: '''
def climbStairs(n):
    a = 1
    b = 1
    for i in range(n - 1):
        a, b = b, a + b
    return b
''',
    EditorLanguage.javascript: '''
function climbStairs(n) {
  let a = 1
  let b = 1
  for (let i = 0; i < n - 1; i++) {
    const next = a + b
    a = b
    b = next
  }
  return b
}
''',
  },

  // Best Time to Buy and Sell Stock — a single scan.
  44: <EditorLanguage, String>{
    EditorLanguage.python: '''
def maxProfit(prices):
    best = 0
    cheapest = float("inf")
    for p in prices:
        if p < cheapest:
            cheapest = p
        elif p - cheapest > best:
            best = p - cheapest
    return best
''',
    EditorLanguage.javascript: '''
function maxProfit(prices) {
  let best = 0
  let cheapest = Infinity
  for (const p of prices) {
    if (p < cheapest) cheapest = p
    else if (p - cheapest > best) best = p - cheapest
  }
  return best
}
''',
  },

  // Valid Palindrome — two pointers and character classification.
  46: <EditorLanguage, String>{
    EditorLanguage.python: '''
def isPalindrome(s):
    cleaned = [c.lower() for c in s if c.isalpha() or c.isdigit()]
    return cleaned == cleaned[::-1]
''',
    EditorLanguage.javascript: '''
function isPalindrome(s) {
  const cleaned = []
  for (const ch of s) {
    const c = ch.toLowerCase()
    if ((c >= "a" && c <= "z") || (c >= "0" && c <= "9")) cleaned.push(c)
  }
  let left = 0
  let right = cleaned.length - 1
  while (left < right) {
    if (cleaned[left] !== cleaned[right]) return false
    left++
    right--
  }
  return true
}
''',
  },

  // Product of Array Except Self — two passes, building a list.
  76: <EditorLanguage, String>{
    EditorLanguage.python: '''
def productExceptSelf(nums):
    n = len(nums)
    out = [1] * n
    running = 1
    for i in range(n):
        out[i] = running
        running = running * nums[i]
    running = 1
    for i in range(n - 1, -1, -1):
        out[i] = out[i] * running
        running = running * nums[i]
    return out
''',
    EditorLanguage.javascript: '''
function productExceptSelf(nums) {
  const n = nums.length
  const out = new Array(n).fill(1)
  let running = 1
  for (let i = 0; i < n; i++) {
    out[i] = running
    running = running * nums[i]
  }
  running = 1
  for (let i = n - 1; i >= 0; i--) {
    out[i] = out[i] * running
    running = running * nums[i]
  }
  return out
}
''',
  },

  // Contains Duplicate — sets.
  71: <EditorLanguage, String>{
    EditorLanguage.python: '''
def containsDuplicate(nums):
    return len(set(nums)) != len(nums)
''',
    EditorLanguage.javascript: '''
function containsDuplicate(nums) {
  return new Set(nums).size !== nums.length
}
''',
  },

  // Valid Anagram — counting.
  78: <EditorLanguage, String>{
    EditorLanguage.python: '''
def isAnagram(s, t):
    if len(s) != len(t):
        return False
    counts = {}
    for c in s:
        counts[c] = counts.get(c, 0) + 1
    for c in t:
        if counts.get(c, 0) == 0:
            return False
        counts[c] = counts[c] - 1
    return True
''',
    EditorLanguage.javascript: '''
function isAnagram(s, t) {
  if (s.length !== t.length) return false
  const counts = new Map()
  for (const c of s) counts.set(c, (counts.get(c) ?? 0) + 1)
  for (const c of t) {
    if ((counts.get(c) ?? 0) === 0) return false
    counts.set(c, counts.get(c) - 1)
  }
  return true
}
''',
  },

  // Move Zeroes — the in-place case, where the answer is the mutated argument
  // rather than a return value.
  81: <EditorLanguage, String>{
    EditorLanguage.python: '''
def moveZeroes(nums):
    write = 0
    for i in range(len(nums)):
        if nums[i] != 0:
            nums[write] = nums[i]
            write = write + 1
    for i in range(write, len(nums)):
        nums[i] = 0
''',
    EditorLanguage.javascript: '''
function moveZeroes(nums) {
  let write = 0
  for (let i = 0; i < nums.length; i++) {
    if (nums[i] !== 0) {
      nums[write] = nums[i]
      write++
    }
  }
  for (let i = write; i < nums.length; i++) nums[i] = 0
}
''',
  },
};

void main() {
  late Map<int, ProblemDTO> problems;

  setUpAll(() {
    final raw = File('assets/problems.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    problems = <int, ProblemDTO>{
      for (final p in decoded['problems'] as List)
        (p as Map<String, dynamic>)['problem_id'] as int: ProblemDTO.fromJson(p),
    };
  });

  ProblemData dataFor(ProblemDTO dto, EditorLanguage language) => ProblemData(
        functionSignature: dto.functionSignature?.dart ?? '',
        language: language,
        testCases: <ProblemTestCase>[
          for (final t in <TestCase>[...?dto.testCases, ...?dto.hiddenTestCases])
            ProblemTestCase(input: t.input?.trim() ?? '', expectedOutput: t.expectedOutput?.trim() ?? ''),
        ],
        comparison: OutputComparison.fromKey(dto.comparison),
      );

  pilotSolutions.forEach((id, byLanguage) {
    byLanguage.forEach((language, code) {
      test('problem $id in ${language.displayName}: passes every stored test case', () {
        final dto = problems[id];
        expect(dto, isNotNull, reason: 'problem $id is not in assets/problems.json');

        final result = const ProblemRunner().runAll(problem: dataFor(dto!, language), userCode: code);

        expect(result.error, isNull, reason: 'problem $id (${dto.name}) failed to run: ${result.error}');
        expect(result.totalCount, greaterThan(0), reason: 'problem $id has no test cases');

        final failures = result.testCaseResults.where((r) => !r.passed).map((r) {
          return 'input: ${r.testCase.input}\n'
              '  expected: ${r.testCase.expectedOutput}\n'
              '  actual:   ${r.actualOutput}\n'
              '  error:    ${r.errorMessage ?? '-'}';
        }).toList();

        expect(failures, isEmpty,
            reason: 'problem $id (${dto.name}) in ${language.displayName}:\n${failures.join('\n')}');
      });
    });
  });

  test('every pilot problem offers exactly the languages it has been proven in', () {
    // The dataset and this file must not drift apart: starter code without a
    // verified solution is an unchecked promise, and a verified solution with
    // no starter code is a language the learner is never offered.
    for (final id in pilotSolutions.keys) {
      final dto = problems[id]!;
      for (final language in pilotSolutions[id]!.keys) {
        final starter = dto.defaultCode?[language.datasetKey];
        expect(starter != null && starter.trim().isNotEmpty, isTrue,
            reason: 'problem $id has a verified ${language.displayName} solution '
                'but no ${language.datasetKey} starter code in assets/problems.json');
      }
    }
  });
}
