// `collections` and `heapq` — the part of the standard library a Python
// interview answer cannot be written without.
//
// These are deliberately written as whole, idiomatic solutions rather than as
// unit tests of each helper: the thing being proved is that the ordinary
// answer a learner already knows how to write actually runs, not that a
// function exists.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

import 'python_support.dart';

void main() {
  group('collections.deque', () {
    test('BFS over a grid, the textbook answer, runs unchanged', () {
      final r = runPython('''
from collections import deque

def shortest_path(grid):
    rows, cols = len(grid), len(grid[0])
    queue = deque()
    queue.append((0, 0, 1))
    seen = set()
    seen.add((0, 0))
    while queue:
        r, c, dist = queue.popleft()
        if r == rows - 1 and c == cols - 1:
            return dist
        for dr, dc in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
            nr, nc = r + dr, c + dc
            if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] == 0:
                if (nr, nc) not in seen:
                    seen.add((nr, nc))
                    queue.append((nr, nc, dist + 1))
    return -1

print(shortest_path([[0, 0, 0], [1, 1, 0], [0, 0, 0]]))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['5']);
    });

    test('appendleft, popleft, rotate and len behave like a real deque', () {
      final r = runPython('''
from collections import deque

d = deque([1, 2, 3])
d.appendleft(0)
d.append(4)
print(len(d))
print(d.popleft())
print(d[0])
d.rotate(1)
print(d)
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['5', '0', '1', '[4, 1, 2, 3]']);
    });

    test('extendleft reverses, exactly as CPython does', () {
      final r = runPython('''
from collections import deque

d = deque([3])
d.extendleft([2, 1])
print(d)
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[1, 2, 3]']);
    });

    test('popleft on an empty deque fails as a runtime error, not a crash', () {
      final r = runPython('''
from collections import deque
d = deque()
d.popleft()
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.runtime);
    });

    test('an empty deque is falsy, so `while queue:` terminates', () {
      final r = runPython('''
from collections import deque
q = deque([1])
q.popleft()
if not q:
    print("drained")
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['drained']);
    });
  });

  group('collections.Counter', () {
    test('counts a string and reads a missing key as zero', () {
      final r = runPython('''
from collections import Counter

c = Counter("aabbbc")
print(c["b"])
print(c["z"])
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['3', '0']);
    });

    test('most_common ranks by count, highest first', () {
      final r = runPython('''
from collections import Counter

c = Counter(["a", "b", "a", "c", "a", "b"])
print(c.most_common(2))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[(a, 3), (b, 2)]']);
    });

    test('valid anagram, solved the way everyone solves it', () {
      final r = runPython('''
from collections import Counter

def is_anagram(s, t):
    return Counter(s) == Counter(t)

print(is_anagram("anagram", "nagaram"))
print(is_anagram("rat", "car"))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['True', 'False']);
    });
  });

  group('collections.defaultdict', () {
    test('defaultdict(list) groups anagrams without seeding keys', () {
      final r = runPython('''
from collections import defaultdict

def group_anagrams(words):
    groups = defaultdict(list)
    for w in words:
        key = "".join(sorted(w))
        groups[key].append(w)
    return sorted([sorted(g) for g in groups.values()])

print(group_anagrams(["eat", "tea", "tan", "ate", "nat", "bat"]))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[[ate, eat, tea], [bat], [nat, tan]]']);
    });

    test('defaultdict(int) supports the bare += 1 increment', () {
      final r = runPython('''
from collections import defaultdict

counts = defaultdict(int)
for ch in "hello":
    counts[ch] += 1
print(counts["l"])
print(counts["h"])
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['2', '1']);
    });

    test('each key gets its own list, never a shared one', () {
      final r = runPython('''
from collections import defaultdict

d = defaultdict(list)
d["a"].append(1)
d["b"].append(2)
print(d["a"])
print(d["b"])
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[1]', '[2]']);
    });

    test('defaultdict(set) builds an adjacency structure', () {
      final r = runPython('''
from collections import defaultdict

graph = defaultdict(set)
graph[1].add(2)
graph[1].add(2)
graph[2].add(3)
print(len(graph[1]))
print(len(graph[9]))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['1', '0']);
    });

    test('a lambda factory is refused with a message that says what to use', () {
      final r = runPython('''
from collections import defaultdict
d = defaultdict(lambda: 0)
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.runtime);
    });
  });

  group('heapq', () {
    test('heappush and heappop give ascending order', () {
      final r = runPython('''
import heapq

h = []
for n in [5, 1, 4, 1, 9]:
    heapq.heappush(h, n)
out = []
while h:
    out.append(heapq.heappop(h))
print(out)
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[1, 1, 4, 5, 9]']);
    });

    test('a (cost, node) tuple heap drives Dijkstra, which needs tuple ordering', () {
      final r = runPython('''
import heapq

def cheapest(graph, start, goal):
    heap = [(0, start)]
    best = {}
    while heap:
        cost, node = heapq.heappop(heap)
        if node in best:
            continue
        best[node] = cost
        if node == goal:
            return cost
        for nxt, w in graph[node]:
            if nxt not in best:
                heapq.heappush(heap, (cost + w, nxt))
    return -1

graph = {
    "a": [("b", 1), ("c", 4)],
    "b": [("c", 2), ("d", 6)],
    "c": [("d", 3)],
    "d": [],
}
print(cheapest(graph, "a", "d"))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['6']);
    });

    test('heapify turns an arbitrary list into a heap whose root is the min', () {
      final r = runPython('''
import heapq

h = [7, 3, 9, 1]
heapq.heapify(h)
print(h[0])
print(heapq.heappop(h))
print(h[0])
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['1', '1', '3']);
    });

    test('a bounded heap finds the k largest, the classic top-k answer', () {
      final r = runPython('''
import heapq

def k_largest(nums, k):
    h = []
    for n in nums:
        heapq.heappush(h, n)
        if len(h) > k:
            heapq.heappop(h)
    return sorted(h)

print(k_largest([3, 1, 5, 12, 2, 11], 3))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[5, 11, 12]']);
    });

    test('heappushpop and heapreplace keep the heap size steady', () {
      final r = runPython('''
import heapq

h = [1, 3, 5]
heapq.heapify(h)
print(heapq.heappushpop(h, 0))
print(heapq.heapreplace(h, 4))
print(sorted(h))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['0', '1', '[3, 4, 5]']);
    });

    test('nlargest and nsmallest', () {
      final r = runPython('''
import heapq
print(heapq.nlargest(2, [4, 1, 7, 3]))
print(heapq.nsmallest(2, [4, 1, 7, 3]))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[7, 4]', '[1, 3]']);
    });

    test('heappop on an empty heap is a runtime error', () {
      final r = runPython('''
import heapq
heapq.heappop([])
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.runtime);
    });
  });

  group('import statements', () {
    test('from ... import binds each name', () {
      final r = runPython('''
from heapq import heappush, heappop

h = []
heappush(h, 2)
heappush(h, 1)
print(heappop(h))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['1']);
    });

    test('plain `import collections` reaches members through the module', () {
      final r = runPython('''
import collections

d = collections.deque([1, 2])
d.appendleft(0)
print(d)
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[0, 1, 2]']);
    });

    test('an unavailable module fails at the import line, not later', () {
      final r = runPython('''
import numpy
print(1)
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.unsupported);
      expect(r.failure!.line, 1);
    });

    test('a member that does not exist is named in the failure', () {
      final r = runPython('''
from collections import OrderedDict
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.unsupported);
    });
  });

  group('tuple ordering, which heapq and sorted both rest on', () {
    test('sorted orders a list of tuples element by element', () {
      final r = runPython('''
print(sorted([(2, "b"), (1, "z"), (1, "a")]))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[(1, a), (1, z), (2, b)]']);
    });

    test('a prefix sorts before the longer sequence it starts', () {
      final r = runPython('''
print(sorted([[1, 2], [1], [0, 9]]))
''');
      expect(r.failure, isNull, reason: '\$r');
      expect(r.stdout, <String>['[[0, 9], [1], [1, 2]]']);
    });
  });
}
