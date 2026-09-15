/// `collections` and `heapq` — the part of the Python standard library that
/// interview solutions genuinely cannot be written without.
///
/// Without these, a learner who writes the ordinary, idiomatic answer to a BFS
/// or a Dijkstra problem gets a crash and concludes the app is broken, which is
/// worse than not offering Python at all. The four names here — `deque`,
/// `Counter`, `defaultdict`, `heapq` — cover the overwhelming majority of that
/// gap.
///
/// Everything is built on the shared value model, like the rest of this
/// directory (contract obligation O5): nothing in `vm/` or `stdlib/` learns
/// that Python exists. The one exception is [DefaultMapValue], which lives in
/// `values/value.dart` because `Value` is sealed, and which the VM's index-read
/// consults by type rather than by language.
library;

import '../../errors/failure.dart';
import '../../values/value.dart';
import 'python_dialect.dart';

// ---------------------------------------------------------------------------
// collections.deque
// ---------------------------------------------------------------------------

/// `deque(iterable)` — represented as a plain [ListValue].
///
/// A real deque is a ring buffer so that both ends are O(1); this one pays O(n)
/// on `popleft`. That is a deliberate trade. Being a genuine list means
/// indexing, `len`, iteration, truthiness (`while queue:`), printing and the
/// grader's serializer all work on it with no further changes, and at interview
/// scale — the queue holds thousands of items, not millions — the copy is not
/// what makes a solution too slow.
Value pyDeque(List<Value> args, InvokeCallback invoke) {
  if (args.isEmpty || args[0] is NullValue || args[0] is UndefinedValue) {
    return ListValue(<Value>[]);
  }
  return ListValue(List<Value>.of(iterableOf(args[0])));
}

/// `q.popleft()` — removes and returns the front item.
Value pyPopLeft(List<Value> args, InvokeCallback invoke) {
  final items = mutableListOf(args[0], 'popleft');
  if (items.isEmpty) {
    throw const VmRuntimeError('runtime', <String, Object?>{'message': 'popleft from an empty deque'});
  }
  return items.removeAt(0);
}

/// `q.appendleft(x)` — pushes onto the front.
Value pyAppendLeft(List<Value> args, InvokeCallback invoke) {
  mutableListOf(args[0], 'appendleft').insert(0, args[1]);
  return NullValue.instance;
}

/// `q.extendleft(xs)` — pushes each item onto the front, so the result is
/// reversed relative to `xs`. That surprises people, but it is what CPython
/// does, and a solution written against the real thing must behave the same.
Value pyExtendLeft(List<Value> args, InvokeCallback invoke) {
  final items = mutableListOf(args[0], 'extendleft');
  for (final v in iterableOf(args[1])) {
    items.insert(0, v);
  }
  return NullValue.instance;
}

/// `q.rotate(n)` — moves the last `n` items to the front (negative goes the
/// other way).
Value pyRotate(List<Value> args, InvokeCallback invoke) {
  final items = mutableListOf(args[0], 'rotate');
  if (items.isEmpty) return NullValue.instance;

  final raw = args.length > 1 ? intArgOf(args[1]) : 1;
  final n = raw % items.length;
  if (n == 0) return NullValue.instance;

  final tail = items.sublist(items.length - n);
  final head = items.sublist(0, items.length - n);
  items
    ..clear()
    ..addAll(tail)
    ..addAll(head);
  return NullValue.instance;
}

// ---------------------------------------------------------------------------
// collections.Counter / collections.defaultdict
// ---------------------------------------------------------------------------

/// `Counter(iterable)` or `Counter(mapping)` — a dict from element to count
/// whose missing keys read as `0`.
Value pyCounter(List<Value> args, InvokeCallback invoke) {
  final counts = DefaultMapValue(() => const IntValue(0));
  if (args.isEmpty || args[0] is NullValue || args[0] is UndefinedValue) return counts;

  final source = args[0];
  if (source is MapValue) {
    counts.entries.addAll(source.entries);
    return counts;
  }

  for (final item in iterableOf(source)) {
    final seen = counts.entries[item];
    counts.entries[item] = IntValue((seen is IntValue ? seen.value : 0) + 1);
  }
  return counts;
}

