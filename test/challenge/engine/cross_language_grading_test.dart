// The point of the whole exercise: one problem, one expected output, three
// languages. A Python solution and a JavaScript solution are graded by the
// same `ProblemRunner` against the same test cases as the Dart one, with no
// per-language expected values anywhere (SC-001, SC-013, FR-010b).
//
// The second half is the other half of that promise: a wrong answer must fail
// in every language too (SC-002).

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart'
    show CustomObjectShape, ProblemData, ProblemRunner, ProblemTestCase;
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// One problem, stated once, independent of language.
class Problem {
  const Problem({required this.signature, required this.cases, required this.solutions});
  final String signature;
  final List<(String input, String expected)> cases;
  final Map<EditorLanguage, String> solutions;
}

ProblemData dataFor(Problem problem, EditorLanguage language) => ProblemData(
      functionSignature: problem.signature,
      language: language,
      testCases: <ProblemTestCase>[
        for (final c in problem.cases) ProblemTestCase(input: c.$1, expectedOutput: c.$2),
      ],
    );

final problems = <String, Problem>{
  'twoSum': Problem(
    signature: 'List<int> twoSum(List<int> nums, int target)',
    cases: <(String, String)>[
      ('nums=[2,7,11,15], target=9', '[0,1]'),
      ('nums=[3,2,4], target=6', '[1,2]'),
      ('nums=[3,3], target=6', '[0,1]'),
    ],
    solutions: <EditorLanguage, String>{
      EditorLanguage.dart: '''
List<int> twoSum(List<int> nums, int target) {
  final seen = <int, int>{};
  for (var i = 0; i < nums.length; i++) {
    final need = target - nums[i];
    if (seen.containsKey(need)) return [seen[need]!, i];
    seen[nums[i]] = i;
  }
  return [];
}
''',
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
  ),
  'isPalindrome': Problem(
    signature: 'bool isPalindrome(String s)',
    cases: <(String, String)>[
      ('s="A man, a plan, a canal: Panama"', 'true'),
      ('s="race a car"', 'false'),
      ('s=""', 'true'),
    ],
    solutions: <EditorLanguage, String>{
      EditorLanguage.dart: '''
bool isPalindrome(String s) {
  final cleaned = <String>[];
  for (var i = 0; i < s.length; i++) {
    final c = s[i].toLowerCase();
    if ((c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
        (c.compareTo('0') >= 0 && c.compareTo('9') <= 0)) {
      cleaned.add(c);
    }
  }
  var left = 0;
  var right = cleaned.length - 1;
  while (left < right) {
    if (cleaned[left] != cleaned[right]) return false;
    left = left + 1;
    right = right - 1;
  }
  return true;
}
''',
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
  ),
  'maxSubArray': Problem(
    signature: 'int maxSubArray(List<int> nums)',
    cases: <(String, String)>[
      ('nums=[-2,1,-3,4,-1,2,1,-5,4]', '6'),
      ('nums=[1]', '1'),
      ('nums=[5,4,-1,7,8]', '23'),
      ('nums=[-3,-1,-2]', '-1'),
    ],
    solutions: <EditorLanguage, String>{
      EditorLanguage.dart: '''
int maxSubArray(List<int> nums) {
  var best = nums[0];
  var running = nums[0];
  for (var i = 1; i < nums.length; i++) {
    running = nums[i] > running + nums[i] ? nums[i] : running + nums[i];
    if (running > best) best = running;
  }
  return best;
}
''',
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
  ),
  'groupCount': Problem(
    signature: 'Map<String, int> groupCount(List<String> words)',
    cases: <(String, String)>[
      ('words=["a","b","a"]', '{a:2,b:1}'),
      ('words=[]', '{}'),
    ],
    solutions: <EditorLanguage, String>{
      EditorLanguage.dart: '''
Map<String, int> groupCount(List<String> words) {
  final counts = <String, int>{};
  for (final w in words) {
    counts[w] = (counts[w] ?? 0) + 1;
  }
  return counts;
}
''',
      EditorLanguage.python: '''
def groupCount(words):
    counts = {}
    for w in words:
        counts[w] = counts.get(w, 0) + 1
    return counts
''',
      EditorLanguage.javascript: '''
function groupCount(words) {
  const counts = {}
  for (const w of words) {
    counts[w] = (counts[w] ?? 0) + 1
  }
  return counts
}
''',
    },
  ),
};

void main() {
  group('a correct solution passes in every language, against one expected output', () {
    for (final entry in problems.entries) {
      for (final language in supportedLanguages) {
        test('${entry.key} in ${language.displayName}', () {
          final result = const ProblemRunner().runAll(
            problem: dataFor(entry.value, language),
            userCode: entry.value.solutions[language]!,
          );
          expect(result.error, isNull, reason: '${entry.key}/${language.name}: ${result.error}');
          expect(
            result.allPassed,
            isTrue,
            reason: '${entry.key}/${language.name} failed: '
                '${result.testCaseResults.where((r) => !r.passed).map((r) => '${r.testCase.input} -> '
                    '${r.actualOutput} (wanted ${r.testCase.expectedOutput}) ${r.errorMessage ?? ''}')}',
          );
        });
      }
    }
  });

  group('every language produces the identical answer for every test case', () {
    for (final entry in problems.entries) {
      test(entry.key, () {
        final perLanguage = <EditorLanguage, List<String>>{
          for (final language in supportedLanguages)
            language: const ProblemRunner()
                .runAll(
                  problem: dataFor(entry.value, language),
                  userCode: entry.value.solutions[language]!,
                )
                .testCaseResults
                .map((r) => r.actualOutput)
                .toList(),
        };
        final dartAnswers = perLanguage[EditorLanguage.dart]!;
        for (final language in supportedLanguages) {
          expect(perLanguage[language], dartAnswers,
              reason: '${language.displayName} disagreed with Dart on ${entry.key}');
        }
      });
    }
  });

  group('a wrong answer fails in every language', () {
    // Near misses, not nonsense: an off-by-one and a swapped order are what a
    // learner actually submits, and both must be rejected everywhere.
    final wrong = <String, Map<EditorLanguage, String>>{
      'twoSum returning the indices the wrong way round': <EditorLanguage, String>{
        EditorLanguage.dart: '''
List<int> twoSum(List<int> nums, int target) {
  final seen = <int, int>{};
  for (var i = 0; i < nums.length; i++) {
    final need = target - nums[i];
    if (seen.containsKey(need)) return [i, seen[need]!];
    seen[nums[i]] = i;
  }
  return [];
}
''',
        EditorLanguage.python: '''
def twoSum(nums, target):
    seen = {}
    for i, n in enumerate(nums):
        need = target - n
        if need in seen:
            return [i, seen[need]]
        seen[n] = i
    return []
''',
        EditorLanguage.javascript: '''
function twoSum(nums, target) {
  const seen = new Map()
  for (let i = 0; i < nums.length; i++) {
    const need = target - nums[i]
    if (seen.has(need)) return [i, seen.get(need)]
    seen.set(nums[i], i)
  }
  return []
}
''',
      },
      'maxSubArray starting its scan one element late': <EditorLanguage, String>{
        EditorLanguage.dart: '''
int maxSubArray(List<int> nums) {
  var best = nums[0];
  var running = nums[0];
  for (var i = 2; i < nums.length; i++) {
    running = nums[i] > running + nums[i] ? nums[i] : running + nums[i];
    if (running > best) best = running;
  }
  return best;
}
''',
        EditorLanguage.python: '''
def maxSubArray(nums):
    best = nums[0]
    running = nums[0]
    for n in nums[2:]:
        running = max(n, running + n)
        best = max(best, running)
    return best
''',
        EditorLanguage.javascript: '''
function maxSubArray(nums) {
  let best = nums[0]
  let running = nums[0]
  for (let i = 2; i < nums.length; i++) {
    running = Math.max(nums[i], running + nums[i])
    best = Math.max(best, running)
  }
  return best
}
''',
      },
    };

    final problemOf = <String, String>{
      'twoSum returning the indices the wrong way round': 'twoSum',
      'maxSubArray starting its scan one element late': 'maxSubArray',
    };

    for (final entry in wrong.entries) {
      for (final language in supportedLanguages) {
        test('${entry.key} — ${language.displayName}', () {
          final result = const ProblemRunner().runAll(
            problem: dataFor(problems[problemOf[entry.key]]!, language),
            userCode: entry.value[language]!,
          );
          expect(result.allPassed, isFalse, reason: 'a wrong answer passed in ${language.displayName}');
        });
      }
    }
  });

  test('a problem needing a linked list says so rather than blaming the learner', () {
    // Linked lists and trees are still built as Dart source text, so offering
    // them in another language would fail every test case with something that
    // reads like the learner's mistake. The runner refuses up front instead.
    final result = const ProblemRunner().runAll(
      problem: const ProblemData(
        functionSignature: 'ListNode reverse(ListNode head)',
        language: EditorLanguage.python,
        testCases: <ProblemTestCase>[ProblemTestCase(input: 'head=[1,2]', expectedOutput: '[2,1]')],
        customObjects: <String, CustomObjectShape>{'ListNode': CustomObjectShape.linkedList},
      ),
      userCode: 'def reverse(head):\n    return head\n',
    );
    expect(result.error, isNotNull);
    expect(result.error, contains('Dart'));
  });
}