/// `c.most_common([n])` — `(element, count)` pairs, highest count first.
///
/// Ties keep insertion order, matching CPython, because [List.sort] is not
/// stable but the decorated sort below compares only the count and Dart's
/// `sort` on equal keys is... not guaranteed stable either — so the index is
/// folded into the comparison explicitly.
Value pyMostCommon(List<Value> args, InvokeCallback invoke) {
  final receiver = args[0];
  if (receiver is! MapValue) {
    throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a Counter'});
  }

  final ranked = <(int, Value, Value)>[];
  var index = 0;
  for (final entry in receiver.entries.entries) {
    ranked.add((index++, entry.key, entry.value));
  }

  ranked.sort((a, b) {
    final byCount = compareValues(b.$3, a.$3, pythonDialect);
    if (byCount != 0) return byCount;
    return a.$1.compareTo(b.$1);
  });

  final limit = args.length > 1 && args[1] is IntValue
      ? (args[1] as IntValue).value.clamp(0, ranked.length)
      : ranked.length;

  return ListValue(<Value>[
    for (final row in ranked.take(limit)) TupleValue(<Value>[row.$2, row.$3]),
  ]);
}

/// `defaultdict(factory)` — a dict that builds a missing value instead of
/// failing.
///
/// Only the builtin type factories are accepted. A `lambda` cannot be honoured
/// because the miss is serviced inside the VM's index-read, which has no frame
/// to call interpreted code on; saying so plainly beats silently returning the
/// wrong thing.
Value pyDefaultDict(List<Value> args, InvokeCallback invoke) {
  if (args.isEmpty || args[0] is NullValue || args[0] is UndefinedValue) {
    return MapValue();
  }

  final factory = args[0];
  if (factory is! NativeFunctionValue) {
    throw const VmRuntimeError('runtime', <String, Object?>{
      'message': 'defaultdict accepts int, list, set, dict, str, float or bool — '
          'a lambda default is not supported here',
    });
  }

  final build = _builtinFactories[factory.name];
  if (build == null) {
    throw VmRuntimeError('runtime', <String, Object?>{
      'message': 'defaultdict(${factory.name}) is not supported — '
          'use int, list, set, dict, str, float or bool',
    });
  }

  return DefaultMapValue(build);
}

/// The zero value of each builtin type, as `defaultdict(T)` means it. A fresh
/// instance per call matters for the mutable ones: `d[k].append(v)` must not
/// append into a list shared by every key.
final Map<String, Value Function()> _builtinFactories = <String, Value Function()>{
  'int': () => const IntValue(0),
  'float': () => const NumValue(0),
  'bool': () => const BoolValue(false),
  'str': () => const StrValue(''),
  'list': () => ListValue(<Value>[]),
  'dict': () => MapValue(),
  'set': () => SetValue(),
  'tuple': () => const TupleValue(<Value>[]),
};

/// The `collections` module, reached as `collections.deque(...)`.
///
/// Only the three names that genuinely work are exposed. `OrderedDict` is
/// deliberately absent: without `move_to_end` and `popitem` it would import
/// cleanly and then fail in use, and a missing-module error at the import line
/// is far easier to act on than a missing-method error twenty lines later.
NamespaceValue pyCollectionsNamespace() => const NamespaceValue('collections', <String, Value>{
      'deque': NativeFunctionValue('deque', 1, pyDeque),
      'Counter': NativeFunctionValue('Counter', 1, pyCounter),
      'defaultdict': NativeFunctionValue('defaultdict', 1, pyDefaultDict),
    });

// ---------------------------------------------------------------------------
// heapq
// ---------------------------------------------------------------------------

/// The `heapq` module, reached as `heapq.heappush(...)`.
///
/// The invariant and the array layout are CPython's exactly — `h[0]` is the
/// smallest item and the heap is an ordinary list — because solutions read
/// `h[0]` directly and print the list. Ordering goes through [compareValues],
/// which orders tuples element-wise, so the `(cost, node)` pattern every
/// Dijkstra answer uses works.
NamespaceValue pyHeapqNamespace() => const NamespaceValue('heapq', <String, Value>{
      'heappush': NativeFunctionValue('heappush', 2, _heapPush),
      'heappop': NativeFunctionValue('heappop', 1, _heapPop),
      'heapify': NativeFunctionValue('heapify', 1, _heapify),
      'heappushpop': NativeFunctionValue('heappushpop', 2, _heapPushPop),
      'heapreplace': NativeFunctionValue('heapreplace', 2, _heapReplace),
      'nlargest': NativeFunctionValue('nlargest', 2, _nLargest),
      'nsmallest': NativeFunctionValue('nsmallest', 2, _nSmallest),
    });

int _cmp(Value a, Value b) => compareValues(a, b, pythonDialect);

List<Value> _heapOf(Value v, String op) {
  if (v is ListValue) return v.items;
  throw VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a list for heapq.$op'});
}

void _siftUp(List<Value> heap, int start) {
  var child = start;
  while (child > 0) {
    final parent = (child - 1) >> 1;
    if (_cmp(heap[child], heap[parent]) >= 0) break;
    final tmp = heap[child];
    heap[child] = heap[parent];
    heap[parent] = tmp;
    child = parent;
  }
}

void _siftDown(List<Value> heap, int start) {
  final length = heap.length;
  var parent = start;
  while (true) {
    final left = parent * 2 + 1;
    if (left >= length) break;
    final right = left + 1;
    var smallest = left;
    if (right < length && _cmp(heap[right], heap[left]) < 0) smallest = right;
    if (_cmp(heap[parent], heap[smallest]) <= 0) break;
    final tmp = heap[parent];
    heap[parent] = heap[smallest];
    heap[smallest] = tmp;
    parent = smallest;
  }
}

Value _heapPush(List<Value> args, InvokeCallback invoke) {
  final heap = _heapOf(args[0], 'heappush');
  heap.add(args[1]);
  _siftUp(heap, heap.length - 1);
  return NullValue.instance;
}

Value _heapPop(List<Value> args, InvokeCallback invoke) {
  final heap = _heapOf(args[0], 'heappop');
  if (heap.isEmpty) {
    throw const VmRuntimeError('runtime', <String, Object?>{'message': 'heappop from an empty heap'});
  }
  final last = heap.removeLast();
  if (heap.isEmpty) return last;

  final smallest = heap[0];
  heap[0] = last;
  _siftDown(heap, 0);
  return smallest;
}

Value _heapify(List<Value> args, InvokeCallback invoke) {
  final heap = _heapOf(args[0], 'heapify');
  for (var i = (heap.length >> 1) - 1; i >= 0; i--) {
    _siftDown(heap, i);
  }
  return NullValue.instance;
}

/// Push then pop, but cheaper than doing both: an item that is already no
/// larger than the root never has to enter the heap at all.
Value _heapPushPop(List<Value> args, InvokeCallback invoke) {
  final heap = _heapOf(args[0], 'heappushpop');
  final item = args[1];
  if (heap.isEmpty || _cmp(item, heap[0]) <= 0) return item;

  final smallest = heap[0];
  heap[0] = item;
  _siftDown(heap, 0);
  return smallest;
}

/// Pop then push. Unlike [_heapPushPop] the new item always goes in, so the
/// heap's size never changes and an empty heap is an error.
Value _heapReplace(List<Value> args, InvokeCallback invoke) {
  final heap = _heapOf(args[0], 'heapreplace');
  if (heap.isEmpty) {
    throw const VmRuntimeError('runtime', <String, Object?>{'message': 'heapreplace on an empty heap'});
  }
  final smallest = heap[0];
  heap[0] = args[1];
  _siftDown(heap, 0);
  return smallest;
}

Value _nLargest(List<Value> args, InvokeCallback invoke) => _nBest(args, largest: true);

Value _nSmallest(List<Value> args, InvokeCallback invoke) => _nBest(args, largest: false);

Value _nBest(List<Value> args, {required bool largest}) {
  final n = intArgOf(args[0]);
  final items = List<Value>.of(iterableOf(args[1]));
  items.sort(_cmp);
  if (largest) {
    final tail = items.reversed.take(n < 0 ? 0 : n).toList();
    return ListValue(tail);
  }
  return ListValue(items.take(n < 0 ? 0 : n).toList());
}

// ---------------------------------------------------------------------------
// Shared argument helpers, public so `python_builtins.dart` can reuse them.
// ---------------------------------------------------------------------------

/// The elements of any Python iterable.
List<Value> iterableOf(Value v) {
  if (v is ListValue) return v.items;
  if (v is TupleValue) return v.items;
  if (v is SetValue) return v.items.toList();
  if (v is MapValue) return v.entries.keys.toList();
  if (v is StrValue) return <Value>[for (final c in v.value.split('')) StrValue(c)];
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an iterable'});
}

/// The backing list of something a deque operation may mutate.
List<Value> mutableListOf(Value v, String op) {
  if (v is ListValue) return v.items;
  throw VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'a deque or list for $op'});
}

int intArgOf(Value v) {
  if (v is IntValue) return v.value;
  if (v is NumValue) return v.value.toInt();
  throw const VmRuntimeError('typeMismatch', <String, Object?>{'expected': 'an integer'});
}
